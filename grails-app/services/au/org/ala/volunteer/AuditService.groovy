package au.org.ala.volunteer

import grails.validation.ValidationException

class AuditService {

    static transactional = true

    def serviceMethod() {}

    /**
     * Returns the number of tasks in a project that have been viewed
     * at least once
     *
     * @return Map of project id -> count
     */
    Map getProjectTaskViewedCounts() {
        def projectTaskCounts = Task.executeQuery(
                """select t.project.id as projectId, count(t) as taskCount from Task t
                 inner join t.viewedTasks as viewedTasks
                 group by t.project.id""")
        projectTaskCounts.toMap()
    }

    /**
     * Returns the number of times a task has been viewed in a project
     *
     * @return Map of project id -> count
     */
    Map getViewCountPerProject() {
        def projectTaskCounts = Task.executeQuery(
                """select t.project.id as projectId, count(t) as taskCount from Task t
                 inner join t.viewedTasks as viewedTasks
                 group by t.project.id""")
        projectTaskCounts.toMap()
    }

    def auditTaskViewing(Task taskInstance, String userId) {
        log.debug "Audit service: " + taskInstance.id
        if (taskInstance.viewedTasks) {
            //update the viewed task
            taskInstance.viewedTasks.each { viewedTask ->
                //lastViewedTask = viewedTask.clone()
                viewedTask.numberOfViews = viewedTask.numberOfViews + 1
                viewedTask.lastUpdated = new Date()
                viewedTask.userId = userId
                viewedTask.lastView = System.currentTimeMillis()
                try {
                    viewedTask.save(flush: true, failOnError: true)
                } catch (ValidationException e) {
                    log.error("Error saving viewedTask: " + e.message, e)
                }
            }
        } else {
            //store the viewed record event
            def viewedTask = new ViewedTask()
            viewedTask.userId = userId
            viewedTask.task = taskInstance
            viewedTask.lastUpdated = new Date()
            viewedTask.lastView = System.currentTimeMillis()
            viewedTask.numberOfViews = 1
            //lastViewedTask = viewedTask
            try {
                viewedTask.save(flush: true, failOnError: true)
            } catch (ValidationException e) {
                log.error("Error saving viewedTask: " + e.message, e)
            }
        }

    }
}
