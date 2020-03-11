package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml

class LandingPage {

    Integer numberOfContributors = 10

    String title
    String shortUrl

    @SanitizedHtml
    String bodyCopy

    String landingPageImage
    String imageAttribution

    ProjectType projectType

    Boolean enabled

    Long version
    Date dateCreated
    Date lastUpdated

    static hasMany = [label: Label]

    static mapping = {
        numberOfContributors defaultValue: '10'
        enabled defaultValue: false
        version defaultValue: '0'
        shortUrl index: 'landing_page_short_url_idx'
       // version false
        autoTimestamp true
    }

    static constraints = {
        title blank: false, nullable: false
        enabled nullable: false
        bodyCopy nullable: true
        numberOfContributors nullable: false, min: 0, max: 20
        landingPageImage nullable: true
        imageAttribution nullable: true
        projectType nullable: true
        shortUrl unique: true, nullable: false, maxSize: 50, validator: { val -> if (val.contains(' ')) return 'value.hasASpace' }
    }

}
