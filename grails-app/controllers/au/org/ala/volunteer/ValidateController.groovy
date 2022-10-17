package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.converters.JSON

//import java.util.concurrent.TimeUnit

class ValidateController {

    def fieldSyncService
    def auditService
    def taskService
    def userService
    def multimediaService

    private static final int SAVE_TYPE_BACKGROUND = 1
    private static final int SAVE_TYPE_PROGRESS = 2

    def task() {
        def task = Task.get(params.long('id'))
        def currentUser = userService.currentUserId
        userService.registerCurrentUser()

        if (task) {

            if (auditService.isTaskLockedForValidation(task)) {
                def lastView = auditService.getLastViewForTask(task)
                // task is already being viewed by another user (with timeout period)
                log.debug("Task ${task.id} is currently locked by ${lastView.userId}. Returning to admin list.")
                def msg = "The requested task (id: " + task.id + ") is being viewed/edited/validated by another user."
                flash.message = msg
                // redirect to another task
                redirect(controller: "task", action: "projectAdmin", id: task.project.id, params: params + [projectId: task.project.id])
                return
            } else {
                // go ahead with this task
                auditService.auditTaskViewing(task, currentUser)
            }

            def isReadonly = false

            def project = Project.findById(task.project.id)
            Template template = Template.findById(project.template.id)
            log.debug("Loading task for validation - project: [${project?.id}], task: [${task.id}], user: [${currentUser}]")

            def isValidator = userService.isValidator(project)
            def isAdmin = (userService.isAdmin() || userService.isInstitutionAdmin(project?.institution))
            log.debug("Role check for user: ${currentUser}; Admin: [${isAdmin}], isValidator: [${isValidator}]")

            if (task.isFullyTranscribed && !task.hasBeenTranscribedByUser(currentUser) && !(isAdmin || isValidator)) {
                isReadonly = "readonly"
                log.debug("Transcribed task is being set to read-only.")
            } else {
                // check that the validator is not the transcriber...Admins can, though!
                if (task.hasBeenTranscribedByUser(currentUser)) {
                    if (isAdmin) {
                        flash.message = "Normally you cannot validate your own tasks, but you have the ADMIN role, so it is allowed in this case"
                    } else {
                        flash.message = "This task is read-only. You cannot validate your own tasks!"
                        isReadonly = "readonly"
                        log.debug("Transcribed task is being set to read-only.")
                    }
                }
            }

            Stopwatch sw = Stopwatch.createStarted()
            Map recordValues = fieldSyncService.retrieveValidationFieldsForTask(task)
            sw.stop()

            def adjacentTasks = taskService.getAdjacentTasksBySequence(task)
            def imageMetaData = taskService.getImageMetaData(task)
            def transcribersAnswers = fieldSyncService.retrieveTranscribersFieldsForTask(task)
/*            if (!recordValues && transcribersAnswers && transcribersAnswers.size() > 0) {
                recordValues = transcribersAnswers[0].fields
            }*/

            // Background saving of tasks for specimens and fieldnotes.
            boolean enableBackgroundSave = (task.project.projectType.name == ProjectType.PROJECT_TYPE_FIELDNOTES ||
                    task.project.projectType.name == ProjectType.PROJECT_TYPE_SPECIMEN)

            render(view: '../transcribe/templateViews/' + template.viewName,
                    model: [taskInstance        : task,
                            recordValues        : recordValues,
                            isReadonly          : isReadonly,
                            nextTask            : adjacentTasks.next,
                            prevTask            : adjacentTasks.prev,
                            sequenceNumber      : adjacentTasks.sequenceNumber,
                            template            : template,
                            validator           : true,
                            imageMetaData       : imageMetaData,
                            transcribersAnswers : transcribersAnswers,
                            thumbnail           : multimediaService.getImageThumbnailUrl(task.multimedia.first(), true),
                            pageController      : 'validate',
                            pageAction          : 'task',
                            mode                : params.mode ?: '',
                            enableBackgroundSave: enableBackgroundSave])
        } else {
            redirect(view: 'list', controller: "task")
        }
    }

    def backgroundSave() {
        dontValidate(SAVE_TYPE_BACKGROUND)
    }

    def saveProgress() {
        dontValidate(SAVE_TYPE_PROGRESS)
    }

    /**
     * Mark a task as validated, hence removing it from the list of tasks to be validated.
     */
    def validate() {
        def taskInstance = Task.get(params.long('id'))
        if (!userService.isValidator(taskInstance?.project) || !taskInstance) {
            log.warn("User requesting unauthed url: ${userService.currentUserId}")
            render(view: '/notPermitted')
            return
        }

        def currentUser = userService.currentUserId

        if (!params.id && params.failoverTaskId) {
            redirect(action: 'task', id: params.failoverTaskId, params: [mode: params.mode ?: ''])
            return
        }

        if (currentUser != null) {
            def seconds = params.getInt('timeTaken', null)
            if (seconds) {
                taskInstance.timeToValidate = (taskInstance.timeToValidate ?: 0) + seconds
//                taskInstance.timeToValidate = seconds
            }
            WebUtils.cleanRecordValues(params.recordValues as Map)

            Transcription transcription = null
            if (taskInstance.project.requiredNumberOfTranscriptions == 1) {
                transcription = taskInstance.transcriptions[0]
            }
            fieldSyncService.syncFields(taskInstance, params.recordValues as Map, currentUser, false,
                    true, true, fieldSyncService.truncateFieldsForProject(taskInstance.project),
                    request.remoteAddr, transcription)

            if (taskInstance.hasErrors()) {
                log.warn("Validation of task ${taskInstance.id} produced errors: " + errors)
            }
            redirect(controller: 'task', action: 'projectAdmin', id: taskInstance.project.id, params: [lastTaskId: taskInstance.id, mode: params.mode ?: ''])
        } else {
            redirect(view: '../index')
        }
    }

    /**
     * Formerly to determine actions if the validator chooses not to validate. Now used as a background save function.
     */
    def dontValidate(int saveType) {
        def taskInstance = Task.get(params.long('id'))
        if (!userService.isValidator(taskInstance?.project) || !taskInstance) {
            if (saveType == SAVE_TYPE_BACKGROUND) {
                render([success: false, message: "Not permitted to do that action.", status: 403] as JSON)
            } else {
                render(view: '/notPermitted')
            }

            return
        }

        def currentUser = userService.currentUserId

        if (!params.id && params.failoverTaskId) {
            if (saveType == SAVE_TYPE_BACKGROUND) {
                render([success: false, message: "Unable to save task with missing ID.", status: 400] as JSON)
            } else {
                redirect(action: 'task', id: params.failoverTaskId, params: [mode: params.mode ?: ''])
            }
            return
        }

        if (currentUser != null) {
            log.debug("${(saveType == 1 ? "Auto-saving" : "Saving")} validation of task [${taskInstance.id}] for user: [${currentUser}]")

            def seconds = params.getInt('timeTaken', null)
            if (seconds) {
                taskInstance.timeToValidate = (taskInstance.timeToValidate ?: 0) + seconds
//                taskInstance.timeToValidate = seconds
            }
            WebUtils.cleanRecordValues(params.recordValues as Map)
            Transcription transcription = null
            if (taskInstance.project.requiredNumberOfTranscriptions == 1) {
                transcription = taskInstance.transcriptions[0]
            }
            fieldSyncService.syncFields(taskInstance, params.recordValues as Map, currentUser, false,
                    true, false, fieldSyncService.truncateFieldsForProject(taskInstance.project),
                    request.remoteAddr, transcription)

            log.debug("Save successful.")
            if (saveType == SAVE_TYPE_BACKGROUND) {
                render([success: true] as JSON)
            } else {
                redirect(controller: 'task', action: 'projectAdmin', id: taskInstance.project.id, params: [lastTaskId: taskInstance.id, mode: params.mode ?: ''])
            }

        } else {
            if (saveType == SAVE_TYPE_BACKGROUND) {
                render([success: false, status: 401] as JSON)
            } else {
                redirect(view: '../index')
            }
        }
    }

    def skip() {
        def taskInstance = Task.get(params.long('id'))
        if (taskInstance != null) {
            redirect(action: 'showNextFromProject', id: taskInstance.project.id, params: [mode: params.mode ?: ''])
        } else {
            flash.message = "No task id supplied!"
            render(view: '/notPermitted')
        }
    }

    def showNextFromProject() {

        def currentUser = userService.currentUserId
        def project = Project.get(params.long('id'))

        if (!userService.isValidator(project) || !project) {
            render(view: '/notPermitted')
            return
        }

        log.debug("Finding next task for user [${currentUser}] from project: [${project.id}], previous task ID: [${params.prevId}], msg: [${params.msg}]")
        flash.message = params.msg

        def previousId = params.long('prevId',-1)
        def prevUserId = params.prevUserId ?: -1

        def taskInstance = taskService.getNextTaskForValidationForProject(currentUser, project)

        // If Skipped, remove viewed task flag to prevent it getting locked.
        if (params.boolean('skip', false)) {
            log.debug("Skipped task, remove viewed task flag to prevent locking.")
            // clear last viewed.
            if (previousId > -1) {
                taskService.resetTaskView(previousId, currentUser, true)
            }
        }

        // Retrieve the details of the template
        if (taskInstance && taskInstance.id == previousId && currentUser != prevUserId) {
            log.debug "1."
            render(view: 'noTasks', model: [projectId: project.id])
        } else if (taskInstance && project) {
            log.debug "2."
            redirect(action: 'task', id: taskInstance.id, params: [mode: params.mode ?: ''])
        } else if (!project) {
            log.error("Project not found for id: " + params.long('id'))
            redirect(view: '/index')
        } else {
            log.debug "4."
            render(view: 'noTasks', model: [projectId: project.id])
        }
    }
}
