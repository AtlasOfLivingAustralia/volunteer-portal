package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml

class Project implements Serializable {

    //Long id
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
    Boolean harvestableByAla = false
    Boolean imageSharingEnabled = false
    Boolean archived = false
    /** If true, the EXIF data from uploaded images will be attempted to be extracted and stored in Task Fields */
    Boolean extractImageExifData = false
    Integer transcriptionsPerTask = Project.DEFAULT_TRANSCRIPTIONS_PER_TASK
    Integer thresholdMatchingTranscriptions = Project.DEFAULT_THRESHOLD_MATCHING_TRANSCRIPTIONS

    Date dateCreated
    Date lastUpdated
    // Project of the Day Last Selected Date
    Date potdLastSelected
    Long sizeInBytes = 0L

    Integer version

    User createdBy

    def grailsApplication
    def grailsLinkGenerator
    //def assetResourceLocator

    static final Integer DEFAULT_TRANSCRIPTIONS_PER_TASK = 1
    static final Integer DEFAULT_THRESHOLD_MATCHING_TRANSCRIPTIONS = 0

    static final String EDIT_SECTION_GENERAL = 'general'
    static final String EDIT_SECTION_IMAGE = 'image'
    static final String EDIT_SECTION_BG_IMAGE = 'bgImage'
    static final String EDIT_SECTION_PICKLIST = 'picklist'
    static final String EDIT_SECTION_TASK = 'task'
    static final String EDIT_SECTION_MAP = 'map'
    static final String EDIT_SECTION_TUTORIAL = 'tutorial'

    static belongsTo = [template: Template, projectType: ProjectType]
    static hasMany = [tasks: Task, labels: Label, transcriptions: Transcription]
    //static transients = ['featuredImage', 'backgroundImage', 'grailsApplication', 'grailsLinkGenerator', 'requiredNumberOfTranscriptions']
    static transients = ['requiredNumberOfTranscriptions']

    static mapping = {
        cache true
        tasks cache: true
        autoTimestamp true
        description sqlType: 'text'
        tasks cascade: 'all,delete-orphan'
        template lazy: false
        harvestableByAla defaultValue: false
        version defaultValue: '0'
        imageSharingEnabled defaultValue: 'false'
        archived defaultValue: 'false'
        transcriptionsPerTask defaultValue: DEFAULT_TRANSCRIPTIONS_PER_TASK
        thresholdMatchingTranscriptions defaultValue: DEFAULT_THRESHOLD_MATCHING_TRANSCRIPTIONS
    }

    static constraints = {
        name maxSize: 200
        description nullable: true, maxSize: 20000, widget: 'textarea'
        template nullable: true
        created nullable: true
        showMap nullable: true
        tutorialLinks nullable: true, maxSize: 2000, widget: 'textarea'
        featuredLabel nullable: true
        featuredOwner nullable: true
        institution nullable: true
        shortDescription nullable: true, maxSize: 500
        disableNewsItems nullable: true
        leaderIconIndex nullable: true
        featuredImageCopyright nullable: true
        backgroundImageAttribution nullable: true
        backgroundImageOverlayColour nullable: true
        collectionEventLookupCollectionCode nullable: true
        localityLookupCollectionCode nullable: true
        picklistInstitutionCode nullable: true
        projectType nullable: true
        mapInitZoomLevel nullable: true
        mapInitLatitude nullable: true
        mapInitLongitude nullable: true
        harvestableByAla nullable: true
        createdBy nullable: true
        extractImageExifData nullable: true
        transcriptionsPerTask nullable: true
        thresholdMatchingTranscriptions nullable: true
        potdLastSelected nullable: true
        sizeInBytes nullable: false
    }

    /**
     * Reads the project template configuration to determine the number of times each Task must be transcribed.
     * The default is 1
     */
    int getRequiredNumberOfTranscriptions() {
        //String transcriptionsPerTask = template?.viewParams?.transcriptionsPerTask ?: "1"
        //Integer.parseInt(transcriptionsPerTask)
        return transcriptionsPerTask?: DEFAULT_TRANSCRIPTIONS_PER_TASK
    }

    String toString() {
        return name
    }

    String getInstitutionName() {
        institution ? institution.name : featuredOwner
    }

//    @SuppressWarnings('unused')
//    void setFeaturedImage(String image) {
//        // do nothing
//    }

    // Executed after an object has been updated
    def afterUpdate() {
        GormEventDebouncer.debounceProject(this.id)
    }

    String getKey() {
        name ?: ''
    }

    static def getCloneableFields() {
        // Don't include anything from hasMany. Do them manually.
        return ['description',
                'tutorialLinks',
                'showMap',
                'shortDescription',
                'featuredOwner',
                'institution',
                'leaderIconIndex',
                'featuredImageCopyright',
                'backgroundImageAttribution',
                'backgroundImageOverlayColour',
                'collectionEventLookupCollectionCode',
                'localityLookupCollectionCode',
                'picklistInstitutionCode',
                'mapInitZoomLevel',
                'mapInitLatitude',
                'mapInitLongitude',
                'imageSharingEnabled',
                'extractImageExifData',
                'transcriptionsPerTask',
                'thresholdMatchingTranscriptions',
                'template',
                'projectType'
                ]
    }

    String getProjectSizeFormatted() {
        String size
        if (!archived) {
            if (sizeInBytes > 0) size = PrettySize.toPrettySize(BigInteger.valueOf(sizeInBytes))
            else size = PrettySize.toPrettySize(BigInteger.valueOf(0))
        } else {
            size = PrettySize.toPrettySize(BigInteger.valueOf(0))
        }
    }
}
