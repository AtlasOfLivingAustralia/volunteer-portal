package au.org.ala.volunteer

class Project implements Serializable {

    String name
    String description
    String tutorialLinks
    Boolean showMap = true
    Date created
    String shortDescription
    String featuredLabel
    String featuredOwner
    Institution institution
    Boolean disableNewsItems = false
    Integer leaderIconIndex = 0
    String featuredImageCopyright = null
    Boolean inactive = false
    String collectionEventLookupCollectionCode
    String localityLookupCollectionCode
    String picklistInstitutionCode
    Integer mapInitZoomLevel
    Double mapInitLatitude
    Double mapInitLongitude
    Boolean harvestableByAla = true

    def grailsApplication
    def grailsLinkGenerator
    def assetResourceLocator

    static belongsTo = [template: Template, projectType: ProjectType]
    static hasMany = [tasks: Task, projectAssociations: ProjectAssociation, newsItems: NewsItem, labels: Label]
    static transients = ['featuredImage', 'backgroundImage', 'grailsApplication', 'grailsLinkGenerator']

    static mapping = {
        version false
        tasks cascade: 'all,delete-orphan'
        projectAssociations cascade: 'all,delete-orphan'
        template lazy: false
        newsItems sort: 'created', order: 'desc', cascade: 'all,delete-orphan'
        harvestableByAla defaultValue: true
    }

    static constraints = {
        name maxSize: 200
        description nullable: true, maxSize: 3000, widget: 'textarea'
        template nullable: true
        created nullable: true
        showMap nullable: true
        tutorialLinks nullable: true, maxSize: 2000, widget: 'textarea'
        featuredImage nullable: true
        featuredLabel nullable: true
        featuredOwner nullable: true
        institution nullable: true
        shortDescription nullable: true, maxSize: 500
        disableNewsItems nullable: true
        leaderIconIndex nullable: true
        featuredImageCopyright nullable: true
        inactive nullable: true
        collectionEventLookupCollectionCode nullable: true
        localityLookupCollectionCode nullable: true
        picklistInstitutionCode nullable: true
        projectType nullable: true
        mapInitZoomLevel nullable: true
        mapInitLatitude nullable: true
        mapInitLongitude nullable: true
        harvestableByAla nullable: true
    }

    public String toString() {
        return name
    }

    public String getInstitutionName() {
        institution ? institution.name : featuredOwner
    }

    public String getFeaturedImage() {
        // Check to see if there is a feature image for this expedition by looking in its project directory.
        // If one exists, use it, otherwise use a default image...
        def localPath = "${grailsApplication.config.images.home}/project/${id}/expedition-image.jpg"
        def file = new File(localPath)
        if (!file.exists()) {
            return grailsLinkGenerator.resource([dir: '/images/banners', file:'default-expedition-large.jpg'])

        } else {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}project/${id}/expedition-image.jpg"
        }
    }

    /**
     * Check to see if there is a feature image for this expedition by looking in its project directory.
     * @return background image url or null if non existent
     */
    String getBackgroundImage() {

        def localPathJpg = "${grailsApplication.config.images.home}/project/${id}/expedition-background-image.jpg"
        def localPathPng = "${grailsApplication.config.images.home}/project/${id}/expedition-background-image.png"
        def fileJpg = new File(localPathJpg)
        def filePng = new File(localPathPng)
        if (fileJpg.exists()) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}project/${id}/expedition-background-image.jpg"
        } else if (filePng.exists()) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}project/${id}/expedition-background-image.png"
        } else {
            return null;
        }
    }

    public void setFeaturedImage(String image) {
        // do nothing
    }

    // Executed after an object has been updated
    def afterUpdate() {
        GormEventDebouncer.debounceProject(this.id)
    }
}
