package au.org.ala.volunteer

class NewsItem implements Serializable {

    Project project
    String title
    String shortDescription
    String body
    Date created
    String createdBy

    static constraints = {
        body nullable: true, maxSize: 4000, widget:'textarea'
        shortDescription nullable: true
    }

    public String toString() {
        return title
    }
}
