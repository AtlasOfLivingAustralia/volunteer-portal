package au.org.ala.volunteer

class ProjectForumTopic extends ForumTopic {

    Project project

    static constraints = {
        project nullable: false
    }

    static mapping = {
        project lazy: false
    }
}
