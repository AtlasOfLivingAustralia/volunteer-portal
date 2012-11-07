package au.org.ala.volunteer

class ForumMessage {

    ForumTopic topic
    User user
    Date date
    String text
    Boolean deleted
    ForumMessage replyTo

    static belongsTo = [topic: ForumTopic]

    static constraints = {
        topic nullable: false
        user nullable: false
        date nullable:  false
        deleted nullable: true
        text nullable: true, maxSize: 16384
        replyTo nullable: true
    }

}
