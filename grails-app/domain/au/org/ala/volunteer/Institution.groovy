package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml
import groovy.transform.EqualsAndHashCode

class Institution implements Serializable {

    Long id
    String name
    String acronym  // optional
    String shortDescription // optional
    @SanitizedHtml
    String description // markdown, optional
    String contactName // optional
    String contactEmail // optional
    String contactPhone // optional
    String websiteUrl // optional
    String collectoryUid // optional
    String imageCaption // optional
    String themeColour // optional
    boolean disableNewsItems = false

    int version

    Date dateCreated
    Date lastUpdated

    static constraints = {
        contactName blank: true, nullable: true
        contactEmail email: true, blank: true, nullable: true
        contactPhone blank: true, nullable: true
        collectoryUid nullable: true
        shortDescription nullable: true, blank: true, maxSize: 512
        description blank: true, nullable: true, maxSize: 16384
        acronym blank: true, nullable: true
        websiteUrl blank: true, nullable: true
        imageCaption blank: true, nullable: true
        themeColour blank: true, nullable: true
    }

    static mapping = {
        description widget: 'textarea'
        disableNewsItems defaultValue: 'false'
    }

    String toString() {
        return name
    }

    public String getKey () {
        return id?.toString()?:''
    }
}
