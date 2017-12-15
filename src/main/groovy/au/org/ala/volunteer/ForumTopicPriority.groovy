package au.org.ala.volunteer

enum ForumTopicPriority {
    Normal,
    Important,
    Warning,
    Critical

    static ForumTopicPriority getInstance(ordinal) {
      ForumTopicPriority.values().find { it.ordinal() == ordinal }
    }

}
