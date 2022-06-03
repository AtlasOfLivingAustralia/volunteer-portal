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
        long timeout = grailsApplication.config.viewedTask.timeout as long
        return task.isLockedForTranscription(userId, timeout)
    }

    boolean isTaskLockedForValidation(Task task, String userId) {
        ViewedTask lastView = getLastViewForTask(task)
        String currentUser = userService.currentUserId

        // If task has been fully transcribed, allow it to be validated straight away:
        if (task.isFullyTranscribed) {
            return false
        } else {
            if (lastView) {
                log.debug "userId = " + currentUser + " || prevUserId = " + lastView.userId + " || prevLastView = " + lastView.lastView
                def millisecondsSinceLastView = System.currentTimeMillis() - lastView.lastView
                if (lastView.userId != currentUser && millisecondsSinceLastView < (grailsApplication.config.viewedTask.timeout as long)) {
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
