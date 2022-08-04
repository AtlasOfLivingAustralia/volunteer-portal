package au.org.ala.volunteer

import grails.gorm.transactions.Transactional

@Transactional
/**
 * The validation service is responsible for auto-validating Tasks that have multiple Transcriptions according to the
 * parameters setup in the Project.
 */
class ValidationService {

    private static final Set EXCLUDED_FIELDS = new HashSet([DarwinCoreField.transcriberNotes.name(), DarwinCoreField.validatorNotes.name()])
    private static final Set CAMERATRAP_EXCLUDED_FIELDS = new HashSet([DarwinCoreField.transcriberNotes.name(), DarwinCoreField.validatorNotes.name(), 'comment'])

    FieldSyncService fieldSyncService
    TaskService taskService

    /**
     * This method is called when a Transcription or Task is changed, we check to see if any of the
     * new Tasks need to be auto-validated and if so, we auto-validate.
     *
     * @param taskIds the tasks to check.
     */
    void autoValidate(Set<Long> taskIds) {

        taskIds.each { taskId ->

            Task task = Task.get(taskId)
            if (!task) {
                log.warn("Missing Task with id: ${taskId}")
                return
            }

            if (shouldAutoValidate(task)) {
                log.debug("Auto-validating Task ${task.id}")

                int numberOfMatchingTranscriptionsConsideredValid = task.project.thresholdMatchingTranscriptions
                Map bestTranscription = findBestMatchingTranscription(task)
                int numberOfMatchingTranscriptions = bestTranscription.matchCount as int

                if (numberOfMatchingTranscriptions >= numberOfMatchingTranscriptionsConsideredValid) {
                    log.debug("Task has ${numberOfMatchingTranscriptions} matching transcriptions -> auto-validating!")
                    markAsValid(task, bestTranscription.bestTranscription)
                } else {
                    log.debug("Task has ${numberOfMatchingTranscriptions} matching transcriptions - not auto-validating")
                }

                if (task.isFullyTranscribed) {
                    task.setNumberOfMatchingTranscriptions(numberOfMatchingTranscriptions)
                }

                task.save()
            }
        }

    }
    /**
     * Returns a Map containing:
     * Key: bestTranscription, value: The Transcription that matches the most other transcriptions (selected
     * randomly from the pool of matching transcriptions)
     * Key: matchCount, value: the number of transcriptions with the same field values as the one returned as the
     * value of the "bestTranscription" key.
     * In the case no Transcriptions match, one of the Transcriptions will be returned with a match count of zero.
     *
     * @param task The Task to match Transcriptions for.
     */
    Map findBestMatchingTranscription(Task task) {
        log.debug("Find best matching transcription")
        Map matchCounts = matchTranscriptions(task)
        def bestMatch = matchCounts.max{it.value}
        Transcription bestMatchingTranscription = task.transcriptions.find{it.id == bestMatch.key}

        [bestTranscription:bestMatchingTranscription, matchCount:bestMatch.value]
    }

    private Map matchTranscriptions(Task task) {
        Map matchCounts = [:].withDefault{1}
        List<Transcription> completeTranscriptions = task.transcriptions.findAll{it.fullyTranscribedBy != null}.toList()
        log.debug("Found ${completeTranscriptions.size()} transcriptions")
        for (int i = 0; i < completeTranscriptions.size(); i++) {
            Transcription t1 = completeTranscriptions[i]
            for (int j=i + 1; j < completeTranscriptions.size(); j++) {
                Transcription t2 = completeTranscriptions[j] as Transcription
                if (fieldsMatch(t1, t2)) {
                    log.debug("Fields match between ${t1.id} and ${t2.id}")
                    matchCounts[t1.id]++
                    matchCounts[t2.id]++
                }
            }
        }
        if (matchCounts.size() == 0) {
            completeTranscriptions.each { transcription ->
                matchCounts[transcription.id] = 0
            }
        }
        matchCounts
    }

    private boolean shouldAutoValidate(Task task) {
        if (task.fullyValidatedBy) {  // Check this first as it doesn't require a query.
            return false
        }
        int numberOfMatchingTranscriptionsConsideredValid = task.project.thresholdMatchingTranscriptions ?: 0
        if (numberOfMatchingTranscriptionsConsideredValid < 2) { // Avoid querying transcriptions if this task can't be auto-validated
            return false
        }
        int numberOfCompleteTranscriptions = task.transcriptions.findAll{it.fullyTranscribedBy != null}.size()
        return numberOfCompleteTranscriptions >= numberOfMatchingTranscriptionsConsideredValid
    }

    /**
     * Compares the fields of two transcriptions, returning true if all fields (excluding the excluded fields) have
     * the same values. The excluded fields are determined by the project type. If the project type is a camera trap,
     * the comparison excludes the comment field in addition to the transcriber and validator notes.
     *
     * @param t1 The first transcription
     * @param t2 The second transcription
     * @return true if all of the fields in this Transcription have the same values as the other Transcription.
     */
    private boolean fieldsMatch(Transcription t1, Transcription t2) {
        if (t1?.project?.projectType?.name == ProjectType.PROJECT_TYPE_CAMERATRAP) {
            return fieldsMatch(t1, t2, CAMERATRAP_EXCLUDED_FIELDS)
        } else {
            return fieldsMatch(t1, t2, EXCLUDED_FIELDS)
        }
    }

    /**
     * Compares the fields of two transcriptions, returning true if all fields (excluding the excluded fields) have
     * the same values.
     *
     * @param t1 The first transcription
     * @param t2 The second transcription
     * @param excludedFields a HashSet of field names to exclude from the comparison.
     * @return true if all of the fields in this Transcription have the same values as the other Transcription.
     */
    private boolean fieldsMatch(Transcription t1, Transcription t2, Set excludedFields) {
        Set t1Fields = (t1.fields ?: new HashSet()).findAll{it.superceded == false  && !excludedFields.contains(it.name)}
        Set t2Fields = (t2.fields ?: new HashSet()).findAll{it.superceded == false  && !excludedFields.contains(it.name)}
        // log.debug("Fields selected: ${t1Fields}")

        if (t1Fields?.size() != t2Fields.size()) {
            return false
        }

        int maxRecIdx = t1Fields.recordIdx.max()
        int maxRecIdx2 = t2Fields.recordIdx.max()

        for (int t1RecIdx = 0; t1RecIdx <= maxRecIdx; t1RecIdx++) {
            Set t1FieldsRec = t1Fields.findAll{it.recordIdx == t1RecIdx}
            boolean isRecMatch = false

            if (t1FieldsRec) {
                // Comparing 2 sets of fields ignoring order of record idx.
                for (int t2RecIdx = 0; t2RecIdx <= maxRecIdx2; t2RecIdx++) {
                    Set t2FieldsRec = t2Fields.findAll { it.recordIdx == t2RecIdx }

                    if (t2FieldsRec) {
                        isRecMatch = compareFieldsRecord(t1FieldsRec, t2FieldsRec)
                        if (isRecMatch) {
                            break
                        }
                    }
                }
            }

            // If t1 record idx doesn't match with any of the t2 record idx, should stop comparing and return false
            if (!isRecMatch) {
                return false
            }
        }

        return true
    }

    private boolean compareFieldsRecord(Set t1FieldsRec, Set t2FieldsRec) {
        for (Field t1Field: (t1FieldsRec as Set<Field>)) {
            Field t2Field = t2FieldsRec.find {
                it.name == t1Field.name && it.value == t1Field.value
            } as Field

            if (!t2Field) {
                return false
            }
        }
        return true
    }

    private void markAsValid(Task task, Transcription validatedTranscription) {
        if (!task.isFullyTranscribed) {
            task.setIsFullyTranscribed(true)
        }

        // Copy this transcription to the Task and mark the Task as validated.
        taskService.validate(task, UserService.SYSTEM_USER, true)
        Map fieldsByRecordIndex = [:].withDefault{[:]}
        // Copy the "validated" transcription data into the Task fields as required.
        Set fields = validatedTranscription.fields
        fields.each { Field field ->
            fieldsByRecordIndex[Integer.toString(field.recordIdx)][field.name] = field.value
        }

        fieldSyncService.syncFields(task, fieldsByRecordIndex, UserService.SYSTEM_USER, false, true, true)
    }

}
