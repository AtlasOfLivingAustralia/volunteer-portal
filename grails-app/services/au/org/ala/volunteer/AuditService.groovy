package au.org.ala.volunteer

class AuditService {

    static transactional = true

    def grailsApplication
    def authService

    def getLastViewForTask(Task taskInstance) {

        def c = ViewedTask.createCriteria()
        def viewedTasks = c.list {
            eq("task", taskInstance)
            maxResults(1)
            order("dateCreated", "desc")
        }
        return viewedTasks ? viewedTasks[0] : null
    }

    public boolean isTaskLockedForUser(Task taskInstance, String userId) {
        def lastView = getLastViewForTask(taskInstance)
        def currentUser = authService.username()

        if (lastView) {
            log.debug "userId = " + currentUser + " || prevUserId = " + lastView.userId + " || prevLastView = " + lastView.lastView
            def millisecondsSinceLastView = System.currentTimeMillis() - lastView.lastView
            if (lastView.userId != currentUser && millisecondsSinceLastView < grailsApplication.config.viewedTask.timeout) {
                return true
            }
        }
        return false
    }

    def auditTaskViewing(Task taskInstance, String userId) {
        log.debug "Audit service: " + taskInstance.id

        def lastViewMillis = System.currentTimeMillis()
        def viewedTask = new ViewedTask(task: taskInstance, numberOfViews: 1, lastUpdated: new Date(), userId: userId, lastView: lastViewMillis)
        viewedTask.save(flush: true, failOnError: true)
        // Also keep track of the last view on the task directly. This makes it much easier when
        // selecting the next task for a user.
        taskInstance.lastViewed = lastViewMillis
        taskInstance.lastViewedBy = userId

        taskInstance.addToViewedTasks(viewedTask)
    }
}
