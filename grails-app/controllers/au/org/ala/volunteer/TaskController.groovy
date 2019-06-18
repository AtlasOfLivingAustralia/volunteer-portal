package au.org.ala.volunteer

import grails.converters.JSON
import groovy.time.TimeCategory
import grails.web.servlet.mvc.GrailsParameterMap
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest

import javax.servlet.http.HttpServletResponse

import static javax.servlet.http.HttpServletResponse.SC_NO_CONTENT
import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST

class TaskController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST", viewTask: "POST"]
    public static final String PROJECT_LIST_STATE_SESSION_KEY = "project.admin.list.state"
    public static final String PROJECT_LIST_LAST_PROJECT_ID_KEY = "project.admin.list.lastProjectId"

    def taskService
    def fieldSyncService
    def fieldService
    def taskLoadService
    def logService
    def userService
    def stagingService
    def auditService
    def multimediaService

    def load() {
        [projectList: Project.list()]
    }

    def project() {
        params.max = Math.min(params.max ? params.int('max') : 20, 50)
        params.order = params.order ? params.order : "asc"
        params.sort = params.sort ? params.sort : "id"
        //render(view: "list", model:[taskInstanceList: Task.list(params), taskInstanceTotal: Task.count()])
        if (params.id) {
            renderProjectListWithSearch(params, "list")
        } else {
            render(view: "list", model:[taskInstanceList: Task.list(params), taskInstanceTotal: Task.count()])
        }
    }

    def projectAdmin() {
        def currentUser = userService.currentUserId
        def project = Project.get(params.int("id"))
        if (project && currentUser && userService.isValidator(project)) {
            renderProjectListWithSearch(params, "adminList")
        } else {
            flash.message = "You do not have permission to view the Admin Task List page (you need to be either an adminstrator or a validator)"
            redirect(controller: "project", action: "index", id: params.id)
        }
    }

    def extra_fields_default = ["catalogNumber","scientificName"]

    def extra_fields_FieldNoteBook = []

    def extra_fields_FieldNoteBookDoublePage = []

    private def renderProjectListWithSearch(GrailsParameterMap params, String view) {

        def projectInstance = Project.get(params.id)

        def currentUser = userService.currentUserId
        def userInstance = User.findByUserId(currentUser)

        String[] fieldNames = null;

        def extraFieldProperty = this.metaClass.properties.find() { it.name == "extra_fields_" + projectInstance.template.name }

        if (extraFieldProperty) {
            fieldNames = extraFieldProperty.getProperty(this)
        }

        if (fieldNames == null) {
            fieldNames = extra_fields_default
        }

        if (projectInstance) {
            // The last time we were at this view, was it for the same project?
            def lastProjectId = session[PROJECT_LIST_LAST_PROJECT_ID_KEY]
            if (lastProjectId && lastProjectId != params.id) {
                // if not, remove the state from the session
                session.removeAttribute(PROJECT_LIST_STATE_SESSION_KEY)
            }

            def lastState = session[PROJECT_LIST_STATE_SESSION_KEY] ?: [ max: 20, order: 'asc', sort: 'id', offset: 0 ]

            params.max = Math.min(params.max ? params.int('max') : lastState.max, 200)
            params.order = params.order ?: lastState.order
            params.sort = params.sort ?: lastState.sort
            params.offset = params.offset ?: lastState.offset

            if (params.q && params.q != lastState.query) {
                params.offset = 0
            }

            // Save the current view state in the session, including the current project id
            session[PROJECT_LIST_STATE_SESSION_KEY] = [
                max: params.max,
                order: params.order,
                sort: params.sort,
                offset: params.offset,
                query: params.q

            ]
            session[PROJECT_LIST_LAST_PROJECT_ID_KEY] = params.id

            def taskInstanceList
            def taskInstanceTotal
            def extraFields = [:] // Map
            def query = params.q as String

            if (query) {
                // def fullList = Task.findAllByProject(projectInstance, [max: 9999])
                def fieldNameList = Arrays.asList(fieldNames)
                taskInstanceList = fieldService.findAllTasksByFieldValues(projectInstance, query, params, fieldNameList)
                taskInstanceTotal = fieldService.countAllTasksByFieldValueQuery(projectInstance, query, fieldNameList)
            } else {
                taskInstanceList = Task.findAllByProject(projectInstance, params)
                taskInstanceTotal = Task.countByProject(projectInstance)
            }

            int transcribedCount = taskService.getNumberOfFullyTranscribedTasks(projectInstance)
            int validatedCount = Task.countByProjectAndFullyValidatedByIsNotNull(projectInstance)

            if (taskInstanceTotal) {
                fieldNames.each {
                    extraFields[it] = fieldService.getLatestFieldsWithTasks(it, taskInstanceList, params).groupBy { it.task.id }
                }
            }


            def views = [:]
            if (taskInstanceList) {
                def c = ViewedTask.createCriteria()
                views = c {
                    'in'("task", taskInstanceList)
                }
                views = views?.groupBy { it.task }
            }

            def lockedMap = [:]
            views?.values().each { List viewList ->
                def max = viewList.max { it.lastView }
                use (TimeCategory) {
                    if (new Date(max.lastView) > 2.hours.ago) {
                        lockedMap[max.task?.id] = max
                    }
                }
            }

            // add some associated "field" values
            render(view: view, model:
                    [taskInstanceList: taskInstanceList, taskInstanceTotal: taskInstanceTotal, validatedCount: validatedCount, transcribedCount: transcribedCount,
                    projectInstance: projectInstance, extraFields: extraFields, userInstance: userInstance, lockedMap: lockedMap])
        }
        else {
            flash.message = "No project found for ID " + params.id
        }
    }

    /**
     * Webservice for Google Maps to display task details in infowindow
     */
    def details() {
        def id = params.int('id')
        def sid = params.id
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

    def loadCSV() {
        def projectId = params.int('projectId')

        if (params.csv) {
            def csv = params.csv;
            flash.message = taskService.loadCSV(projectId, csv)
        }
    }

    def loadCSVAsync() {
        def projectId = params.int('projectId')
        def replaceDuplicates = params.duplicateMode == 'replace'
        if (projectId && params.csv) {
            def project = Project.get(projectId)
            if (project) {
                def (success, message) = taskLoadService.loadTaskFromCSV(project, params.csv, replaceDuplicates)
                if (!success) {
                    flash.message = message + " - Try again when current load is complete."
                }
                redirect( controller:'loadProgress', action:'index')
            }
        }
    }

    def cancelLoad() {
        taskLoadService.cancelLoad()
        flash.message = "Cancelled!"
        redirect( controller:'loadProgress', action:'index')
    }

    def index() {
        redirect(action: "list", params: params)
    }

    /** list all tasks  */
    def list() {
        params.max = Math.min(params.max ? params.int('max') : 20, 50)
        params.order = params.order ? params.order : "asc"
        params.sort = params.sort ? params.sort : "id"
        //render(view: "list", model:[taskInstanceList: Task.list(params), taskInstanceTotal: Task.count()])
        if (params.id) {
            //redirect(action: "project", params: params)
            renderProjectListWithSearch(params, "list")
        } else {
            redirect(controller: 'project', action:'list')
        }
    }

    def thumbs() {
        params.max = Math.min(params.max ? params.int('max') : 8, 16)
        params.order = params.order ? params.order : "asc"
        params.sort = params.sort ? params.sort : "id"
        [taskInstanceList: Task.list(params), taskInstanceTotal: Task.count()]
    }

    def create() {
        def currentUser = userService.currentUserId

        if (currentUser != null && userService.isAdmin()) {
            def taskInstance = new Task()
            taskInstance.properties = params
            return [taskInstance: taskInstance]
        } else {
            flash.message = "You do not have permission to view this page"
            redirect(view: '/index')
        }
    }

    def save() {
        def taskInstance = new Task(params)
        if (taskInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'task.label', default: 'Task'), taskInstance.id])}"
            redirect(action: "show", id: taskInstance.id)
        }
        else {
            render(view: "create", model: [taskInstance: taskInstance])
        }
    }

    def showDetails() {
        def taskInstance = Task.get(params.int('id'))

        def c = Field.createCriteria()
        def fields = c.list(params) {
            eq('task', taskInstance)
        }

        // def fields = Field.findAllByTask(taskInstance, [order: 'updated,superceded'])
        [taskInstance: taskInstance, fields: fields]
    }

    def show() {
        def taskInstance = Task.get(params.id)
        def userTask = params.get('userId')
        if (!taskInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'task.label', default: 'Task'), params.id])}"
            redirect(action: "list")
        } else {

            def currentUser = userService.currentUserId

            def readonly = false
            def msg = ""


            if (taskInstance) {

                // first check is user is logged in...
                if (!currentUser) {
                    readonly = true
                    msg = "You are not logged in. In order to transcribe tasks you need to register and log in."
                } else {
                    // work out if the task is currently being edited by someone else...
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

                    log.debug "<task.show> userId = " + currentUser + " || prevUserId = " + prevUserId + " || prevLastView = " + prevLastView
                    def millisecondsSinceLastView = (prevLastView > 0) ? System.currentTimeMillis() - prevLastView : null

                    boolean isTaskLockedForTranscription = auditService.isTaskLockedForTranscription(taskInstance, currentUser)
                    //if (prevUserId != currentUser && millisecondsSinceLastView && millisecondsSinceLastView < (grailsApplication.config.viewedTask.timeout as long)) {
                    if (isTaskLockedForTranscription) {
                        // task is already being viewed by another user (with timeout period)
                        //log.warn "Task was recently viewed: " + (millisecondsSinceLastView / (60 * 1000)) + " min ago by ${prevUserId}"
                        msg = "This task is being viewed/edited by another user, and is currently read-only"
                        readonly = true
                    } else if (taskInstance.fullyValidatedBy && taskInstance.isValid != null) {
                        msg = "This task has been validated, and is currently read-only."
                        if (userService.isValidator(taskInstance.project)) {
                            def link = createLink(controller: 'validate', action: 'task', id: taskInstance.id)
                            msg += ' As a validator you may review/edit this task by clicking <a href="' + link + '">here</a>.'
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
                def project = Project.findById(taskInstance.project.id)
                def template = Template.findById(project.template.id)
                def isReadonly = 'readonly'
                def isValidator = userService.isValidator(project)
                log.info currentUser + " has role: ADMIN = " + userService.isAdmin() + " &&  VALIDATOR = " + isValidator

//                def imageMetaData = taskService.getImageMetaData(taskInstance)

                //retrieve the existing values - if this is a multiple transcription task, we have to pick
                // which transcription to show.
                Transcription transcription = null //
                if (!taskInstance.fullyValidatedBy || taskInstance.project.requiredNumberOfTranscriptions == 1) { // If the task is not validated, pick a transcription.
                    // If the user has transcribed the Task, use the user's transcription.
                    String userId = currentUser
                    transcription = taskInstance.transcriptions.find{it.fullyTranscribedBy == userId}

                    // Otherwise use the transcription from the user notebook, if supplied.
                    if (params.userId) {
                        transcription = taskInstance.transcriptions.find{it.fullyTranscribedBy == params.userId}
                    }
                    if (!transcription) {
                        transcription = taskInstance.transcriptions.first()
                    }
                }
                Map recordValues = fieldSyncService.retrieveFieldsForTranscription(taskInstance, transcription)
                def adjacentTasks = taskService.getAdjacentTasksBySequence(taskInstance)
                def model = [
                        taskInstance: taskInstance,
                        recordValues: recordValues,
                        isReadonly: isReadonly,
                        template: template,
                        nextTask: adjacentTasks.next,
                        prevTask: adjacentTasks.prev,
                        sequenceNumber: adjacentTasks.sequenceNumber,
                        thumbnail: multimediaService.getImageThumbnailUrl(taskInstance.multimedia.first(), true)
                ]
                render(view: '/transcribe/templateViews/' + template.viewName, model: model)
            }
        }
    }

    def edit() {
        def currentUser = userService.currentUserId
        if (currentUser != null && userService.isAdmin()) {
            def taskInstance = Task.get(params.id)
            if (!taskInstance) {
                flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'task.label', default: 'Task'), params.id])}"
                redirect(action: "list")
            }
            else {
                return [taskInstance: taskInstance]
            }
        } else {
            flash.message = "You do not have permission to view this page"
            redirect(view: '/index')
        }
    }

    def update() {
        def taskInstance = Task.get(params.id)
        if (taskInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (taskInstance.version > version) {

                    taskInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'task.label', default: 'Task')] as Object[], "Another user has updated this Task while you were editing")
                    render(view: "edit", model: [taskInstance: taskInstance])
                    return
                }
            }
            taskInstance.properties = params
            if (!taskInstance.hasErrors() && taskInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'task.label', default: 'Task'), taskInstance.id])}"
                redirect(action: "show", id: taskInstance.id)
            }
            else {
                render(view: "edit", model: [taskInstance: taskInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'task.label', default: 'Task'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete() {
        def taskInstance = Task.get(params.id)
        if (taskInstance) {
            try {
                taskInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'task.label', default: 'Task'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'task.label', default: 'Task'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'task.label', default: 'Task'), params.id])}"
            redirect(action: "list")
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
                    transcriber: userService.detailsForUserId(task.fullyTranscribedBy)?.displayName,
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
            Task task = null;
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
            def projectInstance = task?.project
            def taskList = taskService.transcribedDatesByUserAndProject(userService.currentUserId, projectInstance.id, params.search_text)

            taskList = taskList.sort { it.lastEdit }

            if (task) {
                taskList.remove(task)
            }
            [projectInstance: projectInstance, taskList: taskList.toList(), taskInstance: task]
        }

    }

    def taskDetailsFragment() {
        def task = Task.get(params.int("taskId"))
        if (task) {

            def userId = userService.currentUserId

            def c = Field.createCriteria();

            def fields = c {
                and {
                    eq("task", task)
                    eq("superceded", false)
//                    eq("transcribedByUserId", userId)
                }
            }

            def lastEdit = fields.max({ it.updated })?.updated

            def projectInstance = task.project;
            def template = projectInstance.template;
            def templateFields = TemplateField.findAllByTemplate(template)

            def fieldMap = [:]
            def fieldLabels = [:]
            for (Field field : fields) {

                def templateField = templateFields.find {
                    it.fieldType.toString() == field.name
                }
                if (templateField && field.value && templateField.type != FieldType.hidden) {
                    def category = templateField.category;
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
                    fieldList << field;
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

            def projectInstance = task.project;
            def template = projectInstance.template;
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
        def projectInstance = Project.get(params.int("projectId"))
        if (!projectInstance) {
            redirect(controller: 'index')
            return
        }
        [projectInstance: projectInstance, hasDataFile: stagingService.projectHasDataFile(projectInstance), dataFileUrl:stagingService.dataFileUrl(projectInstance)]
    /*    def profile = ProjectStagingProfile.findByProject(projectInstance)
        if (!profile) {
            profile = new ProjectStagingProfile(project: projectInstance)
            profile.save(flush: true, failOnError: true)
        }

        if (!profile.fieldDefinitions.find { it.fieldName == 'externalIdentifier'}) {
            profile.addToFieldDefinitions(new StagingFieldDefinition(fieldDefinitionType: FieldDefinitionType.NameRegex, format: "^(.*)\$", fieldName: "externalIdentifier"))
        }

        cache false

        def images = stagingService.buildTaskMetaDataList(projectInstance)

        [projectInstance: projectInstance, images: images, profile:profile, hasDataFile: stagingService.projectHasDataFile(projectInstance), dataFileUrl:stagingService.dataFileUrl(projectInstance)]
        */
    }

    def stagedImages() {
        def projectInstance = Project.get(params.int("projectId"))
        def profile = ProjectStagingProfile.findByProject(projectInstance)
        if (!profile) {
            profile = new ProjectStagingProfile(project: projectInstance)
            profile.save(flush: true, failOnError: true)
        }

        if (!profile.fieldDefinitions.find { it.fieldName == 'externalIdentifier'}) {
            profile.addToFieldDefinitions(new StagingFieldDefinition(fieldDefinitionType: FieldDefinitionType.NameRegex, format: "^(.*)\$", fieldName: "externalIdentifier"))
        }

        cache false
        def images = stagingService.buildTaskMetaDataList(projectInstance)
        render template:'stagedImages', model: [images: images, profile:profile]
    }

    def selectImagesForStagingFragment() {
        def projectInstance = Project.get(params.int("projectId"))
        [projectInstance: projectInstance]
    }

    def editStagingFieldFragment() {
        def projectInstance = Project.get(params.int("projectId"))
        def fieldDefinition = StagingFieldDefinition.get(params.int("fieldDefinitionId"))
        def hasDataFile = stagingService.projectHasDataFile(projectInstance)
        def dataFileColumns = []
        if (hasDataFile) {
            dataFileColumns = ['']
            dataFileColumns.addAll(stagingService.getDataFileColumns(projectInstance))
        }
        [projectInstance: projectInstance, fieldDefinition: fieldDefinition, hasDataFile: hasDataFile, dataFileColumns: dataFileColumns ]
    }

    def uploadDataFileFragment() {
        def projectInstance = Project.get(params.int("projectId"))
        [projectInstance: projectInstance]
    }

    def uploadStagingDataFile() {
        def projectInstance = Project.get(params.int("projectId"))
        if (projectInstance) {
            if(request instanceof MultipartHttpServletRequest) {
                MultipartFile f = ((MultipartHttpServletRequest) request).getFile('dataFile')
                if (f != null) {
                    def allowedMimeTypes = ['text/plain','text/csv', 'application/octet-stream', 'application/vnd.ms-excel']
                    if (!allowedMimeTypes.contains(f.getContentType())) {
                        flash.message = "The image file must be one of: ${allowedMimeTypes}, recieved '${f.getContentType()}'}"
                        redirect(action:'staging', params:[projectId:projectInstance?.id])
                        return
                    }

                    if (f.size == 0 || !f.originalFilename) {
                        flash.message = "You must select a file to upload"
                        redirect(action:'staging', params:[projectId:projectInstance?.id])
                        return
                    }
                    stagingService.uploadDataFile(projectInstance, f)
                }
            }
        }
        redirect(action:'staging', params:[projectId:projectInstance?.id])
    }

    def uploadTaskDataFile() {
        def projectInstance = Project.get(params.int("projectId"))
        if (projectInstance) {
            if(request instanceof MultipartHttpServletRequest) {
                MultipartFile f = ((MultipartHttpServletRequest) request).getFile('dataFile')
                if (f != null) {
                    def allowedMimeTypes = ['text/plain','text/csv']
                    if (!allowedMimeTypes.contains(f.getContentType())) {
                        flash.message = "The file must be one of: ${allowedMimeTypes}"
                        redirect(action:'loadTaskData', params:[projectId:projectInstance?.id])
                        return
                    }
                    stagingService.uploadDataFile(projectInstance, f)
                }
            }
        }
        redirect(action:'loadTaskData', params:[projectId:projectInstance?.id])
    }

    def clearTaskDataFile() {
        def projectInstance = Project.get(params.int("projectId"))
        if (projectInstance) {
            stagingService.clearDataFile(projectInstance)
        }
        redirect(action:'loadTaskData', params:[projectId:projectInstance?.id])
    }

    def clearStagedDataFile() {
        def projectInstance = Project.get(params.int("projectId"))
        if (projectInstance) {
            stagingService.clearDataFile(projectInstance)
        }
        redirect(action:'staging', params:[projectId:projectInstance?.id])
    }

    def deleteAllStagedImages() {
        def projectInstance = Project.get(params.int("projectId"))
        if (projectInstance) {
            stagingService.deleteStagedImages(projectInstance)
        }
        redirect(action:'staging', params:[projectId:projectInstance?.id])
    }

    def stageImage() {

        int count = 0
        def projectInstance = Project.get(params.int("projectId"))
        if (projectInstance) {
            if(request instanceof MultipartHttpServletRequest) {
                ((MultipartHttpServletRequest) request).getMultiFileMap().imageFile.each { f ->
                    if (f != null) {
                        def allowedMimeTypes = ['image/jpeg', 'image/gif', 'image/png', 'text/plain']
                        if (!allowedMimeTypes.contains(f.getContentType())) {
                            flash.message = "The image file must be one of: ${allowedMimeTypes}"
                            return
                        }

                        try {
                            stagingService.stageImage(projectInstance, f)
                            count ++
                        } catch (Exception ex) {
                            flash.message = "Failed to upload image file: " + ex.message;
                        }
                    }

                }
            }

        }

        def processed = [:]
        processed.put("processed", count)
        render processed as JSON
    }

    def unstageImage() {
        def projectInstance = Project.get(params.int("projectId"))
        def imageName = params.imageName
        if (projectInstance && imageName) {
            try {
                if (!stagingService.unstageImage(projectInstance, imageName)) {
                    flash.message = "Failed to delete image. Possibly file permissions?"
                }
            } catch (Exception ex) {
                flash.message = "Failed to delete image: " + ex.message
            }
        }
        redirect(action:'staging', params:[projectId:projectInstance?.id])
    }

    def saveFieldDefinition() {
        def projectInstance = Project.get(params.int("projectId"))
        def fieldName = params.fieldName
        if (projectInstance && fieldName) {

            def fieldType = (params.fieldType as FieldDefinitionType) ?: FieldDefinitionType.Literal
            def format = params.format ?: ""
            def recordIndex = params.int("recordIndex") ?: 0

            def profile = ProjectStagingProfile.findByProject(projectInstance)

            def fieldDefinition = StagingFieldDefinition.get(params.int("fieldDefinitionId"))
            if (fieldDefinition) {
                // this is a 'save', not a 'create'
                fieldDefinition.fieldName = fieldName
                fieldDefinition.recordIndex = recordIndex
                fieldDefinition.fieldDefinitionType = fieldType
                fieldDefinition.format = format
                fieldDefinition.save(flush:true)
            } else {
                fieldDefinition = new StagingFieldDefinition(fieldDefinitionType: fieldType, format: format, fieldName: fieldName, recordIndex: recordIndex)
                profile.addToFieldDefinitions(fieldDefinition)
                fieldDefinition.save(flush: true)
            }

        }

        redirect(action:'staging', params:[projectId:projectInstance?.id])
    }

    def updateFieldDefinitionType() {
        def projectInstance = Project.get(params.int("projectId"))
        def fieldDefinition = StagingFieldDefinition.get(params.int("fieldDefinitionId"))
        String newFieldType = params.newFieldType
        if (projectInstance && fieldDefinition && newFieldType) {
            fieldDefinition.fieldDefinitionType = newFieldType
        }
        redirect(action:'staging', params:[projectId:projectInstance?.id])
    }

    def updateFieldDefinitionFormat() {
        def projectInstance = Project.get(params.int("projectId"))
        def fieldDefinition = StagingFieldDefinition.get(params.int("fieldDefinitionId"))
        String newFieldFormat = params.newFieldFormat
        if (projectInstance && fieldDefinition && newFieldFormat) {
            fieldDefinition.format = newFieldFormat
        }
        redirect(action:'staging', params:[projectId:projectInstance?.id])
    }

    def deleteFieldDefinition() {
        def projectInstance = Project.get(params.int("projectId"))
        def fieldDefinition = StagingFieldDefinition.get(params.int("fieldDefinitionId"))
        if (projectInstance && fieldDefinition) {
            fieldDefinition.delete()
        }
        redirect(action:'staging', params:[projectId:projectInstance?.id])
    }

    def loadStagedTasks() {

        def projectInstance = Project.get(params.int("projectId"))
        if (projectInstance) {
            def results = taskLoadService.loadTasksFromStaging(projectInstance)
            flash.message = results.message
            if (results.success) {
                redirect( controller:'loadProgress', action:'index')
                return
            }
        }
        redirect(action:'staging', params:[projectId:projectInstance?.id])
    }

    def exportStagedTasksCSV() {
        def projectInstance = Project.get(params.int("projectId"))

        if (projectInstance) {

            def profile = ProjectStagingProfile.findByProject(projectInstance)

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

            def images = stagingService.buildTaskMetaDataList(projectInstance)

            images.each {
                writer << it
            }

            response.writer.flush()
        }

    }

    def loadTaskData() {

        def projectInstance = Project.get(params.int("projectId"))
        if (!projectInstance) {
            flash.errorMessage = "No project/invalid project id!"
            redirect(controller:'admin', action:'index')
            return
        }

        def hasDataFile = stagingService.projectHasDataFile(projectInstance)
        def fieldValues = [:]
        def columnNames = []
        if (hasDataFile) {
            fieldValues = stagingService.buildTaskFieldValuesFromDataFile(projectInstance)
            if (fieldValues.size() > 0) {
                columnNames = fieldValues[fieldValues.keySet().first()].keySet().collect()
            }
        }

        [projectInstance: projectInstance, hasDataFile: hasDataFile, dataFileUrl:stagingService.dataFileUrl(projectInstance), fieldValues: fieldValues, columnNames: columnNames]
    }

    def processTaskDataLoad() {

        def projectInstance = Project.get(params.int("projectId"))
        if (projectInstance) {
            def results = stagingService.loadTaskDataFromFile(projectInstance)
            flash.message = results?.message
        }

        redirect(action:'loadTaskData', params:[projectId: projectInstance?.id])
    }

    def exportOptionsFragment() {
        [exportCriteria: params.exportCriteria, projectId: params.projectId]
    }

    def viewedTaskFragment() {
        def viewedTask = ViewedTask.get(params.int("viewedTaskId"));
        if (viewedTask) {
            def lastViewedDate = new Date(viewedTask?.lastView)
            def tc = TimeCategory.minus(new Date(), lastViewedDate)
            def agoString = "${tc} ago"

            [viewedTask: viewedTask, lastViewedDate: lastViewedDate, agoString: agoString]
        }
    }

    def resetTranscribedStatus() {

        def taskInstance = Task.get(params.int('id'))
        if (!taskInstance) {
            redirect(action: 'showDetails')
            return
        }

        if (!userService.isAdmin()) {
            flash.errorMessage = "Only ${message(code:"default.application.name")} administrators can perform this action!"
            redirect(action:'showDetails', id: taskInstance.id)
            return
        }

        taskService.resetTranscribedStatus(taskInstance)
        redirect(action:'showDetails', id: taskInstance.id)

    }

    def resetValidatedStatus() {

        def taskInstance = Task.get(params.int('id'))
        if (!taskInstance) {
            redirect(action: 'showDetails')
            return
        }
        if (!userService.isAdmin()) {
            flash.errorMessage = "Only ${message(code:"default.application.name")} administrators can perform this action!"
            redirect(action:'showDetails', id: taskInstance.id)
            return
        }

        taskService.resetValidationStatus(taskInstance)
        redirect(action:'showDetails', id: taskInstance.id)
    }

    def showChangedFields(Task task) {
        if (!task || !task.id) {
            response.sendError(SC_BAD_REQUEST, "must provide a task id")
            return
        }
        def fields = taskService.getChangedFields(task)
        respond(fields)
    }

    def viewTask(Task task) {
        if (!task || !task.id) {
            response.sendError(SC_BAD_REQUEST, "must provide a task id")
            return
        }
        def userId = userService.currentUser?.userId
        log.debug("Adding task view for $userId with task $task")
        auditService.auditTaskViewing(task, userService.currentUser.userId)
        respond status: SC_NO_CONTENT
    }

}
