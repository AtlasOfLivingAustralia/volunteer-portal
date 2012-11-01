package au.org.ala.volunteer

class ForumTopic {

    Date dateCreated
    User creator
    String title
    String text
    Boolean sticky
    Boolean locked
    ForumTopicPriority priority = ForumTopicPriority.Normal
    Integer views = 0

    static belongsTo = [creator: User]

    static constraints = {
        dateCreated nullable: false
        creator nullable: false
        title nullable: false
        text nullable: true
        sticky nullable:  true
        locked nullable:  true
        priority nullable: true
        views nullable: true
    }

}
