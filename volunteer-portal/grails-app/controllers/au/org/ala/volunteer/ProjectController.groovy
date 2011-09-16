package au.org.ala.volunteer

import groovy.sql.Sql
import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.*
import au.com.bytecode.opencsv.CSVWriter

class ProjectController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def taskService
    def fieldService
    def auditService
    def fieldSyncService
    def authService
    javax.sql.DataSource dataSource
    def ROLE_ADMIN = grailsApplication.config.auth.admin_role
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
            // project info
            def taskCount = Task.countByProject(projectInstance)
            def tasksTranscribed = Task.countByProjectAndFullyTranscribedByIsNotNull(projectInstance)
            def userIds = taskService.getUserIdsAndCountsForProject(projectInstance)
            def expedition = ConfigurationHolder.config.expedition
            def roles = [] //  List of Map
            // copy expedition data structure to "roles" & add "members"
            expedition.each {
                def row = it.clone()
                row.put("members", [])
                roles.addAll(row)
            }
            
            userIds.each {
                // iterate over each user and assign to a role.
                def userId = it[0]
                def count = it[1]
                def assigned = false
                def user = User.findByUserId(userId)
                if (user) {
                    roles.eachWithIndex { role, i ->
                        if (count >= role.threshold && role.members.size() < role.max && !assigned) {
                            // assign role
                            def userMap = [name: user.displayName, id: user.id, count: count]
                            role.get("members").add(userMap)
                            assigned = true
                            log.debug("assigned: " + userId)
                        } else {
                            log.debug("not assigned: " + userId)
                        }
                    }
                }
            }

            // get the 5 most recent news items
            def recentNewsItems = projectInstance.newsItems.toArray()
            if (recentNewsItems.size() > 5) {
                recentNewsItems = recentNewsItems.getAt( [0..4] )
            }

            render(view: "index", model: [projectInstance: projectInstance, taskCount: taskCount, tasksTranscribed: tasksTranscribed, roles:roles, recentNewsItems: recentNewsItems])
        }
    }

    /**
     * REST web service to return a list of tasks with coordinates to show on Google Map
     */
    def tasksToMap = {
        def projectInstance = Project.get(params.id)
        def taskListFields = []

        if (projectInstance) {
            private long startQ  = System.currentTimeMillis();
            def taskList = Task.findAllByProjectAndFullyTranscribedByIsNotNull(projectInstance, [sort:"id", max:999])
            def lats = fieldListToMap(fieldService.getLatestFieldsWithTasks("decimalLatitude", taskList, params))
            def lngs = fieldListToMap(fieldService.getLatestFieldsWithTasks("decimalLongitude", taskList, params))
            private long endQ  = System.currentTimeMillis();
            log.debug("DB query took " + (endQ - startQ) + " ms")
            log.debug("List sizes: task = " + taskList.size() + "; lats = " + lats.size() + "; lngs = " + lngs.size())
            taskList.eachWithIndex { tsk, i ->
                def jsonObj = [:]
                jsonObj.put("id",tsk.id)

                if (lats.containsKey(tsk.id) && lngs.containsKey(tsk.id)) {
                    jsonObj.put("lat",lats.get(tsk.id))
                    jsonObj.put("lng",lngs.get(tsk.id))
                    taskListFields.add(jsonObj)
                }
            }

            private long endJ  = System.currentTimeMillis();
            log.debug("JSON loop took " + (endJ - endQ) + " ms")
            log.debug("Method took " + (endJ - startQ) + " ms for " + taskList.size() + " records")
            render taskListFields as JSON
        } else {
            // no project found
            render("No project found for id: " + params.id) as JSON
        }
    }

    /**
     * Output list of email addresses for a given project
     */
    def mailingList = {
        def projectInstance = Project.get(params.id)

        if (projectInstance && authService.userInRole(ROLE_ADMIN)) {
            def userIds = taskService.getUserIdsForProject(projectInstance)
            log.debug("userIds = " + userIds)
            //render(userIds)
            def list = userIds.join(";\n")
            render(text:list, contentType: "text/plain")
        }
        else if (projectInstance) {
            render("You do not have permission to access this page.")
        }
        else {
            render("No project found for id: " + params.id)
        }
    }

    /**
     * Utility to convert list of Fields to a Map with task.id as key
     *
     * @param fieldList
     * @return
     */
    Map fieldListToMap(List fieldList) {
        Map fieldMap = [:]
        fieldList.each {
            if (it.value) {
                fieldMap.put(it.task.id, it.value)
            }
        }

        return fieldMap
    }

    /**
     * Utility to convert list of Fields to a Map of Maps with task.id as key
     *
     * @param fieldList
     * @return
     */
    Map fieldListToMultiMap(List fieldList) {
        Map taskMap = [:]

        fieldList.each {
            if (it.value) {
                def fm = [:]

                if (taskMap.containsKey(it.task.id)) {
                    fm = taskMap.get(it.task.id)
                }

                fm[it.name] = it.value
                taskMap.put(it.task.id, fm)
            }
        }

        return taskMap
    }

    /**
     * Produce a DwC CSV file download for a project
     */
    def exportCSV = {
        def projectInstance = Project.get(params.id)
        boolean validatedOnly = params.validated.toBoolean()
        
        if (projectInstance) {
            def taskList
            if (validatedOnly) {
                taskList = Task.findAllByProjectAndIsValid(projectInstance, true, [sort:"id", max:9999])
            } else {
                taskList = Task.findAllByProjectAndFullyTranscribedByIsNotNull(projectInstance, [sort:"id", max:9999])
            }
            def taskMap = fieldListToMultiMap(fieldService.getAllFieldsWithTasks(taskList))
            def fieldNames =  ["taskID", "transcriberID", "validatorID", "externalIdentifier"]
            fieldNames.addAll(fieldService.getAllFieldNames(taskList))
            log.debug("Fields: "+ fieldNames);
            //render("tasks: " + taskList.size()) as JSON
            def filename = "Project-" + projectInstance.id + "-DwC"
            response.setHeader("Cache-Control", "must-revalidate");
            response.setHeader("Pragma", "must-revalidate");
            response.setHeader("Content-Disposition", "attachment;filename=" + filename +".txt");
            response.setContentType("text/plain");
            OutputStream fout= response.getOutputStream();
            OutputStream bos = new BufferedOutputStream(fout);
            OutputStreamWriter outputwriter = new OutputStreamWriter(bos);

            CSVWriter writer = new CSVWriter(outputwriter);
            // write header line (field names)
            writer.writeNext(fieldNames.toArray(new String[0]))

            taskList.each { task ->
                String[] values = getFieldsforTask(task, fieldNames, taskMap)
                writer.writeNext(values)
            }

            writer.close()
        }
        else {
            throw new Exception("No project found for id: " + params.id)
        }
    }

    String[] getFieldsforTask(Task task, List fields, Map taskMap) {
        List fieldValues = []
        def taskId = task.id

        if (taskMap.containsKey(taskId)) {
            def fieldMap = taskMap.get(taskId)
            fields.eachWithIndex { it, i ->

                if (i == 0) {
                    fieldValues.add(taskId.toString())
                }
                else if (i == 1) {
                    fieldValues.add(task.fullyTranscribedBy)
                }
                else if (i == 2) {
                    fieldValues.add(task.fullyValidatedBy)
                }
                else if (i == 3) {
                    fieldValues.add(task.externalIdentifier)
                }
                else if (fieldMap.containsKey(it)) {
                    fieldValues.add(fieldMap.get(it).replaceAll("\r\n|\n\r|\n|\r", '\\\\n'))
                }
                else {
                    fieldValues.add("") // need to leave blank
                }
            }
        }

        return fieldValues.toArray(new String[0]) // String array
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
