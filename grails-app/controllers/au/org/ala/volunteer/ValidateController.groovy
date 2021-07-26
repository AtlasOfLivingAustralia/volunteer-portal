package au.org.ala.volunteer

import com.google.common.base.Stopwatch

import java.util.concurrent.TimeUnit

class ValidateController {

    def fieldSyncService
    def auditService
    def taskService
    def userService
    def multimediaService

    def task() {
        def taskInstance = Task.get(params.long('id'))
        def currentUser = userService.currentUserId
        userService.registerCurrentUser()

        if (taskInstance) {

            if (auditService.isTaskLockedForValidation(taskInstance, currentUser)) {
                def lastView = auditService.getLastViewForTask(taskInstance)
                // task is already being viewed by another user (with timeout period)
                log.debug("Task ${taskInstance.id} is currently locked by ${lastView.userId}. Returning to admin list.")
                def msg = "The requested task (id: " + taskInstance.id + ") is being viewed/edited/validated by another user."
                flash.message = msg
                // redirect to another task
                redirect(controller: "task", action: "projectAdmin", id: taskInstance.project.id, params: params + [projectId: taskInstance.project.id])
                return
            } else {
                // go ahead with this task
                auditService.auditTaskViewing(taskInstance, currentUser)
            }

            def isReadonly = false

            def project = Project.findById(taskInstance.project.id)
            Template template = Template.findById(project.template.id)

            def isValidator = userService.isValidator(project)
            def isAdmin = (userService.isAdmin() || userService.isInstitutionAdmin(project?.institution))
            log.debug(currentUser + " has role: ADMIN = " + isAdmin + " &&  VALIDATOR = " + isValidator)

            if (taskInstance.isFullyTranscribed && !taskInstance.hasBeenTranscribedByUser(currentUser) && !(isAdmin || isValidator)) {
                isReadonly = "readonly"
            } else {
                // check that the validator is not the transcriber...Admins can, though!
                if (taskInstance.hasBeenTranscribedByUser(currentUser)) {
                    if (isAdmin) {
                        flash.message = "Normally you cannot validate your own tasks, but you have the ADMIN role, so it is allowed in this case"
                    } else {
                        flash.message = "This task is read-only. You cannot validate your own tasks!"
                        isReadonly = "readonly"
                    }
                }
            }

            Stopwatch sw = Stopwatch.createStarted()
            Map recordValues = fieldSyncService.retrieveValidationFieldsForTask(taskInstance)
            sw.stop()
            log.debug("retrieveValidationFieldsForTask: ${sw.elapsed(TimeUnit.SECONDS)}")
            def adjacentTasks = taskService.getAdjacentTasksBySequence(taskInstance)
            def imageMetaData = taskService.getImageMetaData(taskInstance)
            def transcribersAnswers = fieldSyncService.retrieveTranscribersFieldsForTask(taskInstance)
/*            if (!recordValues && transcribersAnswers && transcribersAnswers.size() > 0) {
                recordValues = transcribersAnswers[0].fields
            }*/

            render(view: '../transcribe/templateViews/' + template.viewName,
                    model: [taskInstance       : taskInstance,
                            recordValues       : recordValues,
                            isReadonly         : isReadonly,
                            nextTask           : adjacentTasks.next,
                            prevTask           : adjacentTasks.prev,
                            sequenceNumber     : adjacentTasks.sequenceNumber,
                            template           : template,
                            validator          : true,
                            imageMetaData      : imageMetaData,
                            transcribersAnswers: transcribersAnswers,
                            thumbnail          : multimediaService.getImageThumbnailUrl(taskInstance.multimedia.first(), true)])
        } else {
            redirect(view: 'list', controller: "task")
        }
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
            redirect(action: 'task', id: params.failoverTaskId)
            return
        }

        if (currentUser != null) {
            def seconds = params.getInt('timeTaken', null)
            if (seconds) {
                taskInstance.timeToValidate = (taskInstance.timeToValidate ?: 0) + seconds
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
            redirect(controller: 'task', action: 'projectAdmin', id: taskInstance.project.id, params: [lastTaskId: taskInstance.id])
        } else {
            redirect(view: '../index')
        }
    }

    /**
     * To do determine actions if the validator chooses not to validate
     */
    def dontValidate() {
        def taskInstance = Task.get(params.long('id'))
        if (!userService.isValidator(taskInstance?.project) || !taskInstance) {
            render(view: '/notPermitted')
            return
        }

        def currentUser = userService.currentUserId

        if (!params.id && params.failoverTaskId) {
            redirect(action: 'task', id: params.failoverTaskId)
            return
        }

        if (currentUser != null) {

            def seconds = params.getInt('timeTaken', null)
            if (seconds) {
                taskInstance.timeToValidate = (taskInstance.timeToValidate ?: 0) + seconds
            }
            WebUtils.cleanRecordValues(params.recordValues as Map)
            Transcription transcription = null
            if (taskInstance.project.requiredNumberOfTranscriptions == 1) {
                transcription = taskInstance.transcriptions[0]
            }
            fieldSyncService.syncFields(taskInstance, params.recordValues as Map, currentUser, false,
                    true, false, fieldSyncService.truncateFieldsForProject(taskInstance.project),
                    request.remoteAddr, transcription)
            redirect(controller: 'task', action: 'projectAdmin', id: taskInstance.project.id, params: [lastTaskId: taskInstance.id])
        } else {
            redirect(view: '../index')
        }
    }

    def skip() {
        def taskInstance = Task.get(params.long('id'))
        if (taskInstance != null) {
            redirect(action: 'showNextFromProject', id: taskInstance.project.id)
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

        log.debug("project id = " + params.long('id') + " || msg = " + params.msg?.toString() +
                " || prevInt = " + params.long('prevId'))
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
            render(view: 'noTasks')
        } else if (taskInstance && project) {
            log.debug "2."
            redirect(action: 'task', id: taskInstance.id)
        } else if (!project) {
            log.error("Project not found for id: " + params.long('id'))
            redirect(view: '/index')
        } else {
            log.debug "4."
            render(view: 'noTasks')
        }
    }
}
