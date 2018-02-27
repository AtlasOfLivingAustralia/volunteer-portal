package au.org.ala.volunteer

class ForumTopicNotificationMessage {

    static belongsTo = [user: User, topic: ForumTopic, message: ForumMessage]

    static constraints = {
        user nullable: false
        topic nullable: false
        message nullable: false
    }

}
