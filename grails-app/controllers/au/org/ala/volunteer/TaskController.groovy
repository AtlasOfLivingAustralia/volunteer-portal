package au.org.ala.volunteer

import com.google.common.base.Strings
import grails.converters.JSON
import grails.gorm.transactions.Transactional
import grails.web.servlet.mvc.GrailsParameterMap
import groovy.time.TimeCategory
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest

import javax.imageio.ImageIO
import java.awt.image.BufferedImage

class TaskController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST", viewTask: "POST"]
    public static final String PROJECT_LIST_STATE_SESSION_KEY = "project.admin.list.state"
    public static final String PROJECT_LIST_LAST_PROJECT_ID_KEY = "project.admin.list.lastProjectId"
    public static final String VIEW_TASK_LIST_ADMIN = 'adminList'
    public static final String VIEW_TASK_LIST = 'list'

    def taskService
    def fieldSyncService
    def fieldService
    def taskLoadService
    def userService
    def stagingService
    def auditService
    def multimediaService
    def projectService
    def projectStagingService

    def projectAdmin() {
        def currentUser = userService.currentUserId
        def project = Project.get(params.int("id"))
        if (project && currentUser && userService.isValidator(project)) {
            renderProjectListWithSearch(params, VIEW_TASK_LIST_ADMIN)
        } else {
            flash.message = "You do not have permission to view the Admin Task List page (you need to be either an adminstrator or a validator)"
            redirect(controller: "project", action: "index", id: params.id)
        }
    }

    def extra_fields_default = ["catalogNumber", "scientificName"]

    private def renderProjectListWithSearch(GrailsParameterMap params, String view) {
        def project = Project.get(params.long('id'))
        def currentUser = userService.currentUserId
        def userInstance = User.findByUserId(currentUser)
        String[] fieldNames = null

        def extraFieldProperty = this.metaClass.properties.find() { it.name == "extra_fields_" + project.template.name }
        if (extraFieldProperty) {
            fieldNames = extraFieldProperty.getProperty(this)
        }

        if (fieldNames == null) {
            fieldNames = extra_fields_default
        }

        if (project) {
            // The last time we were at this view, was it for the same project?
            def lastProjectId = session[PROJECT_LIST_LAST_PROJECT_ID_KEY]
            if (lastProjectId && lastProjectId != params.id) {
                // if not, remove the state from the session
                session.removeAttribute(PROJECT_LIST_STATE_SESSION_KEY)
            }

            def lastState = session[PROJECT_LIST_STATE_SESSION_KEY] ?: [ max: 20, order: 'asc', sort: 'id', offset: 0 ]

            params.max = Math.min(params.max ? params.int('max') : lastState.max, 200)
            params.order = params.order ?: lastState.order
            params.offset = params.offset ?: lastState.offset
            params.sort = params.sort ?: lastState.sort

            if (params.statusFilter && params.statusFilter != lastState.statusFilter) {
                params.offset = 0
            }

            if (params.q && params.q != lastState.query) {
                params.offset = 0
            }

            // Save the current view state in the session, including the current project id
            session[PROJECT_LIST_STATE_SESSION_KEY] = [
                max: params.max,
                order: params.order,
                sort: params.sort,
                offset: params.offset,
                query: params.q,
                statusFilter: params.statusFilter
            ]
            session[PROJECT_LIST_LAST_PROJECT_ID_KEY] = params.id

            def taskInstanceList
            def taskQueryTotal
            def extraFields = [:] // Map
            def query = params.q as String
            def statusFilter = params.statusFilter as String

            if (query) {
                def fieldNameList = Arrays.asList(fieldNames)
                def taskInfo = fieldService.findAllTasksByFieldValues(project, query, params)
                taskInstanceList = taskInfo.taskList
                taskQueryTotal = taskInfo.taskCount
            } else {
                def taskInfo = taskService.getTaskListForProject(project, params)
                taskInstanceList = taskInfo.taskList
                taskQueryTotal = taskInfo.taskCount
            }

            int transcribedCount = taskService.getNumberOfFullyTranscribedTasks(project)
            int validatedCount = Task.countByProjectAndFullyValidatedByIsNotNull(project)
            int taskInstanceTotal = (Strings.isNullOrEmpty(statusFilter) && Strings.isNullOrEmpty(params.q) ? taskQueryTotal : Task.countByProject(project))

            if (taskQueryTotal) {
                fieldNames.each {
                    extraFields[it] = fieldService.getLatestFieldsWithTasks(it, taskInstanceList as List<Task>, params).groupBy { it.task.id }
                }
            }

            def views = [:]
            if (taskInstanceList) {
                def c = ViewedTask.createCriteria()
                views = c {
                    'in'("task", taskInstanceList)
                }
                views = views?.groupBy { ((ViewedTask) it).task }
            }

            def lockedMap = [:]
            views?.values()?.each { List viewList ->
                def max = viewList.max { it.lastView }
                use (TimeCategory) {
                    if (new Date(max.lastView as long) > 2.hours.ago && !max.skipped) {
                        // Lock if not fully transcribed
                        // Lock if fully transcribed and opened by a validator
                        if (!max.task?.isFullyTranscribed) {
                            log.debug("Task locked; id: [${max.task?.id}], last view: [${new Date(max.lastView as long)}], skipped: [${max.skipped}]")
                            lockedMap[max.task?.id as long] = max
                        } else {
                            User viewingUser = User.findByUserId(max.userId as String)
                            if (viewingUser) {
                                def lastTranscription = max.task?.transcriptions?.max { it.dateFullyTranscribed }

                                log.debug("Checking who the viewing user is: ${viewingUser}")
                                log.debug("Viewing user is a validator: ${userService.userHasValidatorRole(viewingUser, project.id)}")
                                log.debug("View date: ${max.lastView}, date fully transcribed: ${lastTranscription?.dateFullyTranscribed?.getTime()}")

                                // If the last view came after the date/time of the last transcription, it was opened by a validator.
                                if (max.lastView > lastTranscription?.dateFullyTranscribed?.getTime() &&
                                        (userService.userHasValidatorRole(viewingUser, project.id) && currentUser != max.userId)) {
                                    log.debug("Task locked; id: [${max.task?.id}], last view: [${new Date(max.lastView as long)}] by ${max.userId} (current user ${currentUser}), skipped: [${max.skipped}]")
                                    lockedMap[max.task?.id as long] = max
                                }
                            }
                        }
                    }
                }
            }

            def statusFilterList = [[key: "transcribed", value: "View transcribed tasks"],
                                    [key: "validated", value: "View validated tasks"],
                                    [key: "not-transcribed", value: "View tasks not yet transcribed"]]

            // add some associated "field" values
            render(view: view, model:
                    [taskInstanceList : taskInstanceList,
                     taskQueryTotal   : taskQueryTotal,
                     taskInstanceTotal: taskInstanceTotal,
                     validatedCount   : validatedCount,
                     transcribedCount : transcribedCount,
                     projectInstance  : project,
                     extraFields      : extraFields,
                     userInstance     : userInstance,
                     lockedMap        : lockedMap,
                     statusFilterList : statusFilterList])
        } else {
            flash.message = "No project found for ID " + params.long('id')
        }
    }

    /**
     * Webservice for Google Maps to display task details in infowindow
     */
    def details() {
//        def id = params.int('id')
//        def sid = params.id
        def taskInstance = Task.get(params.int('id'))
        Map recordValues = [:]
        if (taskInstance.fullyValidatedBy) {
            recordValues = fieldSyncService.retrieveValidationFieldsForTask(taskInstance)
        }
        else {
            if (taskInstance.transcriptions) {
                recordValues = fieldSyncService.retrieveFieldsForTranscription(taskInstance, taskInstance.transcriptions.first())
            }
        }

        def jsonObj = [:]
        jsonObj.put("cat", recordValues?.get(0)?.catalogNumber)
        jsonObj.put("name", recordValues?.get(0)?.scientificName)

        List transcribers = []
        taskInstance.transcriptions.each {
            if (it.dateFullyTranscribed) {
                transcribers << userService.detailsForUserId(it.fullyTranscribedBy).displayName
            }
        }
        jsonObj.put("transcriber", transcribers.join(", "))
        render jsonObj as JSON
    }

    /** list all tasks  */
    def list() {
        def currentUser = userService.currentUserId
        params.max = Math.min(params.max ? params.int('max') : 20, 50)
        params.order = params.order ? params.order : "asc"
        params.sort = params.sort ? params.sort : "id"

        def project = Project.get(params.int("id"))
        if (project && currentUser && userService.isValidator(project)) {
            renderProjectListWithSearch(params, VIEW_TASK_LIST)
        } else {
            render(view: '/notPermitted')
        }
    }

    def showDetails() {
        def currentUser = userService.currentUserId
        def taskInstance = Task.get(params.int('id'))
        Project project = taskInstance?.project
        if (project && currentUser && userService.isValidator(project)) {
            def c = Field.createCriteria()
            def fields = c.list(params) {
                eq('task', taskInstance)
            }

            // def fields = Field.findAllByTask(taskInstance, [order: 'updated,superceded'])
            [taskInstance: taskInstance, fields: fields]
        } else {
            render(view: '/notPermitted')
        }
    }

    def show() {
        def task = Task.get(params.long('id'))
        def userTask = params.get('userId')
        if (!task) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: 'task.label', default: 'Task'), params.id]) as String
            redirect(action: "list")
        } else {
            def currentUser = userService.currentUserId
            def readonly = false
            def msg = ""

            if (task) {
                // first check is user is logged in...
                if (!currentUser) {
                    readonly = true
                    msg = "You are not logged in. In order to transcribe tasks you need to register and log in."
                } else {
                    // work out if the task is currently being edited by someone else...
                    def prevUserId = null
                    def prevLastView = 0
                    task.viewedTasks.each { viewedTask ->
                        // viewedTasks is a set so order is not guaranteed
                        if (viewedTask.lastView > prevLastView) {
                            // store the most recent viewedTask
                            prevUserId = viewedTask.userId
                            prevLastView = viewedTask.lastView
                        }
                    }

                    log.debug "<task.show> userId = " + currentUser + " || prevUserId = " + prevUserId + " || prevLastView = " + prevLastView
//                    def millisecondsSinceLastView = (prevLastView > 0) ? System.currentTimeMillis() - prevLastView : null

                    boolean isTaskLockedForTranscription = auditService.isTaskLockedForTranscription(task, currentUser)
                    //if (prevUserId != currentUser && millisecondsSinceLastView && millisecondsSinceLastView < (grailsApplication.config.viewedTask.timeout as long)) {
                    if (isTaskLockedForTranscription) {
                        // task is already being viewed by another user (with timeout period)
                        //log.warn "Task was recently viewed: " + (millisecondsSinceLastView / (60 * 1000)) + " min ago by ${prevUserId}"
                        msg = "This task is being viewed/edited by another user, and is currently read-only"
                        readonly = true
                    } else if (task.fullyValidatedBy && task.isValid != null) {
                        if (task.isValid) {
                            msg = "This task has been validated, and is currently read-only."
                        } else {
                            msg = "This task has been partially validated and is currently read-only."
                        }

                        if (userService.isValidator(task.project)) {
                            def link = createLink(controller: 'validate', action: 'task', id: task.id) as String
                            //msg += ' As a validator you may review/edit this task by clicking <a href="' + link + '">here</a>.'
                            msg += """ As a validator, you may review/${(task.isValid ? "edit" : "continue validating")} 
                                this task by clicking <a href='${link}'>here</a>.""".toString()
                        }
                        readonly = true
                    } else if (userTask && userTask != currentUser) {
                        readonly = true
                    }
                }
            }

            flash.message = msg
            if (!readonly) {
                redirect(controller: 'transcribe', action: 'task', id: params.id)
            } else {
                def project = Project.findById(task.project.id)
                def template = Template.findById(project.template.id)
                def isReadonly = 'readonly'
                // def isValidator = userService.isValidator(project)
                // log.debug currentUser + " has role: ADMIN = " + userService.isAdmin() + " &&  VALIDATOR = " + isValidator

//                def imageMetaData = taskService.getImageMetaData(taskInstance)

                // Retrieve the existing values - if this is a multiple transcription task, we have to pick
                // which transcription to show.
                Transcription transcription = null //
                if (!task.fullyValidatedBy || task.project.requiredNumberOfTranscriptions == 1) { // If the task is not validated, pick a transcription.
                    // If the user has transcribed the Task, use the user's transcription.
                    String userId = currentUser
                    transcription = task.transcriptions.find{it.fullyTranscribedBy == userId}

                    // Otherwise use the transcription from the user notebook, if supplied.
                    if (params.userId) {
                        transcription = task.transcriptions.find{it.fullyTranscribedBy == params.userId}
                    }
                    if (!transcription) {
                        transcription = task.transcriptions.first()
                    }
                }
                Map recordValues = fieldSyncService.retrieveFieldsForTranscription(task, transcription)
                def adjacentTasks = taskService.getAdjacentTasksBySequence(task)
                def model = [
                        taskInstance: task,
                        recordValues: recordValues,
                        isReadonly: isReadonly,
                        template: template,
                        nextTask: adjacentTasks.next,
                        prevTask: adjacentTasks.prev,
                        sequenceNumber: adjacentTasks.sequenceNumber,
                        thumbnail: multimediaService.getImageThumbnailUrl(task.multimedia.first(), true)
                ]
                render(view: '/transcribe/templateViews/' + template.viewName, model: model)
            }
        }
    }

    def summary(Task task) {
        /*
        {
          "filename": "filename",
          "thumbnail": "thumbnail",
          "image": "image",
          "externalId": "externalId",
          "transcriber": "transcriber",
          "dateTranscribed": "dateTranscribed",
          "validator": "validator",
          "dateValidated": "dateValidated",
          "valid": "isValid",
          "fields": {
            [
              { "name", "value", ...}, ...
            ]
          }
        }
         */
        if (!task) {
            response.sendError(404, "Task not found")
            return
        }

        final fields = Field.findAllByTaskAndSuperceded(task, false)
        final mm = task.multimedia.first()

        final result = [
                    filename: task.externalIdentifier,
                    thumbnail: multimediaService.getImageThumbnailUrl(mm, true),
                    image: multimediaService.getImageUrl(mm),
                // TODO: replace these?
                    transcriber: userService.detailsForUserId(task.fullyTranscribedBy as String)?.displayName,
                    dateTranscribed: task.dateFullyTranscribed,
                    validator: userService.detailsForUserId(task.fullyValidatedBy)?.displayName,
                    dateValidated: task.dateFullyValidated,
                    valid: task.isValid,
                    records: fields.groupBy { it.recordIdx }.sort { it.key }.collect { it.value.collectEntries { [(it.name): it.value] } }
                ]

        respond result, model: [taskInstance: task]
    }

    def showImage() {

        if (params.id) {
            def task = Task.findById(params.int("id"))

            if (task) {
                def adjacentTasks = taskService.getAdjacentTasksBySequence(task)
                [taskInstance: task, sequenceNumber: adjacentTasks.sequenceNumber, prevTask:adjacentTasks?.prev, nextTask:adjacentTasks?.next]
            }
        }
    }

    def taskBrowserFragment() {
        if (params.projectId) {
            Task task = null
            if (params.taskId) {
                task = Task.get(params.int("taskId"))
            }
            def projectInstance = Project.get(params.int("projectId"))
            [projectInstance: projectInstance, taskInstance: task]
        }
    }


    def taskBrowserTaskList() {
        if (params.taskId) {
            def task = Task.get(params.int("taskId"))
            def project = task?.project
            def taskList = taskService.transcribedDatesByUserAndProject(userService.currentUserId, project.id, params.search_text as String)

            taskList = taskList.sort { it.lastEdit }

            if (task) {
                taskList.remove(task)
            }

            [projectInstance: project, taskList: taskList.toList(), taskInstance: task]
        }

    }

    def taskDetailsFragment() {
        def task = Task.get(params.int("taskId"))
        if (task) {

            // def userId = userService.currentUserId

            def c = Field.createCriteria()

            def fields = c {
                and {
                    eq("task", task)
                    eq("superceded", false)
//                    eq("transcribedByUserId", userId)
                }
            }

            def lastEdit = fields.max({ it.updated })?.updated

            def projectInstance = task.project
            def template = projectInstance.template
            def templateFields = TemplateField.findAllByTemplate(template)

            def fieldMap = [:]
            def fieldLabels = [:]
            for (Field field : fields) {

                def templateField = templateFields.find {
                    it.fieldType.toString() == field.name
                }
                if (templateField && field.value && templateField.type != FieldType.hidden) {
                    def category = templateField.category
                    if (templateField.fieldType == DarwinCoreField.occurrenceRemarks) {
                        category = FieldCategory.labelText
                    } else if (templateField.fieldType == DarwinCoreField.verbatimLocality) {
                        category = FieldCategory.location
                    }

                    def fieldList = fieldMap[category]
                    if (!fieldList) {
                        fieldList = []
                        fieldMap[category] = fieldList
                    }
                    fieldList << field
                    fieldLabels[field.name] = templateField.label ?: templateField.fieldType.label
                }
            }

            // These categories should be in this order
            def categoryNames  =[ FieldCategory.labelText, FieldCategory.collectionEvent, FieldCategory.location, FieldCategory.identification, FieldCategory.miscellaneous ]
            // any remaining categories can go in any order...
            for (TemplateField tf : templateFields) {
                if (!categoryNames.contains(tf.category)) {
                    categoryNames << tf.category
                }
            }

            def catalogNumberField = fieldService.getFieldForTask(task, "catalogNumber")

            [taskInstance: task, fieldMap: fieldMap, fieldLabels: fieldLabels, sortedCategories: categoryNames, dateTranscribed: lastEdit, catalogNumber: catalogNumberField?.value ]
        }
    }

    def ajaxTaskData() {
        def task = Task.get(params.int("taskId"))

        def username = userService.currentUserId

        if (task) {
            def c = Field.createCriteria()

            def fields = c {
                and {
                    eq("task", task)
                    eq("superceded", false)
                    eq("transcribedByUserId", username)
                }
            }

            def projectInstance = task.project
            def template = projectInstance.template
            def templateFields = TemplateField.findAllByTemplate(template, )
            def results = [:]
            for (Field field : fields) {

                def templateField = templateFields.find {
                    it.fieldType.toString() == field.name
                }
                if (templateField && field.value && templateField.type != FieldType.hidden) {
                    results["recordValues\\.${field.recordIdx?:0}\\.${field.name}"] = field.value
                }
            }

            render results as JSON
        } else {
            render status: 404
        }
    }

    def staging() {
        def projectId = params.int("projectId")
        def project = Project.get(projectId)
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        cache false
        if (!project) {
            redirect(controller: 'index')
            return
        }

        boolean isAudioProject = (project.projectType.name == ProjectType.PROJECT_TYPE_AUDIO)

        if (taskLoadService.isProjectLoadingAlready(projectId)) {
            flash.message = 'Please wait while existing staged images are loaded'
            redirect(controller: 'project', action: 'loadProgress', id: projectId)
        } else {
            [projectInstance: project,
             hasDataFile: stagingService.projectHasDataFile(project),
             dataFileUrl:stagingService.dataFileUrl(project),
             isAudioProject: isAudioProject]
        }
    }

    def stagedImages() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        def profile = projectStagingService.findProjectStagingProfile(project)

        cache false
        def images = stagingService.buildTaskMetaDataList(project)
        render template:'stagedImages', model: [images: images, profile: profile]
    }

    def editStagingFieldFragment() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        def fieldDefinition = StagingFieldDefinition.get(params.int("fieldDefinitionId"))
        def hasDataFile = stagingService.projectHasDataFile(project)
        def dataFileColumns = []
        if (hasDataFile) {
            dataFileColumns = ['']
            dataFileColumns.addAll(stagingService.getDataFileColumns(project))
        }

        [projectInstance: project, fieldDefinition: fieldDefinition, hasDataFile: hasDataFile,
         dataFileColumns: dataFileColumns ]
    }

    def uploadDataFileFragment() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        [projectInstance: project]
    }

    def uploadStagingDataFile() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            if (request instanceof MultipartHttpServletRequest) {
                MultipartFile f = ((MultipartHttpServletRequest) request).getFile('dataFile')
                if (f != null) {
                    def allowedMimeTypes = ['text/plain','text/csv', 'application/octet-stream', 'application/vnd.ms-excel']
                    if (!allowedMimeTypes.contains(f.getContentType())) {
                        flash.message = "The image file must be one of: ${allowedMimeTypes}, recieved '${f.getContentType()}'}"
                        redirect(action:'staging', params:[projectId:project?.id])
                        return
                    }

                    if (f.size == 0 || !f.originalFilename) {
                        flash.message = "You must select a file to upload"
                        redirect(action:'staging', params:[projectId:project?.id])
                        return
                    }
                    stagingService.uploadDataFile(project, f)
                }
            }
        }
        redirect(action: 'staging', params: [projectId: project?.id])
    }

    def uploadTaskDataFile() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            if(request instanceof MultipartHttpServletRequest) {
                MultipartFile f = ((MultipartHttpServletRequest) request).getFile('dataFile')
                if (f != null) {
                    def allowedMimeTypes = ['text/plain','text/csv']
                    if (!allowedMimeTypes.contains(f.getContentType())) {
                        flash.message = "The file must be one of: ${allowedMimeTypes}"
                        redirect(action:'loadTaskData', params:[projectId:project?.id])
                        return
                    }
                    stagingService.uploadDataFile(project, f)
                }
            }
        }
        redirect(action: 'loadTaskData', params: [projectId: project?.id])
    }

    def clearTaskDataFile() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            stagingService.clearDataFile(project)
        }

        redirect(action: 'loadTaskData', params: [projectId: project?.id])
    }

    def clearStagedDataFile() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            stagingService.clearDataFile(project)
        }

        redirect(action: 'staging', params: [projectId: project?.id])
    }

    def deleteAllStagedImages() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            stagingService.deleteStagedImages(project)
        }

        redirect(action: 'staging', params: [projectId: project?.id])
    }

    def unstageImage() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        def imageName = params.imageName as String
        if (project && imageName) {
            try {
                if (!stagingService.unstageImage(project, imageName)) {
                    flash.message = "Failed to delete image. Possibly file permissions?"
                    log.error("Failed to delete image. Possibly file permissions?")
                }
            } catch (Exception ex) {
                flash.message = "Failed to delete image: " + ex.message
                log.error("Failed to delete image: " + ex.message, ex)
            }
        }

        redirect(action: 'staging', params: [projectId: project?.id])
    }

    @Transactional
    def saveFieldDefinition() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        def fieldName = params.fieldName
        if (project && fieldName) {

            def fieldType = (params.fieldType as FieldDefinitionType) ?: FieldDefinitionType.Literal
            def format = params.format ?: params.fmt ?: ""
            def recordIndex = params.int("recordIndex") ?: 0
            def profile = ProjectStagingProfile.findByProject(project)

            def fieldDefinition = StagingFieldDefinition.get(params.int("fieldDefinitionId"))
            if (fieldDefinition) {
                // this is a 'save', not a 'create'
                fieldDefinition.fieldName = fieldName
                fieldDefinition.recordIndex = recordIndex
                fieldDefinition.fieldDefinitionType = fieldType
                fieldDefinition.format = format
                fieldDefinition.save(flush:true)
            } else {
                fieldDefinition = new StagingFieldDefinition(fieldDefinitionType: fieldType, format: format,
                        fieldName: fieldName, recordIndex: recordIndex)
                profile.addToFieldDefinitions(fieldDefinition)
                fieldDefinition.save(flush: true)
            }
        }

        redirect(action: 'staging', params: [projectId: project?.id])
    }

    @Transactional
    def updateFieldDefinitionType() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        def fieldDefinition = StagingFieldDefinition.get(params.int("fieldDefinitionId"))
        String newFieldType = params.newFieldType
        if (project && fieldDefinition && newFieldType) {
            fieldDefinition.fieldDefinitionType = newFieldType
        }
        fieldDefinition.save(flush: true)
        redirect(action: 'staging', params: [projectId: project?.id])
    }

    @Transactional
    def updateFieldDefinitionFormat() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        def fieldDefinition = StagingFieldDefinition.get(params.int("fieldDefinitionId"))
        String newFieldFormat = params.newFieldFormat
        if (project && fieldDefinition && newFieldFormat) {
            fieldDefinition.format = newFieldFormat
        }
        fieldDefinition.save(flush: true)
        redirect(action: 'staging', params: [projectId: project?.id])
    }

    @Transactional
    def deleteFieldDefinition() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        def fieldDefinition = StagingFieldDefinition.get(params.int("fieldDefinitionId"))
        if (project && fieldDefinition) {
            fieldDefinition.delete(flush: true)
        }

        redirect(action: 'staging', params: [projectId: project?.id])
    }

    def loadStagedTasks() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            def results = taskLoadService.loadTasksFromStaging(project)
            flash.message = results.message
            if (results.success) {
                redirect(controller:'project', action:'loadProgress', id: project.id)
                return
            }
        }
        redirect(action: 'staging', params: [projectId: project?.id])
    }

    def exportStagedTasksCSV() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            def profile = ProjectStagingProfile.findByProject(project)

            response.addHeader("Content-type", "text/plain")
            def writer = new BVPCSVWriter( (Writer) response.writer,  {
                'imageName' { it.name }
                'url' { it.url }
            })

            profile.fieldDefinitions.each { field ->
                writer.columns[field.fieldName + "_" + field.recordIndex] =  {
                    it.valueMap[field.fieldName + "_" + field.recordIndex] ?: ''
                }
            }
            writer.resetProducers()
            writer.writeHeadings = true

            def images = stagingService.buildTaskMetaDataList(project)

            images.each {
                writer << it
            }

            response.writer.flush()
        }
    }

    def loadTaskData() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (!project) {
            flash.errorMessage = "No project/invalid project id!"
            redirect(controller:'admin', action:'index')
            return
        }

        def hasDataFile = stagingService.projectHasDataFile(project)
        def fieldValues = [:]
        def columnNames = []
        if (hasDataFile) {
            fieldValues = stagingService.buildTaskFieldValuesFromDataFile(project)
            if (fieldValues.size() > 0) {
                columnNames = fieldValues[fieldValues.keySet().first()].keySet().collect()
            }
        }

        [projectInstance: project, hasDataFile: hasDataFile, dataFileUrl:stagingService.dataFileUrl(project),
         fieldValues: fieldValues, columnNames: columnNames]
    }

    def processTaskDataLoad() {
        def project = Project.get(params.int("projectId"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            def results = stagingService.loadTaskDataFromFile(project)
            flash.message = results?.message
        }

        redirect(action: 'loadTaskData', params: [projectId: project?.id])
    }

    def exportOptionsFragment() {
        def project = Project.get(params.long('projectId'))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        [exportCriteria: params.exportCriteria, projectId: params.projectId]
    }

    def viewedTaskFragment() {
        def viewedTask = ViewedTask.get(params.int("viewedTaskId"))
        def project = viewedTask?.task?.project
        if (!projectService.isAdminForProject(project) && !userService.isValidator(viewedTask?.task?.project)) {
            render(view: '/notPermitted')
            return
        }

        if (viewedTask) {
            def lastViewedDate = new Date(viewedTask?.lastView)
            def tc = TimeCategory.minus(new Date(), lastViewedDate)
            def agoString = "${tc} ago"

            [viewedTask: viewedTask, lastViewedDate: lastViewedDate, agoString: agoString]
        }
    }

    def resetTranscribedStatus() {
        def task = Task.get(params.int('id'))
        if (!task || (!userService.isAdmin() && !userService.isInstitutionAdmin(task.project.institution))) {
            if (task) flash.errorMessage = "Only ${message(code:"default.application.name")} administrators can perform " +
                    "this action!"
            redirect(action: 'showDetails', id: params.id)
            return
        }

        taskService.resetTranscribedStatus(task)
        redirect(action: 'showDetails', id: task.id)
    }

    def resetValidatedStatus() {
        def task = Task.get(params.int('id'))
        if (!task || (!userService.isAdmin() && !userService.isInstitutionAdmin(task.project.institution))) {
            if (task) flash.errorMessage = "Only ${message(code:"default.application.name")} administrators can perform " +
                    "this action!"
            redirect(action: 'showDetails', id: params.id)
            return
        }

        taskService.resetValidationStatus(task)
        redirect(action:'showDetails', id: task.id)
    }

    /**
     * Moved from deprecated MultimediaController.
     * @return
     */
    def imageDownload() {
        def mm = Multimedia.get(params.int("id"))
        if (mm) {
            def path = mm?.filePath
            String urlPrefix = grailsApplication.config.images.urlPrefix
            String imagesHome = grailsApplication.config.images.home

            // have to reverse engineer the files location on disk, this info should be part of the Multimedia structure!
            path = URLDecoder.decode(imagesHome + '/' + path.substring(urlPrefix?.length()))

            BufferedImage image = ImageIO.read(new File(path))
            def rotate = params.int("rotate") ?: 0
            if (rotate) {
                image = ImageUtils.rotateImage(image, rotate)
            }

            if (params.maxDimension) {
                def size = params.int("maxDimension")
                image = ImageUtils.scale(image, size, size)
            } else if (params.maxWidth) {
                def width = params.int("maxWidth")
                image = ImageUtils.scaleWidth(image, width)
            }

            def outputBytes = ImageUtils.imageToBytes(image)
            response.setContentType(mm.mimeType ?: "image/jpeg")
            response.setHeader("Content-disposition", "attachment;filename=${mm.task.externalIdentifier}.jpg")
            response.outputStream.write(outputBytes)
            response.flushBuffer()
        }
    }
}
