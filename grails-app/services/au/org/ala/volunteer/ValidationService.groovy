package au.org.ala.volunteer

import grails.transaction.Transactional

@Transactional
/**
 * The validation service is responsible for auto-validating Tasks that have multiple Transcriptions according to the
 * parameters setup in the Project.
 */
class ValidationService {

    FieldSyncService fieldSyncService

    void autoValidate(Set<Long> taskIds) {

        taskIds.each { taskId ->

            Task task = Task.get(taskId)
            if (shouldAutoValidate(task)) {

                log.info("Auto-validating Task ${task.id}")

                int numberOfMatchingTranscriptionsConsideredValid = 3 // Get from Project.
                int numberOfTranscriptions = task.transcriptions.size()

                Set distinctTranscriptions = task.transcriptions.unique(false) { Transcription t1, Transcription t2 ->
                    fieldsMatch(t1, t2) ? 0 : -1
                }

                int matchingTranscriptions = numberOfTranscriptions - distinctTranscriptions.size() + 1

                if (matchingTranscriptions >= numberOfMatchingTranscriptionsConsideredValid) {
                    log.info("Task has ${matchingTranscriptions} matching transcriptions -> auto-validating!")
                    Set matching = task.transcriptions.minus(distinctTranscriptions)
                    markAsValid(task, matching.first())
                }
                else {
                    log.info("Task has ${matchingTranscriptions} matching transcriptions - not auto-validating")
                }

            }
        }

    }

    private boolean shouldAutoValidate(Task task) {
        return task.project.requiredNumberOfTranscriptions > 1 && task.isFullyTranscribed() && task.fullyValidatedBy == null
    }

    /**
     * Compares this Transcription to another, returning true if all Fields have the same values.
     * @param otherTranscription the Transcription to compare to this one.
     * @return true if all of the fields in this Transcription have the same values as the other Transcription
     */
    private boolean fieldsMatch(Transcription t1, Transcription t2) {
        Set t1Fields = (t1.fields ?: new HashSet()).findAll{it.superceded == false}
        Set t2Fields = (t2.fields ?: new HashSet()).findAll{it.superceded == false}

        if (t1Fields?.size() != t2Fields.size()) {
            return false
        }

        for (Field t1Field : t1Fields) {
            Field t2Field = t2Fields.find{it.name == t1Field.name}

            if (!t2Field || t1Field.value != t2Field.value) {
                return false
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
