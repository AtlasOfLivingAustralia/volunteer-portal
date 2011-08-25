package au.org.ala.volunteer

class FieldService {

    static transactional = true

    def serviceMethod() {}

    List getLatestFieldsWithTasks(String fieldName, List<Task> taskList) {
        def fieldValues = Field.executeQuery(
            """select f from Field f
               where f.name = :name and f.superceded = false and
               f.task in (:list) order by f.task.id""", [name: fieldName,list: taskList])
        fieldValues.toList()
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
}
