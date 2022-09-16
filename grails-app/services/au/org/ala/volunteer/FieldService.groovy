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
                f.task in (:list) """,
            [name: fieldName, list: taskList], [sort: sort, order: order])
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
    def findAllTasksByFieldValues(Project projectInstance, String query, Map params, def fieldNames = []) {
        query = query?.toLowerCase()
        def queryParams = [projectId: projectInstance.id, query: '%' + query + '%']

        String statusFilterClause = " and (task.is_fully_transcribed = :transcribed and task.fully_validated_by :validatedClause)"
        if (params.statusFilter && params.statusFilter == 'transcribed') {
            statusFilterClause = statusFilterClause.replace(':validatedClause', 'is null')
            queryParams.transcribed = true
        } else if (params.statusFilter && params.statusFilter == 'validated') {
            statusFilterClause = statusFilterClause.replace(':validatedClause', 'is not null')
            queryParams.transcribed = true
        } else if (params.statusFilter && params.statusFilter == 'not-transcribed') {
            statusFilterClause = statusFilterClause.replace(':validatedClause', 'is null')
            queryParams.transcribed = false
        } else {
            statusFilterClause = ""
        }

        String fieldClause = " and f.name in (:fieldNames) "
        if (fieldNames) {
            queryParams.fieldNames = fieldNames
        } else {
            fieldClause = ""
        }

//        String queryString = """\
//            select distinct f.task
//            from Field f
//            where f.superceded = false
//            ${fieldClause}
//            and f.task.project = :projectInstance
//            ${statusFilterClause}
//            and (lower(f.value) like :query
//                or lower(f.transcription.fullyTranscribedBy) like :query
//                or lower(f.task.externalIdentifier) like :query) """.stripIndent()
        String queryString = """\
            select distinct task.id, 
                task.is_valid, 
                task.number_of_matching_transcriptions,
                task.external_identifier,
                task.fully_validated_by
            from field f
            join task on (f.task_id = task.id)
            left join transcription on (transcription.task_id = task.id)
            left join vp_user u1 on (transcription.fully_transcribed_by = u1.user_id)
            left join vp_user v1 on (task.fully_validated_by = v1.user_id)
            where f.superceded = false
            ${fieldClause}
            and task.project_id = :projectId
            ${statusFilterClause}
            and (lower(f.value) like :query  
                or lower(task.external_identifier) like :query 
                or lower(concat(u1.first_name, ' ', u1.last_name)) like :query
                or lower(concat(v1.first_name, ' ', v1.last_name)) like :query) """.stripIndent()

        def sortClause = " order by "
        switch (params.sort) {
            case 'isValid':
                sortClause += " task.is_valid " + (params.order ?: 'asc') + ", task.id asc "
                break
            case 'numberOfMatchingTranscriptions':
                sortClause += " COALESCE(task.number_of_matching_transcriptions, 0) " + (params.order ?: 'asc') + ", task.id asc "
                break
            case 'fullyValidatedBy':
                sortClause += " task.fully_validated_by " + (params.order ?: 'asc')
                break
            case 'externalIdentifier':
                sortClause += " task.external_identifier " + (params.order ?: 'asc')
                break
            default:
                sortClause += " task." + (params.sort ?: 'id') + " " + (params.order ?: 'asc')
                break
        }

        def selectQuery = queryString + sortClause + (params.max ? " limit ${params.max} " : "") +
                (params.offset ? " offset ${params.offset} " : "")
        def countQuery = "select count(*) as taskCount from (" + queryString + ") taskList"

        log.debug("Field query: ${selectQuery}")

        def sql = new Sql(dataSource)
        def taskList = []
        sql.eachRow(selectQuery, queryParams) { row ->
            Task task = Task.get(row.id as long)
            if (task) taskList.add(task)
        }

        def taskCount = sql.firstRow(countQuery, queryParams)?.taskCount

        sql.close()
        [taskList: taskList, taskCount: (taskCount ?: 0)]
    }

    int countAllTasksByFieldValueQuery(Project projectInstance, String query, List fieldNames = []) {

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

    List findAllTasksByFieldAndFieldValue(Project project, String fieldName, String fieldValue, String sortFieldName = null) {
        def select = """
            SELECT distinct task_id
            FROM field
            JOIN task ON (task.id = field.task_id)
            WHERE task.project_id = :projectId
            AND field.name = :fieldName
            AND field.value = :fieldValue
        """

        def params = [projectId: project.id, fieldName: fieldName, fieldValue: fieldValue]

        if (sortFieldName) {
            select = """
                ${select}
                ORDER BY ${sortFieldName} ASC
            """
        }

        log.debug("Query: ${select}")

        def sql = new Sql(dataSource)
        def taskList = []
        sql.eachRow(select, params) { row ->
            Task task = Task.get(row.task_id as long)
            if (task) {
                taskList.add(task)
            }
        }
        sql.close()

        taskList
    }

}
