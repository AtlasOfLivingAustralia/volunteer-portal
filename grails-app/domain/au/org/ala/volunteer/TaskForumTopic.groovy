package au.org.ala.volunteer

class TaskForumTopic extends ForumTopic {

    Task task

    static constraints = {
        task nullable: false
    }
}
