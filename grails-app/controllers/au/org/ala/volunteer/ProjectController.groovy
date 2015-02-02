package au.org.ala.volunteer

import grails.converters.*
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.MultipartFile
import au.org.ala.cas.util.AuthenticationCookieUtils

class ProjectController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    static numbers = ["Zero","One", 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen', 'Twenty']

    def grailsApplication
    def taskService
    def fieldService
    def logService
    def userService
    def exportService
    def collectionEventService
    def localityService
    def projectService
    def picklistService
    def projectStagingService
    def projectTypeService
    def authService

    /**
     * Project home page - shows stats, etc.
     */
    def index = {
        def projectInstance = Project.get(params.id)

        String currentUserId = null

        def username = AuthenticationCookieUtils.getUserName(request)
        if (username) currentUserId = authService.getUserForEmailAddress(username)?.userId

        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            // project info
            def taskCount = Task.countByProject(projectInstance)
            def tasksTranscribed = Task.countByProjectAndFullyTranscribedByIsNotNull(projectInstance)
            def userIds = taskService.getUserIdsAndCountsForProject(projectInstance, new HashMap<String, Object>())
            def expedition = grailsApplication.config.expedition
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
                            def details = userService.detailsForUserId(userId)
                            def userMap = [name: details.displayName, id: user.id, count: count, userId: user.userId]
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
            def newsItems = NewsItem.findAllByProject(projectInstance, [sort:'created', order:'desc', max: 1])

            def newsItem = null
            if (newsItems) {
                newsItem = newsItems?.first()
            }

            def projectSummary = projectService.makeSummaryListFromProjectList([projectInstance], params)?.projectRenderList?.get(0)

            def percentComplete = (taskCount > 0) ? ((tasksTranscribed / taskCount) * 100) : 0
            if (percentComplete > 99 && taskCount != tasksTranscribed) {
                // Avoid reporting 100% unless the transcribed count actually equals the task count
                percentComplete = 99;
            }

            render(view: "index", model: [projectInstance: projectInstance, taskCount: taskCount, tasksTranscribed: tasksTranscribed, roles:roles, newsItem: newsItem, currentUserId: currentUserId, leader: leader, percentComplete: percentComplete, newsItems: newsItems, projectSummary: projectSummary])
        }
    }

    /**
     * REST web service to return a list of tasks with coordinates to show on Google Map
     */
    def tasksToMap() {

        def projectInstance = Project.get(params.id)
        def taskListFields = []

        if (projectInstance) {
            long startQ  = System.currentTimeMillis();
            def taskList = Task.findAllByProjectAndFullyTranscribedByIsNotNull(projectInstance, [sort:"id", max:999])

            if (taskList.size() > 0) {
                def lats = fieldListToMap(fieldService.getLatestFieldsWithTasks("decimalLatitude", taskList, params))
                def lngs = fieldListToMap(fieldService.getLatestFieldsWithTasks("decimalLongitude", taskList, params))
                long endQ  = System.currentTimeMillis();
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

                long endJ  = System.currentTimeMillis();
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

        if (projectInstance && userService.isAdmin()) {
            def userIds = taskService.getUserIdsForProject(projectInstance)
            log.debug("userIds = " + userIds)
            def userEmails = userService.getEmailAddressesForIds(userIds)
            //render(userIds)
            def list = userEmails.join(";\n")
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
    private Map fieldListToMap(List fieldList) {
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
    private static Map fieldListToMultiMap(List fieldList) {
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
     * Produce an export file
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
            def fieldNames =  ["taskID", "validationStatus", "transcriberID", "validatorID", "externalIdentifier", "exportComment", "dateTranscribed", "dateValidated"]
            fieldNames.addAll(fieldService.getAllFieldNames(taskList))

            Closure export_func = exportService.export_default
            if (params.exportFormat == 'zip') {
                export_func = exportService.export_zipFile
            }

//            def exporter_func_property = exportService.metaClass.getProperties().find() { it.name == 'export_' + projectInstance.template.name }
//            if (exporter_func_property) {
//                export_func = exporter_func_property.getProperty(exportService)
//            }

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

    def deleteTasks = {
        def projectInstance = Project.get(params.id)
        projectService.deleteTasksForProject(projectInstance, true)
        redirect(action: "edit", id: projectInstance?.id)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 24, 1000)

        params.sort = params.sort ?: session.expeditionSort ? session.expeditionSort : 'completed'

        def projectSummaryList = projectService.getProjectSummaryList(params)

        def numberOfUncompletedProjects = projectSummaryList.numberOfIncompleteProjects < numbers.size() ? numbers[projectSummaryList.numberOfIncompleteProjects] : "" + projectSummaryList.numberOfIncompleteProjects;

        session.expeditionSort = params.sort;

        [
            projects: projectSummaryList.projectRenderList,
            filteredProjectsCount: projectSummaryList.matchingProjectCount,
            numberOfUncompletedProjects: numberOfUncompletedProjects
        ]
    }

    def create = {
        def currentUser = userService.currentUserId
        if (currentUser != null && userService.isAdmin()) {
            def projectInstance = new Project()
            projectInstance.properties = params

            def eventCollectionCodes = [""]
            eventCollectionCodes.addAll(collectionEventService.getCollectionCodes())

            def localityCollectionCodes = [""]
            localityCollectionCodes.addAll(localityService.getCollectionCodes())

            def picklistInstitutionCodes = [""]
            picklistInstitutionCodes.addAll(picklistService.getInstitutionCodes())

            return [projectInstance: projectInstance, templateList: Template.list(), eventCollectionCodes: eventCollectionCodes, localityCollectionCodes: localityCollectionCodes, picklistInstitutionCodes: picklistInstitutionCodes]
        } else {
            flash.message = "You do not have permission to view this page"
            redirect(controller: "project", action: "index", id: params.id)
        }
    }

    def save = {
        def projectInstance = new Project(params)

        if (!projectInstance.template) {
            flash.message = "Please select a template before continuing!"
            render(view: "create", model: [projectInstance: projectInstance])
            return
        }

        if (!projectInstance.featuredLabel) {
            flash.message = "You must supply a featured label!"
            render(view: "create", model: [projectInstance: projectInstance])
            return
        }

        if (projectInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'project.label', default: 'Project'), projectInstance.id])}"
            redirect(action: "index", id: projectInstance.id)
        } else {
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
                redirect(url: grailsApplication.config.server.url + task?.multimedia?.filePathToThumbnail.get(0))
            }
        }
    }

    def show = {
        def projectInstance = Project.get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            redirect(action:'index', id: projectInstance.id)
        }
    }

    def edit = {
        def currentUser = userService.currentUserId
        if (currentUser != null && userService.isAdmin()) {
            redirect(action:"editGeneralSettings", params: params)
            return
        } else {
            flash.message = "You do not have permission to view this page"
            redirect(controller: "project", action: "index", id: params.id)
        }
    }

    def editGeneralSettings() {
        def projectInstance = Project.get(params.int("id"))
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            final insts = Institution.list()
            final names = insts*.name
            final nameToId = insts.collectEntries { ["${it.name}": it.id] }
            return [projectInstance: projectInstance, templates: Template.listOrderByName(), projectTypes: ProjectType.listOrderByName(), institutions: names, institutionsMap: nameToId]
        }
    }

    def editTutorialLinksSettings() {
        def projectInstance = Project.get(params.int("id"))
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            return [projectInstance: projectInstance, templates: Template.list(), projectTypes: ProjectType.list() ]
        }
    }

    def editPicklistSettings() {
        def projectInstance = Project.get(params.int("id"))
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            def picklistInstitutionCodes = [""]
            picklistInstitutionCodes.addAll(picklistService.getInstitutionCodes())

            return [projectInstance: projectInstance, picklistInstitutionCodes: picklistInstitutionCodes ]
        }
    }

    def editMapSettings() {
        def projectInstance = Project.get(params.int("id"))
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            return [projectInstance: projectInstance ]
        }
    }

    def editBannerImageSettings() {
        def projectInstance = Project.get(params.int("id"))
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            return [projectInstance: projectInstance ]
        }
    }

    def editTaskSettings() {
        def projectInstance = Project.get(params.int("id"))
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            def taskCount = Task.countByProject(projectInstance)
            return [projectInstance: projectInstance, taskCount: taskCount]
        }
    }

    def editNewsItemsSettings() {
        def projectInstance = Project.get(params.int("id"))
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            def newsItems = NewsItem.findAllByProject(projectInstance, [sort:'created', order:'desc'])
            return [projectInstance: projectInstance, newsItems: newsItems]
        }
    }

    def updateGeneralSettings() {

        def projectInstance = Project.get(params.id)
        if (projectInstance) {

            if (params.name) {
                params.featuredLabel = params.name
            }

            final instId = params.getLong("institutionId")
            def inst
            if (instId && (inst = Institution.get(instId))) {
                projectInstance.institution = inst
            } else {
                projectInstance.institution = null
            }

            if (!saveProjectSettingsFromParams(projectInstance, params)) {
                render(view: "editGeneralSettings", model: [projectInstance: projectInstance])
            } else {
                redirect(action:'editGeneralSettings', id: projectInstance.id)
            }
        }  else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
    }

    def update() {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            if (!saveProjectSettingsFromParams(projectInstance, params)) {
                render(view: "editGeneralSettings", model: [projectInstance: projectInstance])
            } else {
                redirect(action:'editGeneralSettings', id: projectInstance.id)
            }
        }  else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
    }

    def updateTutorialLinksSettings() {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            if (!saveProjectSettingsFromParams(projectInstance, params)) {
                def newsItems = NewsItem.findAllByProject(projectInstance, [sort:'created', order:'desc'])
                render(view: "editTutorialLinksSettings", model: [projectInstance: projectInstance, newsItems: newsItems])
            } else {
                redirect(action:'editTutorialLinksSettings', id: projectInstance.id)
            }
        }  else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
    }

    def updateNewsItemsSettings() {

        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            if (!saveProjectSettingsFromParams(projectInstance, params)) {
                render(view: "editNewsItemsSettings", model: [projectInstance: projectInstance])
            } else {
                redirect(action:'editNewsItemsSettings', id: projectInstance.id)
            }
        }  else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
    }


    def deleteAllTasksFragment() {
        def projectInstance = Project.get(params.int("id"))
        def taskCount = Task.countByProject(projectInstance)
        [projectInstance: projectInstance, taskCount: taskCount]
    }

    def deleteProjectFragment() {
        def projectInstance = Project.get(params.int("id"))
        def taskCount = Task.countByProject(projectInstance)
        [projectInstance: projectInstance, taskCount: taskCount]
    }

    private boolean saveProjectSettingsFromParams(Project projectInstance, GrailsParameterMap params) {

        if (projectInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (projectInstance.version > version) {
                    projectInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'project.label', default: 'Project')] as Object[], "Another user has updated this Project while you were editing")
                    return false
                }
            }
            projectInstance.properties = params

            if (!projectInstance.hasErrors() && projectInstance.save(flush: true)) {
                flash.message = "Expedition updated"
                return true
            }
        }
        return false
    }

    def updatePicklistSettings() {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            if (!saveProjectSettingsFromParams(projectInstance, params)) {
                render(view: "editPicklistSettings", model: [projectInstance: projectInstance])
                return
            } else {
                redirect(action:'editPicklistSettings', id: projectInstance.id)
            }
        }  else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
    }


    def delete = {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            try {
                projectService.deleteProject(projectInstance)
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
            
            if (f != null && f.size > 0) {

                def allowedMimeTypes = ['image/jpeg', 'image/png']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    flash.message = "Image must be one of: ${allowedMimeTypes}"
                    render(view:'editBannerImageSettings', model:[projectInstance:projectInstance])
                    return;
                }

                try {
                    def filePath = "${grailsApplication.config.images.home}/project/${projectInstance.id}/expedition-image.jpg"
                    def file = new File(filePath);
                    file.getParentFile().mkdirs();
                    f.transferTo(file);
                    projectService.checkAndResizeExpeditionImage(projectInstance)
                } catch (Exception ex) {
                    flash.message = "Failed to upload image: " + ex.message;
                    render(view:'editBannerImageSettings', model:[projectInstance:projectInstance])
                    return;
                }
            }
        }

        projectInstance.featuredImageCopyright = params.featuredImageCopyright

        redirect(action: "editBannerImageSettings", id: params.id)
    }

    def resizeExpeditionImage() {
        def projectInstance = Project.get(params.int("id"))
        if (projectInstance) {
            projectService.checkAndResizeExpeditionImage(projectInstance)
        }
        redirect(action:'edit', id:projectInstance?.id)
    }

    def setLeaderIconIndex = {
        if (params.id) {
            def project = Project.get(params.id)
            if (project) {
                def iconIndex = params.int("iconIndex")?:0
                def role = grailsApplication.config.expedition[0]
                def icons = role.icons
                if (iconIndex >= 0 && iconIndex < icons.size()) {
                    project.leaderIconIndex = iconIndex
                    project.save()
                }
            }
        }

        redirect(action: "index", id: params.id)
    }

    def projectLeaderIconSelectorFragment() {
        def projectInstance = Project.get(params.getInt("id"))
        def expeditionConfig = grailsApplication.config.expedition
        // find the leader role from the config map
        def role = expeditionConfig.find { it.name == "Expedition Leader"}
        [projectInstance: projectInstance, role: role]
    }

    def updateMapSettings() {
        def projectInstance = Project.get(params.int("id"))
        if (projectInstance) {
            def showMap = params.showMap == "on"
            def zoom = params.int("mapZoomLevel")
            def latitude = params.double("mapLatitude")
            def longitude = params.double("mapLongitude")

            projectInstance.showMap = showMap

            if (zoom && latitude && longitude) {
                projectInstance.mapInitZoomLevel = zoom
                projectInstance.mapInitLatitude = latitude
                projectInstance.mapInitLongitude = longitude
            }
            flash.message = "Map settings updated"
        }
        redirect(action:'editMapSettings', id:projectInstance?.id)
    }

    def createNewProjectFlow = {

        def checkMandatory = { List errors, Map...paramDescriptors ->
            paramDescriptors?.each { paramDesc ->
                if (!params[paramDesc.name]) {
                    errors << "You must supply a ${paramDesc.label}"
                }
            }
        }

        welcome {
            onEntry {
                if (!flow.project) {
                    flow.project = new NewProjectDescriptor(stagingId: UUID.randomUUID().toString())
                }
            }
            onRender {
                def list = Institution.list()
                def institutions = list*.name
                def institutionsMap = list.collectEntries { [ (it.name): it.id ] }
                [institutions: institutions, institutionsMap: institutionsMap]
            }
            on("continue").to "institutionDetails"
            on("cancel").to "cancel"
        }

        institutionDetails {
            onEntry {
                println flow.project.featuredOwner
            }
            on("continue") {
                def errors = []
                if (!params.featuredOwner) {
                    errors << "You must supply the name of the project owner or sponsor"
                }

                if (errors) {
                    flow.errorMessages = errors
                    return validationError()
                } else {
                    flow.errorMessages = []
                }

                flow.project.featuredOwner = params.featuredOwner
                flow.project.featuredOwnerId = params.getLong('featuredOwnerId')
            }.to "projectDetails"
            on("cancel").to "cancel"
            on("back").to "welcome"
        }

        projectDetails {
            onEntry {
                flow.templates = Template.listOrderByName([:])
                flow.projectTypes = ProjectType.listOrderByName([:])
            }
            on("continue") {

                def errors = []

                checkMandatory(errors, [name:'projectName', label:'project name'], [name:'shortDescription', label: 'short description'], [name:'longDescription', label:'long description'])

                // The hibernate session (including it's cache) is included in the flow persistence context
                // which means that if we do a findByName below, and a project exists, it will stored.
                // Projects are currently not serializable because of an injected dependency, so we do the count
                // method instead
                def existing = Project.countByName(params.projectName)
                if (existing) {
                    errors << "A project with this name already exists. Choose another name"
                }

                if (errors) {
                    flow.errorMessages = errors
                    return validationError()
                } else {
                    flow.errorMessages = []
                }

                flow.project.name = params.projectName
                flow.project.shortDescription = params.shortDescription
                flow.project.longDescription = params.longDescription
                flow.project.templateId = Long.parseLong(params.templateId)
                flow.project.projectTypeId = Long.parseLong(params.projectTypeId)

            }.to "projectImage"

            on("cancel").to "cancel"
            on("back").to "institutionDetails"
        }

        projectImage {
            onEntry {
                if (projectStagingService.hasProjectImage(flow.project)) {
                    flow.projectImageUrl = projectStagingService.getProjectImageUrl(flow.project)
                } else {
                    flow.projectImageUrl = null
                }
            }

            on("continue") {

                def errors = []

                if(request instanceof MultipartHttpServletRequest) {
                    MultipartFile f = ((MultipartHttpServletRequest) request).getFile('featuredImage')
                    if (f != null && f.size > 0) {
                        def allowedMimeTypes = ['image/jpeg', 'image/png']
                        if (!allowedMimeTypes.contains(f.getContentType())) {
                            errors << "Image must be one of: ${allowedMimeTypes}"
                        } else {
                            projectStagingService.uploadProjectImage(flow.project, f)
                        }
                    }
                }

                flow.project.imageCopyright = params.imageCopyright

                if (errors) {
                    flow.errorMessages = errors
                    return validationError()
                } else {
                    flow.errorMessages = []
                }

            }.to "projectMap"

            on("clearImage") {
                projectStagingService.clearProjectImage(flow.project)
            }.to "projectImage"
            on("cancel").to "cancel"
            on("back").to "projectDetails"
        }

        projectMap {
            onEntry {
            }
            on("continue"){

                flow.project.showMap = params.showMap ? true : false
                if (params.showMap) {
                    flow.project.mapInitZoomLevel = Integer.parseInt(params.mapZoomLevel)
                    flow.project.mapInitLatitude = Double.parseDouble(params.mapLatitude)
                    flow.project.mapInitLongitude = Double.parseDouble(params.mapLongitude)
                }

            }.to "summary"
            on("cancel").to "cancel"
            on("back").to "projectImage"
        }

        summary {
            onEntry {
                if (projectStagingService.hasProjectImage(flow.project)) {
                    flow.projectImageUrl = projectStagingService.getProjectImageUrl(flow.project)
                } else {
                    flow.projectImageUrl = null
                }
                flow.projectTypeImageUrl = projectTypeService.getIconURL(ProjectType.get(flow.project.projectTypeId))
            }
            on("continue").to "createProject"
            on("cancel").to "cancel"
            on("back").to "projectMap"
        }

        createProject {
            action {
                def projectInstance = projectStagingService.createProject(flow.project as NewProjectDescriptor)
                if (!projectInstance) {
                    return fail()
                }
                flow.projectId = projectInstance.id
                flow.persistenceContext.evict(projectInstance)
            }
            on("success").to "createSuccess"
            on("fail").to "createFailure"
        }

        cancel {
            onEntry {
                projectStagingService.purgeProject(flow.project)
            }
            redirect(controller:'admin', action:"index")
        }

        createFailure {
            on("finish") {
                redirect(controller:'admin', action:"index")
            }
        }

        createSuccess {

            on("finish") {
                redirect(controller:'admin', action:"index")
            }

            on("createAnother") {
                redirect(controller:'project', action:"createNewProject")
            }

        }

        finish {
            redirect(controller:'admin', action:"index")
        }

    }

    def ajaxFeaturedOwnerList() {
        def c = Project.createCriteria()
        def results = c {
            ilike("featuredOwner", "%${params.q ?: ''}%")
            projections {
                distinct("featuredOwner")
            }
        }
        render(results as JSON)
    }

    def findProjectFragment() {

    }

    def findProjectResultsFragment() {

        def q = params.q as String ?: ""

        def c = Project.createCriteria()
        def projectList = c.list {
            or {
                ilike("name", "%${q}%")
                ilike("featuredOwner", "%${q}%")
                ilike("featuredLabel", "%${q}%")
                ilike("shortDescription", "%${q}%")
                ilike("description", "%${q}%")
            }
        }

        [projectList: projectList]

    }

}
