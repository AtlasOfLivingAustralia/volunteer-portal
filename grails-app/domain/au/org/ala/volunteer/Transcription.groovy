package au.org.ala.volunteer

class Transcription implements Serializable {

    String fullyTranscribedBy
    Date dateFullyTranscribed
    String fullyTranscribedIpAddress
    UUID transcribedUUID // unique id for the transcription
    String fullyValidatedBy
    Date dateFullyValidated

    static belongsTo = [task:Task, project: Project]

    static constraints = {
        task nullable: false
        fullyTranscribedBy nullable: true
        dateFullyTranscribed nullable: true
        fullyTranscribedIpAddress nullable: true
        transcribedUUID nullable: true
        dateFullyValidated nullable: true
        fullyValidatedBy nullable: true
    }

    static mapping = {
         task lazy: false
         transcribedUUID type: 'pg-uuid'
    }

}