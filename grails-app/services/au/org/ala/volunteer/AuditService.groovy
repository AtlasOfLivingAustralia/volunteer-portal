package au.org.ala.volunteer

import grails.gorm.transactions.Transactional

@Transactional
class AuditService {

    def grailsApplication
    def userService

    ViewedTask getLastViewForTask(Task taskInstance) {
        def c = ViewedTask.createCriteria()
        def viewedTasks = c.list {
            eq("task", taskInstance)
            maxResults(1)
            order("dateCreated", "desc")
        }
        return viewedTasks ? viewedTasks[0] : null
    }

    boolean isTaskLockedForTranscription(Task task, String userId) {
        long timeout = grailsApplication.config.getProperty("viewedTask.timeout", Long.class).longValue()
        return task.isLockedForTranscription(userId, timeout)
    }

    boolean isTaskLockedForValidation(Task task) {
        ViewedTask lastView = getLastViewForTask(task)
        String currentUser = userService.currentUserId
        //log.debug("[isTaskLockedForValidation] Requesting user: ${currentUser}, lastView: ${lastView.userId}|${lastView.lastView}, task.lastUpdated: ${task.dateLastUpdated.getTime()}")

        // If task is already validated, we don't mind if multiple users look at it - it's considered completed.
        if (!task.dateFullyValidated) {
            if (lastView) {
                def millisecondsSinceLastView = System.currentTimeMillis() - lastView.lastView
                if (lastView.userId != currentUser && millisecondsSinceLastView < (grailsApplication.config.getProperty('viewedTask.timeout', Long).longValue())) {
                    // Task was viewed inside the lock timeout - potentially locked...
                    // However, if this view was before the task was last updated, then assume view was from the last
                    // transcription (not yet validated) (and update was from setting is_fully_transcribed).
                    if (lastView.lastView <= task.dateLastUpdated.getTime()) {
                        //log.debug("Last view comes before dateLastUpdated: allow validation")
                        return false
                    }
                    return true
                }
            }
        }
        return false
    }

    def auditTaskViewing(Task taskInstance, String userId) {
        log.debug "Audit service: " + taskInstance.id

        def lastViewMillis = System.currentTimeMillis()
        def viewedTask = new ViewedTask(task: taskInstance, numberOfViews: 1, lastUpdated: new Date(), userId: userId, lastView: lastViewMillis, skipped: false)
        viewedTask.save(flush: true, failOnError: true)
        // Also keep track of the last view on the task directly. This makes it much easier when
        // selecting the next task for a user.
        taskInstance.lastViewed = lastViewMillis
        taskInstance.lastViewedBy = userId

        taskInstance.addToViewedTasks(viewedTask)
    }
}
