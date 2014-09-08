package au.org.ala.volunteer

class NewsItem implements Serializable {

    Institution institution
    Project project
    String title
    String shortDescription
    String body
    Date created
    String createdBy

    static constraints = {
        body nullable: true, maxSize: 4000, widget:'textarea'
        shortDescription nullable: true
        project nullable: true
        institution nullable: true, validator: { val, obj -> val == null && obj.project == null ? "projectOrInstitutionRequired" : null }
    }

    public String toString() {
        return title
    }
}
