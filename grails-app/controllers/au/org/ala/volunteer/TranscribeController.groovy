package au.org.ala.volunteer

//import com.google.common.base.Stopwatch
import grails.converters.JSON
import grails.gorm.transactions.Transactional
import org.apache.commons.lang.StringUtils

class TranscribeController {

    private static final String HEADER_PRAGMA = "Pragma"
    private static final String HEADER_EXPIRES = "Expires"
    private static final String HEADER_CACHE_CONTROL = "Cache-Control"

    private static final int SAVE_TYPE_BACKGROUND = 1
    private static final int SAVE_TYPE_PARTIAL = 2
    private static final int SAVE_TYPE_SUBMIT = 3

    def fieldSyncService
    def auditService
    def taskService
    def userService
    def multimediaService
    def groovyPageRenderer
    def projectService

    static allowedMethods = [saveTranscription: "POST"]

    def index() {
        if (params.id) {
            log.debug("index redirect to showNextFromProject: " + params.long('id'))
            redirect(action: "showNextFromProject", id: params.id, params: [mode: params.mode ?: ''])
        } else {
            flash.message = "Something unexpected happened. Try pressing the back button to return to the previous task and trying again."
            redirect(uri:"/")
        }

    }

    @Transactional
    def task() {
//        Stopwatch sw = Stopwatch.createStarted()

        def task = Task.get(params.int('id'))
        def currentUserId = userService.currentUserId
        userService.registerCurrentUser()

        if (task) {

            boolean isLockedByOtherUser = auditService.isTaskLockedForTranscription(task, currentUserId)
            log.debug("Checking if task ${task.id} is currently locked: [${isLockedByOtherUser}]")

            def isAdmin = (userService.isAdmin() || userService.isInstitutionAdmin(task.project.institution))
            if (isLockedByOtherUser && !isAdmin) {
                def lastView = auditService.getLastViewForTask(task)
                // task is already being viewed by another user (with timeout period)
                log.debug("Task ${task.id} is currently locked by ${lastView.userId}. Another task will be allocated")
                flash.message  = "The requested task (id: " + task.id + ") is being viewed/edited by another user. You have been allocated a new task"
                // redirect to another task
                redirect(action: "showNextFromProject", id: task.project.id, params: [prevId: task.id, prevUserId: lastView?.userId, mode: params.mode ?: ''])
                return
            } else {
                if (isLockedByOtherUser) {
                    flash.message = "This task is currently locked by another user. Because you are an admin you are able to work on this task, but only do so if you are confident that no-one else is working on this task as well, as data will be lost if two people save the same task!"
                }
                // go ahead with this task
                auditService.auditTaskViewing(task, currentUserId)
            }

            def project = Project.findById(task.project.id)
            def isReadonly = false

            def isValidator = userService.isValidator(project)
            log.debug(currentUserId + " has role: ADMIN = " + isAdmin + " &&  VALIDATOR = " + isValidator)
            if (task.isFullyTranscribed && !task.hasBeenTranscribedByUser(currentUserId) && !isAdmin) {
                isReadonly = "readonly"
            }

            log.debug("Loading task for transcription - project: [${project.id}], task: [${task.id}], user: [${currentUserId}]")

            // Disable browser caching of this page, to force it to reload from server always
            // This, in turn, ensures that there is always an active http session when the page
            // is loaded and that all the page JS is run when the back button is clicked.
            // If this is not done and the back button is used to return to the page, the
            // JS on the page is not run and there may be no active session when the form is
            // submitted.  There is code to detect this condition and restore data from
            // the web brower's local storage but it may not work correctly with all templates.
            response.setHeader(HEADER_PRAGMA, "no-cache")
            response.setDateHeader(HEADER_EXPIRES, 1L)
            response.setHeader(HEADER_CACHE_CONTROL, "no-cache")
            response.addHeader(HEADER_CACHE_CONTROL, "no-store")

            // Background saving of tasks for specimens and fieldnotes.
            boolean enableBackgroundSave = (task.project.projectType.name == ProjectType.PROJECT_TYPE_FIELDNOTES ||
                    task.project.projectType.name == ProjectType.PROJECT_TYPE_SPECIMEN)

            //retrieve the existing values
            Map recordValues = fieldSyncService.retrieveFieldsForTask(task, currentUserId)
            def adjacentTasks = taskService.getAdjacentTasksBySequence(task)
            def model = [
                    taskInstance: task,
                    recordValues: recordValues,
                    isReadonly: isReadonly,
                    template: project.template,
                    nextTask: adjacentTasks.next,
                    prevTask: adjacentTasks.prev,
                    sequenceNumber: adjacentTasks.sequenceNumber,
                    complete: params.complete,
                    thumbnail: multimediaService.getImageThumbnailUrl(task.multimedia.first(), true),
                    pageController: 'transcribe',
                    pageAction: 'task',
                    mode: params.mode ?: '',
                    enableBackgroundSave: enableBackgroundSave
            ]
            //log.debug('task before render: {}', sw)
            render(view: 'templateViews/' + project.template.viewName, model: model)
        } else {
            redirect(view: 'list', controller: "task")
        }
    }

    def showNextAction() {
        log.debug("Rendering view: nextAction")
        def taskInstance = Task.get(params.id)
        render(view: 'nextAction', model: [id: params.id, taskInstance: taskInstance, userId: userService.currentUserId, mode: params.mode ?: ''])
    }

    /**
     * Save the values of selected fields to their picklists, if the value does not already exist...
     */
    @Transactional
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
        commonSave(params, true, SAVE_TYPE_SUBMIT)
    }

    /**
     * Sync fields
     */
    def savePartial() {
        commonSave(params, false, SAVE_TYPE_PARTIAL)
    }

    /**
     * Sync fields but return a json response (with no redirect) for AJAX calls.
     * @return
     */
    def backgroundSave() {
        commonSave(params, false, SAVE_TYPE_BACKGROUND)
    }

    /**
     * To be called via AJAX to initialise background saving.
     * This needs to happen so that we can tell the difference between a new transcription and one that was closed
     * before saving (and returning to the transcription).
     * @return JSON response success or failure.
     */
    def initBackgroundSave() {
        def currentUser = userService.currentUserId

        if (!params.id) {
            log.error("Attempting to save transcription, no task ID was found. Returning error.")
            render([success: false, message: "Unable to save task with missing ID.", status: 400] as JSON)
            return
        }

        if (currentUser != null) {
            def task = Task.get(params.long('id'))

            Transcription transcription = task.findUserTranscription(currentUser)
            if (!transcription) {
                // try to reuse existing transcription which could have been reset
                if (task.project.requiredNumberOfTranscriptions == 1) {
                    transcription = task.transcriptions[0]
                }
            }

            render([success: true, timerInitValue: (transcription?.timeToTranscribe ?: 0)] as JSON)
            return
        }

        render([sucess: true, timeToTranscribe: 0] as JSON)
    }

    /**
     * CommonSave (cannot be used for validator's save fields. For multi transcriptions task, validators don't have
     * their own transcription record, except for validator's fields
     */
    private def commonSave(params, markTranscribed, int saveType) {
        def currentUser = userService.currentUserId
        def currentUserObj = userService.getCurrentUser()
        //log.debug("Params: ${params}")

        if (!params.id && params.failoverTaskId) {
            log.error("Attempting to save transcription, no task ID was found. Returning error.")
            if (saveType == SAVE_TYPE_BACKGROUND) {
                render([success: false, message: "Unable to save task with missing ID.", status: 400] as JSON)
            } else {
                redirect(action:'task', id: params.failoverTaskId, params: [mode: params.mode ?: ''])
            }
            return
        }

        if (currentUser != null) {
            log.debug("${(saveType == 1 ? "Auto-saving" : "Saving")} transcription for user: [${currentUser}]")
            def taskInstance = Task.get(params.long('id'))

            // Check if the user has actually viewed this task (remote transcription spam protection)
            def currentViews = taskInstance.viewedTasks.findAll {view ->
                return (view.userId == currentUser)
            }
            if (!currentViews) {
                def msg = "Task save ${markTranscribed ? '' : 'partial '}failed: "
                log.error(msg + "User ${currentUserObj.displayName} (${currentUserObj.id}) attempted to save a transcription not assigned to them.")
                if (saveType == SAVE_TYPE_BACKGROUND) {
                    render([success: false,
                            message: "User attempted to save a transcription not assigned to them. " +
                                    "User: ${currentUserObj.displayName} (${currentUserObj.id})", status: 400] as JSON)
                } else {
                    flash.message = msg + "You attempted to save a transcription for a task not assigned to you."
                    redirect(action:'task', id: params.id, params: [mode: params.mode ?: ''])
                }
                return
            } else {
                // If Background save, update view time
                if (saveType == SAVE_TYPE_BACKGROUND) {
                    def actualView
                    if (currentViews.size() > 1) {
                        def sortedViews = currentViews.sort { a, b ->
                            a.lastView <=> b.lastView
                        }.reverse()
                        actualView = sortedViews?.first()
                    } else {
                        actualView = currentViews.first()
                    }

                    try {
                        if (actualView) {
                            taskService.updateLastView(actualView, System.currentTimeMillis())
                        }
                    } catch (Exception e) {
                        log.error("Error updating last view during auto save of transcription. Exception message is: ${e.getMessage()}", e)
                    }
                }
            }

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

            // If background or saving partial, only update the transcription record.
            // If Submitting the transcription for validation, add the timer value to the task.
            def seconds = params.getInt('timeTaken', null)
            if (seconds) {
                switch(saveType) {
                    case SAVE_TYPE_BACKGROUND:
                    case SAVE_TYPE_PARTIAL:
                        transcription.timeToTranscribe = seconds
                        break
                    case SAVE_TYPE_SUBMIT:
                        transcription.timeToTranscribe = seconds
                        taskInstance.timeToTranscribe = (taskInstance.timeToTranscribe ?: 0) + seconds
                        break
                }
            }

            def skipNextAction = params.getBoolean('skipNextAction', false)
            WebUtils.cleanRecordValues(params.recordValues as Map)

            fieldSyncService.syncFields(taskInstance, params.recordValues as Map, currentUser, markTranscribed,
                    false, null, fieldSyncService.truncateFieldsForProject(taskInstance.project),
                    request.remoteAddr, transcription)

            if (!taskInstance.hasErrors()) {
                updatePicklists(taskInstance)
                if (skipNextAction) {
                    if (saveType == SAVE_TYPE_BACKGROUND) {
                        // Flow should not reach this...
                        render([success: true] as JSON)
                    } else {
                        log.debug("Save successful, skip to next task.")
                        redirect(action: 'showNextFromProject', id: taskInstance.project.id,
                                params: [prevId: taskInstance.id, prevUserId: currentUser, complete: params.id, mode: params.mode ?: ''])
                    }
                } else {
                    if (saveType == SAVE_TYPE_BACKGROUND) {
                        log.debug("Save successful.")
                        render([success: true] as JSON)
                    } else {
                        log.debug("Save successful. Redirecting to show next action view")
                        redirect(action: 'showNextAction', id: params.id, params: [mode: params.mode ?: ''])
                    }
                }
            } else {
                def msg = "Task save ${markTranscribed ? '' : 'partial '}failed: " + taskInstance.hasErrors()
                log.error(msg)
                if (saveType == SAVE_TYPE_BACKGROUND) {
                    render([success: false, message: msg, status: 400] as JSON)
                } else {
                    flash.message = msg
                    redirect(action:'task', id: params.id, params: [mode: params.mode ?: ''])
                }
            }
        } else {
            if (saveType == SAVE_TYPE_BACKGROUND) {
                render([success: false, status: 401] as JSON)
            } else {
                redirect(view: '../index')
            }
        }
    }

    /**
     * Show the next task for the supplied project.
     */
    def showNextFromProject() {
        def currentUser = userService.currentUserId
        def project = Project.get(params.long('id'))

        if (project == null) {
            log.error("Project not found for id: ${params.id}")
            redirect(view: '/index')
            return
        }

        log.debug("Finding next task for user [${currentUser}] from project: [${project.id}], previous task ID: [${params.prevId}], msg: [${params.msg}]")

        if (params.msg) {
            flash.message = params.msg
        }
        def previousId = params.long('prevId',-1)
        // def prevUserId = params.prevUserId?:-1

        // If Skipped, remove viewed task flag to prevent it getting locked.
        if (params.boolean('skip', false)) {
            log.debug("Skipped task, remove viewed task flag to prevent locking.")
            // clear last viewed.
            if (previousId > -1) {
                taskService.resetTaskView(previousId, currentUser)
            }
        }

        def taskInstance = taskService.getNextTask(currentUser, project, previousId)

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
        log.debug("Loading image for task: ${multimedia}")
        [multimedia: multimedia, height: height, rotate: rotate, hideControls: hideControls, hideShowInOtherWindow: hideShowInOtherWindow, hidePinImage: hidePinImage]
    }

    def taskLockTimeoutFragment() {
        def taskInstance = Task.get(params.int("taskId"))
        def validator = params.boolean("validator")
        [taskInstance: taskInstance, isValidator: validator]
    }

    def taskIdleFragment() {
        def task = Task.get(params.int('taskId'))
        def validator = params.boolean('validator')
        //log.debug("Picking up validator parameter: [${params.validator}] - [${params.boolean('validator')}]")
        log.debug("Displaying idle warning to user for ${task.toString()}")
        [taskInstance: task, isValidator: validator]
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