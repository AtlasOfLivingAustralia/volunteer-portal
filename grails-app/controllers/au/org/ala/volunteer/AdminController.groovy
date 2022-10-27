package au.org.ala.volunteer

import com.google.common.base.Strings
import grails.converters.JSON
import grails.gorm.transactions.Transactional
import groovy.time.TimeCategory
import org.elasticsearch.action.search.SearchType
import grails.plugins.csv.CSVWriter
import org.hibernate.FlushMode
import org.jooq.Transaction
import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.MultipartFile

import java.text.SimpleDateFormat
import java.util.regex.Matcher
import java.util.regex.Pattern

class AdminController {

    def taskService
    def grailsCacheAdminService
    def tutorialService
    def sessionFactory
    def userService
    def projectService
    def fullTextIndexService
    def eventSourceService
    def institutionService

    def index() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
        }

        render(view: 'index')
    }

    def mailingList() {
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }

        def userIds = User.withCriteria {
            projections {
                property('userId', 'userId')
            }
        }
        def emails = userService.getEmailAddressesForIds(userIds as List<String>)
        def list = emails.join(";\n")
        render(text:list, contentType: "text/plain")
    }

    /**
     * Checks if the current logged in user has the access privilleges to access the admin page.
     * @param includeInstitutionAdmin if true, adds a check if user is an institution admin and returns true or false
     * as necessary.
     * @return true if access allowed. Redirects to home page with flash message if no access.
     */
    boolean checkAdminAccess(Boolean includeInstitutionAdmin) {
        log.debug("User: ${userService.getCurrentUser()}")
        if (userService.getCurrentUser() && (userService.isAdmin() || (includeInstitutionAdmin && userService.isInstitutionAdmin()))) {
            log.debug("Admin access allowed.")
            return true
        } else {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            //flash.message = "You do not have permission to view this page"
            //redirect(uri: grailsApplication.config.grails.serverURL)
            //respond status: 403
            return false
        }
    }

    /**
     * Main page request for managing Institution Admins.
     */
    def manageInstitutionAdmins() {
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }

        def institutionId = params.long('institution')
        def institution = Institution.get(institutionId)
        def institutionAdminRoles

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
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }

        log.debug("Params: ${params}")
        User user = null
        def addType = "added"

        // If params.userId is empty and params.userSearch isn't, search CAS.
        if (Strings.isNullOrEmpty(params.userId as String) && !Strings.isNullOrEmpty(params.userSearch as String)) {
            log.debug("Locating user in CAS Auth: ${params.userSearch}")
            addType = "imported"
            def userDetails = userService.findAuthUserByEmail(params.userSearch as String)
            log.debug("User Details: ${userDetails}")
            if (!userDetails) {
                flash.message = "Unable to find a registered user with a name or email of ${params.userSearch}."
                redirect(action: 'manageInstitutionAdmins')
                return
            } else {
                // Search DigiVol users for existing account.
                user = User.findByEmail(userDetails.email)
                if (!user) {
                    // User not xferred from CAS Auth to DigiVol yet.
                    // Create a user and save.
                    user = userService.registerUserFromDetails(userDetails)
                }
            }
        } else {
            def userId = params.userId?.toString()
            user = User.findByUserId(userId)

            if (!user) {
                flash.message = message(code: 'default.not.found.message',
                        args: [message(code: 'user.label', default: 'User'), userId]) as String
                redirect(action: 'manageInstitutionAdmins')
                return
            }
        }

        def institutionId = params.long('institution')
        def institution = Institution.get(institutionId)
        if (!institution) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'institution.label', default: 'Institution'), institutionId]) as String
            redirect(action: 'manageInstitutionAdmins')
            return
        }

        def role = Role.findByName(BVPRole.INSTITUTION_ADMIN)

        // Check for pre-existing role
        def roleCheck = UserRole.findAllByUserAndRoleAndInstitution(user, role, institution)
        if (roleCheck.size() > 0) {
            flash.message = message(code: 'admin.user.role.not.created',
                     args: [message(code: 'user.role.label', default: 'User Role'),
                           " an existing ${role.name} role for ${user.firstName} ${user.lastName} and ${institution.name}"]) as String
            redirect(action: 'manageInstitutionAdmins')
            return
        }

        createUserRole(user, role, [institution: institution])

        // User.displayName doesn't work here if the user was just imported from CAS.
        flash.message = """Successfully ${addType} Institution Admin role to 
            ${user.firstName} ${user.lastName} for ${institution.name}.""".stripIndent().toString()
        redirect(action: 'manageInstitutionAdmins')
    }

    /**
     * Creates a user role object
     * @param user the user to add to the role
     * @param role the role to grant to the user.
     * @param props the properties for the role (i.e. institution, project, both or null).
     * @return
     */
    @Transactional
    private def createUserRole(User user, Role role, def props) {
        if (!user || !role) return null

        def userRole = new UserRole(user: user, role: role, createdBy: userService.getCurrentUser())
        if (props?.institution) {
            userRole.institution = props.institution
        } else if (props?.project) {
            userRole.project = props.project
        }

        userRole.save(flush: true, failOnError: true)
    }

    /**
     * Deletes the selected Institution Admin {@link UserRole}.
     * Called via AJAX (Returns JSON).
     */
    @Transactional
    def deleteUserRole() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
        }

        def currentUser = userService.getCurrentUser()
        def userRoleId = params.long('userRoleId')
        def userRole = UserRole.get(userRoleId)
        log.debug("Params: ${params}")
        log.debug("userRoleId: ${userRoleId}")

        if (!userRole) {
            flash.message = message(code: 'default.not.found.message',
                                args: [message(code: 'user.role.label', default: 'User Role'), userRoleId]) as String
            redirect(action: 'manageUserRoles')
            return
        }

        // Because this action is run by both Site admins (for IA's) and IA's (for user roles), check that that user
        // has permission to delete the selected role
        // Also check, in the case of IA's, that they are not deleting another institution's role.
        def institution = (userRole.institution ? userRole.institution : userRole.project?.institution)

        if (userRole.role.name == BVPRole.INSTITUTION_ADMIN && !userService.isAdmin()) {
            log.error("Delete User Role: User ${currentUser.displayName} attempted deletion of Institution Admin role " +
                    "${userRole} without permission: ${userRole}")
            flash.message = message(code: 'default.not.permitted.message', args: ["delete this role"]) as String
                    //"You do not have permission to delete that role."
            redirect(action: 'manageUserRoles')
            return
        } else if (!userService.isAdmin() && !userService.isInstitutionAdmin(institution)) {
            log.error("Delete User Role: User ${currentUser.displayName} attempted deletion of user role ${userRole} " +
                    "without permission: ${userRole}")
            flash.message = message(code: 'default.not.permitted.message', args: ["delete this role"]) as String
            //"You do not have permission to delete that role."
            redirect(action: 'manageUserRoles')
            return
        }

        // TODO Do we log this somewhere for auditing?
        userRole.delete(flush: true)
        log.info("Institution Admin role held by ${userRole.user} was deleted by ${currentUser}")

        def reloadParams = [:]
        if (params.institution)  reloadParams.institution = params.institution

        flash.message = "User Role successfully deleted."

        if (userRole.role.name == BVPRole.INSTITUTION_ADMIN) {
            redirect(action: 'manageInstitutionAdmins', params: reloadParams)
        } else {
            redirect(action: 'manageUserRoles', params: reloadParams)
        }

    }

    @Transactional
    def addUserRole() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
        }

        def currentUser = userService.getCurrentUser()
        def userId = params.userId?.toString()
        def user = User.findByUserId(userId)

        if (!user) {
            log.error("Add user role: No user found for ${params.userId}")
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'user.label', default: 'User'), userId]) as String
            redirect(action: 'manageUserRoles')
            return
        }

        def levelOption = params.opt
        def institutionId = params.long('institution')
        def institution = Institution.get(institutionId)
        def projectId = params.long('project')
        def project = Project.get(projectId)

        if (!institution && !project) {
            log.error("Add user role: No project or institution found: project ID: ${params.projectId}, " +
                    "institution ID: ${params.institutionId}")
            flash.message = message(code: 'admin.user.role.not.created',
                    args: [message(code: 'user.role.label', default: 'User Role'), 'a missing Institution or Project']) as String
            redirect(action: 'manageUserRoles')
            return
        }

        def level
        if (levelOption == "byinst") {
            level = 1
        } else if (levelOption == "byproj") {
            level = 2
        } else {
            log.error("Add user role: No project or institution found: project ID: ${params.projectId}, " +
                    "institution ID: ${params.institutionId}")
            flash.message = message(code: 'admin.user.role.not.created',
                     args: [message(code: 'user.role.label', default: 'User Role'), 'a missing Institution or Project']) as String
            redirect(action: 'manageUserRoles')
            return
        }

        def role = Role.get(params.userRole_role?.toString())
        if (!role) {
            log.error("Add user role: No role found: ${params.userRole_role}")
            flash.message = message(code: 'admin.user.role.not.created',
                     args: [message(code: 'user.role.label', default: 'User Role'), 'a missing role type']) as String
            redirect(action: 'manageUserRoles')
            return
        }

        log.debug("Adding new user role: ${params.userRole_role}, projectId: ${projectId}, institutionId: ${institutionId}, user: ${user}")

        def userRole
        if (level == 1) {
            def roleCheck = UserRole.findAllByRoleAndInstitutionAndUser(role, institution, user)
            if (roleCheck.size() > 0) {
                log.debug("Existing roles: ${roleCheck}")
                log.error("Role already exists: ${params.userRole_role} for institution: ${institution}")
                flash.message = message(code: 'admin.user.role.not.created',
                        args: [message(code: 'user.role.label', default: 'User Role'),
                               " an existing ${role.name} role for ${user.displayName} and ${institution.name}"]) as String
                redirect(action: 'manageUserRoles')
                return
            }
            userRole = createUserRole(user, role, [institution: institution])
        } else {
            def roleCheck = UserRole.findAllByRoleAndProjectAndUser(role, project, user)
            if (roleCheck.size() > 0) {
                log.debug("Existing roles: ${roleCheck}")
                log.error("Role already exists: ${params.userRole_role} for project: ${project}")
                flash.message = message(code: 'admin.user.role.not.created',
                        args: [message(code: 'user.role.label', default: 'User Role'),
                               " an existing ${role.name} role for ${user.displayName} and ${project.name}"]) as String
                redirect(action: 'manageUserRoles')
                return
            }

            // Check if they have an institution role already.
            roleCheck = UserRole.findByUserAndRoleAndInstitution(user, role, project.institution)
            if (roleCheck) {
                log.debug("Existing roles: ${roleCheck}")
                log.error("Role already exists: ${params.userRole_role} for project: ${project} at institution-level.")
                flash.message = message(code: 'admin.user.role.not.created',
                        args: [message(code: 'user.role.label', default: 'User Role'),
                               " a ${role.name} role for ${user.displayName} already existing for that project's institution"]) as String
                redirect(action: 'manageUserRoles')
                return
            }
            userRole = createUserRole(user, role, [project: project])
        }

        if (userRole) {
            log.debug("Saved User Role: ${userRole}")
            flash.message = "Successfully added ${role.name} role to ${user.displayName}".toString()
        }

        def reloadParams = [:]
        if (params.institution)  reloadParams.institution = params.institution

        redirect(action: 'manageUserRoles', params: reloadParams)
    }

    def manageUserRoles() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
        }

        def parameters = [:]
        def displayUserFilter = ""

        def institutionId = params.long('institution')
        def institution = Institution.get(institutionId)
        if (institution) parameters.institution = institution.id

        if (params.max) parameters.max = params.int('max')
        else params.max = parameters.max = 25

        if (params.offset) parameters.offset = params.int('offset')

        // Obtain the available institutions/projects (i.e. if Institution Admin, only allow access to that
        // institution's roles).
        // If an IA, add that to the userRole query parameters.
        def institutionList = (!userService.isSiteAdmin() ? userService.getAdminInstitutionList() : Institution.listApproved(sort: 'name', order: 'asc'))
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

        if (!Strings.isNullOrEmpty(params.q?.toString())) {
            parameters.q = params.q
        }

        if (!Strings.isNullOrEmpty(params.userid?.toString())) {
            parameters.userid = params.userid
        }

        if (params.userid) {
            def userFilter = User.findByUserId(params.userid as String)
            if (userFilter) {
                displayUserFilter = userFilter.displayName
            }
        }

        Map userRoles = userService.listUserRoles(parameters)
        List userRoleList = userRoles.userRoleList
        log.debug("userRoleList.size(): ${userRoleList.size()}")

        render(view: 'manageUserRoles', model: [institutionList: institutionList,
                                                projectList: projectList,
                                                userRoleList: userRoleList,
                                                displayUserFilter: displayUserFilter,
                                                userRoleTotalCount: userRoles.totalCount])
    }

    def tutorialManagement() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
        }

        def searchTerm = (params.q) ? params.q : null
        def tutorials = tutorialService.listTutorials(searchTerm)
        render (view: 'tutorialManagement', model: [tutorials: tutorials])
    }

    def uploadTutorial() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
        }

        if (request instanceof MultipartHttpServletRequest) {
            log.debug("Uploading file.")
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('tutorialFile')
            if (f != null) {
                def allowedMimeTypes = ['application/pdf']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    log.debug("invalid file type")
                    flash.message = "The file must be one of the following file types: ${allowedMimeTypes}"
                    redirect(action: 'tutorialManagement')
                    return
                }

                //noinspection RegExpDuplicateCharacterInClass
                Pattern special = Pattern.compile(/[@#$%*=+|`'<>:;{}\\\\/]/);
                Matcher matcher = special.matcher(f.originalFilename)
                if (matcher.find()) {
                    log.debug("Invalid file name")
                    flash.message = "Filename includes illegal characters (one or more of the following: @,#,\$,%,^,*,=,<,>,{,},\\,/,|,',\",;,:,?)" +
                            ". <br />Please rename the file and try again."
                    redirect(action: 'tutorialManagement')
                    return
                }

                try {
                    tutorialService.uploadTutorialFile(f)
                    flash.message = "Tutorial uploaded successfully"
                } catch (Exception ex) {
                    flash.message = "Failed to upload tutorial file: " + ex.message
                    log.error("Failed to upload tutorial file: " + ex.message, ex)
                }
            }
        }
        redirect(action: 'tutorialManagement')
    }

    def deleteTutorial() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
        }

        def filename = params.tutorialFile?.toString()
        log.debug("Filename: ${filename}")
        if (filename) {
            try {
                tutorialService.deleteTutorial(filename)
                flash.message = "Tutorial deleted successfully"
            } catch (Exception ex) {
                flash.message = "Failed to delete tutorial file: " + ex.message
                log.error("Failed to delete tutorial file: " + ex.message, ex)
            }
        }
        redirect(action: 'tutorialManagement')
    }

    def renameTutorial() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
        }

        def filename = params.tutorialFile?.toString()
        def newName = params.newName?.toString()

        log.debug("Filename: ${filename}")
        log.debug("New name: ${newName}")

        //noinspection RegExpDuplicateCharacterInClass
        Pattern special = Pattern.compile(/[@#$%*=+|`'<>:;{}\\\\/]/);
        Matcher matcher = special.matcher(newName)
        if (matcher.find()) {
            log.debug("invalid file name")
            flash.message = "The filename '${newName}' contains illegal characters (one or more of the following: @,#,\$,%,^,*,=,<,>,{,},\\,/,|,',\",;,:,?)" +
                    ". <br />Please rename the file and try again."
            redirect(action: 'tutorialManagement')
            return
        }

        if (!newName.contains('.pdf')) {
            log.debug("No file extension")
            flash.message = "The filename '${newName}' does not have a file extension. Please ensure it has a '.pdf' extension."
            redirect(action: 'tutorialManagement')
            return
        }

        if (filename && newName) {
            try {
                tutorialService.renameTutorial(filename, newName)
            } catch (Exception ex) {
                flash.message = "Failed to rename tutorial file: " + ex.message
                log.error("Failed to rename tutorial file: " + ex.message)
            }

        }
        redirect(action: 'tutorialManagement')
    }

    /**
     * Some template definitions include recordedByID as a hidden field which conflicts with an existing "hard-coded" version of the same field
     * This results in the field values becoming an array, which ends up causing the value to lost completely as the array is 'toString'ed into the database
     * This routine attempts to find all 'recorded by id' fields whose value contains 'String' and attempts to look up the real collector id from a relevant picklist.
     * It is entirely possible that not collector id can be found, in which case the field value is cleared
     */
    def fixRecordedByID() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
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
                                    break
                                }
                            }
                        }
                    }
                }

                log.debug("Updating field ${field.id} value from '${field.value}' to '${newValue}'.")
                field.value = newValue

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

        redirect(action: 'index')
    }

    def fixUserCounts() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
        }

        def users = User.list()
        int count = 0
        users.each { user ->
            def transcribedCount = Transcription.countByFullyTranscribedBy(user.userId)
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
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }

        render(view: 'currentUsers')
    }

    def userActivityInfo() {
        if (userService.isAdmin()) {
            def activities = UserActivity.list([sort: 'timeLastActivity', order: 'desc'])
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

            def actWithOpenEventSources = activities*.properties.collect {
                it + [openESRequests: eventSourceService.getOpenRequestsForUser(emailToIdMap[it.userId]?.toString() ?: '')]
            }
            respond([activities: actWithOpenEventSources])
        } else {
            render status: 403
        }
    }

    def tools() {
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }
        render(view: 'tools')
    }

    def mappingTool() {
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }
        render(view: 'mappingTool')
    }

    def migrateProjectsToInstitutions() {
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }
        final projectsWithOwners = Project.executeQuery("select new map (id as id, name as name, featuredOwner as featuredOwner) from Project where institution is null".toString(), [:], [sort: params.sort ?: 'featuredOwner', order: params.order ?: 'asc']).each { it.put('lowerFeaturedOwner', it?.featuredOwner?.replaceAll('\\s', '')?.toLowerCase()) }
        final insts = Institution.executeQuery("select new map(id as id, name as name) from Institution").each { it.put('lowerName', it?.name?.replaceAll('\\s', '')?.toLowerCase()) }

        final projectsWithScores = projectsWithOwners.collect { proj ->
            final projOwner = proj.lowerFeaturedOwner ?: ''
            final scores = insts.collect {
                final name = it.lowerName ?: ''
                [id: it.id, name: it.name, score: Fuzzy.ldRatio(projOwner, name)]
            }.sort { it.score }.reverse()//.subList(0, 10)
            [id: proj.id, name: proj.name, owner: proj.featuredOwner, scores: scores]
        }

        respond projectsWithScores, model: [projectsWithScores: projectsWithScores]
    }

    @Transactional
    def doMigrateProjectsToInstitutions() {
        if (userService.isAdmin()) {
            def cmd = request.JSON
            log.debug("cmd: ${cmd}")
            cmd.each {
                def proj = Project.get(new Long(it.id?.toString()).longValue())
                proj.institution = Institution.get(new Long(it.inst?.toString()).longValue())
                log.debug("updated project: ${proj} to institution: ${proj.institution}")
                proj.save(flush: true, failOnError: true)
            }
            render status: 205
        } else {
            render status: 403
        }
    }

    def projectSummaryReport() {
        if (!checkAdminAccess(true)) {
            render(view: '/notPermitted')
            return
        }

        def projects
        if (userService.isInstitutionAdmin() && !userService.isSiteAdmin()) {
            def institutionList = userService.getAdminInstitutionList()
            projects = institutionService.listProjectsForInstititutionList(institutionList)
        } else {
            projects = Project.list([sort:'id'])
        }

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

        def dateStr = { Date d ->
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

    def reindexAllTasks() {
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }

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

        redirect(action: 'tools')
    }

    def rebuildIndex() {
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }
        fullTextIndexService.reinitialiseIndex()
        redirect(action: 'tools')
    }
    
    def testQuery(String query, String searchType, String aggregation) {
        if (userService.isAdmin()) {
            def searchTypeVal = searchType ? SearchType.fromString(searchType) : SearchType.DEFAULT
            log.debug("SearchType: $searchType, $searchTypeVal")
            def result = fullTextIndexService.rawSearch(query, searchTypeVal, aggregation, fullTextIndexService.elasticSearchToJsonString)
            response.setContentType("application/json")
            render result
        } else {
            render status: 403
        }
    }

    // clear the grails gsp caches
    def clearPageCaches() {
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }
		
		grailsCacheAdminService.clearTemplatesCache()
		grailsCacheAdminService.clearBlocksCache()
		flash.message = "Template and blocks caches cleared"
		redirect action: 'tools'
    }

    def clearAllCaches() {
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }
		grailsCacheAdminService.clearAllCaches()
		flash.message = "All caches cleared"
		redirect action: 'tools'
    }

    def updateUsers() {
        if (!checkAdminAccess(false)) {
            render(view: '/notPermitted')
            return
        }
        userService.updateAllUsers()
        redirect(controller: 'user', action: 'list')
    }

}
