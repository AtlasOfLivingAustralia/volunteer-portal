package au.org.ala.volunteer

import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.*

import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.MultipartFile
import au.org.ala.cas.util.AuthenticationCookieUtils

class ProjectController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    static numbers = ["Zero","One", 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen', 'Twenty']

    def taskService
    def fieldService
    def auditService
    def fieldSyncService
    def authService
    def exportService
    javax.sql.DataSource dataSource
    def ROLE_ADMIN = grailsApplication.config.auth.admin_role
    /**
     * Project home page - shows stats, etc.
     */
    def index = {
        def projectInstance = Project.get(params.id)

        String currentUserId = null

        currentUserId = AuthenticationCookieUtils.getUserName(request)

        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            // project info
            def taskCount = Task.countByProject(projectInstance)
            def tasksTranscribed = Task.countByProjectAndFullyTranscribedByIsNotNull(projectInstance)
            def userIds = taskService.getUserIdsAndCountsForProject(projectInstance, new HashMap<String, Object>())
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
                            def userMap = [name: user.displayName, id: user.id, count: count, userId: user.userId]
                            role.get("members").add(userMap)
                            assigned = true
                            log.debug("assigned: " + userId)
                        } else {
                            log.debug("not assigned: " + userId)
                        }
                    }
                }
            }

            def leader = roles.find { it.name == "Expedition Leader" } ?.members.getAt(0)
            def items = projectInstance.newsItems.asList()
            def newsItem = items.size() > 0 ? items[0] : null;

            def percentComplete = (taskCount > 0) ? ((tasksTranscribed / taskCount) * 100) : 0
            if (percentComplete > 99 && taskCount != tasksTranscribed) {
                // Avoid reporting 100% unless the transcribed count actually equals the task count
                percentComplete = 99;
            }

            render(view: "index", model: [projectInstance: projectInstance, taskCount: taskCount, tasksTranscribed: tasksTranscribed, roles:roles, newsItem: newsItem, currentUserId: currentUserId, leader: leader, percentComplete: percentComplete])
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

            if (taskList.size() > 0) {
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
            }
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
                Map fm = null;

                if (taskMap.containsKey(it.task.id)) {
                    fm = taskMap.get(it.task.id)
                } else {
                    fm = [:]
                    taskMap[it.task.id] = fm
                }

                Map valueMap = null;
                if (fm.containsKey(it.name)) {
                   valueMap = fm[it.name]
                } else {
                    valueMap = [:]
                    fm[it.name] = valueMap
                }

                valueMap[it.recordIdx] = it.value
            }
        }

        return taskMap
    }

    /**
     * Produce a DwC CSV file download for a project
     */
    def exportCSV = {
        def projectInstance = Project.get(params.id)
        boolean transcribedOnly = params.transcribed?.toBoolean()
        boolean validatedOnly = params.validated?.toBoolean()

        if (projectInstance) {
            def taskList
            if (transcribedOnly) {
                taskList = Task.findAllByProjectAndFullyTranscribedByIsNotNull(projectInstance, [sort:"id", max:9999])
            } else if (validatedOnly) {
                taskList = Task.findAllByProjectAndIsValid(projectInstance, true, [sort:"id", max:9999])
            } else {
                taskList = Task.findAllByProject(projectInstance, [sort:"id", max:9999])
            }
            def taskMap = fieldListToMultiMap(fieldService.getAllFieldsWithTasks(taskList))
            def fieldNames =  ["taskID", "transcriberID", "validatorID", "externalIdentifier", "exportComment"]
            fieldNames.addAll(fieldService.getAllFieldNames(taskList))
            log.debug("Fields: "+ fieldNames);

            Closure export_func = exportService.export_default
            def exporter_func_property = exportService.metaClass.getProperties().find() { it.name == 'export_' + projectInstance.template.name }
            if (exporter_func_property) {
                export_func = exporter_func_property.getProperty(exportService)
            }

            if (export_func) {
                response.setHeader("Cache-Control", "must-revalidate");
                response.setHeader("Pragma", "must-revalidate");

                export_func(projectInstance, taskList, taskMap, fieldNames, response)
            } else {
                throw new Exception("No export function for template ${projectInstance.template.name}!")
            }

        }
        else {
            throw new Exception("No project found for id: " + params.id)
        }
    }

//    String[] getFieldsforTask(Task task, List fields, Map taskMap) {
//        List fieldValues = []
//        def taskId = task.id
//
//        def date = new Date().format("dd-MMM-yyyy")
//
//        if (taskMap.containsKey(taskId)) {
//            def fieldMap = taskMap.get(taskId)
//            fields.eachWithIndex { it, i ->
//
//                if (i == 0) {
//                    fieldValues.add(taskId.toString())
//                }
//                else if (i == 1) {
//                    fieldValues.add(task.fullyTranscribedBy)
//                }
//                else if (i == 2) {
//                    fieldValues.add(task.fullyValidatedBy)
//                }
//                else if (i == 3) {
//                    fieldValues.add(task.externalIdentifier)
//                }
//                else if (i == 4) {
//                    def sb = new StringBuilder()
//                    if (task.fullyTranscribedBy) {
//                        sb.append("Fully transcribed by ${task.fullyTranscribedBy}. ")
//                    }
//                    sb.append("Exported on ${date} from ALA Volunteer Portal (http://volunteer.ala.org.au)")
//                    fieldValues.add((String) sb.toString())
//                }
//                else if (fieldMap.containsKey(it)) {
//                    fieldValues.add(fieldMap.get(it).replaceAll("\r\n|\n\r|\n|\r", '\\\\n'))
//                }
//                else {
//                    fieldValues.add("") // need to leave blank
//                }
//            }
//        }
//
//        return fieldValues.toArray(new String[0]) // String array
//    }

    def deleteTasks = {

        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            def tasks = Task.findAllByProject(projectInstance)
            for (Task t : tasks) {
                t.delete()
            }
        }
        redirect(action: "edit", id: projectInstance?.id)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)

        params.sort = params.sort ? params.sort : session.expeditionSort ? session.expeditionSort : 'completed'

        def projectList = Project.list()

        def taskCounts = taskService.getProjectTaskCounts()
        def fullyTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts()

        def projects = [:]
        def incompleteCount = 0;
        for (Project project : projectList) {
            def percent = 0;
            if (taskCounts[project.id] && fullyTranscribedCounts[project.id]) {
                percent = ((fullyTranscribedCounts[project.id] / taskCounts[project.id]) * 100)
                if (percent > 99 && taskCounts[project.id] != fullyTranscribedCounts[project.id]) {
                    // Avoid reported 100% unless the transcribed count actually equals the task count
                    percent = 99;
                }
            }
            if (percent < 100) {
                incompleteCount++;
            }
            def iconImage = 'icon_specimens.png'
            def iconLabel = 'Specimens'

            if (project.template.name.equalsIgnoreCase('Journal') || project.template.name?.toLowerCase().startsWith("fieldnotebook")) {
                iconImage = 'icon_fieldnotes.png'
                iconLabel = 'Field notes'
            }

            def volunteer = User.findAll("from User where userId in (select distinct fullyTranscribedBy from Task where project_id = ${project.id})")

            projects[project.id] = [id: project.id, project: project, iconLabel: iconLabel, iconImage: iconImage, volunteerCount: volunteer.size(), countComplete: fullyTranscribedCounts[project.id] , percentComplete: percent ? Math.round(percent) : 0 ]

        }

        def numberOfUncompletedProjects = incompleteCount < numbers.size() ? numbers[incompleteCount] : "" + incompleteCount;

        def renderList = projects.collect({ kvp -> kvp.value })

        renderList = renderList.sort { p ->

            if (params.sort == 'completed') {
                return p.percentComplete
            }

            if (params.sort == 'volunteers') {
                return p.volunteerCount;
            }

            if (params.sort == 'institution') {
                return p.project.featuredOwner;
            }

            if (params.sort == 'type') {
                return p.iconLabel;
            }

            p.project.featuredLabel
        }

        int startIndex = params.offset ? params.int('offset') : 0;
        if (startIndex >= renderList.size()) {
            startIndex = renderList.size() - max;
            if (startIndex < 0) {
                startIndex = 0;
            }
        }

        int endIndex = startIndex + params.int('max') - 1;
        if (endIndex >= renderList.size()) {
            endIndex = renderList.size() - 1;
        }

        if (params.order == 'desc') {
            renderList = renderList.reverse()
        }


        session.expeditionSort = params.sort;

        [
            projects: renderList[startIndex .. endIndex],
            projectInstanceTotal: Project.count(),
            numberOfUncompletedProjects: numberOfUncompletedProjects
        ]
    }

    def create = {
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(ROLE_ADMIN)) {
            def projectInstance = new Project()
            projectInstance.properties = params
            return [projectInstance: projectInstance, templateList: Template.list()]
        } else {
            flash.message = "You do not have permission to view this page (${ROLE_ADMIN} required)"
            redirect(controller: "project", action: "index", id: params.id)
        }
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
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(ROLE_ADMIN)) {
            def projectInstance = Project.get(params.id)
            if (!projectInstance) {
                flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
                redirect(action: "list")
            } else {

                return [projectInstance: projectInstance, taskCount: Task.findAllByProject(projectInstance).size()]
            }
        } else {
            flash.message = "You do not have permission to view this page (${ROLE_ADMIN} required)"
            redirect(controller: "project", action: "index", id: params.id)
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
    
    def uploadFeaturedImage = {
        def projectInstance = Project.get(params.id)

        if(request instanceof MultipartHttpServletRequest) {
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('featuredImage')
            
            if (f != null) {
                def allowedMimeTypes = ['image/jpeg']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    flash.message = "Image must be one of: ${allowedMimeTypes}"
                    render(view:'edit', model:[projectInstance:projectInstance])
                    return;
                }

                try {
                    def filePath = "${ConfigurationHolder.config.images.home}/project/${projectInstance.id}/expedition-image.jpg"
                    def file = new File(filePath);
                    file.getParentFile().mkdirs();
                    f.transferTo(file);
                } catch (Exception ex) {
                    flash.message = "Failed to upload image: " + ex.message;
                    render(view:'edit', model:[projectInstance:projectInstance])
                    return;
                }

            }
        }
        redirect(action: "edit", id: params.id)
    }

    def setLeaderIconIndex = {
        if (params.id) {
            def project = Project.get(params.id)
            if (project) {
                def iconIndex = params.int("iconIndex")?:0
                def role = ConfigurationHolder.config.expedition[0]
                def icons = role.icons
                if (iconIndex >= 0 && iconIndex < icons.size()) {
                    project.leaderIconIndex = iconIndex
                    project.save()
                }
            }
        }

        redirect(action: "index", id: params.id)
    }
}
