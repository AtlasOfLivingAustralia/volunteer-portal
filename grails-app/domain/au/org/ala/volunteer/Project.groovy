package au.org.ala.volunteer

import org.codehaus.groovy.grails.commons.ConfigurationHolder

class Project {

    String name
    String description
    String bannerImage
    String tutorialLinks
    Boolean showMap = true
    Date created
    String shortDescription
    String featuredLabel
    String featuredOwner
    Boolean disableNewsItems = false
    Integer leaderIconIndex = 0

    static belongsTo = [template: Template]
    static hasMany = [tasks: Task, projectAssociations: ProjectAssociation, newsItems: NewsItem]

    static mapping = {
        version false
        tasks cascade: 'all-delete-orphan'
        projectAssociations cascade: 'all-delete-orphan'
        template lazy: false
        newsItems sort: 'created', order: 'desc'
    }

    static constraints = {
        name maxSize: 200
        description nullable: true, maxSize: 2000, widget: 'textarea'
        template nullable: true
        created nullable: true
        bannerImage nullable: true
        showMap nullable: true
        tutorialLinks nullable: true, maxSize: 2000, widget: 'textarea'
        featuredImage nullable: true
        featuredLabel nullable: true
        featuredOwner nullable: true
        shortDescription nullable: true
        disableNewsItems nullable: true
        leaderIconIndex nullable: true
    }

    public String toString() {
        return name
    }

    public String getFeaturedImage() {
        return "${ConfigurationHolder.config.server.url}/${ConfigurationHolder.config.images.urlPrefix}project/${id}/expedition-image.jpg"
    }

    public void setFeaturedImage(String image) {
        // do nothing
    }
}
