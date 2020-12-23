package au.org.ala.volunteer

import org.h2.util.StringUtils
import org.hibernate.FlushMode

class ProjectToolsService {

    def sessionFactory

    def updateKeyFieldFromPicklistField(Project projectInstance, String lookupField, String keyField) {

        if (!projectInstance.picklistInstitutionCode) {
            log.error("Project does not have a picklist institution code set. Aborting.")
            return
        }


        def picklist = Picklist.findByName(lookupField)
        if (!picklist) {
            log.error("No picklist for for ${lookupField}. Aborting.")
            return
        }

        // Get a list of all the relevant fields for this project
        def c = Field.createCriteria()
        def fields = c.list {
            task {
                eq("project", projectInstance)
            }
            or {
                eq('name', lookupField)
                eq('name', keyField)
            }
            or {
                eq('superceded', false)
                isNull('superceded')
            }
        }
        // place into a map keyed by task...
        def taskMap = fields.groupBy { it.task }
        def cache = [:]
        try {

            sessionFactory.currentSession.setFlushMode(FlushMode.MANUAL)
            def tasksProcessed = 0
            def fieldsUpdated = 0
            taskMap.each { kvp ->
                def task = kvp.key as Task
                def fieldList = kvp.value as List<Field>
                fieldList.each { field ->
                    if (field.name.equals(lookupField) && field.value) {
                        // Looking for a corresponding key field with the same record index (important!)
                        def targetField = fieldList.find { it.name.equals(keyField) && it.recordIdx == field.recordIdx }
                        boolean isCandidate = false
                        if (targetField) {
                            if (StringUtils.isNullOrEmpty(targetField.value?.trim()) || targetField.value.contains("[Ljava.lang.String;")) {
                                isCandidate = true
                            }
                        } else {
                            isCandidate = true
                        }

                        if (isCandidate) {

                            def keyValue = null
                            // first look in cache
                            if (cache.containsKey(field.value)) {
                                keyValue = cache[field.value]
                            } else {
                                // Found a candidate for lookup...
                                def item = PicklistItem.findByPicklistAndInstitutionCodeAndValue(picklist, projectInstance.picklistInstitutionCode, field.value)
                                if (item) {
                                    keyValue = item.key
                                    cache[field.value] = keyValue
                                } else {
                                    cache[field.value] = false
                                }
                            }

                            if (keyValue) {
                                log.debug("Saving value for task ${task.id} (${lookupField}=${field.value}) field=${keyField}[${field.recordIdx}] value=${keyValue}")
                                if (targetField) {
                                    targetField.value = keyValue
                                    targetField.transcribedByUserId = UserService.SYSTEM_USER
                                } else {
                                    targetField = new Field(task: task, recordIdx: field.recordIdx, name: keyField, value: keyValue, superceded: false, transcribedByUserId: UserService.SYSTEM_USER, validatedByUserId: field.validatedByUserId)
                                    targetField.save()
                                }
                                fieldsUpdated++
                            } else {
                                log.debug("No item found for ${field.value}")
                            }
                        }
                    }
                }
                tasksProcessed++
                if (fieldsUpdated > 0 && fieldsUpdated % 200 == 0) {
                    sessionFactory.currentSession.flush()
                    log.debug("${fieldsUpdated} rows flushed (${tasksProcessed} tasks processed).")
                }
            }
            log.debug("Finished. ${tasksProcessed} tasks processed. ${fieldsUpdated} fields modified or inserted.")
            return fieldsUpdated
        } finally {
            sessionFactory.currentSession.setFlushMode(FlushMode.AUTO)
        }

    }
}
