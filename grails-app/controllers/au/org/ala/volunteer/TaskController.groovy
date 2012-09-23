package au.org.ala.volunteer

import grails.converters.*
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.codehaus.groovy.grails.commons.ConfigurationHolder
import javax.imageio.ImageIO

class TaskController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def taskService
    def fieldSyncService
    def fieldService
    def authService
    def taskLoadService
    def logService
    def userService

    def ROLE_ADMIN = grailsApplication.config.auth.admin_role
    def LAST_VIEW_TIMEOUT_MILLIS = grailsApplication.config.viewedTask.timeout


    def load = {
        [projectList: Project.list()]
    }

    def project = {
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

    def projectAdmin = {
        def currentUser = authService.username()
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

    def renderProjectListWithSearch(GrailsParameterMap params, String view) {

        def projectInstance = Project.get(params.id)

        def currentUser = authService.username()
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
            params.max = Math.min(params.max ? params.int('max') : 20, 50)
            params.order = params.order ? params.order : "asc"
            params.sort = params.sort ? params.sort : "id"
            def taskInstanceList
            def taskInstanceTotal
            def extraFields = [:] // Map
            def query = params.q

            if (query) {
                def fullList = Task.findAllByProject(projectInstance, [max: 999])
                taskInstanceList = fieldService.findAllFieldsWithTasksAndQuery(fullList, query, params)
                taskInstanceTotal = fieldService.countAllFieldsWithTasksAndQuery(fullList, query)
                if (taskInstanceTotal) {
                    fieldNames.each {
                        extraFields[it] = fieldService.getLatestFieldsWithTasks(it, taskInstanceList, params).groupBy { it.task.id }
                    }
                }
            } else {
                taskInstanceList = Task.findAllByProject(projectInstance, params)
                taskInstanceTotal = Task.countByProject(projectInstance)
                if (taskInstanceTotal) {
                    fieldNames.each {
                        extraFields[it] = fieldService.getLatestFieldsWithTasks(it, taskInstanceList, params).groupBy { it.task.id }
                    }
                }
            }

            // add some associated "field" values
            render(view: view, model: [taskInstanceList: taskInstanceList, taskInstanceTotal: taskInstanceTotal,
                    projectInstance: projectInstance, extraFields: extraFields, userInstance: userInstance])
        }
        else {
            flash.message = "No project found for ID " + params.id
        }
    }

    def renderListWithSearch(GrailsParameterMap params, List fieldNames, String view) {
        params.max = Math.min(params.max ? params.int('max') : 20, 50)
        params.order = params.order ? params.order : "asc"
        params.sort = params.sort ? params.sort : "id"
        def taskInstanceList
        def taskInstanceTotal
        def extraFields = [:] // Map
        def query = params.q
        log.info("q = " + query)
        if (query) {
            def max = params.max // store it
            def offset = params.offset?:0
            params.max = 999 // to get full list
            params.offset = 0
            def fullList = Task.list(params)
            params.max = max // reset for paging
            params.offset = offset
            taskInstanceList = fieldService.findAllFieldsWithTasksAndQuery(fullList, query, params)
            taskInstanceTotal = fieldService.countAllFieldsWithTasksAndQuery(fullList, query)
            if (taskInstanceTotal) {
                fieldNames.each {
                    extraFields[it] = fieldService.getLatestFieldsWithTasks(it, taskInstanceList, params)
                }
            }
        } else {
            taskInstanceList = Task.list(params)
            taskInstanceTotal = Task.count()
            fieldNames.each {
                extraFields[it] = fieldService.getLatestFieldsWithTasks(it, taskInstanceList, params)
            }
        }

        render(view: view, model: [taskInstanceList: taskInstanceList, taskInstanceTotal: taskInstanceTotal,
                extraFields: extraFields])
    }

    /**
     * Webservice for Google Maps to display task details in infowindow
     */
    def details = {
        def taskInstance = Task.get(params.id)
        Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)
        def jsonObj = [:]
        jsonObj.put("cat", recordValues?.get(0)?.catalogNumber)
        jsonObj.put("name", recordValues?.get(0)?.scientificName)
        jsonObj.put("transcriber", User.findByUserId(taskInstance.fullyTranscribedBy).displayName)
        render jsonObj as JSON
    }

    def loadCSV = {
        def projectId = params.int('projectId')

        if (params.csv) {
            def csv = params.csv;
            flash.message = taskService.loadCSV(projectId, csv)
        }
    }

    def loadCSVAsync = {
        def projectId = params.int('projectId')
        def replaceDuplicates = params.duplicateMode == 'replace'
        if (projectId && params.csv) {
            def project = Project.get(projectId)
            if (project) {
                def (success, message) = taskLoadService.loadTaskFromCSV(project, params.csv, replaceDuplicates)
                if (!success) {
                    flash.message = message + " - Try again when current load is complete."
                }
                redirect( uri: "/loadProgress.gsp")
            }
        }
    }

    def cancelLoad = {
        taskLoadService.cancelLoad()
        flash.message = "Cancelled!"
        redirect( uri: "/loadProgress.gsp")
    }

    def index = {
        redirect(action: "list", params: params)
    }

    /** list all tasks  */
    def list = {
        params.max = Math.min(params.max ? params.int('max') : 20, 50)
        params.order = params.order ? params.order : "asc"
        params.sort = params.sort ? params.sort : "id"
        //render(view: "list", model:[taskInstanceList: Task.list(params), taskInstanceTotal: Task.count()])
        if (params.id) {
            //redirect(action: "project", params: params)
            renderProjectListWithSearch(params, "list")
        } else {
            //render(view: "list", model:[taskInstanceList: Task.list(params), taskInstanceTotal: Task.count()])
            renderListWithSearch(params, ["catalogNumber","scientificName"], "list")
        }
    }

    def thumbs = {
        params.max = Math.min(params.max ? params.int('max') : 8, 16)
        params.order = params.order ? params.order : "asc"
        params.sort = params.sort ? params.sort : "id"
        [taskInstanceList: Task.list(params), taskInstanceTotal: Task.count()]
    }

    def create = {
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(ROLE_ADMIN)) {
            def taskInstance = new Task()
            taskInstance.properties = params
            return [taskInstance: taskInstance]
        } else {
            flash.message = "You do not have permission to view this page (${ROLE_ADMIN} required)"
            redirect(view: '/index')
        }
    }

    def save = {
        def taskInstance = new Task(params)
        if (taskInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'task.label', default: 'Task'), taskInstance.id])}"
            redirect(action: "show", id: taskInstance.id)
        }
        else {
            render(view: "create", model: [taskInstance: taskInstance])
        }
    }

    def show = {
        def taskInstance = Task.get(params.id)
        if (!taskInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'task.label', default: 'Task'), params.id])}"
            redirect(action: "list")
        } else {

            def currentUser = authService.username()

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

                    if (prevUserId != currentUser && millisecondsSinceLastView && millisecondsSinceLastView < LAST_VIEW_TIMEOUT_MILLIS) {
                        // task is already being viewed by another user (with timeout period)
                        log.warn "Task was recently viewed: " + (millisecondsSinceLastView / (60 * 1000)) + " min ago by ${prevUserId}"
                        msg = "This task is being viewed/edited by another user, and is currently read-only"
                        readonly = true
                    } else if (taskInstance.fullyValidatedBy && taskInstance.isValid != null) {
                        msg = "This task has been validated, and is currently read-only."
                        if (userService.isValidator(taskInstance.project)) {
                            def link = createLink(controller: 'validate', action: 'task', id: taskInstance.id)
                            msg += ' As a validator you may review/edit this task by clicking <a href="' + link + '">here</a>.'
                        }
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
                logService.log currentUser + " has role: ADMIN = " + authService.userInRole(ROLE_ADMIN) + " &&  VALIDATOR = " + isValidator

                def imageMetaData = taskService.getImageMetaData(taskInstance)

                //retrieve the existing values
                Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)
                render(view: '/transcribe/' + template.viewName, model: [taskInstance: taskInstance, recordValues: recordValues, isReadonly: isReadonly, template: template, imageMetaData: imageMetaData])
            }
        }
    }

    def edit = {
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(ROLE_ADMIN)) {
            def taskInstance = Task.get(params.id)
            if (!taskInstance) {
                flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'task.label', default: 'Task'), params.id])}"
                redirect(action: "list")
            }
            else {
                return [taskInstance: taskInstance]
            }
        } else {
            flash.message = "You do not have permission to view this page (${ROLE_ADMIN} required)"
            redirect(view: '/index')
        }
    }

    def update = {
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

    def delete = {
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

    def showImage = {

        if (params.id) {
            def task = Task.findById(params.int("id"))

            if (task) {
                Task prevTask = null
                Task nextTask = null
                Integer sequenceNumber = null;
                def field = Field.findByTaskAndName(task, "sequenceNumber")
                if (field) {
                    sequenceNumber = Integer.parseInt(field.value)
                    prevTask = taskService.findByProjectAndFieldValue(task.project, "sequenceNumber", (sequenceNumber - 1).toString())
                    nextTask = taskService.findByProjectAndFieldValue(task.project, "sequenceNumber", (sequenceNumber + 1).toString())
                }

                [taskInstance: task, sequenceNumber: sequenceNumber, prevTask:prevTask, nextTask:nextTask]
            }
        }
    }

    def taskBrowserFragment = {
        if (params.projectId) {
            Task task = null;
            if (params.taskId) {
                task = Task.get(params.int("taskId"))
            }
            def projectInstance = Project.get(params.int("projectId"))
            [projectInstance: projectInstance, taskInstance: task]
        }
    }


    def taskBrowserTaskList = {
        if (params.taskId) {
            def task = Task.get(params.int("taskId"))
            def projectInstance = task?.project
            def taskList = taskService.transcribedDatesByUserAndProject(getUserId(), projectInstance.id, params.search_text)

            taskList = taskList.sort { it.lastEdit }

            if (task) {
                taskList.remove(task)
            }
            [projectInstance: projectInstance, taskList: taskList.toList(), taskInstance: task]
        }

    }

    def getUserId = {
        def userId = authService.username();
        // overridden for testing --- please comment out!!!
        // userId = 'Donald.Hobern@csiro.au'
        return userId;
    }

    def taskDetailsFragment = {
        def task = Task.get(params.int("taskId"))
        if (task) {

            def userId = getUserId();

            def c = Field.createCriteria();

            def fields = c {
                and {
                    eq("task", task)
                    eq("superceded", false)
                    eq("transcribedByUserId", userId)
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

    def ajaxTaskData = {
        def task = Task.get(params.int("taskId"))

        def username = getUserId();

        if (task) {
            def c = Field.createCriteria();

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
        }
    }
}