package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationCookieUtils
import com.google.common.base.Stopwatch
import com.google.common.base.Strings
import grails.converters.JSON
import grails.gorm.transactions.Transactional
import grails.web.servlet.mvc.GrailsParameterMap
import org.apache.commons.io.FileUtils
import org.jooq.DSLContext
import org.springframework.dao.DataIntegrityViolationException
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest

import static au.org.ala.volunteer.jooq.tables.TaskDescriptor.TASK_DESCRIPTOR
import static java.util.concurrent.TimeUnit.MILLISECONDS
import static javax.servlet.http.HttpServletResponse.*

class ProjectController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST",
                             archive: "POST", toggleProjectInactivity: "POST",
                             wizardImageUpload: "POST", wizardClearImage: "POST", wizardAutosave: "POST", wizardCreate: "POST"]

    static numbers = ["Zero", "One", 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven',
                      'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen',
                      'Twenty']

    static final LABEL_COLOURS = ["label-success", "label-warning", "label-danger", "label-info", "label-primary", "label-default"]
    public static final int MAX_BACKGROUND_SIZE = 512 * 1024

    def taskService
    def fieldService
    def userService
    def exportService
    def projectService
    def picklistService
    def projectStagingService
    def authService
    def groovyPageRenderer
    def templateService
    Closure<DSLContext> jooqContext

    /**
     * Project home page - shows stats, etc.
     */
    def index() {
        def projectInstance = Project.get(params.long('id'))
        def showTutorial = (params.showTutorial == "true")

        // If the tutorial has been requested but the field is empty, redirect to tutorial index.
        if (showTutorial && Strings.isNullOrEmpty(projectInstance.tutorialLinks)) {
            redirect(controller: "tutorials", action: "index")
            return
        }

        String currentUserId = null

        def username = AuthenticationCookieUtils.getUserName(request)
        if (username) currentUserId = authService.getUserForEmailAddress(username)?.userId

        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.long('id')])}"
            redirect(action: "list")
        } else {
            // project info
            List userIds = taskService.getUserIdsAndCountsForProject(projectInstance, new HashMap<String, Object>())
            def expedition = grailsApplication.config.expedition as List
            def roles = [] //  List of Map
            // copy expedition data structure to "roles" & add "members"
            expedition.each {
                def row = it.clone() as Map
                row.put("members", [])
                roles.addAll(row)
            }

            userIds.each { it ->
                // iterate over each user and assign to a role.
                def userId = it[0] as String
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
            log.debug "roles = ${roles as JSON}"

            def leader = roles.find { it.name == "Expedition Leader" } ?.members?.getAt(0)

            def projectSummary = projectService.makeSummaryListFromProjectList([projectInstance], null, null,
                    null, null, null, null, null, null, false)?.projectRenderList?.get(0)

            def taskCount
            def tasksTranscribed
            if (projectSummary) {
                taskCount = projectSummary.taskCount
                tasksTranscribed = projectSummary.transcribedCount
            } else {
                taskCount = Task.countByProject(projectInstance)
                tasksTranscribed = Task.countByProjectAndIsFullyTranscribed(projectInstance, true)
            }

            def percentComplete = (taskCount > 0) ? ((tasksTranscribed / taskCount) * 100) : 0
            if (percentComplete > 99 && taskCount != tasksTranscribed) {
                // Avoid reporting 100% unless the transcribed count actually equals the task count
                percentComplete = 99
            }

            render(view: "index", model: [
                    projectInstance : projectInstance,
                    taskCount       : taskCount,
                    tasksTranscribed: tasksTranscribed,
                    roles           : roles,
                    currentUserId   : currentUserId,
                    leader          : leader,
                    percentComplete : percentComplete,
                    projectSummary  : projectSummary,
                    transcriberCount: userIds.size(),
                    showTutorial    : showTutorial
            ])
        }
    }

    /**
     * REST web service to return a list of tasks with coordinates to show on Google Map
     */
    def tasksToMap() {
        def projectInstance = Project.get(params.long('id'))
        def taskListFields = []

        if (projectInstance) {
            long startQ  = System.currentTimeMillis()
            def taskList = taskService.getFullyTranscribedTasks(projectInstance, [sort:"id", max:999])

            if (taskList.size() > 0) {
                def lats = fieldListToMap(fieldService.getLatestFieldsWithTasks("decimalLatitude", taskList, params))
                def lngs = fieldListToMap(fieldService.getLatestFieldsWithTasks("decimalLongitude", taskList, params))
                def cats = fieldListToMap(fieldService.getLatestFieldsWithTasks("catalogNumber", taskList, params))
                long endQ  = System.currentTimeMillis()
                log.debug("DB query took " + (endQ - startQ) + " ms")
                log.debug("List sizes: task = " + taskList.size() + "; lats = " + lats.size() + "; lngs = " + lngs.size())
                taskList.eachWithIndex { tsk, i ->
                    def jsonObj = [:]
                    jsonObj.put("id",tsk.id)
                    jsonObj.put("filename",tsk.externalIdentifier)
                    jsonObj.put("cat", cats[tsk.id])

                    if (lats.containsKey(tsk.id) && lngs.containsKey(tsk.id)) {
                        jsonObj.put("lat",lats.get(tsk.id))
                        jsonObj.put("lng",lngs.get(tsk.id))
                        taskListFields.add(jsonObj)
                    }
                }

                long endJ  = System.currentTimeMillis()
                log.debug("JSON loop took " + (endJ - endQ) + " ms")
                log.debug("Method took " + (endJ - startQ) + " ms for " + taskList.size() + " records")
            }
            render taskListFields as JSON
        } else {
            // no project found
            render("No project found for id: " + params.long('id')) as JSON
        }
    }

    /**
     * Output list of email addresses for a given project
     */
    def mailingList() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            def userIds = taskService.getUserIdsForProject(project)
            log.debug("userIds = " + userIds)
            def userEmails = userService.getEmailAddressesForIds(userIds as List<String>)
            def list = userEmails.join(";\n")
            render(text:list, contentType: "text/plain")
        } else {
            render("No project found for id: " + params.long('id'))
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
     * Produce an export file
     */
    def exportCSV() {
        def project = Project.get(params.long('id'))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        boolean transcribedOnly = params.transcribed?.toBoolean()
        boolean validatedOnly = params.validated?.toBoolean()

        if (project) {
            def sw = Stopwatch.createStarted()

            def taskList
            if (transcribedOnly) {
                taskList = taskService.getFullyTranscribedTasksAndTranscriptions(project, [max:9999, sort:"id"])
            } else if (validatedOnly) {
                taskList = taskService.getValidTranscribedTasks(project, [max:9999, sort:"id"])
            } else {
                taskList = taskService.getAllTasksAndTranscriptionsIfExists(project, [max: 9999])
            }

            log.debug("Got task list in ${sw.elapsed(MILLISECONDS)}ms")
            sw.reset().start()

            def fieldList = fieldService.getAllFieldsWithTasks(taskList)
            log.debug("Got all fields for tasks in ${sw.elapsed(MILLISECONDS)}ms")
            sw.reset().start()
            def fieldNames =  ["taskID", "taskURL", "validationStatus", "transcriberID", "validatorID",
                               "externalIdentifier", "exportComment", "dateTranscribed", "dateValidated"]
            fieldNames.addAll(fieldList.name.unique().sort() as List<String>)
            log.debug("Got all field names in ${sw.elapsed(MILLISECONDS)}ms")
            sw.reset().start()

            Closure export_func = exportService.export_default
            if (params.exportFormat == 'zip') {
                export_func = exportService.export_zipFile
            }

            if (export_func) {
                response.setHeader("Cache-Control", "must-revalidate")
                response.setHeader("Pragma", "must-revalidate")
                export_func(project, taskList, fieldNames, fieldList, response)
                log.debug("Ran export func in ${sw.elapsed(MILLISECONDS)}ms")
            } else {
                throw new Exception("No export function for template ${project.template.name}!")
            }

        } else {
            throw new Exception("No project found for id: " + params.long('id'))
        }
    }

    def deleteTasks() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }
        projectService.deleteTasksForProject(project, true)
        render '', status: SC_ACCEPTED
    }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 24, 1000)
        params.sort = params.sort ?: session.expeditionSort ? session.expeditionSort : 'completed'

        def projectSummaryList = projectService.getProjectSummaryList(params, false)
        def numberOfUncompletedProjects =
                projectSummaryList.numberOfIncompleteProjects < numbers.size() ?
                        numbers[projectSummaryList.numberOfIncompleteProjects] : "" + projectSummaryList.numberOfIncompleteProjects

        session.expeditionSort = params.sort
        def queryStringParams = [
                sort: params.sort,
                order: params.order,
                q: params.q,
                statusFilter: params.statusFilter,
                activeFilter: params.activeFilter,
                offset: params.offset,
                max: params.max
        ]
        log.debug("Query String: ${queryStringParams}")

        [
            projects: projectSummaryList.projectRenderList,
            filteredProjectsCount: projectSummaryList.matchingProjectCount,
            numberOfUncompletedProjects: numberOfUncompletedProjects,
            totalUsers: User.countByTranscribedCountGreaterThan(0),
            queryStringParams: queryStringParams
        ]
    }

    def customLandingPage() {
        String shortUrl = params.shortUrl ?: ''
        def offset = params.getInt('offset', 0)
        def max = Math.min(params.int('max', 24), 1000)
        def sort = params.sort ?: session.expeditionSort ? session.expeditionSort : 'completed'
        def order = params.getOrDefault('sort', 'asc').toString()
        def statusFilterMode = ProjectStatusFilterType.fromString(params?.statusFilter?.toString())
        def activeFilterMode = ProjectActiveFilterType.fromString(params?.activeFilter?.toString())
        def q = params.q ?: null

        LandingPage landingPage = LandingPage.findByShortUrl(shortUrl)
        if (!landingPage) {
            Long id = params.getLong('id')
            if (id) {
                landingPage = LandingPage.get(id)
            }
        }

        if (!landingPage) {
            if (shortUrl) {
                // if we've accidentally captured an attempt a controller default action, forward that here.
                log.debug("custom landing page caught $shortUrl")
                return forward(controller: shortUrl, params: params)
            } else {
                return redirect(uri: '/')
            }
        }

        ProjectType pt = landingPage.getProjectType()
        def labels = landingPage.label
        def tags = null
        if (labels && labels.size() > 0) {
            tags = labels*.value
        }

        def projectSummaryList = projectService.getProjectSummaryList(statusFilterMode, activeFilterMode, q, sort,
                offset, max, order, pt, tags, false)
        def numberOfUncompletedProjects =
                projectSummaryList.numberOfIncompleteProjects < numbers.size() ?
                        numbers[projectSummaryList.numberOfIncompleteProjects] : "" + projectSummaryList.numberOfIncompleteProjects

        session.expeditionSort = params.sort
        def queryStringParams = [
                sort: params.sort,
                order: params.order,
                statusFilter: params.statusFilter,
                activeFilter: params.activeFilter,
                offset: params.offset,
                max: params.max,
                shortUrl: shortUrl // This is needed to make customLandingPage links
            ]
        if (params.resetSearch) {
            queryStringParams.remove('q')
            params.remove('resetSearch')
        }
        log.debug("Query String: ${queryStringParams}")

        def model = [
                landingPageInstance: landingPage,
                projectType: pt.name,
                tags: tags,
                projects: projectSummaryList.projectRenderList,
                filteredProjectsCount: projectSummaryList.matchingProjectCount,
                numberOfUncompletedProjects: numberOfUncompletedProjects,
                totalUsers: User.countByTranscribedCountGreaterThan(0),
                queryStringParams: queryStringParams
        ]

        render(view: 'customLandingPage', model: model)
    }

    /**
     * Redirects an image for the supplied project
     */
    def showImage() {
        def project = Project.get(params.long('id'))
        if (project) {
            params.max = 1
            def task = Task.findByProject(project, params)
            if (task?.multimedia?.filePathToThumbnail) {
                redirect(url: grailsApplication.config.server.url + task?.multimedia?.filePathToThumbnail?.get(0))
            }
        }
    }

    def show() {
        def project = Project.get(params.long('id'))
        if (!project) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "list")
        } else {
            redirect(action: 'index', id: project.id, params: params)
        }
    }

    def create() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def institutionList = (userService.isSiteAdmin() ? Institution.listApproved([sort: 'name', order: 'asc']) : userService.getAdminInstitutionList())
        def projectTypes = ProjectType.listOrderByName()

        [institutionList: institutionList, projectTypes: projectTypes]
    }

    def save() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        Project project = new Project()
        bindData(project, params)

        if (params.institutionId) {
            Institution institution = Institution.get(params.long('institutionId') as long)
            if (institution) {
                project.institution = institution
            } else {
                project.errors.rejectValue("institution", "project.institution.required",
                        "Institution is required.")
            }
        }

        if (params.template) {
            if (!isValidTemplateView(((params.projectType) ? ProjectType.get(params.long('projectType') as long) : project.projectType),
                    Template.get(params.long('template') as long).viewName as String)) {
                project.errors.rejectValue("template", "project.template.notcompatible",
                        "Template is not compatible with expedition type.")
            }
        }

        if (project.errors.hasErrors()) {
            def institutionList = (userService.isSiteAdmin() ? Institution.listApproved([sort: 'name', order: 'asc']) : userService.getAdminInstitutionList())
            def projectTypes = ProjectType.listOrderByName()
            render(view: 'create', model: [projectInstance: project, params: params, institutionList: institutionList, projectTypes: projectTypes])
            return
        } else {
            if (!projectService.createProject(project)) {
                log.error("Error creating project, reloading create page.")
                flash.message = "An error occurred creating the Project."
                def institutionList = (userService.isSiteAdmin() ? Institution.listApproved([sort: 'name', order: 'asc']) : userService.getAdminInstitutionList())
                def projectTypes = ProjectType.listOrderByName()
                render(view: 'create', model: [params: params, institutionList: institutionList, projectTypes: projectTypes])
                return
            }
        }

        redirect(action: 'index', id: project?.id)
    }

    def edit() {
        def currentUser = userService.currentUserId
        Project p = Project.get(params.long('id'))
        if (currentUser != null && (userService.isSiteAdmin() || userService.isInstitutionAdmin(p?.institution))) {
            redirect(action:"editGeneralSettings", params: params)
        } else {
            flash.message = "You do not have permission to view this page"
            redirect(controller: "project", action: "index", id: params.long('id'))
        }
    }

    @Transactional
    def toggleProjectInactivity(Project project) {
        if (!project) {
            render status: 404
            return
        }

        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (!params.verifyId || params.verifyId as long != project.id) {
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return
        }

        // inactive == true, sets false, inactive == false, sets true
        project.inactive = (!project.inactive)
        if (!project.save(flush: true, failOnError: true)) {
            flash.message = "The expedition status was not able to be updated."
            render(view: '/notPermitted')
        } else {
            if (!project.inactive) {
                generateActivationNotification(project)
            }
            flash.message = "The expedition status has been updated."
            redirect(uri: request?.getHeader("referer") ?: createLink(controller: 'project', action: 'editGeneralSettings', id: project.id))
        }
    }

    def editGeneralSettings() {
        Project project = Project.get(params.long("id"))

        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (!project) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "list")
        } else {
            def editLists = getGeneralProjectLists(project)

            return [projectInstance: project,
                    templates      : editLists?.templates,
                    projectTypes   : ProjectType.listOrderByName(),
                    institutionList: editLists?.insts,
                    labelColourMap : editLists?.catColourMap,
                    sortedLabels   : editLists?.sortedLabels]
        }
    }

    def getGeneralProjectLists(Project project) {
        final insts = (userService.isSiteAdmin() ? Institution.listApproved([sort: 'name', order: 'asc']) : userService.getAdminInstitutionList())
        final labelCats = Label.withCriteria { projections { distinct 'category' } }
        final templates = templateService.getTemplatesForProject(project, userService.isSiteAdmin())

        final sortedLabels = project.labels.sort { a,b ->
            def x = a.category?.compareTo(b.category)
            return x == 0 ? a.value <=> b.value : x
        }

        def counter = 0
        final catColourMap = labelCats?.collectEntries { [(it): LABEL_COLOURS[counter++ % LABEL_COLOURS.size()]] }

        return [insts: insts, labelCats: labelCats, templates: templates, sortedLabels: sortedLabels, catColourMap: catColourMap]
    }

    def checkTemplateSupportMultiTranscriptions() {
        def project = Project.findById(params.long('projectId'))
        if (!projectService.isAdminForProject(project)) {
            render (["status": 403, "error": "Forbidden"] as JSON)
        } else {
            def template = Template.findById(params.long("templateId"))
            if (template) {
                render(["supportMultipleTranscriptions": "${template.supportMultipleTranscriptions}"] as JSON)
            } else {
                render(["supportMultipleTranscriptions": "false"] as JSON)
            }
        }
    }

    def editTutorialLinksSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (!project) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "list")
        } else {
            return [projectInstance: project, templates: Template.list(), projectTypes: ProjectType.list() ]
        }
    }

    def editPicklistSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (!project) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "list")
        } else {
            def picklistInstitutionCodes = [""]
            picklistInstitutionCodes.addAll(picklistService.getInstitutionCodes())

            return [projectInstance: project, picklistInstitutionCodes: picklistInstitutionCodes ]
        }
    }

    private def getCommonEditSettings(def params) {
        def projectInstance = Project.get(params.long("id"))
        if (!projectInstance) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "list")
        } else {
            return [projectInstance: projectInstance ]
        }
    }

    def editMapSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        return getCommonEditSettings(params)
    }

    def editBannerImageSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        return getCommonEditSettings(params)
    }

    def editBackgroundImageSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        return getCommonEditSettings(params)
    }

    def editTaskSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }
        def projectId = params.long("id")
        if (!project) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "list")
        } else {
            def currentlyLoading = jooqContext.call().fetchExists(TASK_DESCRIPTOR, TASK_DESCRIPTOR.PROJECT_ID.eq(projectId))
            def taskCount = Task.countByProject(project)
            return [projectInstance: project, taskCount: taskCount, currentlyLoading: currentlyLoading]
        }
    }

    def updateGeneralSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            if (params.name) {
                params.featuredLabel = params.name
            }

            if (!saveProjectSettingsFromParams(project, params)) {
                def editLists = getGeneralProjectLists(project)
                render(view: "editGeneralSettings", model: [projectInstance: project,
                                                            templates      : editLists?.templates,
                                                            projectTypes   : ProjectType.listOrderByName(),
                                                            institutionList: editLists?.insts,
                                                            labelColourMap : editLists?.catColourMap,
                                                            sortedLabels   : editLists?.sortedLabels])
            } else {
                redirect(action:'editGeneralSettings', id: project.id)
            }
        }  else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "list")
        }
    }

    def update() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            if (!saveProjectSettingsFromParams(project, params)) {
                render(view: "editGeneralSettings", model: [projectInstance: project])
            } else {
                redirect(action:'editGeneralSettings', id: project.id)
            }
        }  else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "list")
        }
    }

    def updateTutorialLinksSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            if (!saveProjectSettingsFromParams(project, params)) {
                render(view: "editTutorialLinksSettings", model: [projectInstance: project])
            } else {
                redirect(action:'editTutorialLinksSettings', id: project.id)
            }
        }  else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "list")
        }
    }

    def deleteAllTasksFragment() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }
        def taskCount = Task.countByProject(project)
        [projectInstance: project, taskCount: taskCount]
    }

    def deleteProjectFragment() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }
        def taskCount = Task.countByProject(project)
        [projectInstance: project, taskCount: taskCount]
    }

    private boolean saveProjectSettingsFromParams(Project project, GrailsParameterMap params) {
        if (!projectService.isAdminForProject(project)) {
            return false
        }

        if (project != null) {
            // Issue #371 - Activation notification
            def oldInactiveFlag = project.inactive == null ? false : project.inactive
            boolean newInactive = (params.inactive != null ? params.inactive == "true" : project.inactive)

            // If the user is toggling the inactive setting, only that parameter exists.
            if (params.inactive) {
                project.inactive = (params.inactive == "true")
            } else {
                if (params.version) {
                    def version = params.version.toLong()
                    if (project.version > version) {
                        project.errors.rejectValue("version", "default.optimistic.locking.failure",
                                [message(code: 'project.label', default: 'Project')] as Object[],
                                "Another user has updated this Project while you were editing")
                        return false
                    }
                }

                if (params.formType == Project.EDIT_SECTION_GENERAL) {
                    if (params.template) {
                        Template newTemplate = Template.get(params.long('template'))
                        if ((project.template.id != newTemplate.id) && newTemplate.isHidden) {
                            project.errors.rejectValue("template", "project.template.notavailable",
                                    [newTemplate.name] as Object[],
                                    "Template is no longer available.")
                            return false
                        }
                    }

                    log.debug("Institution from edit: ${params.institutionId}")
                    def inst = Institution.get(params.getLong('institutionId'))
                    if (inst) {
                        project.institution = inst
                    } else {
                        project.errors.rejectValue("institutionId", "project.institution.required",
                                [message(code: 'project.label', default: 'Project')] as Object[],
                                message(code: 'project.institution.required', default: 'Institution required') as String)
                        return false
                    }

                    if (params.template) {
                        if (!isValidTemplateView(((params.projectType) ? ProjectType.get(params.long('projectType')) : project.projectType),
                            Template.get(params.long('template')).viewName)) {
                            project.errors.rejectValue("template", "project.template.notcompatible",
                                    "Template is not compatible with expedition type.")
                            return false
                        }
                    }
                }

                bindData(project, params)

                if (!project.template.supportMultipleTranscriptions) {
                    project.transcriptionsPerTask = Project.DEFAULT_TRANSCRIPTIONS_PER_TASK
                    project.thresholdMatchingTranscriptions = Project.DEFAULT_THRESHOLD_MATCHING_TRANSCRIPTIONS
                }
            }

            if (!project.hasErrors() && projectService.saveProject(project)) {
                log.debug("inactive flag; old: ${oldInactiveFlag}, new: ${newInactive}")
                if (((oldInactiveFlag != newInactive) && (!newInactive))) {
                    log.info("Project was activated Sending project activation notification")
                    generateActivationNotification(project)
                }
                if (project.template.isHidden) {
                    flash.message = "Warning: Expedition updated, however, the selected template has been disabled. It is advisable to select a new template."
                } else {
                    flash.message = "Expedition updated"
                }
                return true
            } else {
                flash.message = "Expedition update failed"
            }
        }
        return false
    }

    private isValidTemplateView(ProjectType projectType, String viewName) {
        // log.debug("[isValidTemplateView]: ${(projectType.name == ProjectType.PROJECT_TYPE_AUDIO && viewName.contains("audio"))}")
        return (projectType.name == ProjectType.PROJECT_TYPE_AUDIO && viewName.contains("audio") ||
                projectType.name != ProjectType.PROJECT_TYPE_AUDIO && !viewName.contains("audio"))
    }

    private def generateActivationNotification(Project project) {
        def message = groovyPageRenderer.render(view: '/project/projectActivationNotification', model: [projectName: project.name])
        projectService.emailNotification(project, message, ProjectService.NOTIFICATION_TYPE_ACTIVATION)
    }

    def updatePicklistSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            if (!saveProjectSettingsFromParams(project, params)) {
                render(view: "editPicklistSettings", model: [projectInstance: project])
            } else {
                redirect(action:'editPicklistSettings', id: project.id)
            }
        }  else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "list")
        }
    }

    def delete() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            try {
                projectService.deleteProject(project)
                flash.message = message(code: 'default.deleted.message',
                         args: [message(code: 'project.label', default: 'Project'), project.name]) as String
                redirect(action: "manage")
            } catch (DataIntegrityViolationException e) {
                String message = message(code: 'default.not.deleted.message',
                          args: [message(code: 'project.label', default: 'Project'), project.name]) as String
                flash.message = message
                log.error(message, e)
                redirect(action: "show", id: params.long('id'))
            }
        } else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.long('id')]) as String
            redirect(action: "manage")
        }
    }
    
    def uploadFeaturedImage() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (request instanceof MultipartHttpServletRequest) {
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('featuredImage')
            
            if (f != null && f.size > 0) {
                def allowedMimeTypes = ['image/jpeg', 'image/png']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    flash.message = "Image must be one of: ${allowedMimeTypes}"
                    render(view: 'editBannerImageSettings', model: [projectInstance:project])
                    return
                }

                try {
                    def filePath = "${grailsApplication.config.images.home}/project/${project.id}/expedition-image.jpg"
                    def file = new File(filePath)
                    file.getParentFile().mkdirs()
                    f.transferTo(file)
                    projectService.checkAndResizeExpeditionImage(project)
                } catch (Exception ex) {
                    flash.message = "Failed to upload image: " + ex.message
                    log.error("Failed to upload image: " + ex.message, ex)
                    render(view: 'editBannerImageSettings', model: [projectInstance:project])
                    return
                }
            }
        }

        project.featuredImageCopyright = params.featuredImageCopyright
        projectService.saveProject(project)
        flash.message = "Expedition image settings updated."
        redirect(action: "editBannerImageSettings", id: params.long('id'))
    }

    def uploadBackgroundImage() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (request instanceof MultipartHttpServletRequest) {
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('backgroundImage')

            if (f != null && f.size > 0) {
                def allowedMimeTypes = ['image/jpeg', 'image/png']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    flash.message = "Image must be one of: ${allowedMimeTypes}"
                    render(view: 'editBackgroundImageSettings', model: [projectInstance:project])
                    return
                }

                if (f.size >= MAX_BACKGROUND_SIZE) {
                    flash.message = "Image size cannot be bigger than 512 KB (half a MB)"
                    render(view: 'editBackgroundImageSettings', model: [projectInstance:project])
                    return
                }

                try {
                    f.inputStream.withCloseable {
                        //project.setBackgroundImage(it, f.contentType)
                        projectService.setBackgroundImage(project, it, f.contentType)
                    }
                } catch (Exception ex) {
                    flash.message = "Failed to upload image: " + ex.message
                    log.error("Failed to upload image: " + ex.message, ex)
                    render(view: 'editBackgroundImageSettings', model: [projectInstance:project])
                    return
                }
            }
        }

        project.backgroundImageAttribution = params.backgroundImageAttribution
        project.backgroundImageOverlayColour = params.backgroundImageOverlayColour
        projectService.saveProject(project)
        flash.message = "Background image settings updated."
        redirect(action: "editBackgroundImageSettings", id: params.long('id'))
    }

    def clearBackgroundImageSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            project.backgroundImageAttribution = null
            project.backgroundImageOverlayColour = null
            //project.setBackgroundImage(null,null)
            projectService.setBackgroundImage(project, null, null)
        }

        flash.message = "Background image settings have been deleted."
        redirect(action: "editBackgroundImageSettings", id: params.long('id'))
    }

    def updateMapSettings() {
        def project = Project.get(params.long("id"))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            def showMap = params.showMap == "on"
            def zoom = params.int("mapZoomLevel")
            def latitude = params.double("mapLatitude")
            def longitude = params.double("mapLongitude")

            project.showMap = showMap

            if (zoom && latitude && longitude) {
                project.mapInitZoomLevel = zoom
                project.mapInitLatitude = latitude
                project.mapInitLongitude = longitude
            }
            flash.message = "Map settings updated"
            projectService.saveProject(project, true, true)
        }

        redirect(action: 'editMapSettings', id: project?.id)
    }

    def findProjectFragment() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        render(view: 'findProjectFragment')
    }

    def findProjectResultsFragment() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def q = params.q?.toString() ?: ""
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

    def addLabel(Project project) {
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        def labelId = params.long('labelId')
        def label = Label.get(labelId)
        if (!label) {
            render status: 404
            return
        }

        project.addToLabels(label)
        projectService.saveProject(project, true)

        // Just adding a label won't trigger the GORM update event, so force a project update
        DomainUpdateService.scheduleProjectUpdate(project.id)
        render status: 204
    }

    def removeLabel(Project project) {
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        def labelId = params.long('labelId')
        def label = Label.get(labelId)
        if (!label) {
            render status: 404
            return
        }

        project.removeFromLabels(label)
        projectService.saveProject(project, true)

        // Just adding a label won't trigger the GORM update event, so force a project update
        DomainUpdateService.scheduleProjectUpdate(project.id)
        render status: 204
    }

    def newLabels(Project project) {
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        def term = params.term ?: ''
        def ilikeTerm = "%${term.replace('%','')}%"
        def existing = project?.labels
        def labels

        if (existing) {
            def existingIds = existing*.id.toList()
            labels = Label.withCriteria {
                or {
                    ilike 'category', ilikeTerm
                    ilike 'value', ilikeTerm
                }
                not {
                    inList 'id', existingIds
                }
            }
        } else {
            labels = Label.findAllByCategoryIlikeOrValueIlike(ilikeTerm, ilikeTerm)
        }

        render labels as JSON
    }

    /**
     * Project Creation Wizard.
     * @deprecated
     * @param id
     */
    def wizard(String id) {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        if (!id) {
            def stagingId = UUID.randomUUID().toString()
            projectStagingService.ensureStagingDirectoryExists(stagingId)
            redirect(action: 'wizard', id: stagingId)
            return
        }

        if (!projectStagingService.stagingDirectoryExists(id)) {
            // this one has probably been cancelled or saved already
            redirect(action: 'wizard')
            return
        }

        def project = new NewProjectDescriptor(stagingId: id)

        def list = Institution.list()
        def institutions = list.collect { [id: it.id, name: it.name ] }
        def templates = Template.listOrderByName([:])
        def projectTypes = ProjectType.listOrderByName([:])
        def projectImageUrl = projectStagingService.hasProjectImage(project) ? projectStagingService.getProjectImageUrl(project) : null
        def labels = Label.list()
        def autosave = projectStagingService.getTempProjectDescriptor(id)

        def c = PicklistItem.createCriteria()
        def picklistInstitutionCodes = c {
            isNotNull("institutionCode")
            projections {
                distinct("institutionCode")
            }
            order('institutionCode')
        }

        final labelCats = Label.withCriteria { projections { distinct 'category' } }
        def counter = 0
        final catColourMap = labelCats.collectEntries { [(it): LABEL_COLOURS[counter++ % LABEL_COLOURS.size()]] }

        [
                stagingId: id,
                institutions: institutions,
                templates: templates,
                projectTypes: projectTypes,
                projectImageUrl: projectImageUrl,
                labels: labels,
                autosave: autosave,
                picklists: picklistInstitutionCodes,
                labelColourMap: catColourMap
        ]
    }

    /**
     * @deprecated
     * @param id
     */
    def wizardAutosave(String id) {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }
        projectStagingService.saveTempProjectDescriptor(id, request.reader)
        render status: 204
    }

    /**
     * @deprecated
     * @param id
     */
    def wizardImageUpload(String id) {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }

        def project = new NewProjectDescriptor(stagingId: id)
        def errors = []
        def errorStatus = SC_BAD_REQUEST
        def result = ""

        if (request instanceof MultipartHttpServletRequest) {
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('image')

            if (f != null && f.size > 0) {
                final allowedMimeTypes = ['image/jpeg', 'image/png']

                if (!allowedMimeTypes.contains(f.getContentType())) {
                    errors << "Image must be one of: ${allowedMimeTypes}"
                    errorStatus = SC_UNSUPPORTED_MEDIA_TYPE
                } else {
                    if (params.type == 'backgroundImageUrl') {
                        if (f.size > MAX_BACKGROUND_SIZE) {
                            errors << "Background image must be less than 512KB"
                            errorStatus = SC_REQUEST_ENTITY_TOO_LARGE
                        } else {
                            projectStagingService.uploadProjectBackgroundImage(project, f)
                            result = projectStagingService.getProjectBackgroundImageUrl(project)
                        }
                    } else {
                        projectStagingService.uploadProjectImage(project, f)
                        result = projectStagingService.getProjectImageUrl(project)
                    }
                }
            } else {
                errors << "No file provided?!"
            }
        }

        if (errors) {
            response.status = errorStatus
            render(errors as JSON)
        } else {
            render([imageUrl: !result ? "" : result] as JSON)
        }
    }

    /**
     * @deprecated
     * @param id
     */
    def wizardClearImage(String id) {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }

        def project = new NewProjectDescriptor(stagingId: id)
        def type = request.getJSON()?.type ?: ''
        if (type == 'background') {
            projectStagingService.clearProjectBackgroundImage(project)
        } else {
            projectStagingService.clearProjectImage(project)
        }
        render status: 204
    }

    /**
     * @deprecated
     * @param name
     */
    def wizardProjectNameValidator(String name) {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }

        render([ count: Project.countByName(name) ] as JSON)
    }

    /**
     * @deprecated
     * @param id
     */
    def wizardCancel(String id) {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }

        projectStagingService.purgeProject(new NewProjectDescriptor(stagingId: id))
        redirect(controller:'admin', action:"index")
    }

    /**
     * @deprecated
     * @param id
     */
    def wizardCreate(String id) {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }

        try {
            def body = request.getJSON()
            body.createdBy = userService.getCurrentUserId()
            def descriptor = NewProjectDescriptor.fromJson(id, body)

            log.debug("Attempting to create project with descriptor: $descriptor")

            def projectInstance = projectStagingService.createProject(descriptor)
            if (!projectInstance) {
                render status: 400
            } else {
                response.status = 201
                def obj = [id: projectInstance.id] as JSON
                render(obj)
            }
        } finally {
            projectStagingService.purgeProject(new NewProjectDescriptor(stagingId: id))
        }
    }

    def manage() {
        if (!userService.isInstitutionAdmin()) {
            response.sendError(SC_FORBIDDEN, "you don't have permission")
            return
        }

        def institutionList = (userService.isSiteAdmin() ? Institution.listApproved([sort: 'name', order: 'asc']) :
                userService.getAdminInstitutionList())

        def statusFilterList = [[key: "active", value: "Active"],
                                [key: "inactive", value: "Inactive"],
                                [key: "archived", value: "Archived"],
                                [key: "not-archived", value: "Not Archived"]]

        params.sort = (params.sort ?: 'id')
        params.order = (params.order ?: 'asc')
        params.max = (params.max ?: 20)
        if (params.sort == 'status') {
            if (params.order == 'asc') params.sortFields = ['inactive', 'archived', 'id']
            else params.sortFields = ['archived', 'inactive', 'id']
        }

        def institutionFilter = []
        Institution institution = (params.institutionFilter ? Institution.get(params.long('institutionFilter')) : null)
        if (institution) institutionFilter.add(institution)
        else institutionFilter = institutionList

        def statusFilter = (params.statusFilter ?: null)

        def results = getProjectsForManagement(institutionFilter, statusFilter)
        def projectList = results.projectList
        def completions = projectService.calculateCompletion(projectList)
        def totalProjects = results.count
        // Drop the sortFields to prevent junking up the querystring.
        params.remove('sortFields')

        List<ManageProject> projectsWithSize = projectList.collect {
            log.debug("Project: ${it}")
            final counts = completions[it.id as long]
            final transcribed
            final validated
            if (counts) {
                transcribed = (counts.transcribed / counts.total) * 100.0
                validated = (counts.validated / counts.total) * 100.0
            } else {
                transcribed = 0.0
                validated = 0.0
            }

            new ManageProject(project: it, percentTranscribed: transcribed, percentValidated: validated)
        }

        render(view: 'manage', model: ['archiveProjectInstanceList'    : projectsWithSize,
                                       'archiveProjectInstanceListSize': totalProjects,
                                       'imageStoreStats'               : projectService.imageStoreStats(),
                                       'institutionList'               : institutionList,
                                       'statusFilterList'              : statusFilterList])
    }

    /**
     * Private method to get list of projects for management.
     * Not in the service due to clash with JOOQ.
     * @param institutionFilter the list of Institutions to select projects for. Use an empty list for ALL projects.
     * @param params the query parameters (q, sort, order, max, offset etc)
     * @return a Map containing the projectList and count.
     */
    private def getProjectsForManagement(List institutionFilter, String statusFilter = null) {
        Closure fetchProjects = {
            if (institutionFilter?.size() > 0) {
                'in' ('institution', institutionFilter)
            }
            if (!Strings.isNullOrEmpty(params.q as String)) {
                or {
                    ilike('name', "%${params.q}%")
                }
            }
            if (statusFilter) {
                switch (statusFilter) {
                    case 'active':
                        and {
                            eq('inactive', false)
                            eq('archived', false)
                        }
                        break
                    case 'inactive':
                        and {
                            eq('inactive', true)
                            eq('archived', false)
                        }
                        break
                    case 'archived':
                        eq('archived', true)
                        break
                    case 'not-archived':
                        eq('archived', false)
                        break
                }
            }
        }
        List results = Project.createCriteria().list() {
            fetchProjects.delegate = delegate
            fetchProjects()
            maxResults(params.int('max'))
            firstResult(params.int('offset') ?: 0)
            if (params.sortFields) {
                params.sortFields.each {
                    order(it as String, params.order as String)
                }
            } else {
                order(params.sort as String, params.order as String)
            }
        } as List

        int resultCount = Project.createCriteria().get() {
            fetchProjects.delegate = delegate
            fetchProjects()
            projections {
                count('id')
            }
        } as int

        return [projectList: results, count: resultCount]
    }

    def cloneProjectFragment() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def project = Project.get(params.int("sourceProjectId"))
        [project: project]
    }

    def cloneProject() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def project = Project.get(params.int("projectId"))
        String newName = params.newName

        if (newName) {
            def existing = Project.findByName(newName)
            if (existing) {
                flash.message = message(code: 'project.clone.fail.existing.name', default: 'Cloning project failed.', args: [newName]) as String
                redirect(action: 'manage')
                return
            }
        }

        def newProject
        if (project && newName) {
            newProject = projectService.cloneProject(project, newName)
        }

        if (newProject) {
            redirect(action: 'edit', id: newProject.id)
        } else {
            flash.message = message(code: 'project.clone.fail', default: 'Cloning project failed.') as String
            redirect(action: 'manage')
        }
    }

    /**
     * @deprecated
     * @return
     */
    def archiveList() {
        final sw = Stopwatch.createStarted()
        if (!userService.isInstitutionAdmin()) {
            response.sendError(SC_FORBIDDEN, "you don't have permission")
            return
        }

        def institutionList
        if (userService.isSiteAdmin()) {
            institutionList = Institution.list([sort: 'name', order: 'asc'])
        } else {
            institutionList = userService.getAdminInstitutionList()
        }

        if (!params.sort) {
            params.sort = 'id'
            params.order = 'asc'
        }
        if (!params.max) {
            params.max = 20
        }

        def projects
        def total
        Institution institution
        if (params.institution) {
            institution = Institution.get(params.long('institution'))
        }

        if (institution && !Strings.isNullOrEmpty(params.q?.toString())) {
            if (institution) {
                projects = Project.findAllByArchivedAndInstitutionAndNameIlike(false, institution, "%${params.q}%", params)
                total = Project.countByArchivedAndInstitutionAndNameIlike(false, institution, "%${params.q}%")
            } else {
                projects = null
                total = 0
            }
        } else if (institution) {
            if (institution) {
                projects = Project.findAllByArchivedAndInstitution(false, institution, params)
                total = Project.countByArchivedAndInstitution(false, institution)
            } else {
                projects = null
                total = 0
            }
        } else {
            // No institution parameter, if Institution Admin, only show projects for their institutions.
            if (!userService.isSiteAdmin()) {
                if (!Strings.isNullOrEmpty(params.q?.toString())) {
                    projects = Project.findAllByArchivedAndNameIlikeAndInstitutionInList(false, "%${params.q}%", institutionList, params)
                    total = Project.countByArchivedAndNameIlikeAndInstitutionInList(false, "%${params.q}%", institutionList)
                } else {
                    projects = Project.findAllByArchivedAndInstitutionInList(false, institutionList, params)
                    total = Project.countByArchivedAndInstitutionInList(false, institutionList)
                }
            } else {
                if (!Strings.isNullOrEmpty(params.q?.toString())) {
                    projects = Project.findAllByArchivedAndNameIlike(false, "%${params.q}%", params)
                    total = Project.countByArchivedAndNameIlike(false, "%${params.q}%")
                } else {
                    projects = Project.findAllByArchived(false, params)
                    total = Project.countByArchived(false)
                }
            }

        }

        if (!projects) {
            projects = []
        }
        if (!total) {
            total = 0
        }
        sw.stop()
        log.debug("archiveList: findAllByArchived = $sw")

        sw.reset().start()
        def completions = projectService.calculateCompletion(projects)
        sw.stop()
        log.debug("archiveList: calculateCompletion = $sw")
        sw.reset().start()

        List<ManageProject> projectsWithSize = projects.collect {
            final counts = completions[it.id]
            final transcribed
            final validated
            if (counts) {
                transcribed = (counts.transcribed / counts.total) * 100.0
                validated = (counts.validated / counts.total) * 100.0
            } else {
                transcribed = 0.0
                validated = 0.0
            }
            new ManageProject(project: it, percentTranscribed: transcribed, percentValidated: validated)
        }

        respond(projectsWithSize, model: ['archiveProjectInstanceListSize': total,
                                          'imageStoreStats'               : projectService.imageStoreStats(),
                                          'institutionList'               : institutionList])
    }

    /**
     * @deprecated
     * @param project
     * @return
     */
    def projectSize(Project project) {
        if (!userService.isInstitutionAdmin()) {
            respond status: 403
        } else {
            def size
            if (!project.archived) {
                def projectSize = projectService.projectSize(project).size as long
                if (projectSize > 0) size = PrettySize.toPrettySize(BigInteger.valueOf(projectSize))
                else size = PrettySize.toPrettySize(BigInteger.valueOf(0))
            } else {
                size = PrettySize.toPrettySize(BigInteger.valueOf(0))
            }
            respond([size: size])
        }
    }

    /**
     * Archive project controller action. Archives a project or returns an error if not allowed.
     * @param project the project to archive.
     */
    def archive(Project project) {
        if (!projectService.isAdminForProject(project)) {
            log.error("Unauthorised access by ${userService.getCurrentUser()?.displayName}")
            render(view: '/notPermitted')
            return
        }

        try {
            projectService.archiveProject(project)
            log.debug("${project.name} (id=${project.id}) archived")
            flash.message = "${message(code: 'project.label', default: 'Project')} ${project.name} archived."
            redirect(action: 'manage', params: params)
        } catch (e) {
            flash.message = "An error occured while archiving ${project.name}."
            log.error("An error occured while archiving ${message(code: 'project.label', default: 'Project')} ${project}", e)
            redirect(action: 'manage', params: params)
        }
    }

    def downloadImageArchive(Project project) {
        if (!userService.isAdmin() && !userService.isInstitutionAdmin(project?.institution)) {
            response.sendError(SC_FORBIDDEN, "you don't have permission")
            return
        }
        response.contentType = 'application/zip'
        response.setHeader('Content-Disposition', "attachment; filename=\"${project.id}-${project.name}-images.zip\"")
        final os = response.outputStream
        try {
            projectService.writeArchive(project, os)
        } catch (e) {
            log.error("Exception while creating image archive for $project", e)
            //os.close()
        }
    }

    // Deprecated?
    def summary() {
        /*
        {
          "project": "Name of project or expidition",
          "contributors": "Number of individual users",
          "numberOfSubjects": "Number of total assets/specimens/subjects",
          "percentComplete": "0-100",
          "firstContribution": "UTC Timestamp",
          "lastContribution": "UTC Timestamp"
        }
         */
        final Project project
        def id = params.id
        if (id.isLong()) {
            project = Project.get(id as Long)
        } else {
            project = Project.findByName(id as String)
        }

        if (!project) {
            response.sendError(404, "project not found")
            return
        }

        def completions = projectService.calculateCompletion([project])[project.id]
        def numberOfSubjects = completions?.total
        def percentComplete = numberOfSubjects > 0 ? ((completions?.transcribed as Double) / ((numberOfSubjects ?: 1.0) as Double)) * 100.0 : 0.0
        def contributors = projectService.calculateNumberOfTranscribers(project)
        def dates = projectService.calculateStartAndEndTranscriptionDates(project)

        def result = [
                project: project.name,
                contributors: contributors,
                numberOfSubjects: numberOfSubjects,
                percentComplete: percentComplete,
                firstContribution: dates?.start,
                lastContribution: dates?.end
        ]

        respond result
    }

    def loadProgress(Project project) {
        if (!project || !projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
        } else {
            respond project
        }
    }
}
