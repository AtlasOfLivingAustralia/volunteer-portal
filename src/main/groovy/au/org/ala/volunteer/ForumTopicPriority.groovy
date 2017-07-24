package au.org.ala.volunteer

enum ForumTopicPriority {
    Normal("ForumTopicPriority.normal"),
    Important("ForumTopicPriority.important"),
    Warning("ForumTopicPriority.warning"),
    Critical("ForumTopicPriority.critical")

    def String i18nLabel

    private ForumTopicPriority(String i18nLabel) {
        this.i18nLabel = i18nLabel
    }

    String getI18nLabel() {
        return i18nLabel
    }

    static ForumTopicPriority getInstance(ordinal) {
      ForumTopicPriority.values().find { it.ordinal() == ordinal }
    }

}
