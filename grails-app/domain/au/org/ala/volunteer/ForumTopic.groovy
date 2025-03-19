package au.org.ala.volunteer

class ForumTopic {

    Date dateCreated
    User creator
    String title
    Boolean sticky
    Boolean locked
    // DEPRECATED
    ForumTopicPriority priority = ForumTopicPriority.Normal
    ForumTopicType topicType = ForumTopicType.Discussion
    Boolean isAnswered
    Integer views = 0
    Boolean deleted
    Date lastReplyDate
    Boolean featured

    static belongsTo = [creator: User]

    static hasMany = [ messages: ForumMessage ]

    static constraints = {
        dateCreated nullable: true
        creator nullable: false
        title nullable: false
        sticky nullable:  true
        locked nullable:  true
        priority nullable: true
        topicType nullable: true
        isAnswered nullable: true
        views nullable: true
        deleted nullable: true
        lastReplyDate nullable: true
        featured nullable: true
    }

    static mapping = {
        priority enumType:"ordinal"
        topicType enumType:"ordinal"
        messages fetch: 'join'
    }

}
