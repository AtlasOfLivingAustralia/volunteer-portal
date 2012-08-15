package au.org.ala.volunteer

class TaskComment {

    static belongsTo = [task:Task]

    User user
    Date date
    String comment

    static constraints = {
        comment maxSize: 4096
    }
}
