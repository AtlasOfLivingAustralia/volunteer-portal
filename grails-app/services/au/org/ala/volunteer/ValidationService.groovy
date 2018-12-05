package au.org.ala.volunteer

import grails.transaction.Transactional

@Transactional
/**
 * The validation service is responsible for auto-validating Tasks that have multiple Transcriptions according to the
 * parameters setup in the Project.
 */
class ValidationService {

    private static final Set EXCLUDED_FIELDS = new HashSet([DarwinCoreField.transcriberNotes.name()])

    FieldSyncService fieldSyncService

    void autoValidate(Set<Long> taskIds) {

        taskIds.each { taskId ->

            Task task = Task.get(taskId)
            if (!task) {
                log.warn("Missing Task with id: ${taskId}")
                return
            }
            if (shouldAutoValidate(task)) {

                log.info("Auto-validating Task ${task.id}")

                int numberOfMatchingTranscriptionsConsideredValid = task.project.thresholdMatchingTranscriptions //3 // Get from Project.

                Map matchCounts = matchTranscriptions(task)
                def bestMatch = matchCounts.max{it.value}
                int numberOfMatchingTranscriptions = bestMatch.value

                if (numberOfMatchingTranscriptions >= numberOfMatchingTranscriptionsConsideredValid) {
                    log.info("Task has ${numberOfMatchingTranscriptions} matching transcriptions -> auto-validating!")
                    markAsValid(task, task.transcriptions.find{it.id == bestMatch.key})
                }
                else {
                    log.info("Task has ${numberOfMatchingTranscriptions} matching transcriptions - not auto-validating")
                }
                task.setNumberOfMatchingTranscriptions(numberOfMatchingTranscriptions)
                task.save()

            }
        }

    }

    private Map matchTranscriptions(Task task) {

        Map matchCounts = [:].withDefault{1}
        for (int i=0; i<task.transcriptions.size(); i++) {
            Transcription t1 = task.transcriptions[i]
            for (int j=i+1; j<task.transcriptions.size(); j++) {
                Transcription t2 = task.transcriptions[j]
                if (fieldsMatch(t1, t2)) {
                    matchCounts[t1.id]++
                    matchCounts[t2.id]++
                }
            }
        }
        matchCounts
    }


    private boolean shouldAutoValidate(Task task) {
        return task.project.requiredNumberOfTranscriptions > 1 && task.isFullyTranscribed() && task.fullyValidatedBy == null
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
