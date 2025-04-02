package au.org.ala.volunteer

class ProjectForumTopic extends ForumTopic {

    Project project

    static belongsTo = [Project]

    static constraints = {
        project nullable: false
    }

    static mapping = {
        project lazy: false
    }
}
