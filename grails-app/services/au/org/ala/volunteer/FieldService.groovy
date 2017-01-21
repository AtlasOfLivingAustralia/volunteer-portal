package au.org.ala.volunteer

import grails.transaction.Transactional

@Transactional
class FieldService {

    List getLatestFieldsWithTasks(String fieldName, List<Task> taskList, Map params) {
        if (!taskList) {
            return []
        }

        def sort = "f.task." + (params.sort?:"id")
        def order = params.order?:"asc"
        def fieldValues = Field.executeQuery(
                """select f from Field f
               where f.name = :name and f.superceded = false and f.recordIdx = 0 and
               f.task in (:list) order by ${sort} ${order}""",
                [name: fieldName, list: taskList])
        fieldValues.toList()
    }

    /**
     * Search for tasks based on field values (within the context of a project)
     * Also searches psuedo fields, such as external-identifier and fullyTranscribedBy and fullyValidatedBy
     * @param projectInstance
     * @param query
     * @param params
     * @param fieldNames
     * @return
     */
    List findAllTasksByFieldValues(Project projectInstance, String query, Map params, List fieldNames = []) {
        query = query?.toLowerCase()

        def taskList

        if (fieldNames) {
            taskList = Field.executeQuery(
                    """select distinct f.task from Field f
               where f.superceded = false and
               f.name in (:fieldNames) and
               f.task.project = :projectInstance and
               (lower(f.value) like :query or lower(f.task.fullyTranscribedBy) like :query or lower(f.task.externalIdentifier) like :query)
               """, [projectInstance: projectInstance, query: '%' + query + '%', fieldNames: fieldNames], params)
        } else {
            taskList = Field.executeQuery(
                    """select distinct f.task from Field f
               where f.superceded = false and
               f.task.project = :projectInstance and
               (lower(f.value) like :query or lower(f.task.fullyTranscribedBy) like :query or lower(f.task.externalIdentifier) like :query)
               """, [projectInstance: projectInstance, query: '%' + query + '%'], params)
        }

        taskList?.toList()
    }

    public int countAllTasksByFieldValueQuery(Project projectInstance, String query, List fieldNames = []) {

        query = query?.toLowerCase()
        def count
        if (fieldNames) {
            count = Field.executeQuery(
                    """select count(distinct f.task) as count from Field f
               where f.superceded = false and
               f.name in (:fieldNames) and
               f.task.project = :projectInstance and
               (lower(f.value) like :query or lower(f.task.fullyTranscribedBy) like :query or lower(f.task.externalIdentifier) like :query)
               """, [projectInstance: projectInstance, query: '%' + query + '%', fieldNames: fieldNames])
        } else {
            count = Field.executeQuery(
                    """select count(distinct f.task) from Field f
               where f.superceded = false and
               f.task.project = :projectInstance and
               (lower(f.value) like :query or lower(f.task.fullyTranscribedBy) like :query or lower(f.task.externalIdentifier) like :query)
               """, [projectInstance: projectInstance, query: '%' + query + '%'])
        }
        return count?.get(0) as Integer
    }

    List getAllFieldsWithTasks(List<Task> taskList) {
        def fieldValues = Field.executeQuery(
                """select f from Field f
               where f.superceded = false and
               f.task in (:list) order by f.task.id""", [list: taskList])
        fieldValues.toList()
    }

    List getAllFieldNames(List<Task> taskList) {
        def fieldValues = Field.executeQuery(
                """select distinct f.name from Field f
               where f.superceded = false and
               f.task in (:list) order by f.name""", [list: taskList])
        fieldValues.toList()
    }

    Field getFieldForTask(Task task, String fieldName) {
        def c = Field.createCriteria()

        def fields = c {
            and {
                eq("task", task)
                eq("superceded", false)
                eq("name", fieldName)
            }
        }

        if (fields && fields.size() > 0) {
            return fields.get(0)
        }
        return null
    }

    def getPointForTask(Task task) {
        def c = Field.createCriteria()

        def fields = c.list {
            and {
                eq("task", task)
                eq("superceded", false)
                or {
                    eq("name", "decimalLatitude")
                    eq("name", "decimalLongitude")
                }
            }
        }

        if (fields && fields.size() > 1) {
            def results =[:]
            results.lng = fields.find({ Field field -> field.name == 'decimalLongitude' })?.value
            results.lat = fields.find({ Field field -> field.name == 'decimalLatitude' })?.value
            return results
        }
        return null
    }

    int getLastSequenceNumberForProject(Project project) {
        def taskList = Task.findAllByProject(project)
        def c = Field.createCriteria()

        if (taskList) {
            def fields = c {
                and {
                    inList("task", taskList)
                    eq('name', 'sequenceNumber')
                }
                projections {
                    max('value')
                }
            }
            try{
                return fields[0] as Integer ?: 0
            } catch (NumberFormatException e) {
                log.debug("Can not extract sequence number from ${fields[0]}")
                // fall through to default value
            }
        }

        return 0
    }

    Field setFieldValueForTask(Task task, String fieldName, int recordIndex, String value, String userId = "system") {
        // Check if there is an existing (current) value for this field/index
        if (task == null || fieldName == null || value == null) {
            return null
        }

        def existing = Field.find {
            eq("task", task)
            eq("name", fieldName)
            eq("superceded", false)
            eq("recordIdx", recordIndex)
        }

        if (existing) {
            existing.superceded = true
        }
        // Now create a new field for this value
        def field = new Field(task: task, name: fieldName, recordIdx: recordIndex, superceded: false, value: value, transcribedByUserId: userId)
        field.save(flush: true, failOnError: true)
        return field
    }

}
