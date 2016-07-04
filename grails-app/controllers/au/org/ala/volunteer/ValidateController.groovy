package au.org.ala.volunteer

class ValidateController {

    def fieldSyncService
    def auditService
    def taskService
    def userService
    def logService
    def grailsApplication

    def task = {
        def taskInstance = Task.get(params.id)
        def currentUser = userService.currentUserId
        userService.registerCurrentUser()

        if (taskInstance) {

            if (auditService.isTaskLockedForUser(taskInstance, currentUser)) {
                def lastView = auditService.getLastViewForTask(taskInstance)
                // task is already being viewed by another user (with timeout period)
                log.debug("Task ${taskInstance.id} is currently locked by ${lastView.userId}. Returning to admin list.")
                def msg = "The requested task (id: " + taskInstance.id + ") is being viewed/edited/validated by another user."
                flash.message = msg
                // redirect to another task
                redirect(controller: "task", action:  "projectAdmin", id: taskInstance.project.id, params: params + [projectId:taskInstance.project.id])
                return
            } else {
                // go ahead with this task
                auditService.auditTaskViewing(taskInstance, currentUser)
            }

            def isReadonly = false

            def project = Project.findById(taskInstance.project.id)
            def template = Template.findById(project.template.id)

            def isValidator = userService.isValidator(project)
            log.info(currentUser + " has role: ADMIN = " + userService.isAdmin() + " &&  VALIDATOR = " + isValidator)

            if (taskInstance.fullyTranscribedBy && taskInstance.fullyTranscribedBy != currentUser && !(userService.isAdmin() || isValidator)) {
                isReadonly = "readonly"
            } else {
                // check that the validator is not the transcriber...Admins can, though!
                if ((currentUser == taskInstance.fullyTranscribedBy)) {
                    if (userService.isAdmin()) {
                        flash.message = "Normally you cannot validate your own tasks, but you have the ADMIN role, so it is allowed in this case"
                    } else {
                        flash.message = "This task is read-only. You cannot validate your own tasks!"
                        isReadonly = "readonly"
                    }
                }
            }

            Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)
            def adjacentTasks = taskService.getAdjacentTasksBySequence(taskInstance)
            def imageMetaData = taskService.getImageMetaData(taskInstance)
            render(view: '../transcribe/templateViews/' + template.viewName, model: [taskInstance: taskInstance, recordValues: recordValues, isReadonly: isReadonly, nextTask: adjacentTasks.next, prevTask: adjacentTasks.prev, sequenceNumber: adjacentTasks.sequenceNumber, template: template, validator: true, imageMetaData: imageMetaData])
        } else {
            redirect(view: 'list', controller: "task")
        }
    }

    /**
     * Mark a task as validated, hence removing it from the list of tasks to be validated.
     */
    def validate = {
        def currentUser = userService.currentUserId

        if (!params.id && params.failoverTaskId) {
            redirect(action:'task', id: params.failoverTaskId)
            return
        }

        if (currentUser != null) {
            def taskInstance = Task.get(params.id)
            WebUtils.cleanRecordValues(params.recordValues)
            fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, false, true, true, fieldSyncService.truncateFieldsForProject(taskInstance.project), request.remoteAddr)
            redirect(controller: 'task', action: 'projectAdmin', id:taskInstance.project.id, params:[lastTaskId: taskInstance.id])
        } else {
            redirect(view: '../index')
        }
    }

    /**
     * To do determine actions if the validator chooses not to validate
     */
    def dontValidate = {
        def currentUser = userService.currentUserId

        if (!params.id && params.failoverTaskId) {
            redirect(action:'task', id: params.failoverTaskId)
            return
        }

        if (currentUser != null) {
            def taskInstance = Task.get(params.id)
            WebUtils.cleanRecordValues(params.recordValues)
            fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, false, true, false, fieldSyncService.truncateFieldsForProject(taskInstance.project), request.remoteAddr)
            redirect(controller: 'task', action: 'projectAdmin', id:taskInstance.project.id, params:[lastTaskId: taskInstance.id])
        } else {
            redirect(view: '../index')
        }
    }

    def skip = {
        def taskInstance = Task.get(params.id)
        if (taskInstance != null) {
            redirect(action: 'showNextFromProject', id:taskInstance.project.id)
        } else {
            flash.message = "No task id supplied!"
            redirect(uri:"/")
        }
    }

    def showNextFromProject = {
        def currentUser = userService.currentUserId
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
        def tasks = Task.executeQuery("""select t from Task t
         where t.project = :project and t.fullyTranscribedBy is not null""",
                project: projectInstance)
        render(view: '../task/list', model: [tasks: tasks, project: projectInstance])
    }
}
