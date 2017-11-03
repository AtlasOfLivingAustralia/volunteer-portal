package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml

class WildlifeSpotter {

    Integer numberOfContributors = 10

    @SanitizedHtml
    String bodyCopy

    String heroImage
    String heroImageAttribution

    Long version
    Date dateCreated
    Date lastUpdated

    static mapping = {
        numberOfContributors defaultValue: '10'
    }

    static constraints = {
        bodyCopy nullable: true
        numberOfContributors nullable: false, min: 0, max: 20
        heroImage nullable: true
        heroImageAttribution nullable: true
    }

    static WildlifeSpotter instance() {
        return WildlifeSpotter.list()[0]
    }

}
