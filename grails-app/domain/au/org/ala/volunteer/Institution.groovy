package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml

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
    boolean isInactive = true
    boolean isApproved = false
    boolean displayContact = true
    User createdBy

    int version

    Date dateCreated
    Date lastUpdated

    static constraints = {
        contactName blank: false, nullable: false
        contactEmail email: true, blank: false, nullable: false
        contactPhone blank: true, nullable: true
        collectoryUid nullable: true
        shortDescription nullable: true, blank: true, maxSize: 512
        description blank: true, nullable: true, maxSize: 16384
        acronym blank: true, nullable: true
        websiteUrl blank: true, nullable: true
        imageCaption blank: true, nullable: true
        themeColour blank: true, nullable: true
        createdBy nullable: true
    }

    static mapping = {
        description widget: 'textarea'
        disableNewsItems defaultValue: 'false'
        isInactive defaultValue: true
        isApproved defaultValue: false
        displayContact defaultValue: true
    }

    String toString() {
        return name + (isInactive ? " (inactive)" : "")
    }

    String getKey () {
        return id?.toString()?:''
    }

    static List<Institution> listApproved(Map params) {
        return findAllByIsApproved(true, params)
    }

    int getProjectCount() {
        def result = Project.createCriteria().get {
            'institution' {
                eq('id', this.id)
            }
            projections {
                rowCount()
            }
        }

        result as int
    }
}
