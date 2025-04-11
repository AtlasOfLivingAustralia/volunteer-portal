package au.org.ala.volunteer

enum ForumTopicType {
    Question,
    Discussion,
    Announcement

    static ForumTopicType getInstance(ordinal) {
        ForumTopicType.values().find { it.ordinal() == ordinal }
    }
}