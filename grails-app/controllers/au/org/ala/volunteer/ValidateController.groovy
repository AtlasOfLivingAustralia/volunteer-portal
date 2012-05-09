package au.org.ala.volunteer

class ValidateController {

    def fieldSyncService
    def auditService
    def taskService
    def authService
    def userService
    def ROLE_ADMIN = grailsApplication.config.auth.admin_role
    def ROLE_VALIDATOR = grailsApplication.config.auth.validator_role
    def LAST_VIEW_TIMEOUT_MINUTES = grailsApplication.config.viewedTask.timeout

    def index = {
        redirect(action: "showNextTaskForValidation")
    }

    def task = {
        def taskInstance = Task.get(params.id)
        def currentUser = authService.username()
        userService.registerCurrentUser()

        if (taskInstance) {
            //record the viewing of the task
            //auditService.auditTaskViewing(taskInstance, currentUser)
            // determine if task has been recently viewed by another user
            def prevUserId = null
            def prevLastView = 0
            taskInstance.viewedTasks.each { viewedTask ->
                // viewedTasks is a set so order is not guaranteed
                if (viewedTask.lastView > prevLastView) {
                    // store the most recent viewedTask
                    prevUserId = viewedTask.userId
                    prevLastView = viewedTask.lastView
                }
            }

            log.debug "userId = " + currentUser + " || prevUserId = " + prevUserId + " || prevLastView = " + prevLastView
            def millisecondsSinceLastView = (prevLastView > 0) ? System.currentTimeMillis() - prevLastView : null

            if (prevUserId != currentUser && millisecondsSinceLastView && millisecondsSinceLastView < LAST_VIEW_TIMEOUT_MINUTES) {
                // task is already being viewed by another user (with timeout period)
                log.warn "Task was recently viewed: " + (millisecondsSinceLastView / (60 * 1000)) + " min ago."
                def msg = "The requested task (id: " + taskInstance.id + ") is being viewed/edited by another user. " +
                        "You have been allocated a new task"
                // redirect to another task
                redirect(action: "showNextFromProject", id: taskInstance.project.id,
                        params: [msg: msg, prevId: taskInstance.id, prevUserId: prevUserId])
            } else {
                // go ahead with this task
                auditService.auditTaskViewing(taskInstance, currentUser)
            }
            def project = Project.findById(taskInstance.project.id)
            def template = Template.findById(project.template.id)
            def isReadonly
            println(currentUser + " has role: ADMIN = " + authService.userInRole(ROLE_ADMIN) + " &&  VALIDATOR = " + authService.userInRole(ROLE_VALIDATOR))

            if (taskInstance.fullyTranscribedBy && taskInstance.fullyTranscribedBy != currentUser && !(authService.userInRole(ROLE_ADMIN) || authService.userInRole(ROLE_VALIDATOR))) {
                isReadonly = "readonly"
            }

            //retrieve the existing values
            Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)
            //log.info("recordValues = " + recordValues)
            render(view: '../transcribe/' + template.viewName, model: [taskInstance: taskInstance, recordValues: recordValues,
                    isReadonly: isReadonly, template: template, validator: true])
        } else {
            redirect(view: 'list', controller: "task")
        }
    }

    /**
     * Mark a task as validated, hence removing it from the list of tasks to be validated.
     */
    def validate = {
        def currentUser = authService.username()
        if (currentUser != null) {
            def taskInstance = Task.get(params.id)
            WebUtils.cleanRecordValues(params.recordValues)
            fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, false, true, true)
            //update the count for validated tasks for the user who transcribed
            userService.updateUserValidatedCount(taskInstance.fullyTranscribedBy)
            redirect(action: 'showNextFromProject', id:taskInstance.project.id)
        } else {
            redirect(view: '../index')
        }
    }

    /**
     * To do determin actions if the validator chooses not to validate
     */
    def dontValidate = {
        def currentUser = authService.username()
        if (currentUser != null) {
            def taskInstance = Task.get(params.id)
            WebUtils.cleanRecordValues(params.recordValues)
            fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, false, true, false)
            //update the count for validated tasks for the user who transcribed
            userService.updateUserValidatedCount(taskInstance.fullyTranscribedBy)
            redirect(action: 'showNextFromProject', id:taskInstance.project.id)
        } else {
            redirect(view: '../index')
        }
    }

    def skip = {
        def taskInstance = Task.get(params.id)
        if (taskInstance != null) {
            redirect(action: 'showNextFromProject', id:taskInstance.project.id)
        } else {
            redirect(action: 'showNextFromProject')
        }
    }

    def showNextTaskForValidation = {
        //need to check the user has sufficient privileges at a project level
        def taskInstance = taskService.getNextTaskForValidation()
        if (taskInstance != null) {
            redirect(action: 'task', id: taskInstance.id)
        } else {
            render(view: 'noTasks')
        }
    }

    def showNextFromProject = {
        def currentUser = authService.username()
        def project = Project.get(params.id)
        log.debug("project id = " + params.id + " || msg = " + params.msg + " || prevInt = " + params.prevId)
        flash.message = params.msg
        def previousId = params.prevId?:-1
        def prevUserId = params.prevUserId?:-1

        def taskInstance = taskService.getNextTaskForValidationForProject(currentUser, project)

        //retrieve the details of the template
        if (taskInstance && taskInstance.id == previousId.toInteger() && currentUser != prevUserId) {
            log.debug "1."
            render(view: 'noTasks')
        } else if (taskInstance && project) {
            log.debug "2."
            redirect(action: 'task', id: taskInstance.id)
        } else if (!project) {
            log.error("Project not found for id: " + params.id)
            redirect(view: '/index')
        } else {
            log.debug "4."
            render(view: 'noTasks')
        }
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        def tasks = Task.findAllByFullyTranscribedByIsNotNull(params)
        def taskInstanceTotal = Task.countByFullyTranscribedByIsNotNull()
        render(view: '../task/list', model: [tasks: tasks, taskInstanceTotal: taskInstanceTotal])
    }

    def listForProject = {
        def projectInstance = Task.get(params.id)
        def tasks = Task.executeQuery(""""select t from Task t
         where t.project = :project and t.fullyTranscribedBy is not null""",
                project: projectInstance)
        render(view: '../task/list', model: [tasks: tasks, project: projectInstance])
    }
}
