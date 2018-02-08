package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml

class Institution implements Serializable {

    Translation i18nName
    @SanitizedHtml
    Translation i18nShortDescription
    @SanitizedHtml
    Translation i18nDescription // markdown, optional

    Translation i18nAcronym

    Long id

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
        websiteUrl blank: true, nullable: true
        imageCaption blank: true, nullable: true
        themeColour blank: true, nullable: true

        i18nName blank: false, nullable: false, lazy: false
        i18nShortDescription blank: true, nullable: true, lazy: false
        i18nDescription blank: true, nullable: true, lazy: false
        i18nAcronym blank: true, nullable: true, lazy: false
    }

    static mapping = {
        disableNewsItems defaultValue: 'false'
    }
}