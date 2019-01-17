package au.org.ala.volunteer

import grails.transaction.Transactional

@Transactional
/**
 * The validation service is responsible for auto-validating Tasks that have multiple Transcriptions according to the
 * parameters setup in the Project.
 */
class ValidationService {

    private static final Set EXCLUDED_FIELDS = new HashSet([DarwinCoreField.transcriberNotes.name(), DarwinCoreField.validatorNotes.name()])

    FieldSyncService fieldSyncService

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

                log.info("Auto-validating Task ${task.id}")

                int numberOfMatchingTranscriptionsConsideredValid = task.project.thresholdMatchingTranscriptions

                Map bestTranscription = findBestMatchingTranscription(task)

                int numberOfMatchingTranscriptions = bestTranscription.matchCount

                if (numberOfMatchingTranscriptions >= numberOfMatchingTranscriptionsConsideredValid) {
                    log.info("Task has ${numberOfMatchingTranscriptions} matching transcriptions -> auto-validating!")
                    markAsValid(task, bestTranscription.bestTranscription)
                }
                else {
                    log.info("Task has ${numberOfMatchingTranscriptions} matching transcriptions - not auto-validating")
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
        Map matchCounts = matchTranscriptions(task)
        def bestMatch = matchCounts.max{it.value}
        Transcription bestMatchingTranscription = task.transcriptions.find{it.id == bestMatch.key}

        [bestTranscription:bestMatchingTranscription, matchCount:bestMatch.value]
    }

    private Map matchTranscriptions(Task task) {

        Map matchCounts = [:].withDefault{1}
        List completeTranscriptions = new ArrayList(task.transcriptions.findAll{it.fullyTranscribedBy != null})
        for (int i=0; i<completeTranscriptions.size(); i++) {
            Transcription t1 = completeTranscriptions[i]
            for (int j=i+1; j<completeTranscriptions.size(); j++) {
                Transcription t2 = completeTranscriptions[j]
                if (fieldsMatch(t1, t2)) {
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

        int numberOfMatchingTranscriptionsConsideredValid = task.project.thresholdMatchingTranscriptions
        if (numberOfMatchingTranscriptionsConsideredValid < 2) { // Avoid querying transcriptions if this task can't be auto-validated
            return false
        }
        int numberOfCompleteTranscriptions = task.transcriptions.findAll{it.fullyTranscribedBy != null}.size()
        return numberOfCompleteTranscriptions >= numberOfMatchingTranscriptionsConsideredValid
    }

    /**
     * Compares this Transcription to another, returning true if all Fields have the same values.
     * @param otherTranscription the Transcription to compare to this one.
     * @return true if all of the fields in this Transcription have the same values as the other Transcription
     */
    private boolean fieldsMatch(Transcription t1, Transcription t2, Set excludedFields = EXCLUDED_FIELDS) {
        Set t1Fields = (t1.fields ?: new HashSet()).findAll{it.superceded == false}
        Set t2Fields = (t2.fields ?: new HashSet()).findAll{it.superceded == false}

        if (t1Fields?.size() != t2Fields.size()) {
            return false
        }

        for (Field t1Field : t1Fields) {
            if (!excludedFields.contains(t1Field.name)) {
                Field t2Field = t2Fields.find{it.name == t1Field.name}

                if (!t2Field || t1Field.value != t2Field.value) {
                    return false
                }
            }

        }

        return true
    }


    private void markAsValid(Task task, Transcription validatedTranscription) {

        if (!task.isFullyTranscribed) {
            task.setIsFullyTranscribed(true)
        }
        // Copy this transcription to the Task and mark the Task as validated.
        task.validate(UserService.SYSTEM_USER, true)


        Map fieldsByRecordIndex = [:].withDefault{[:]}
        // Copy the "validated" transcription data into the Task fields as required.
        Set fields = validatedTranscription.fields
        fields.each{ Field field ->
            fieldsByRecordIndex[Integer.toString(field.recordIdx)][field.name] = field.value
        }
        fieldSyncService.syncFields(task, fieldsByRecordIndex, UserService.SYSTEM_USER, false, true, true)
    }

}
