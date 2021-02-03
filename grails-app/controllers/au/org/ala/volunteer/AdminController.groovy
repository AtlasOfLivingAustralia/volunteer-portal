package au.org.ala.volunteer

import com.google.common.base.Strings
import grails.converters.JSON
import groovy.time.TimeCategory
import org.elasticsearch.action.search.SearchType
import grails.plugins.csv.CSVWriter
import org.hibernate.FlushMode
import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.MultipartFile

import java.text.SimpleDateFormat

class AdminController {

    def taskService
    def grailsCacheAdminService
    def tutorialService
    def sessionFactory
    def userService
    def projectService
    def fullTextIndexService
    //def domainUpdateService
    def eventSourceService

    def index() {
        checkAdminAccess(true)
        render(view: 'index')
    }

    def mailingList() {
        if (checkAdminAccess()) {
            def userIds = User.withCriteria {
                projections {
                    property('userId', 'userId')
                }
            }
            def emails = userService.getEmailAddressesForIds(userIds)
            def list = emails.join(";\n")
            render(text:list, contentType: "text/plain")
        }
    }

    /**
     * Checks if the current logged in user has the access privilleges to access the admin page.
     *
     * @return true if access allowed. Redirects to home page with flash message if no access.
     */
    boolean checkAdminAccess(Boolean includeInstitutionAdmin) {
        if (userService.isAdmin() || (includeInstitutionAdmin && userService.isInstitutionAdmin())) {
            log.info("Admin access allowed.")
            return true
        } else {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            redirect(uri: grailsApplication.config.grails.serverURL)
        }
    }

    /**
     * Main page request for managing Institution Admins.
     */
    def manageInstitutionAdmins() {
        checkAdminAccess(false)
        def institutionId = params.long('institution')
        def institution = Institution.get(institutionId)
        List institutionAdminRoles

        if (institution) {
            def c = UserRole.createCriteria()
            institutionAdminRoles = c.list() {
                and {
                    eq('role', Role.findByName(BVPRole.INSTITUTION_ADMIN))
                    eq('institution', institution)
                }
            }
        } else {
            institutionAdminRoles = UserRole.findAllByRole(Role.findByName(BVPRole.INSTITUTION_ADMIN))
        }
        institutionAdminRoles.sort {UserRole a, UserRole b ->
            a.role.name <=> b.role.name ?: a.institution?.name <=> b.institution?.name ?: a.user.lastName <=> b.user.lastName
        }
        render(view: 'manageInstitutionAdmins', model: [institutionAdminRoles: institutionAdminRoles])
    }

    /**
     * Adds a new {@link UserRole} for an Institution Admin.
     */
    def addInstituionAdmin() {
        checkAdminAccess(false)
        def currentUser = userService.getCurrentUser()
        def userId = params.userId
        def user = User.findByUserId(userId)

        if (!user) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), userId])
            redirect(action: 'manageInstitutionAdmins')
            return
        }

        def institutionId = params.long('institution')
        def institution = Institution.get(institutionId)
        if (!institution) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: 'institution.label', default: 'Institution'), institutionId])
            redirect(action: 'manageInstitutionAdmins')
            return
        }

        def role = Role.findByName(BVPRole.INSTITUTION_ADMIN)
        def userRole = new UserRole(user: user, role: role, institution: institution, createdBy: currentUser)
        userRole.save(flush: true, failOnError: true)
        flash.message = "Successfully added Institution Admin role to ${user.displayName}".toString()
        redirect(action: 'manageInstitutionAdmins')
    }

    /**
     * Deletes the selected Institution Admin {@link UserRole}.
     */
    def deleteUserRole() {
        checkAdminAccess(true)
        def currentUser = userService.getCurrentUser()
        def userRoleId = params.long('userRoleId')
        def userRole = UserRole.get(userRoleId)

        if (!userRole) {
            render ([status: "error",
                     message: message(code: 'default.not.found.message', args: [message(code: 'user.role.label', default: 'User Role'), userRoleId])] as JSON)
            return
        }

        // Because this action is run by both Site admins (for IA's) and IA's (for user roles), check that that user
        // has permission to delete the selected role
        // Also check, in the case of IA's, that they are not deleting another institution's role.
        if (userRole.role.name == BVPRole.INSTITUTION_ADMIN && !userService.isAdmin()) {
            log.error("Delete User Role: User ${currentUser.displayName} attempted deletion of Institution Admin role " +
                    "${userRole} without permission: ${userRole}")
            flash.message = "You do not have permission to delete role ${userRole.role.name} (held by ${userRole.user.displayName})."
            redirect(action: 'manageInstitutionAdmins')
            return
        } else if (!userService.isAdmin() && !userService.isInstitutionAdmin(userRole.getInstitution())) {
            log.error("Delete User Role: User ${currentUser.displayName} attempted deletion of user role ${userRole} " +
                    "without permission: ${userRole}")
            flash.message = "You do not have permission to delete role ${userRole.role.name} (held by ${userRole.user.displayName})."
            redirect(action: 'manageUserRoles')
            return
        }

        // TODO Do we log this somewhere for auditing?
        userRole.delete(flush: true)
        log.info("Institution Admin role held by ${userRole.user} was deleted by ${currentUser}")
        render ([status: "success"] as JSON)
    }

    def addUserRole() {
        checkAdminAccess(true)
        def currentUser = userService.getCurrentUser()
        def userId = params.userId
        def user = User.findByUserId(userId)

        if (!user) {
            log.error("Add user role: No user found for ${params.userId}")
            flash.message = message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), userId])
            redirect(action: 'manageUserRoles')
            return
        }

        def levelOption = params.opt
        def institutionId = params.long('institution')
        def institution = Institution.get(institutionId)
        def projectId = params.long('project')
        def project = Project.get(projectId)

        def level
        if (levelOption == "byinst") {
            level = 1
        } else if (levelOption == "byproj") {
            level = 2
        } else {
            log.error("Add user role: No project or institution found: project ID: ${params.projectId}, institution ID: ${params.institutionId}")
            flash.message = message(code: 'admin.user.role.not.created', args: [message(code: 'user.role.label', default: 'User Role'), 'missing Institution or Project ID'])
            redirect(action: 'manageUserRoles')
            return
        }

        def role = Role.get(params.userRole_role)
        if (!role) {
            log.error("Add user role: No role found: ${params.userRole_role}")
            flash.message = message(code: 'admin.user.role.not.created', args: [message(code: 'user.role.label', default: 'User Role'), 'missing role type'])
            redirect(action: 'manageUserRoles')
            return
        }

        log.debug("Adding new user role: ${params.userRole_role}, projectId: ${projectId}, institutionId: ${institutionId}, user: ${user}")

        def userRole
        if (level == 1) {
            userRole = new UserRole(user: user, role: role, institution: institution, createdBy: currentUser)
        } else {
            userRole = new UserRole(user: user, role: role, project: project, createdBy: currentUser)
        }

        if (userRole) {
            userRole.save(flush: true, failOnError: true)
            log.debug("Saved User Role: ${userRole}")
            flash.message = "Successfully added User role to ${user.displayName}".toString()
        }

        def reloadParams = [:]
        if (params.institution)  reloadParams.institution = params.institution

        redirect(action: 'manageUserRoles', params: reloadParams)
    }

    def manageUserRoles() {
        checkAdminAccess(true)
        def parameters = [:]

        def institutionId = params.long('institution')
        def institution = Institution.get(institutionId)
        if (institution) parameters.institution = institution.id

        if (params.max) parameters.max = params.int('max')
        else params.max = parameters.max = 25

        if (params.offset) parameters.offset = params.int('offset')

        // Obtain the available institutions/projects (i.e. if Institution Admin, only allow access to that
        // institution's roles).
        // If an IA, add that to the userRole query parameters.
        def institutionList = (!userService.isSiteAdmin() ? userService.getAdminInstitutionList() : Institution.list(sort: 'name', order: 'asc'))
        if (!userService.isSiteAdmin()) parameters.institutionList = institutionList

        def projectList
        if (!userService.isSiteAdmin()) {
            def query = Project.where {
                institution in institutionList
            }
            projectList = query.list(sort: "name")
            parameters.projectList = projectList
        } else {
            projectList = Project.list(sort: 'name', order: 'asc')
        }

        if (!Strings.isNullOrEmpty(params.q)) {
            parameters.q = params.q
        }

        if (!Strings.isNullOrEmpty(params.userid)) {
            parameters.userid = params.userid
        }

        Map userRoles = userService.listUserRoles(parameters)
        List userRoleList = userRoles.userRoleList
        log.debug("userRoleList.size(): ${userRoleList.size()}")

        render(view: 'manageUserRoles', model: [institutionList: institutionList,
                                                projectList: projectList,
                                                userRoleList: userRoleList,
                                                userRoleTotalCount: userRoles.totalCount])
    }

    def tutorialManagement() {
        def searchTerm = (params.q) ? params.q : null
        def tutorials = tutorialService.listTutorials(searchTerm)
        [tutorials: tutorials]
    }

    def uploadTutorial() {

        if(request instanceof MultipartHttpServletRequest) {
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('tutorialFile')
            if (f != null) {
                def allowedMimeTypes = ['application/pdf']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    flash.message = "The file must be one of: ${allowedMimeTypes}"
                    redirect(action:'tutorialManagement')
                    return;
                }

                try {
                    tutorialService.uploadTutorialFile(f)
                    flash.message = "Tutorial uploaded successfully";
                } catch (Exception ex) {
                    flash.message = "Failed to upload tutorial file: " + ex.message;
                    log.error("Failed to upload tutorial file: " + ex.message, ex)
                }

            }
        }

        redirect(action:'tutorialManagement')
    }

    def deleteTutorial() {
        def filename = params.tutorialFile
        if (filename) {
            try {
                tutorialService.deleteTutorial(filename)
                flash.message = "Tutorial deleted successfully"
            } catch (Exception ex) {
                flash.message = "Failed to delete tutorial file: " + ex.message
                log.error("Failed to delete tutorial file: " + ex.message, ex)
            }
        }
        redirect(action:'tutorialManagement')
    }

    def renameTutorial() {
        def filename = params.tutorialFile
        def newName = params.newName

        if (filename && newName) {
            try {
                tutorialService.renameTutorial(filename, newName)
            } catch (Exception ex) {
                flash.message = "Failed to rename tutorial file: " + ex.message
                log.error("Failed to rename tutorial file: " + ex.message)
            }
        }

        redirect(action:'tutorialManagement')
    }

    /**
     * Some template definitions include recordedByID as a hidden field which conflicts with an existing "hard-coded" version of the same field
     * This results in the field values becoming an array, which ends up causing the value to lost completely as the array is 'toString'ed into the database
     * This routine attempts to find all 'recorded by id' fields whose value contains 'String' and attempts to look up the real collector id from a relevant picklist.
     * It is entirely possible that not collector id can be found, in which case the field value is cleared
     */
    def fixRecordedByID() {
        if (!checkAdminAccess()) {
             throw new RuntimeException("Not authorised!")
        }

        // First find the candidate fields
        def fields = Field.findAllByNameAndValueLikeAndSuperceded('recordedByID', '%String%', false)
        def count = 0
        def collectorsFound = 0
        def picklist = Picklist.findByName("recordedBy")

        sessionFactory.currentSession.setFlushMode(FlushMode.MANUAL)

        try {
            fields.each { field ->
                // find the collector name
                def collectorNameField = Field.findByTaskAndNameAndRecordIdxAndSuperceded(field.task, "recordedBy", field.recordIdx, false)
                def collectorName = collectorNameField?.value
                def newValue = ''

                if (collectorName) {
                    def instCode = field.task.project.picklistInstitutionCode
                    def items
                    if (instCode) {
                        items = PicklistItem.findAllByPicklistAndInstitutionCodeAndValue(picklist, instCode, collectorName)
                    } else {
                        items = PicklistItem.findAllByPicklistAndValue(picklist, collectorName)
                    }

                    if (items && items.size() > 0) {

                        if (items.size() == 1 && items[0].key) {
                            newValue = items[0].key
                            log.debug("1st chance. Found one collector number for ${collectorName}: ${newValue}")
                        } else {
                            for (int i = 0; i < items.size(); ++i) {
                                def item = items[i]
                                if (item.key) {
                                    log.debug("2nd chance. Found a collector number for ${collectorName}: ${newValue}")
                                    newValue = item.key
                                    break;
                                }
                            }
                        }
                    }
                }

                log.debug("Updating field ${field.id} value from '${field.value}' to '${newValue}'.")
                field.value = newValue;

                if (newValue) {
                    collectorsFound++
                }

                count++
                if (count % 1000 == 0) {
                    // Doing this significantly speeds up imports...
                    sessionFactory.currentSession.flush()
                    log.debug("${count} rows flushed.")
                }
            }
            // flush the last lot
            sessionFactory.currentSession.flush()
        } finally {
            sessionFactory.currentSession.flushMode = FlushMode.AUTO
        }

        def message = "${count} fields updated, $collectorsFound of which were set to a collector number."
        flash.message = message
        log.debug(message)

        redirect(action:'index')
    }


    def fixUserCounts() {

        if (!checkAdminAccess()) {
             throw new RuntimeException("Not authorised!")
        }

        def users = User.list();
        int count = 0
        users.each { user ->
            def transcribedCount = Task.countByFullyTranscribedBy(user.userId)
            def validatedCount = Task.countByFullyValidatedBy(user.userId)

            if (user.transcribedCount < transcribedCount) {
                // Don't hit network to get email address here as it's only logging
                log.debug("Updating transcribed count for ${user.userId} (${user.email}) from ${user.transcribedCount} to ${transcribedCount}")
                user.transcribedCount = transcribedCount
            }

            if (user.validatedCount < validatedCount) {
                // Don't hit network to get email address here as it's only logging
                log.debug("Updating validated count for ${user.userId} (${user.email}) from ${user.validatedCount} to ${validatedCount}")
                user.validatedCount = validatedCount
            }
            count++
        }

        flash.message ="${count} users checked."

        redirect(action:'index')
    }

    def currentUsers() {
    }

    def userActivityInfo() {
        def activities = UserActivity.list([sort:'timeLastActivity', order:'desc'])
        def emailToIdMap
        if (activities) {
            emailToIdMap = User.withCriteria {
                inList('email', activities*.userId)
                projections {
                    property('email')
                    property('userId')
                }
            }.toMap()
        } else {
            emailToIdMap = [:]
        }

        def actWithOpenEventSources = activities*.properties.collect { it + [ openESRequests: eventSourceService.getOpenRequestsForUser(emailToIdMap[it.userId] ?: '') ] }
        respond([activities: actWithOpenEventSources])
    }

    def tools() {
    }

    def mappingTool() {

    }

    def migrateProjectsToInstitutions() {
        final projectsWithOwners = Project.executeQuery("select new map (id as id, name as name, featuredOwner as featuredOwner) from Project where institution is null order by ${params.sort ?: 'featuredOwner'} ${params.order ?: 'asc'}").each { it.put('lowerFeaturedOwner', it?.featuredOwner?.replaceAll('\\s', '')?.toLowerCase()) }
        final insts = Institution.executeQuery("select new map(id as id, name as name) from Institution").each { it.put('lowerName', it?.name?.replaceAll('\\s', '')?.toLowerCase()) }

        final projectsWithScores = projectsWithOwners.collect { proj ->
            final projOwner = proj.lowerFeaturedOwner ?: ''
            final scores = insts.collect {
                final name = it.lowerName ?: ''
                [id: it.id, name: it.name, score: Fuzzy.ldRatio(projOwner, name)]
            }.sort { it.score }.reverse()//.subList(0, 10)
            [id: proj.id, name: proj.name, owner: proj.featuredOwner, scores: scores ]
        }

        respond projectsWithScores, model: [projectsWithScores: projectsWithScores]
    }

    def doMigrateProjectsToInstitutions() {
        def cmd = request.JSON
        cmd.each {
            def proj = Project.get(it.id)
            proj.institution = Institution.get(it.inst)
            proj.save()
        }
        render status: 205
    }

    def projectSummaryReport() {
        if (checkAdminAccess()) {
            def projects = Project.list([sort:'id'])

            def dates = taskService.getProjectDates()

            def projectSummaries = projectService.getProjectSummaryList(params, true)

            def summaryMap = projectSummaries.projectRenderList.collectEntries { [(it.project.id) : it ] }

            def data = projects.collect { project ->
                def summary = summaryMap[project.id]
                [project: project, summary: summary, dates: dates[project.id]]
            }

            response.setHeader("Content-Disposition", "attachment;filename=expedition-summary.csv")
            response.addHeader("Content-type", "text/plain")
            def sdf = new SimpleDateFormat("yyyy-MM-dd")

            def dateStr = { d ->
                if (d) {
                    return sdf.format(d)
                }
                return ""
            }

            def daysBetween = { Date d1, Date d2 ->
                if (d1 && d2) {
                    return TimeCategory.minus(d2, d1).days
                }
                return ""
            }

            def writer = new CSVWriter((Writer) response.writer,  {
                'Expedition Id' { it.project.id }
                'Expedtion Name' { it.project.featuredLabel }
                'Institution' { it.project.institution ? it.project.institution.name : it.project.featuredOwner }
                'Institution Id' { it.project.institution?.id ?: "" }
                'Inactive' { it.project.inactive ? "t" : "f" }
                'Template' { it.project.template?.name }
                'Expedition Type' { it.project.projectType?.name ?: "<unknown>" }
                'Tasks' { it.summary?.taskCount ?: 0 }
                'Transcribed Tasks' { it.summary?.transcribedCount ?: 0 }
                'Validated Tasks' { it.summary?.validatedCount ?: 0 }
                'Percent Transcribed' { it.summary?.percentTranscribed }
                'Percent Validated' { it.summary?.percentValidated }
                'Active Transcribers' { it.summary?.transcriberCount }
                'Active Validators' { it.summary?.validatorCount }
                'Transcription Start Date' { dateStr(it.dates?.transcribeStartDate) }
                'Transcription End Date' { dateStr(it.dates?.transcribeEndDate) }
                'Time taken (Transcribe)' { daysBetween(it.dates?.transcribeStartDate, it.dates?.transcribeEndDate) }
                'Validation Start Date' { dateStr(it.dates?.validateStartDate) }
                'Validation End Date' { dateStr(it.dates?.validateEndDate) }
                'Time taken (Validate)' { daysBetween(it.dates?.validateStartDate, it.dates?.validateEndDate) }

            })

            for (def row : data) {
                writer << row
            }
            response.flushBuffer()
        }
    }

    def reindexAllTasks() {
        if (checkAdminAccess()) {

            def c = Task.createCriteria()
            def results = c.list() {
                projections {
                    property("id")
                    order("lastViewed", "desc")
                }
            }

            results?.each { long taskId ->
                DomainUpdateService.scheduleTaskIndex(taskId)
            }

        }
        redirect(action:'tools')
    }

    def rebuildIndex() {
        if (checkAdminAccess()) {
            fullTextIndexService.reinitialiseIndex()
        }

        redirect(action:'tools')
    }
    
    def testQuery(String query, String searchType, String aggregation) {
        def searchTypeVal = searchType ? SearchType.fromString(searchType) : SearchType.DEFAULT
        log.debug("SearchType: $searchType, $searchTypeVal")

//        def offset = params.offset
//        def

        def result = fullTextIndexService.rawSearch(query, searchTypeVal, aggregation, fullTextIndexService.elasticSearchToJsonString)
        
        response.setContentType("application/json")
        render result
    }

    // clear the grails gsp caches
    def clearPageCaches() {
        if (!checkAdminAccess()) {
            render status: 403
            return
        }
        grailsCacheAdminService.clearTemplatesCache()
        grailsCacheAdminService.clearBlocksCache()
        flash.message = "Template and blocks caches cleared"
        redirect action: 'tools'
    }

    def clearAllCaches() {
        if (!checkAdminAccess()) {
            render status: 403
            return
        }
        grailsCacheAdminService.clearAllCaches()
        flash.message = "All caches cleared"
        redirect action: 'tools'
    }

    def updateUsers() {
        if (!checkAdminAccess()) {
            render status: 403
            return
        }

        userService.updateAllUsers()

        redirect(controller: 'user', action: 'list')
    }

}
