package au.org.ala.volunteer

class ForumMessage {

    ForumTopic topic
    User user
    Date date
    Boolean deleted
    Boolean sticky

    static belongsTo = [topic: ForumTopic, user: User]

    static constraints = {
        topic nullable: false
        user nullable: false
        date nullable:  false
        deleted nullable: true
        sticky nullable: true
    }

}
