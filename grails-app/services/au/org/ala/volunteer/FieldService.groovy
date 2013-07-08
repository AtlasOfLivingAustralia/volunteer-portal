package au.org.ala.volunteer

class FieldService {

    static transactional = true

    def serviceMethod() {}

    List getLatestFieldsWithTasks(String fieldName, List<Task> taskList, Map params) {
        def sort = "f.task." + (params.sort?:"id")
        def order = params.order?:"asc"
        def fieldValues = Field.executeQuery(
            """select f from Field f
               where f.name = :name and f.superceded = false and f.recordIdx = 0 and
               f.task in (:list) order by ${sort} ${order}""",
            [name: fieldName, list: taskList])
        fieldValues.toList()
    }

    List findAllFieldsWithTasksAndQuery(List<Task> taskList, String query, Map params) {
        query = query?.toLowerCase()

        def fieldValues = Field.executeQuery(
            """select distinct f.task from Field f
               where f.superceded = false and
               f.task in (:list) and (lower(f.value) like :query or lower(f.task.fullyTranscribedBy) like :query)
               order by 1""", [list: taskList, query: '%'+query+'%'], params)
        fieldValues.toList()
    }

    int countAllFieldsWithTasksAndQuery(List<Task> taskList, String query) {
        def fieldValues = Field.executeQuery(
            """select count(distinct f.task) from Field f
               where f.superceded = false and
               f.task in (:list) and (lower(f.value) like :query or lower(f.task.fullyTranscribedBy) like :query)
               order by 1""", [list: taskList, query: '%'+query+'%'])
        fieldValues.get(0)
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
            return fields[0] as Integer ?: 0
        }

        return 0
    }

}
