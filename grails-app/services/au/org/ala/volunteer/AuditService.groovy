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

//        if (taskInstance.viewedTasks) {
//            //update the viewed task
//            taskInstance.viewedTasks.each { viewedTask ->
//                //lastViewedTask = viewedTask.clone()
//                viewedTask.numberOfViews = viewedTask.numberOfViews + 1
//                viewedTask.lastUpdated = new Date()
//                viewedTask.userId = userId
//                viewedTask.lastView = System.currentTimeMillis()
//                try {
//                    viewedTask.save(flush: true, failOnError: true)
//                } catch (ValidationException e) {
//                    log.error("Error saving viewedTask: " + e.message, e)
//                }
//            }
//        } else {
//            //store the viewed record event
//            def viewedTask = new ViewedTask()
//            viewedTask.userId = userId
//            viewedTask.task = taskInstance
//            viewedTask.lastUpdated = new Date()
//            viewedTask.lastView = System.currentTimeMillis()
//            viewedTask.numberOfViews = 1
//            //lastViewedTask = viewedTask
//            try {
//                viewedTask.save(flush: true, failOnError: true)
//            } catch (ValidationException e) {
//                log.error("Error saving viewedTask: " + e.message, e)
//            }
//        }

    }
}
