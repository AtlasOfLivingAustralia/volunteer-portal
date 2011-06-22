package au.org.ala.volunteer

import groovy.sql.Sql
import org.codehaus.groovy.grails.commons.ConfigurationHolder

class ProjectController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def taskService
    def auditService
    def fieldSyncService
    javax.sql.DataSource dataSource

    /**
     * Project home page - shows stats, etc.
     */
    def index = {
        def projectInstance = Project.get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
        else {
            def taskCount = Task.executeQuery('select count(t) from Task t where t.project.id = :projectId', [projectId: projectInstance.id])
            def taskList = Task.findAllByProject(projectInstance, [max:999])
            def taskListFields = []
            def allUsersMap = [:]
            taskList.each {
                Map recordValues = fieldSyncService.retrieveFieldsForTask(it)
                def userId = it.fullyTranscribedBy
                recordValues?.get(0)?.transcribedBy = User.findByUserId(userId?:"")?.displayName
                taskListFields.add(recordValues)
                if (userId) {
                    def count = (allUsersMap.containsKey(userId)) ? (allUsersMap.get(userId) + 1) : 1
                    allUsersMap.put(userId , count)
                }
            }
            // reverse sort on user counts
            allUsersMap = allUsersMap.sort {a, b ->
                b.value <=> a.value
            }

            def expedition = ConfigurationHolder.config.expedition
            def roles = [] //  List of Map
            // copy expedition data structure to "roles" & add "members"
            expedition.each {
                def row = it.clone()
                row.put("members", [])
                roles.addAll(row)
            }

            allUsersMap.each { userId ->
                // iterate over each user and assign to a role.
                def assigned = false
                roles.eachWithIndex { role, i ->
                    if (userId.value >= role.threshold && role.members.size() < role.max && !assigned) {
                        // assign role
                        def user = User.findByUserId(userId.key)
                        def userMap = [name: user.displayName, id: user.id, count: userId.value]
                        role.get("members").add(userMap)
                        assigned = true
                    }
                }
            }

            render(view: "index", model: [projectInstance: projectInstance, taskCount: taskCount.get(0), taskList: taskList,
                    taskListFields: taskListFields, usersMap: allUsersMap, roles:roles])
        }
    }

    def deleteTasks = {

        def sql = new Sql(dataSource)
        def projectInstance = Project.get(params.id)
        sql.call("delete from task where project_id=" + params.id)

//      Multimedia.executeUpdate("delete Multimedia m inner join m.task where m.task.project.id = :projectId", [projectId:params.long('id')])
        //      Task.executeUpdate("delete Task t where t.project.id = :projectId", [projectId:params.long('id')])
        redirect(action: "show", id: projectInstance.id)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [projectInstanceList: Project.list(params), projectInstanceTotal: Project.count(),
                projectTaskCounts: taskService.getProjectTaskCounts(),
                projectFullyTranscribedCounts: taskService.getProjectTaskFullyTranscribedCounts(),
                projectTaskTranscribedCounts: taskService.getProjectTaskTranscribedCounts(),
                projectTaskValidatedCounts: taskService.getProjectTaskValidatedCounts(),
                projectTaskViewedCounts: auditService.getProjectTaskViewedCounts(),
                viewCountPerProject: auditService.getViewCountPerProject()
        ]
    }

    def create = {
        def projectInstance = new Project()
        projectInstance.properties = params
        return [projectInstance: projectInstance, templateList: Template.list()]
    }

    def save = {
        def projectInstance = new Project(params)
        if (projectInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'project.label', default: 'Project'), projectInstance.id])}"
            redirect(action: "show", model: [id: projectInstance.id])
        }
        else {
            render(view: "create", model: [projectInstance: projectInstance])
        }
    }

    /**
     * Redirects a image for the supplied project
     */
    def showImage = {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            params.max = 1
            def task = Task.findByProject(projectInstance, params)
            if (task?.multimedia?.filePathToThumbnail) {
                redirect(url: ConfigurationHolder.config.server.url + task?.multimedia?.filePathToThumbnail.get(0))
            }
        }
    }

    def show = {
        def projectInstance = Project.get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
        else {
            def taskCount = Task.executeQuery('select count(t) from Task t where t.project.id = :projectId', [projectId: projectInstance.id])
            [projectInstance: projectInstance, taskCount: taskCount]
        }
    }

    def edit = {
        def projectInstance = Project.get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [projectInstance: projectInstance]
        }
    }

    def update = {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (projectInstance.version > version) {

                    projectInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'project.label', default: 'Project')] as Object[], "Another user has updated this Project while you were editing")
                    render(view: "edit", model: [projectInstance: projectInstance])
                    return
                }
            }
            projectInstance.properties = params
            if (!projectInstance.hasErrors() && projectInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'project.label', default: 'Project'), projectInstance.id])}"
                redirect(action: "show", id: projectInstance.id)
            }
            else {
                render(view: "edit", model: [projectInstance: projectInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            try {
                projectInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
    }
}
