package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import org.apache.commons.lang.StringUtils

class TranscribeController {

    private static final String HEADER_PRAGMA = "Pragma";
    private static final String HEADER_EXPIRES = "Expires";
    private static final String HEADER_CACHE_CONTROL = "Cache-Control";

    def fieldSyncService
    def auditService
    def taskService
    def userService
    def logService
    def multimediaService
    def groovyPageRenderer
    def projectService

    static allowedMethods = [saveTranscription: "POST"]

    def index() {
        if (params.id) {
            log.debug("index redirect to showNextFromProject: " + params.id)
            redirect(action: "showNextFromProject", id: params.id)
        } else {
            flash.message = "Something unexpected happened. Try pressing the back button to return to the previous task and trying again."
            redirect(uri:"/")
        }

    }

    def task() {

        Stopwatch sw = Stopwatch.createStarted()

        def taskInstance = Task.get(params.int('id'))
        def currentUserId = userService.currentUserId
        userService.registerCurrentUser()

        if (taskInstance) {

            boolean isLockedByOtherUser = auditService.isTaskLockedForTranscription(taskInstance, currentUserId)

            def isAdmin = (userService.isAdmin() || userService.isInstitutionAdmin(taskInstance.project.institution))
            if (isLockedByOtherUser && !isAdmin) {
                def lastView = auditService.getLastViewForTask(taskInstance)
                // task is already being viewed by another user (with timeout period)
                log.debug("Task ${taskInstance.id} is currently locked by ${lastView.userId}. Another task will be allocated")
                flash.message  = "The requested task (id: " + taskInstance.id + ") is being viewed/edited by another user. You have been allocated a new task"
                // redirect to another task
                redirect(action: "showNextFromProject", id: taskInstance.project.id, params: [prevId: taskInstance.id, prevUserId: lastView?.userId])
                return
            } else {
                if (isLockedByOtherUser) {
                    flash.message = "This task is currently locked by another user. Because you are an admin you are able to work on this task, but only do so if you are confident that no-one else is working on this task as well, as data will be lost if two people save the same task!"
                }
                // go ahead with this task
                auditService.auditTaskViewing(taskInstance, currentUserId)
            }

            def project = Project.findById(taskInstance.project.id)
            def isReadonly = false

            def isValidator = userService.isValidator(project)
            log.debug(currentUserId + " has role: ADMIN = " + isAdmin + " &&  VALIDATOR = " + isValidator)
            if (taskInstance.isFullyTranscribed && !taskInstance.hasBeenTranscribedByUser(currentUserId) && !isAdmin) {
                isReadonly = "readonly"
            }

            // Disable browser caching of this page, to force it to reload from server always
            // This, in turn, ensures that there is always an active http session when the page
            // is loaded and that all the page JS is run when the back button is clicked.
            // If this is not done and the back button is used to return to the page, the
            // JS on the page is not run and there may be no active session when the form is
            // submitted.  There is code to detect this condition and restore data from
            // the web brower's local storage but it may not work correctly with all templates.
            response.setHeader(HEADER_PRAGMA, "no-cache");
            response.setDateHeader(HEADER_EXPIRES, 1L);
            response.setHeader(HEADER_CACHE_CONTROL, "no-cache");
            response.addHeader(HEADER_CACHE_CONTROL, "no-store");

            //retrieve the existing values
            Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance, currentUserId)
            def adjacentTasks = taskService.getAdjacentTasksBySequence(taskInstance)
            def model = [
                    taskInstance: taskInstance,
                    recordValues: recordValues,
                    isReadonly: isReadonly,
                    template: project.template,
                    nextTask: adjacentTasks.next,
                    prevTask: adjacentTasks.prev,
                    sequenceNumber: adjacentTasks.sequenceNumber,
                    complete: params.complete,
                    thumbnail: multimediaService.getImageThumbnailUrl(taskInstance.multimedia.first(), true)
            ]
            log.debug('task before render: {}', sw)
            render(view: 'templateViews/' + project.template.viewName, model: model)
        } else {
            redirect(view: 'list', controller: "task")
        }
    }

    def showNextAction() {
        log.debug("rendering view: nextAction")
        def taskInstance = Task.get(params.id)
        render(view: 'nextAction', model: [id: params.id, taskInstance: taskInstance, userId: userService.currentUserId])
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
     * done in the form.
     */
    def save() {
        commonSave(params, true)
    }

    /**
     * Sync fields
     */
    def savePartial() {
        commonSave(params, false)
    }

    /**
     * CommonSave (cannot be used for validator's save fields. For multi transcriptions task, validators don't have their own transcription record, except for validator's fields
     */
    private def commonSave(params, markTranscribed) {
        def currentUser = userService.currentUserId

        if (!params.id && params.failoverTaskId) {
            redirect(action:'task', id: params.failoverTaskId)
            return
        }

        if (currentUser != null) {
            def taskInstance = Task.get(params.id)

            Transcription transcription = taskInstance.findUserTranscription(currentUser)
            if (!transcription) {
                // try to reuse existing transcription which could have been reset
                if (taskInstance.project.requiredNumberOfTranscriptions == 1) {
                    transcription = taskInstance.transcriptions[0]
                }
                if (!transcription) {
                    transcription = taskInstance.addTranscription()
                }
            }

            def seconds = params.getInt('timeTaken', null)
            if (seconds) {
                taskInstance.timeToTranscribe = (taskInstance.timeToTranscribe ?: 0) + seconds
                transcription.recordTranscriptionTime(seconds)
            }
            def skipNextAction = params.getBoolean('skipNextAction', false)
            WebUtils.cleanRecordValues(params.recordValues)
            fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, markTranscribed, false, null, fieldSyncService.truncateFieldsForProject(taskInstance.project), request.remoteAddr, transcription)
            if (!taskInstance.hasErrors()) {
                updatePicklists(taskInstance)
                if (skipNextAction) redirect(action: 'showNextFromProject', id: taskInstance.project.id, params: [prevId: taskInstance.id, prevUserId: currentUser, complete: params.id])
                else redirect(action: 'showNextAction', id: params.id)
            }
            else {
                def msg = "Task save ${markTranscribed ? '' : 'partial '}failed: " + taskInstance.hasErrors()
                log.error(msg)
                flash.message = msg
                redirect(action:'task', id: params.id)
                //render(view: 'task', model: [taskInstance: taskInstance, recordValues: params.recordValues])
            }
        } else {
            redirect(view: '../index')
        }
    }

    /**
     * Show the next task for the supplied project.
     */
    def showNextFromProject() {
        def currentUser = userService.currentUserId
        def project = Project.get(params.id)

        if (project == null) {
            log.error("Project not found for id: " + params.id)
            redirect(view: '/index')
        }

        log.debug("project id = " + params.id + " || msg = " + params.msg + " || prevInt = " + params.prevId)

        if (params.msg) {
            flash.message = params.msg
        }
        def previousId = params.long('prevId',-1)
        def prevUserId = params.prevUserId?:-1

        // If Skipped, remove viewed task flag to prevent it getting locked.
        if (params.boolean('skip', false)) {
            log.debug("Skipped task, remove viewed task flag to prevent locking.")
            // clear last viewed.
            if (previousId > -1) {
                taskService.resetTaskView(previousId, currentUser)
            }
        }

        def taskInstance = taskService.getNextTask(currentUser, project, previousId)

        //retrieve the details of the template
//        if (taskInstance && taskInstance.id == previousId && currentUser != prevUserId) {
//            log.debug "1."
//            render(view: 'noTasks', model: [complete: params.complete])
//        } else if (taskInstance) {
//            log.debug "2."
//            def redirectParams = [:]
//            if (params.complete) {
//                redirectParams.complete = params.complete
//            }
//            redirect(action: 'task', id: taskInstance.id, params: redirectParams)
//        } else {
//            log.debug "4."
//            render(view: 'noTasks', model: [complete: params.complete])
//        }

        // Issue #371 - Completion notification
        // Refactored the above; flipped the logic:
        // * If a task exists that is different to the previous task, display task
        // * Else, check if completed. If so, send email notification, then render no tasks page.
        if (taskInstance && taskInstance.id != previousId) {
            log.debug "Found task: ${taskInstance}"
            def redirectParams = [:]
            if (params.complete) {
                redirectParams.complete = params.complete
            }
            redirect(action: 'task', id: taskInstance.id, params: redirectParams)
        } else {
            log.debug("No available tasks were found.")
            if (isComplete(project)) {
                log.info("Project was completed; Sending project completion notification")
                def message = groovyPageRenderer.render(view: '/project/projectCompleteNotification', model: [projectName: project.name])
                projectService.emailNotification(project, message, ProjectService.NOTIFICATION_TYPE_COMPLETION)
            }
            render(view: 'noTasks', model: [complete: params.complete])
        }
    }

    /**
     * Checks to see if the Project has been completed. A project is complete when there is at least one task and the
     * number of tasks equals the number of tasks transcribed.
     * @param projectInstance the instance of the project to check.
     * @return true if all tasks have been trascribed, false if not.
     */
    private boolean isComplete(Project projectInstance) {
        log.debug("Checking for project completion.")
        def taskCount = Task.countByProject(projectInstance)
        def tasksTranscribed = Task.countByProjectAndIsFullyTranscribed(projectInstance, true)
        log.debug("Task count: [${taskCount}], Tasks transcribed: [${tasksTranscribed}]")
        return (taskCount > 0 && taskCount == tasksTranscribed)
    }

    def geolocationToolFragment() {
    }

    def imageViewerFragment() {
        def multimedia = Multimedia.get(params.int("multimediaId"))
        def height = params.height?.toInteger() ?: 400
        def rotate = params.int("rotate") ?: 0
        def hideControls = params.boolean("hideControls") ?: false
        def hideShowInOtherWindow = params.boolean("hideShowInOtherWindow") ?: false
        def hidePinImage = params.boolean("hidePinImage") ?: false
        [multimedia: multimedia, height: height, rotate: rotate, hideControls: hideControls, hideShowInOtherWindow: hideShowInOtherWindow, hidePinImage: hidePinImage]
    }

    def taskLockTimeoutFragment() {
        def taskInstance = Task.get(params.int("taskId"))
        def validator = params.boolean("validator")
        [taskInstance: taskInstance, isValidator: validator]
    }

    def discard() {
        def taskInstance = Task.get(params.id)
        if (!taskInstance) {
            respond status: 404
            return
        }

        if (taskInstance.lastViewedBy != userService.currentUserId) {
            respond status: 403
            return
        }
        // clear last viewed.
        taskInstance.lastViewedBy = null
        taskInstance.lastViewed = null
        redirect controller: 'project', action: 'index', id: taskInstance.project.id
    }
}