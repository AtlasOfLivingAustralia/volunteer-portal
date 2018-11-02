package au.org.ala.volunteer

class Transcription implements Serializable {

    Long id
  //  Long taskId
    String fullyTranscribedBy
    Date dateFullyTranscribed
    String fullyTranscribedIpAddress
    UUID transcribedUUID // unique id for the transcription
    UUID validatedUUID
    String fullyValidatedBy
    Date dateFullyValidated
    Integer timeToTranscribe
    Integer timeToValidate



    static belongsTo = [task:Task, project: Project]

    static constraints = {
        task nullable: false
        fullyTranscribedBy nullable: true
        dateFullyTranscribed nullable: true
        fullyTranscribedIpAddress nullable: true
        transcribedUUID nullable: true
        validatedUUID nullable: true
        timeToTranscribe nullable: true
        timeToValidate nullable: true
    }

    static mapping = {
        task lazy: false
        transcribedUUID type: 'pg-uuid'
        validatedUUID type: 'pg-uuid'
    }

}