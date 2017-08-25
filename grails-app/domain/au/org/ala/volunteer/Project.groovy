package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml

class Project implements Serializable {

    String name
    @SanitizedHtml
    String description
    @SanitizedHtml
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
    String backgroundImageAttribution = null
    String backgroundImageOverlayColour = null
    Boolean inactive = false
    String collectionEventLookupCollectionCode
    String localityLookupCollectionCode
    String picklistInstitutionCode
    Integer mapInitZoomLevel
    Double mapInitLatitude
    Double mapInitLongitude
    Boolean harvestableByAla = true
    Boolean archived = false

    Date dateCreated
    Date lastUpdated

    Integer version

    User createdBy

    def grailsApplication
    def grailsLinkGenerator
    //def assetResourceLocator

    static belongsTo = [template: Template, projectType: ProjectType]
    static hasMany = [tasks: Task, projectAssociations: ProjectAssociation, newsItems: NewsItem, labels: Label]
    static transients = ['featuredImage', 'backgroundImage', 'grailsApplication', 'grailsLinkGenerator']

    static mapping = {
        autoTimestamp true
        tasks cascade: 'all,delete-orphan'
        projectAssociations cascade: 'all,delete-orphan'
        template lazy: false
        newsItems sort: 'created', order: 'desc', cascade: 'all,delete-orphan'
        harvestableByAla defaultValue: true
        version defaultValue: '0'
        archived defaultValue: 'false'
    }

    static constraints = {
        name maxSize: 200
        description nullable: true, maxSize: 20000, widget: 'textarea'
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
        backgroundImageAttribution nullable: true
        backgroundImageOverlayColour nullable: true
        inactive nullable: true
        collectionEventLookupCollectionCode nullable: true
        localityLookupCollectionCode nullable: true
        picklistInstitutionCode nullable: true
        projectType nullable: true
        mapInitZoomLevel nullable: true
        mapInitLatitude nullable: true
        mapInitLongitude nullable: true
        harvestableByAla nullable: true
        createdBy nullable: true
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
            return grailsLinkGenerator.resource(file: '/banners/default-expedition-large.jpg')

        } else {
            def urlPrefix = grailsApplication.config.images.urlPrefix
            def infix = urlPrefix.endsWith('/') ? '' : '/'
            return "${grailsApplication.config.server.url}/${urlPrefix}${infix}project/${id}/expedition-image.jpg"
        }
    }

    /**
     * Retrieves background image url
     * @return background image url or null if non existent
     */
    String getBackgroundImage() {

        String localPathJpg = "${grailsApplication.config.images.home}/project/${id}/expedition-background-image.jpg"
        String localPathPng = "${grailsApplication.config.images.home}/project/${id}/expedition-background-image.png"
        File fileJpg = new File(localPathJpg)
        File filePng = new File(localPathPng)
        if (fileJpg.exists()) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}project/${id}/expedition-background-image.jpg"
        } else if (filePng.exists()) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}project/${id}/expedition-background-image.png"
        } else {
            return null;
        }
    }

    /**
     * Saves the uploaded background image or deletes the existing one if argument is null.  Consumes the inputstream
     * but doesn't close it
     * @param multipartFile
     */
    void setBackgroundImage(InputStream inputStream, String contentType) {
        if (inputStream && contentType) {
            // Save image
            String fileExtension = contentType == 'image/png' ? 'png' : 'jpg'
            def filePath = "${grailsApplication.config.images.home}/project/${id}/expedition-background-image.${fileExtension}"
            def file = new File(filePath);
            file.getParentFile().mkdirs();
            file.withOutputStream {
              it << inputStream
            }
        } else {
            // Remove image if exists
            String localPathJpg = "${grailsApplication.config.images.home}/project/${id}/expedition-background-image.jpg"
            String localPathPng = "${grailsApplication.config.images.home}/project/${id}/expedition-background-image.png"
            File fileJpg = new File(localPathJpg)
            File filePng = new File(localPathPng)
            if (fileJpg.exists()) {
                fileJpg.delete();
            } else if (filePng.exists()) {
                filePng.delete();
            }
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
