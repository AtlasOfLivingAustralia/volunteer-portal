package au.org.ala.volunteer

import grails.converters.*

class TaskController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def taskService
    def fieldSyncService
    def fieldService
    def authService
    def ROLE_ADMIN = grailsApplication.config.auth.admin_role
    def load = {
        [projectList: Project.list()]
    }

    def project = {
        def projectInstance = Project.get(params.id)
        params.max = Math.min(params.max ? params.int('max') : 8, 16)
        params.order = params.order ? params.order : "asc"
        params.sort = params.sort ? params.sort : "id"
        def taskInstanceList = Task.findAllByProject(projectInstance, params)
        def taskInstanceTotal = Task.countByProject(projectInstance)
        render(view: "thumbs", model: [taskInstanceList: taskInstanceList, taskInstanceTotal: taskInstanceTotal, projectInstance: projectInstance])
    }

    def projectAdmin = {
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(ROLE_ADMIN)) {
            def projectInstance = Project.get(params.id)
            params.max = Math.min(params.max ? params.int('max') : 20, 50)
            params.order = params.order ? params.order : "asc"
            params.sort = params.sort ? params.sort : "id"
            def taskInstanceList
            def taskInstanceTotal
            def catalogNums
            def query = params.q
            if (query) {
                def fullList = Task.findAllByProject(projectInstance,[max:999])
                taskInstanceList = fieldService.findAllFieldsWithTasksAndQuery(fullList, query, params)
                taskInstanceTotal = fieldService.countAllFieldsWithTasksAndQuery(fullList, query)
                if (taskInstanceTotal) {
                    catalogNums = fieldService.getLatestFieldsWithTasks("catalogNumber", taskInstanceList, params)
                }
            } else {
                taskInstanceList = Task.findAllByProject(projectInstance,params)
                taskInstanceTotal = Task.countByProject(projectInstance)
                catalogNums = fieldService.getLatestFieldsWithTasks("catalogNumber", taskInstanceList, params)
            }
            // add some associated "field" values
            render(view: "list", model: [taskInstanceList: taskInstanceList, taskInstanceTotal: taskInstanceTotal,
                    projectInstance: projectInstance, catalogNums: catalogNums])
        } else {
            flash.message = "You do not have permission to view the Admin Task List page (${ROLE_ADMIN} required)"
            redirect(controller: "project", action: "index", id: params.id)
        }
    }

    /**
     * Webservice for Google Maps to display task details in infowindow
     */
    def details = {
        def taskInstance = Task.get(params.id)
        Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)
        def jsonObj = [:]
        jsonObj.put("cat", recordValues?.get(0).catalogNumber)
        jsonObj.put("name", recordValues?.get(0).scientificName)
        jsonObj.put("transcriber", User.findByUserId(taskInstance.fullyTranscribedBy).displayName)
        render jsonObj as JSON
    }

    def loadCSV = {
        taskService.loadCSV(params.int('projectId'), params.csv)
        redirect(action: "list")
    }

    def index = {
        redirect(action: "list", params: params)
    }

    /** list all tasks  */
    def list = {
        params.max = Math.min(params.max ? params.int('max') : 8, 16)
        params.order = params.order ? params.order : "asc"
        params.sort = params.sort ? params.sort : "id"
        render(view: "thumbs", model:[taskInstanceList: Task.list(params), taskInstanceTotal: Task.count()])
    }

    def thumbs = {
        params.max = Math.min(params.max ? params.int('max') : 8, 16)
        params.order = params.order ? params.order : "asc"
        params.sort = params.sort ? params.sort : "id"
        [taskInstanceList: Task.list(params), taskInstanceTotal: Task.count()]
    }

    def create = {
        def taskInstance = new Task()
        taskInstance.properties = params
        return [taskInstance: taskInstance]
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
        }
        else {
            [taskInstance: taskInstance]
        }
    }

    def edit = {
        def taskInstance = Task.get(params.id)
        if (!taskInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'task.label', default: 'Task'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [taskInstance: taskInstance]
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
}