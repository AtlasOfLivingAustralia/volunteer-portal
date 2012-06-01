package au.org.ala.volunteer

class TaskComment {

    Task task
    User user
    Date date
    String comment

    static constraints = {
        comment maxSize: 4096
    }
}
