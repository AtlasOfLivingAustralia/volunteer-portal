package au.org.ala.volunteer

class LatestTranscribersTaskMultimedia {
    static belongsTo = [latestTranscribersTask: LatestTranscribersTask]
    String filePath
    String filePathToThumbnail
    String licence
    String mimeType
    Date created
    String creator

    static mapping = {
        version false
    }

    static constraints = {
        latestTranscribersTask lazy: false
        created nullable: true
        creator nullable: true, maxSize: 200
        filePath nullable: true, maxSize: 200
        filePathToThumbnail nullable: true, maxSize: 200
        licence nullable: true, maxSize: 200
        mimeType nullable: true, maxSize: 50
        latestTranscribersTask nullable: true
    }
}
