package au.org.ala.volunteer

import org.springframework.validation.Errors
import org.springframework.web.context.request.RequestContextHolder

class TranscribeController {

    def fieldSyncService
    def auditService
    def taskService
    def authService
    def userService
    def ROLE_ADMIN = grailsApplication.config.auth.admin_role
    def ROLE_VALIDATOR = grailsApplication.config.auth.validator_role

    static allowedMethods = [saveTranscription: "POST"]

    def index = {
        if (params.id) {
            log.debug("index redirect to showNextFromProject: " + params.id)
            redirect(action: "showNextFromProject", id: params.id)
        } else {
            redirect(action: "showNextFromAny", params: params)
        }

    }

    def task = {

        def taskInstance = Task.get(params.id)
        def currentUser = authService.username()
        userService.registerCurrentUser()

        if (taskInstance) {
            //record the viewing of the task
            auditService.auditTaskViewing(taskInstance, currentUser)
            def project = Project.findById(taskInstance.project.id)
            def template = Template.findById(project.template.id)
            def isReadonly
            println(currentUser + " has role: ADMIN = " + authService.userInRole(ROLE_ADMIN) + " &&  VALIDATOR = " + authService.userInRole(ROLE_VALIDATOR))

            if (taskInstance.fullyTranscribedBy && taskInstance.fullyTranscribedBy != currentUser && !(authService.userInRole(ROLE_ADMIN) || authService.userInRole(ROLE_VALIDATOR))) {
                isReadonly = "readonly"
            }

            //retrieve the existing values
            Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)
            log.debug("recordValues = " + recordValues)
            render(view: template.viewName, model: [taskInstance: taskInstance, recordValues: recordValues, isReadonly: isReadonly, template: template])
        } else {
            redirect(view: 'list', controller: "task")
        }
    }

    def showNextAction = {
        log.debug("rendering view: nextAction")
        def taskInstance = Task.get(params.id)
        render(view: 'nextAction', model: [id: params.id, taskInstance: taskInstance, userId: authService.username()])
    }

    /**
     * Retrieve the next un-transcribed record from any project, but supply one I havent seen,
     * or the least recently seen record.
     */
    def showNextFromAny = {
        def projectInstance = Project.get(params.id)
        def currentUser = authService.username()
        //println "current user = "+currentUser
        def taskInstance
        
        if (projectInstance) {
            taskInstance = taskService.getNextTask(currentUser, projectInstance)
            log.info("skip with project id "+ projectInstance.id)
        } else {
            taskInstance = taskService.getNextTask(currentUser)
        }

        //retrieve the details of the template
        if (taskInstance) {
            redirect(action: 'task', id: taskInstance.id)
        } else {
            //TODO retrieve this information from the template
            render(view: 'noTasks')
        }
    }

    /**
     * Sync fields.
     * TODO record validation using the template information. Hoping some data validation
     *
     * done in the form.
     */
    def save = {
        def currentUser = authService.username()
        if (currentUser != null) {
            def taskInstance = Task.get(params.id)
            def project = Project.findById(taskInstance.project.id)
            def template = Template.findById(project.template.id)
            WebUtils.cleanRecordValues(params.recordValues)
            fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, true, false, null)
            if (!taskInstance.hasErrors()) {
                redirect(action: 'showNextAction', id: params.id)
            }
            else {
                def msg = "Task save partial failed: " + taskInstance.hasErrors()
                log.error(msg)
                flash.message = msg
                render(view: template.viewName, model: [taskInstance: taskInstance, recordValues: params.recordValues])
            }
        } else {
            redirect(view: '../index')
        }
    }

    /**
     * Sync fields.
     *
     * TODO handle multiple records per submit.
     */
    def savePartial = {
        def currentUser = authService.username()
        if (currentUser) {
            def taskInstance = Task.get(params.id)
            WebUtils.cleanRecordValues(params.recordValues) // removes strange characters from UTF-8 pages
            fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, false, false, null)
            if (!taskInstance.hasErrors()) {
                redirect(action: 'showNextAction', id: params.id)
            }
            else {
                def msg = "Task save partial failed: " + taskInstance.hasErrors()
                log.error(msg)
                flash.message = msg
                render(view: template.viewName, model: [taskInstance: taskInstance, recordValues: params.recordValues])
            }
        } else {
            redirect(view: '/index')
        }
    }

    def savePartial2 = {
        redirect(action: 'savePartial', id: params.id)
    }

    /**
     * Show the next task for the supplied project.
     */
    def showNextFromProject = {
        def currentUser = authService.username()
        def project = Project.get(params.id)
        log.debug("params.id =" + params.id);
        def taskInstance = taskService.getNextTask(currentUser, project)

        //retrieve the details of the template
        if (taskInstance && project) {
            redirect(action: 'task', id: taskInstance.id)
        } else if (!project) {
            log.error("Project not found for id: " + params.id)
            redirect(view: '/index')
        } else {
            render(view: 'noTasks')
        }
    }
}