package au.org.ala.volunteer

import grails.gorm.async.AsyncEntity

class Task implements Serializable, AsyncEntity<Task> {

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
    Integer numberOfMatchingTranscriptions
    Boolean isFullyTranscribed = false

    static belongsTo = [project: Project]
    static hasMany = [multimedia: Multimedia, viewedTasks: ViewedTask, fields: Field, transcriptions: Transcription]

    static mapping = {
        cache true
        multimedia cache: true
        version false
        multimedia cascade: 'all,delete-orphan'
        viewedTasks cascade: 'all,delete-orphan'
        fields cascade: 'all,delete-orphan'
        //comments cascade: 'all,delete-orphan'
        transcriptions cascade: 'all,delete-orphan'
        //transcribedUUID type: 'pg-uuid'
        validatedUUID type: 'pg-uuid'
        project index: 'task_project'
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
        numberOfMatchingTranscriptions nullable: true
        isFullyTranscribed nullable: true
    }

    /**
     * Returns true if all of the required number of Transcriptions have been completed for this Task.
     * The default is one Transcription per Task, but this can be overridden in the project template.
     */
    boolean allTranscriptionsComplete() {
        if (isFullyTranscribed) {
            return true
        }
        int requiredTranscriptionCount = project.requiredNumberOfTranscriptions
        int transcriptionCount = (int) (transcriptions?.count { it.fullyTranscribedBy } ?: 0)
        return transcriptionCount >= requiredTranscriptionCount
    }

    /**
     * Returns true if the supplied user has transcribed (fully or partially) this Task.
     *
     */
    boolean hasBeenTranscribedByUser(String userId) {
        Transcription userTranscription = transcriptions?.find{
            it.fullyTranscribedBy == userId
        }
        return userTranscription != null
        //return findUserTranscription(userId) != null
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

    Transcription getExistingEmptyTranscription() {

        // If there is already an empty Transcription which could have been reset previously, return that
        Transcription existingEmptyTranscription = transcriptions.find {
            !it.fullyTranscribedBy
        }
        return existingEmptyTranscription
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

        taskFields
    }

    /**
     * Determines if the task is locked for transcribing. If the task has been viewed by a user or the number of users
     * equal to the required number of transcriptions for a task in the associated project, within a given timeout
     * and it was not skipped, it is determined to be locked and not accessible to other users for the duration of the
     * timeout.
     * @param userId the user requesting the task
     * @param timeoutInSeconds the timeout for locking a task.
     * @return true if the task has been determined as locked/false if not.
     */
    boolean isLockedForTranscription(String userId, long timeoutInSeconds) {

        long timeoutWindow = System.currentTimeMillis() - timeoutInSeconds
        Set usersWhoCompletedTheirTranscriptions = transcriptions.findAll{it.fullyTranscribedBy}
                .collect{it.fullyTranscribedBy}.toSet()
        log.debug("[isLockedForTranscription] Task: ${id}; Users with transcriptions: ${usersWhoCompletedTheirTranscriptions}")

        boolean locked = false
        if (!usersWhoCompletedTheirTranscriptions.contains(userId)) {
            // Only views made by users that have not completed their transcription are relevant.
            Set currentViews = viewedTasks.findAll { view ->
                // If this view's user is not in the list of completed transcriptions
                // AND the view was less than 2hours ago
                //     and the view's user is not the requesting user
                //     and the view wasn't skipped
                // Then the task is locked.
                log.debug("View on this task by user: [${view.userId}], date: [${new Date(view.lastView)}]")
                log.debug("Does view count towards locking: ${!(view.userId in usersWhoCompletedTheirTranscriptions) && (view.lastView > timeoutWindow && userId != view.userId && !view.skipped)}")
                return !(view.userId in usersWhoCompletedTheirTranscriptions) && (view.lastView > timeoutWindow && userId != view.userId && !view.skipped)
            }.collect{it.userId}.toSet()

            log.debug("locked = usersWhoCompletedTranscriptions.size() [${usersWhoCompletedTheirTranscriptions.size()}] + currentViews.size() [${currentViews.size()}] > project.getRequiredNumberOfTranscriptions() [${project.getRequiredNumberOfTranscriptions()}]")
            locked = (usersWhoCompletedTheirTranscriptions.size() + currentViews.size()) >= project.getRequiredNumberOfTranscriptions()
        }

        log.debug("locked: ${locked}")
        return locked
    }

    /**
     * Determines if the task was most recently skipped by the provided user.
     * The Skip window is set to 15 minutes. After this time, the user can access that task again.
     *
     * @param userId the user who is requesting the task.
     * @return true if the user has skipped the task in the last 15mins/false if user has not skipped or not skipped
     * the task in the last 15mins.
     */
    boolean wasSkippedByUser(String userId) {
        long skipWindow = System.currentTimeMillis() - (15 * 60 * 1000) // 15 minutes in milliseconds
        log.debug("Skip timeout: ${(15 * 60 * 1000)}")
        log.debug("Skip Window: ${skipWindow}")

        // Find all views for this user and sort in descending order.
        def currentViews = viewedTasks.findAll{
            return (it.userId == userId)
        }.sort{a, b ->
            a.lastView == b.lastView ? 0 : a.lastView > b.lastView ? -1 : 1
        }

        if (currentViews.size() > 0) {
            def mostRecent = currentViews.first()
            log.debug("Checking if skipped; view: ${mostRecent}")
            log.debug("Was skipped? ${(mostRecent.skipped && skipWindow < mostRecent.lastView)}")
            return (mostRecent.skipped && skipWindow < mostRecent.lastView)
        }

        return false
    }

    String toString() {
        return "Task: [id: ${id}, projectId: ${project.id}, externalIdentifier: ${externalIdentifier}, lastViewed: ${lastViewed}, " +
                "lastViewedBy: ${lastViewedBy}, isFullyTranscribed: ${isFullyTranscribed}]"
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
