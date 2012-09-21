package au.org.ala.volunteer

import org.springframework.validation.Errors
import org.springframework.web.context.request.RequestContextHolder
import org.apache.commons.lang.StringUtils
import javax.imageio.ImageIO
import org.codehaus.groovy.grails.commons.ConfigurationHolder

class TranscribeController {

    def fieldSyncService
    def auditService
    def taskService
    def authService
    def userService
    def logService
    def ROLE_ADMIN = grailsApplication.config.auth.admin_role
    def LAST_VIEW_TIMEOUT_MINUTES = grailsApplication.config.viewedTask.timeout

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

        def taskInstance = Task.get(params.int('id'))
        def currentUser = authService.username()
        userService.registerCurrentUser()

        if (taskInstance) {
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
                log.warn "Task was recently viewed: " + (millisecondsSinceLastView / (60 * 1000)) + " min ago by ${prevUserId}"
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

            def isValidator = userService.isValidator(project)
            logService.log(currentUser + " has role: ADMIN = " + authService.userInRole(ROLE_ADMIN) + " &&  VALIDATOR = " + isValidator)
            if (taskInstance.fullyTranscribedBy && taskInstance.fullyTranscribedBy != currentUser && !(authService.userInRole(ROLE_ADMIN))) {
                isReadonly = "readonly"
            }

            //retrieve the existing values
            Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)

            Task prevTask = null;
            Task nextTask = null;
            Integer sequenceNumber = null

            if (recordValues[0]?.sequenceNumber) {
                sequenceNumber = Integer.parseInt(recordValues[0]?.sequenceNumber);
                // prev task
                prevTask = taskService.findByProjectAndFieldValue(project, "sequenceNumber", (sequenceNumber - 1).toString())
                nextTask = taskService.findByProjectAndFieldValue(project, "sequenceNumber", (sequenceNumber + 1).toString())
            }

            def imageMetaData = [:]

            taskInstance.multimedia.each {
                def path = it.filePath;
                String urlPrefix = ConfigurationHolder.config.images.urlPrefix
                String imagesHome = ConfigurationHolder.config.images.home
                path = imagesHome + '/' + path.substring(urlPrefix.length())  // have to reverse engineer the files location on disk, this info should be part of the Multimedia structure!
                println path
                CodeTimer t = new CodeTimer("Extracting meta data for ${path}")
                def image = ImageIO.read(new File(path))
                def aspectRatio = image.height / image.width
                def smallSizeHeight = 400
                if (image.height > image.width) {
                    def smallWidth = 600 / aspectRatio
                    smallSizeHeight = smallWidth * aspectRatio
                }
                imageMetaData[it.id] = [width: image.width, height: image.height, aspectRatio: aspectRatio, smallSizeHeight: smallSizeHeight]
                t.stop(true)
            }


            render(view: template.viewName, model: [taskInstance: taskInstance, recordValues: recordValues, isReadonly: isReadonly, template: template, nextTask: nextTask, prevTask: prevTask, sequenceNumber: sequenceNumber, imageMetaData: imageMetaData])
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
     * Save the values of selected fields to their picklists, if the value does not already exist...
     */
    def updatePicklists(Task task) {

        // Add the name of the picklist here if it is to be updated with user entered values
        def updateablePicklists = ['recordedBy']

        // Find the template fields used by this tasks template
        def templateFields = TemplateField.findAllByTemplate(task.project.template)

        // Isolate the fields whose names coincide with a picklist, and for which this task has a value
        for (TemplateField tf : templateFields) {
            def f = task.fields.find { it.name == tf.fieldType.name() }
            // The fieldname/picklist name must also be in the list of updateable picklists
            if (f && updateablePicklists.contains(f.name) && StringUtils.isNotEmpty(f.value)) {
                log.debug("Checking picklist ${f.name} for value ${f.value}")
                // Check that the picklist actually exists...
                def picklist = Picklist.findByName(f.name)
                if (picklist) {
                    // And see if it already contains this value
                    def existing = PicklistItem.findByPicklistAndValue(picklist, f.value)
                    if (existing) {
                        log.debug("Will not update picklist: value ${f.value} already exisits in picklist ${picklist.name}.")
                    } else {
                        // Add the new value to the picklist
                        log.debug("Adding new picklist item to picklist '${picklist.name} with value '${f.value}")
                        def newItem = new PicklistItem(picklist: picklist, value: f.value)
                        newItem.save(flush: true)
                    }
                }
            }
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
                updatePicklists(taskInstance)
                redirect(action: 'showNextAction', id: params.id)
            }
            else {
                def msg = "Task save failed: " + taskInstance.hasErrors()
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
                updatePicklists(taskInstance)
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

        if (project == null) {
            log.error("Project not found for id: " + params.id)
            redirect(view: '/index')
        }

        log.debug("project id = " + params.id + " || msg = " + params.msg + " || prevInt = " + params.prevId)
        flash.message = params.msg
        def previousId = params.prevId?:-1
        def prevUserId = params.prevUserId?:-1
        def taskInstance = taskService.getNextTask(currentUser, project)
        //retrieve the details of the template
        if (taskInstance && taskInstance.id == previousId.toInteger() && currentUser != prevUserId) {
            log.debug "1."
            render(view: 'noTasks')
        } else if (taskInstance) {
            log.debug "2."
            redirect(action: 'task', id: taskInstance.id)
        } else {
            log.debug "4."
            render(view: 'noTasks')
        }
    }
}