package au.org.ala.volunteer

class TaskForumTopic extends ForumTopic {

    static belongsTo = [task: Task]

    static constraints = {
        task nullable: false
    }

    static mapping = {
        task lazy: false
    }
}
