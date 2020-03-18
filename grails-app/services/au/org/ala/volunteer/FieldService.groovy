package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import groovy.sql.Sql
import javax.sql.DataSource

@Transactional
class FieldService {

    DataSource dataSource

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
               (lower(f.value) like :query or lower(f.transcription.fullyTranscribedBy) like :query or lower(f.task.externalIdentifier) like :query)
               """, [projectInstance: projectInstance, query: '%' + query + '%', fieldNames: fieldNames], params)
        } else {
            taskList = Field.executeQuery(
                    """select distinct f.task from Field f
               where f.superceded = false and
               f.task.project = :projectInstance and
               (lower(f.value) like :query or lower(f.transcription.fullyTranscribedBy) like :query or lower(f.task.externalIdentifier) like :query)
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
               (lower(f.value) like :query or lower(f.transcription.fullyTranscribedBy) like :query or lower(f.task.externalIdentifier) like :query)
               """, [projectInstance: projectInstance, query: '%' + query + '%', fieldNames: fieldNames])
        } else {
            count = Field.executeQuery(
                    """select count(distinct f.task) from Field f
               where f.superceded = false and
               f.task.project = :projectInstance and
               (lower(f.value) like :query or lower(f.transcription.fullyTranscribedBy) like :query or lower(f.task.externalIdentifier) like :query)
               """, [projectInstance: projectInstance, query: '%' + query + '%'])
        }
        return count?.get(0) as Integer
    }

    List getAllFieldsWithTasks(List<Task> taskList) {
        List<Field> fieldValues = []
        if (taskList && taskList.size() > 0) {
            fieldValues = Field.executeQuery(
                    """select f from Field f
                   left outer join fetch f.transcription 
                   where f.superceded = false and
                   f.task in (:list) 
                   order by f.task.id""", [list: taskList])
        }
        fieldValues
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

    Field setFieldValueForTask(Task task, String fieldName, int recordIndex, String value, String userId = UserService.SYSTEM_USER) {
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

    /**
     * Finds and returns the maximum record index for each unique Field name recorded transcribed any Task in a Project
     */
    List getMaxRecordIndexByFieldForProject(Project project) {
        def select ="""
                WITH task_ids AS 
                    (SELECT id FROM task WHERE project_id = :projectId)
                SELECT name , max(record_idx) AS recordIdx
                FROM field
                WHERE field.task_id in (SELECT id FROM task_ids)
            GROUP BY name
            ORDER BY name
        """
        def sql = new Sql(dataSource)
        def databaseFieldNames = sql.rows(select, [projectId: project.id])
        sql.close()
        databaseFieldNames
    }

}
