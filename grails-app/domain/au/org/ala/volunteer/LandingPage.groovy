package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml

class LandingPage {

    Integer numberOfContributors = 10

    String title

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
    }

}
