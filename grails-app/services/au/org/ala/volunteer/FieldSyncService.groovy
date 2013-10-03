package au.org.ala.volunteer

import org.springframework.validation.Errors

class FieldSyncService {

    static transactional = true

    Map retrieveFieldsForTask(Task taskInstance) {
        Map recordValues = new LinkedHashMap()
        taskInstance?.fields?.each { field ->
            def recordMap = recordValues.get(field.recordIdx)
            if (recordMap == null) {
                recordMap = new LinkedHashMap()
                recordValues.put field.recordIdx, recordMap
            }
            if (!field.superceded) {
                recordMap.put field.name, field.value
            }
        }
        recordValues
    }

    /**
     * Takes some new field values and sensibly syncs with existing field values
     * in the database.
     *
     * @param record
     * @param fieldValues
     * @return
     */
    void syncFields(Task task, Map fieldValues, String transcriberUserId, Boolean markAsFullyTranscribed, Boolean markAsFullyValidated, Boolean isValid) {
        //sync
        def idx = 0
        def hasMore = true
        while (hasMore) {
            def fieldValuesForRecord = fieldValues.get(idx.toString())
            if (fieldValuesForRecord) {

                //get existing fields, and add to a map
                def oldFields = Field.executeQuery("from Field f where task = :task and recordIdx = :recordIdx and superceded = false",
                        [task: task, recordIdx: idx])

                Map oldFieldValues = new LinkedHashMap()
                oldFields.each { field -> oldFieldValues.put(field.name, field) }

                fieldValuesForRecord.each { keyValue ->

                    Field oldFieldValue = oldFieldValues.get(keyValue.key)
                    if (oldFieldValue != null) {

                        if (oldFieldValue.value != keyValue.value) {
                            //if different users
                            if (oldFieldValue.transcribedByUserId != transcriberUserId) {
                                //just save it
                                Field field = new Field()
                                field.name = keyValue.key
                                field.value = keyValue.value
                                field.transcribedByUserId = transcriberUserId
                                field.task = task
                                field.recordIdx = idx
                                field.updated = new Date()
                                field.save(flush: true)
                                if (field.hasErrors()) {
                                    field.errors.allErrors.each { log.error(it) }
                                    task.errors.reject(field.errors.toString())
                                    return;
                                }

                                //keep the original, but mark as superceded
                                oldFieldValue.superceded = true
                                oldFieldValue.updated = new Date()
                                oldFieldValue.save(flush: true)
                                if (oldFieldValue.hasErrors()) {
                                    oldFieldValue.errors.allErrors.each { log.error(it) }
                                    task.errors.reject(oldFieldValue.errors.toString())
                                    //task.errors.addAllErrors(oldFieldValue.errors)
                                    return;
                                }

                            } else {
                                //just replace the value
                                oldFieldValue.value = keyValue.value
                                oldFieldValue.updated = new Date()
                                oldFieldValue.save(flush: true)

                                if (oldFieldValue.hasErrors()) {
                                    oldFieldValue.errors.allErrors.each { log.error(it) }
                                    task.errors.reject(oldFieldValue.errors.toString())
                                    //task.errors.addAllErrors(oldFieldValue.errors)
                                    return;
                                }
                            }
                        }

                    } else {
                        //persist these values
                        Field field = new Field(recordIdx: idx, name: keyValue.key, value: keyValue.value,
                                task: task, transcribedByUserId: transcriberUserId, superceded: false)
                        field.save(flush: true)
                        if (field.hasErrors()) {
                            field.errors.allErrors.each { log.error(it) }
                            task.errors.reject(field.errors.toString())
                            return;
                        }
                    }
                }
                idx = idx + 1
            } else {
                hasMore = false
            }
        }

        def now = Calendar.instance.time;

        //set the transcribed by
        if (markAsFullyTranscribed) {
            // Only set it if it hasn't already been set. The rules are the first person to save gets the transcription
            if (!task.fullyTranscribedBy) {
                task.fullyTranscribedBy = transcriberUserId
                def user = User.findByUserId(transcriberUserId)
                user.transcribedCount++
                user.save(flush: true)
            }
            if (!task.dateFullyTranscribed) {
                task.dateFullyTranscribed = now
            }
        }

        if (markAsFullyValidated) {
            // Again, only update the validated user and date if it hasn't already been set.
            if (!task.fullyValidatedBy) {
                task.fullyValidatedBy = transcriberUserId
                def user = User.findByUserId(transcriberUserId)
                user.validatedCount++
                user.save(flush: true)
            }
            if (!task.dateFullyValidated) {
                task.dateFullyValidated = now
            }

        } else {
            //reset the fully validated flag
            task.fullyValidatedBy = null
        }

        if (isValid != null) {
            task.isValid = isValid
        }

        task.dateLastUpdated = now
        task.viewed++; // increment view count

        task.save(flush: true)
    }

}
