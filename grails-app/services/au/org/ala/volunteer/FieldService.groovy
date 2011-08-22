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
}
