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
        transcriptions.add(transcription)

        transcription
    }

    /**
     * Returns the Fields that are not assigned to a Transcription.  For an unvalidated Task, these will be
     * the Fields that were loaded when the Task was loaded.  For a validated Task, these will be the Set of
     * valid fields that have been approved (or transcribed) by a validator.
     */
    Set<Field> getTaskFields() {

        Set taskFields = fields.findAll{it.transcription == null}

        println taskFields
        taskFields


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

    /**
     * Updates the properties of this Task that marks it as validated.
     * @param userId the user who validated the task.
     * @param isValid true if the Task is considered valid.
     * @param validationDate the Date the task was validated (defaults to now)
     */
    void validate(String userId, boolean isValid, Date validationDate = new Date()) {
        if (!fullyValidatedBy) {
            fullyValidatedBy = userId
        }
        if (!dateFullyValidated) {
            dateFullyValidated = validationDate
        }
        if (!validatedUUID) {
            validatedUUID = UUID.randomUUID()
        }
        if (isValid) {
            this.isValid = true
        }
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
