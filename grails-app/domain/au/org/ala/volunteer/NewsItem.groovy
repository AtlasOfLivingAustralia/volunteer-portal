package au.org.ala.volunteer

class NewsItem {
    Project project
    String title
    String body
    Date created
    String createdBy

    static constraints = {
        body nullable: true, maxSize: 4000, widget:'textarea'
    }
}
