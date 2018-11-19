package au.org.ala.volunteer

class Task implements Serializable {

    //Project project
    Long id
    String externalIdentifier
    String externalUrl
//    String fullyTranscribedBy
//    Date dateFullyTranscribed
//    String fullyTranscribedIpAddress
 //   UUID transcribedUUID // unique id for the transcription
    String fullyValidatedBy
    Date dateFullyValidated
    UUID validatedUUID // unique id for the validation
    Boolean isValid
    Integer viewed = -1
    Date created
    Date dateLastUpdated
    Long lastViewed
    String lastViewedBy
    Integer timeToTranscribe
    Integer timeToValidate

    static belongsTo = [project: Project]
    static hasMany = [multimedia: Multimedia, viewedTasks: ViewedTask, fields: Field, comments: TaskComment, transcriptions: Transcription]

    static mapping = {
        version false
        multimedia cascade: 'all,delete-orphan'
        viewedTasks cascade: 'all,delete-orphan'
        fields cascade: 'all,delete-orphan'
        comments cascade: 'all,delete-orphan'
        transcriptions cascade: 'all,delete-orphan'
        //transcribedUUID type: 'pg-uuid'
        validatedUUID type: 'pg-uuid'
    }

    static constraints = {
        externalIdentifier nullable: true
        externalUrl nullable: true
//        fullyTranscribedBy nullable: true
//        dateFullyTranscribed nullable: true
//        fullyTranscribedIpAddress nullable: true
//        transcribedUUID nullable: true
        fullyValidatedBy nullable: true
        dateFullyValidated nullable: true
        validatedUUID nullable: true
        isValid nullable: true
        viewed nullable: true
        created nullable: true
        dateLastUpdated nullable: true
        lastViewed nullable: true
        lastViewedBy nullable: true
        timeToTranscribe nullable: true
        timeToValidate nullable: true
    }

    /**
     * Returns true if all of the required number of Transcriptions have been completed for this Task.
     * The default is one Transcription per Task, but this can be overridden in the project template.
     */
    boolean isFullyTranscribed() {
        int requiredTranscriptionCount = project.requiredNumberOfTranscriptions
        int transcriptionCount = transcriptions?.count{it.fullyTranscribedBy} ?: 0
        return transcriptionCount >= requiredTranscriptionCount
    }

    /**
     * Returns true if the supplied user has transcribed (fully or partially) this Task.
     */
    boolean hasBeenTranscribedByUser(String userId) {
        return findUserTranscription(userId) != null
    }

    /**
     * If a user has previously transcribed this Task, return the Transcription that was performed by that user.
     * @param userId The user to check.
     * @return the Transcription the user performed, or null if the user has never Transcribed this task.
     */
    Transcription findUserTranscription(String userId) {

        // If there is already a Transcription completed by the user, return that.
        Transcription userTranscription = transcriptions?.find{
            it.fullyTranscribedBy == userId
        }
        // Otherwise, check if the user has saved any fields (a partial transcription) and return the
        // Transcription associated with those Fields.
        if (!userTranscription) {
            Field field = fields?.find{it.transcribedByUserId == userId}
            if (field) {
                userTranscription = field.transcription
            }
        }
        userTranscription
    }

    Transcription addTranscription() {
        Transcription transcription = new Transcription(task:this, project:project)

        // Copy any fields that were loaded with the Task originally into the new Transcription.
        // Possibly this should be done when the transcription is loaded (so we aren't duplicating this
        // data, just showing it on the page as required.
        if (fields) {
            fields.each { field ->
                if (!field.transcription) {
                    transcription.fields << new Field(transcription: transcription, name:field.name, value:field.value, recordIdx: field.recordIdx, superceded: false)
                }
            }
        }
        transcriptions.add(transcription)

        transcription
    }

    boolean isLockedForTranscription(String userId, long timeoutInSeconds) {

        long timeoutWindow = System.currentTimeMillis() - timeoutInSeconds
        Set usersWhoCompletedTheirTranscriptions = transcriptions.findAll{it.fullyTranscribedBy}.collect{it.fullyTranscribedBy}.toSet()

        boolean locked = false
        if (!usersWhoCompletedTheirTranscriptions.contains(userId)) {
            // Only views made by users that have not completed their transcription are relevant.
            Set currentViews = viewedTasks.findAll { view ->
                return !(view.userId in usersWhoCompletedTheirTranscriptions) && (view.lastView > timeoutWindow && userId != view.userId)
            }.collect{it.userId}.toSet()

            locked = (usersWhoCompletedTheirTranscriptions.size() + currentViews.size()) >= project.getRequiredNumberOfTranscriptions()
        }

        return locked
    }

    // These events use a static method rather than an injected service
    // to prevent issues with serialisation in webflows
    
    // Executed after an object is persisted to the database
    def afterInsert() {
        GormEventDebouncer.debounceTask(this.id)
    }
    // Executed after an object has been updated
    def afterUpdate() {
        GormEventDebouncer.debounceTask(this.id)
    }
    // Executed after an object has been deleted
    def afterDelete() {
        GormEventDebouncer.debounceDeleteTask(this.id)
    }
}
