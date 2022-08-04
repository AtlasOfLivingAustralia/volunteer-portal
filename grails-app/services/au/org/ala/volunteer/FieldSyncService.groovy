package au.org.ala.volunteer

import grails.gorm.DetachedCriteria
import grails.gorm.transactions.Transactional
import org.apache.commons.lang3.StringUtils
import org.jooq.DSLContext
import org.springframework.beans.factory.annotation.Autowired

import static au.org.ala.volunteer.jooq.tables.VpUser.VP_USER

@Transactional
class FieldSyncService {

    ValidationService validationService
    TaskService taskService

    @Autowired
    Closure<DSLContext> jooqContextFactory

    Map retrieveFieldsForTask(Task taskInstance, String currentUserId) {

        Transcription transcription = taskInstance.findUserTranscription(currentUserId)

        // In case task transcription status is reset
        if (transcription == null && taskInstance.project.requiredNumberOfTranscriptions == 1) {
            transcription = taskInstance.getExistingEmptyTranscription()
        }

        retrieveFieldsForTranscription(taskInstance, transcription)
    }

    Map retrieveFieldsForTranscription(Task task, Transcription transcription) {
        Map recordValues = new LinkedHashMap()

        // If the transcription already exists, use any fields attached to the transcription.  Otherwise,
        // use any fields loaded from the Task.
        Set fields = transcription ? transcription.fields : task.getTaskFields()
        fields?.each { field ->
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
     * Retrieves the Fields to use to populate the Task template for a validator.
     *
     * If the the Task has not yet been validated, select the most appropriate Transcription to use: in the case
     * of single Transcription Tasks, this will be the only Transcription.  In the case of multiple Transcription Tasks
     * the Transcription with the most matching Fields will be selected.  (e.g. if there are 5 transcriptions and
     * 3 of them have the same field values, one of the 3 matching transcriptions will be used).
     *
     * If the Task has already been validated, the fields supplied during the validation operation are returned.
     *
     */
    Map retrieveValidationFieldsForTask(Task taskInstance) {

        Transcription transcriptionToUse = null

        if (taskInstance.isFullyTranscribed && !taskInstance.fullyValidatedBy) {
            if (taskInstance.transcriptions.size() > 1 ) {
                Map result = validationService.findBestMatchingTranscription(taskInstance)
                transcriptionToUse = result.bestTranscription
            }
            else if (taskInstance.transcriptions.size() > 0) {
                transcriptionToUse = taskInstance.transcriptions[0]
            }
        } else {
            if (taskInstance.transcriptions.size() == 1 && taskInstance.fullyValidatedBy) {
                transcriptionToUse = taskInstance.transcriptions[0]
            }
        }
        return retrieveFieldsForTranscription(taskInstance, transcriptionToUse)
    }

    List retrieveTranscribersFieldsForTask(Task taskInstance) {
        /* if (taskInstance.isFullyTranscribed && taskInstance.project.requiredNumberOfTranscriptions == 1) {
             def map = retrieveFieldsForTranscription(taskInstance, taskInstance.transcriptions[0])
             return new ArrayList<Map>().add(map)
         }
         else if (taskInstance.isFullyTranscribed && taskInstance.project.requiredNumberOfTranscriptions > 1) { */

        def list = new ArrayList<Map>()

        if (taskInstance.isFullyTranscribed && taskInstance.project.requiredNumberOfTranscriptions > 1) {
            for (tr in taskInstance.transcriptions) {
                Map fieldValues = retrieveFieldsForTranscription(taskInstance, tr)
                if (fieldValues && fieldValues.size() > 0) {
                    Map rec = new HashMap()
                    rec.put('fields', fieldValues)
                    rec.put('fullyTranscribedBy', tr.fullyTranscribedBy)
                    list.add(rec)
                }
            }
        }
        return list
    }

    boolean fieldValuesAreEqual(String a, String b) {
        String value1 = a ?: ""  // Normalize null to empty strings for the sake of comparison
        String value2 = b ?: ""
        return value1.equals(value2);
    }

    boolean isCollectionOrArray(object) {
        if (object == null) {
            return false
        }
        [Collection, Object[]].any { it.isAssignableFrom(object.getClass()) }
    }

    /** Duplicate values are an indication that there are multiple form fields with the exact same name, and the values are being collated into and array
     * This is generally bad, but may happen because templates are user modifiable. In a lot of cases the values may well be the same, so
     * we can coalesce them back into a single string value, otherwise we comma separate them in order to preserve their values for manual fix up later
     *
     * @param values
     * @return
     */
    def handleDuplicateFormFields(Task task, String fieldname, values) {
        def distinctValues = []
        values.each {
            if (StringUtils.isNotEmpty(it) && !distinctValues.contains(it)) {
                distinctValues << it
            }
        }

        // They are all null
        if (distinctValues.size() == 0) {
            return ""
        }
        if (distinctValues.size() == 1) {
            return distinctValues[0]
        }

        def value = distinctValues.join(",")
        log.warn("WARNING: Duplicate field values detected for task: ${task?.id} field: ${fieldname} values: ${value}")
        return value
    }

    // TODO hard coded for expediency, replace with something more useful in future
    List<String> truncateFieldsForProject(Project project) {
        def result;
        switch (project.template.viewName) {
            case 'cameratrapTranscribe': result = ['vernacularName', 'certainty', 'unlisted']
                break
            default: result = []
        }
        return result
    }

    /**
     * Takes some new field values and sensibly syncs with existing field values
     * in the database.
     *
     * @param record
     * @param fieldValues
     * @return
     */
    void syncFields(Task task, Map fieldValues, String transcriberUserId, Boolean markAsFullyTranscribed, Boolean markAsFullyValidated, Boolean isValid, List<String> truncateFields = [], String userIp = null, Transcription transcription = null) {
        //sync
        def idx = 0
        def hasMore = true
        while (hasMore) {
            def fieldValuesForRecord = fieldValues.get(idx.toString())
            Map oldFieldValues

            if (fieldValuesForRecord) {

                //get existing fields, and add to a map
                def oldFields = Field.createCriteria().list {
                    eq('task', task)
                    eq('recordIdx', idx)
                    eq('superceded', false)
                    if (transcription) {
                        eq('transcription', transcription)
                    } else {
                        isNull('transcription')
                    }
                }
//                def oldFields = Field.executeQuery("from Field f where task = :task and recordIdx = :recordIdx and superceded = false",
//                        [task: task, recordIdx: idx])

                oldFieldValues = new LinkedHashMap()
                oldFields.each { field -> oldFieldValues.put(field.name, field) }


                fieldValuesForRecord.each { keyValue ->

                    def value = keyValue.value

                    if (isCollectionOrArray(value)) {
                        value = handleDuplicateFormFields(task, keyValue.key, value)
                    }

                    Field oldFieldValue = oldFieldValues?.get(keyValue.key) ?: null
                    if (oldFieldValue != null) {

                        if (!fieldValuesAreEqual(oldFieldValue.value, value)) {
                            //if different users
                            if (oldFieldValue.transcribedByUserId != transcriberUserId) {
                                //just save it
                                Field field = new Field()
                                field.name = keyValue.key
                                field.value = value
                                field.transcribedByUserId = transcriberUserId
                                field.task = task
                                field.transcription = transcription
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
                                    return;
                                }

                            } else {
                                //just replace the value
                                oldFieldValue.value = value
                                oldFieldValue.updated = new Date()
                                oldFieldValue.save(flush: true)

                                if (oldFieldValue.hasErrors()) {
                                    oldFieldValue.errors.allErrors.each { log.error(it) }
                                    task.errors.reject(oldFieldValue.errors.toString())
                                    return;
                                }
                            }
                        }

                    } else {
                        //persist these values
                        Field field = new Field(recordIdx: idx, name: keyValue.key, value: value, transcription: transcription,
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

        // Slightly dodgy hack, as camera trap records can be removed on re-save or validation
        // and the record index is shared between selected images and unlisted write ins
        def sortedIndexes = fieldValues.keySet().findAll { StringUtils.isNumeric(it) }.collect {
            Integer.parseInt(it)
        }.sort().reverse()
        truncateFields.each { fieldName ->
            def truncIdx = maxIndexFor(fieldName, fieldValues, sortedIndexes)
            markSuperceded(task, truncIdx, fieldName, transcription)
        }

        def now = Calendar.instance.time;

        //set the transcribed by
        if (markAsFullyTranscribed) {
            if (!transcription) {
                throw new IllegalArgumentException("A Transcription is required if markAsFullyTranscribed is true")
            }
            // Only set it if it hasn't already been set. The rules are the first person to save gets the transcription
            if (!transcription.fullyTranscribedBy) {
                transcription.fullyTranscribedBy = transcriberUserId
                transcription.fullyTranscribedIpAddress = userIp
                def user = User.findByUserId(transcriberUserId)
//                user?.transcribedCount++
//                user?.save(flush: true)
                incrementTranscriptionCount(user.id)
            }
            if (!transcription.dateFullyTranscribed) {
                transcription.dateFullyTranscribed = now
            }
            if (!transcription.transcribedUUID) {
                transcription.transcribedUUID = UUID.randomUUID()
            }

            if (task.allTranscriptionsComplete()) {
                task.isFullyTranscribed = true
            }
        }

        if (markAsFullyValidated) {
            // Again, only update the validated user and date if it hasn't already been set.

            if (!task.fullyValidatedBy) {
                def user = User.findByUserId(transcriberUserId)
//                user?.validatedCount++
//                user?.save(flush: true)
                incrementValidationCount(user.id)
            }
            taskService.validate(task, transcriberUserId, isValid, now)
        }

        if (isValid != null) {
            task.isValid = isValid
        }

        task.dateLastUpdated = now
        task.viewed++; // increment view count

        task.save(flush: true, failOnError: true)

        // Should be dealt with by GORM event
        //DomainUpdateService.scheduleTaskIndex(task)
    }

    int maxIndexFor(fieldName, Map fieldValues, sortedIndexes) {

        for (def key : sortedIndexes) {
            if (fieldValues.get(key.toString())[fieldName]) {
                return key
            }
        }
        return -1;
//        def c = Field.createCriteria()
//        c.get {
//            eq('task', task)
//            eq('name', fieldName)
//            eq('superceded', false)
//            projections {
//                max('recordIdx')
//            }
//        }
    }

    void markSuperceded(Task theTask, int truncIdx, String fieldName, Transcription transcriptionToUpdate) {

        new DetachedCriteria(Field).build {
            eq('task', theTask)
            eq('name', fieldName)
            eq('superceded', false)
            gt('recordIdx', truncIdx)
            if (transcriptionToUpdate) {
                eq('transcription', transcriptionToUpdate)
            } else {
                isNull("transcription")
            }
        }.updateAll(superceded: true)
    }

    /**
     * Increments the transcription count for a user by 1. Done with JOOQ so that issues with cached values aren't
     * encountered.
     * @param userId the user's ID.
     */
    def incrementTranscriptionCount(long userId) {
        DSLContext context = jooqContextFactory()

        context.update(VP_USER)
                .set(VP_USER.TRANSCRIBED_COUNT, VP_USER.TRANSCRIBED_COUNT.plus(1))
                .where(VP_USER.ID.eq(userId))
                .execute()
    }

    /**
     * Decrements the transcription count for a user by 1. Done with JOOQ so that issues with cached values aren't
     * encountered.
     * @param userId the user's ID.
     */
    def decrementTranscriptionCount(long userId) {
        DSLContext context = jooqContextFactory()

        context.update(VP_USER)
                .set(VP_USER.TRANSCRIBED_COUNT, VP_USER.TRANSCRIBED_COUNT.minus(1))
                .where(VP_USER.ID.eq(userId))
                .execute()
    }

    /**
     * Increments the validated count for a user by 1. Done with JOOQ so that issues with cached values aren't
     * encountered.
     * @param userId the user's ID.
     */
    def incrementValidationCount(long userId) {
        DSLContext context = jooqContextFactory()

        context.update(VP_USER)
                .set(VP_USER.VALIDATED_COUNT, VP_USER.VALIDATED_COUNT.plus(1))
                .where(VP_USER.ID.eq(userId))
                .execute()
    }

    /**
     * Decrements the validated count for a user by 1. Done with JOOQ so that issues with cached values aren't
     * encountered.
     * @param userId the user's ID.
     */
    def decrementValidationCount(long userId) {
        DSLContext context = jooqContextFactory()

        context.update(VP_USER)
                .set(VP_USER.VALIDATED_COUNT, VP_USER.VALIDATED_COUNT.minus(1))
                .where(VP_USER.ID.eq(userId))
                .execute()
    }
}
