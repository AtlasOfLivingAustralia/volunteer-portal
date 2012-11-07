package au.org.ala.volunteer

class ForumTopicNotificationMessage {

    User user
    ForumTopic topic
    ForumMessage message

    static constraints = {
        user nullable: false
        topic nullable: false
        message nullable: false
    }

}
