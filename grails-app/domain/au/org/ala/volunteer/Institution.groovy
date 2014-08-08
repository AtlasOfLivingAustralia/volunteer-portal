package au.org.ala.volunteer

class Institution implements Serializable {

    Long id

    String name
    String description // markdown, optional
    String contactName // optional
    String contactEmail // optional
    String contactPhone // optional

    Integer collectoryId // optional

    int version

    Date dateCreated
    Date lastUpdated

    static constraints = {
        contactName blank: true, nullable: true
        contactEmail email: true, blank: true, nullable: true
        contactPhone blank: true, nullable: true
        collectoryId nullable: true, unique: true
        description blank: true, nullable: true, maxSize: 16384
    }

    static mapping = {
        description widget: 'textarea'
    }
}
