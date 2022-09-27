package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationUtils
import au.org.ala.userdetails.UserDetailsFromIdListResponse
import au.org.ala.userdetails.UserDetailsClient
import au.org.ala.web.UserDetails
import com.google.common.base.Stopwatch
import grails.gorm.transactions.NotTransactional
import grails.gorm.transactions.Transactional
import groovy.sql.Sql
import com.google.common.base.Strings
import grails.plugin.cache.Cacheable
import grails.web.servlet.mvc.GrailsParameterMap
import groovy.sql.Sql
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.web.context.request.RequestContextHolder

import javax.servlet.http.HttpServletRequest
import java.security.MessageDigest
import java.util.concurrent.ConcurrentLinkedQueue

@Transactional
class UserService {

    def dataSource
    def authService
    def grailsApplication
    def emailService
    def groovyPageRenderer
    def messageSource
    def freemarkerService
    def fullTextIndexService
    UserDetailsClient userDetailsClient

    /** Recorded as the user id when changes are made automatically */
    public static final String SYSTEM_USER = "system"

    private static Queue<UserActivity> _userActivityQueue = new ConcurrentLinkedQueue<UserActivity>()

    /**
     * Register the current user in the system.
     */
    def registerCurrentUser() {
        def userId = currentUserId
        def displayName = authService.displayName
        def firstName = AuthenticationUtils.getPrincipalAttribute(RequestContextHolder.currentRequestAttributes().request, AuthenticationUtils.ATTR_FIRST_NAME)
        def lastName = AuthenticationUtils.getPrincipalAttribute(RequestContextHolder.currentRequestAttributes().request, AuthenticationUtils.ATTR_LAST_NAME)
        log.debug("Checking user is registered: ${displayName} (UserId=${userId})")
        if (userId) {
            if (User.findByUserId(userId) == null) {
                log.debug("Registering new user: ${displayName} (UserId=${userId})")
                User user = new User()
                user.userId = userId
                user.email = currentUserEmail
                user.created = new Date()
                user.firstName = firstName
                user.lastName = lastName
                user.save(flush: true)
            }
        }
    }

    /**
     * Registers a new user within DigiVol for the user provided. All fields must exist and must not already exist in the
     * user table.
     * @param userDetails the details of the user.
     * @return the new user.
     */
    def registerUserFromDetails(def userDetails) {
        if (isSiteAdmin()) {
            if (userDetails && userDetails.userId && userDetails.email && userDetails.firstName && userDetails.lastName) {
                if (User.findByUserId(userDetails.userId as String) == null) {
                    log.debug("Registering new user: ${userDetails.firstName} ${userDetails.lastName} (UserId=${userDetails.userId})")
                    User user = new User()
                    user.userId = userDetails.userId
                    user.email = userDetails.email
                    user.created = new Date()
                    user.firstName = userDetails.firstName
                    user.lastName = userDetails.lastName
                    user.save(flush: true)
                }
            }
        }
    }

    def findAuthUserByEmail(String email) {
        if (Strings.isNullOrEmpty(email)) {
            return null
        }
        log.debug("Calling CAS Auth Service, looking for user: ${email}")
        def user = getAuthUserForUserId(email, true)
        log.debug("user: ${user}")
        if (user) {
            log.debug("Found! ${user}")
            return [userId: user.userId, firstName: user.firstName, lastName: user.lastName, email: user.userName]
        } else {
            return null
        }
    }

    UserDetails getAuthUserForUserId(String userId, boolean includeProps = true) {
        if (!userId) return null // this would have failed anyway
        def call = userDetailsClient.getUserDetails(userId, includeProps)
        try {
            def response = call.execute()
            log.debug("Response: ${response}")

            if (response.successful) {
                return response.body()
            } else {
                log.warn("Failed to retrieve user details for userId: $userId, includeProps: $includeProps. Error was: ${response.message()}")
            }
        } catch (Exception ex) {
            log.error("Exception caught trying get find user details for $userId.", ex)
        }
        return null
    }

    /**
     * Sends email to list of users.
     * Deprecated in favour of daily digest to DigiVol contact address.
     * @param user
     * @param displayName
     * @see {@link au.org.ala.volunteer.NewUserDigestNotifierJob}
     * @deprecated
     */
    @NotTransactional
    private void notifyNewUser(User user, String displayName) {
        def interestedUsers = [] //getUsersWithRole(BVPRole.SITE_ADMIN)
        def message = groovyPageRenderer.render(view: '/user/newUserRegistrationMessage', model: [user: user, displayName: displayName])
        def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)

        interestedUsers.each {
            emailService.pushMessageOnQueue(detailsForUserId(it.userId).email, "A new user has been registered to ${appName}", message)
        }
    }

    def getUserCounts(List<String> ineligibleUsers = [], Integer limit = null) {
        def params = ineligibleUsers ? [ineligibleUsers: ineligibleUsers] : [:]
        log.debug("params: ${params}")
        def args = [:]
        if (limit) {
            args['max'] = limit
        }

        def ineligibleUserClause = ""
        if (ineligibleUsers.size() > 0) {
            log.debug("Adding user clause")
            ineligibleUserClause = "and userId not in (:ineligibleUsers)"
        }

        def query = """
            select new map(concat(firstName, ' ', lastName) as displayName, email as email, transcribedCount as transcribed, validatedCount as validated, (transcribedCount + validatedCount) as total, userId as userId, id as id)
            from User
            where (transcribedCount > 0 or validatedCount > 0)
            :ineligibleUserClause
            order by (transcribedCount + validatedCount) desc
        """.stripIndent()
        String userQuery = query.replace(":ineligibleUserClause", ineligibleUserClause)
        log.debug("user query: ${userQuery}")

        def users = User.executeQuery(userQuery, params, args)

        def deets = authService.getUserDetailsById(users.collect { it['userId'] })
        if (deets) {
            users.each {
                def deet = deets.users.get(it['userId'])
                it['displayName'] = deet.displayName
                it['email'] = deet.userName // this is actually the email address
            }
        }
        return users
    }

    int countActiveUsers() {
        return User.countByTranscribedCountGreaterThanOrValidatedCountGreaterThan(0,0)
    }

    def getUserScore(User user) {
        return (user.transcribedCount ?: 0) + (user.validatedCount ?: 0)
    }

    /**
     * Determines if the current user holds the institution admin role for a specific institution.
     * To find if a user holds the institution admin role for any institution, call
     * {@link UserService#isInstitutionAdmin()}.
     * <b>Note:</b> Will return FALSE if user is a site admin, unless they hold the institution admin role.
     *
     * @param institution the specific institution to check against the user.
     * @return true if user has the institution admin role. False returned if not.
     */
    boolean isInstitutionAdmin(Institution institution) {
        def user = User.findByUserId(currentUserId)
        if (user && institution) {
            def institutionAdminRole = Role.findByNameIlike(BVPRole.INSTITUTION_ADMIN)
            def userRole = user.userRoles.find {
                it.role.id == institutionAdminRole.id && it.institution.id == institution.id
            }
            if (userRole) {
                return true
            }
        }

        return false
    }

    /**
     * Returns a list of users who hold the institution admin role for a given project's institution.
     * @param project
     * @return
     */
    List<User> getInstitutionAdminsForProject(Project project) {
        if (!project) return []

        // log.debug("Getting institution admins for project: [${project.id}]")

        def role = Role.findByNameIlike(BVPRole.INSTITUTION_ADMIN)
        // log.debug("role: ${role}")
        // log.debug("institution: ${project.institution}")

        def userRoles = UserRole.findAllByRoleAndInstitution(role, project.institution)
        // log.debug("User roles: ${userRoles}")

        def users = userRoles.collect {
            it.user
        }

        users
    }

    /**
     * Determines if the current user holds the institution admin role for any institution.
     * To find if a user holds the institution admin role for a specific institution, call
     * {@link UserService#isInstitutionAdmin(Institution)}
     * <br />
     * <b>Note:</b> Will also return true if user is a site admin.
     *
     * @return true if user has the institution admin role. False returned if not.
     */
    boolean isInstitutionAdmin() {

        def userId = currentUserId
        if (!userId) {
            return false
        }

        // If User is a Site Admin, return true for any institution.
        if (isSiteAdmin()) {
            return true
        }

        def user = User.findByUserId(userId)
        if (user) {
            def institutionAdminRole = Role.findByNameIlike(BVPRole.INSTITUTION_ADMIN)
            def userRole = user.userRoles.find {
                it.role.id == institutionAdminRole.id
            }
            if (userRole) {
                return true
            }
        }

        return false
    }

    /**
     * Returns a list of institutions the current user holds the Institution Admin for.
     */
    def getAdminInstitutionList() {
        def user = currentUser
        if (!user) {
            return []
        }

        def institutionAdminRole = Role.findByNameIlike(BVPRole.INSTITUTION_ADMIN)
        def userRoleList = user.userRoles.findAll { UserRole userRole ->
            userRole.role.id == institutionAdminRole.id
        }
        def institutionList = []
        userRoleList.each { UserRole userRole ->
            def institution = userRole.getLinkedInstitution()
            if (institution) institutionList.add(institution)
        }
        institutionList.sort { Institution a, Institution b ->
            a?.name <=> b?.name
        }

        return institutionList
    }

    boolean isSiteAdmin() {
        def userId = currentUserId
        if (!userId) {
            return false
        }

        return authService.userInRole(CASRoles.ROLE_ADMIN)
    }

    /**
     * returns true if the current user can validate tasks from the specified project
     * @param project
     * @return
     */
    boolean isValidator(Project project) {
        return isValidatorForProjectId(project?.id, project?.institution?.id)
    }

    /**
     * Returns true if the current user can validate tasks from the specified project
     * @param projectId the project to check validator access to. Returns false if no project ID provided.
     * @param institutionId (optional) where the project belongs to (if any)
     * @return true if user has validator access, false if user does not.
     */
    boolean isValidatorForProjectId(Long projectId, Long projectInstitutionId = null) {
        def userId = currentUserId
        if (!userId) {
            return false
        }

        // Site administrator/institution admin can validate anything
        if (isSiteAdmin() || isInstitutionAdmin(Project.get(projectId)?.institution)) {
            return true
        }

        // If the user has been granted the ALA-AUTH ROLE_VALIDATOR role...
        if (authService.userInRole(CASRoles.ROLE_VALIDATOR)) {
            return true
        }

        // Otherwise check the intra app roles...
        // If, for the user's roles:
        // - If both project and institution are null, this is a global level role - return true.
        // - If the provided project's institution or the provided institution matches the role's institution,
        //   this is an institution-level role - return true.
        // - If the provided project matches the role's project, this is a project-level role - return true.
        log.debug("Checking if user has validator role")
        def user = User.findByUserId(userId)

        return userHasValidatorRole(user, projectId, projectInstitutionId)
    }

    @Cacheable(value = 'UserHasValidator', key = { "${user ? (user.id ? user.id.toString() : '-1') : '-1'}-${projectId ?: '-1'}-${projectInstitutionId ?: '-1'}" })
    boolean userHasValidatorRole(User user, Long projectId, Long projectInstitutionId = null) {
        if (user) {

            if (hasCasRole(user, CASRoles.ROLE_VALIDATOR) || hasCasRole(user, CASRoles.ROLE_ADMIN)) {
                log.debug("[userHasValidatorRole]: User has CAS Validator role/CAS Site Admin, granting validator.")
                return true
            }

            def validatorRole = Role.findByNameIlike(BVPRole.VALIDATOR)
            def role = user.userRoles.find {
                it.role.id == validatorRole.id && ((it.institution == null && it.project == null) ||
                        projectId == null ||
                        (it.institution != null && it.institution?.id == projectInstitutionId) ||
                        it.project?.id == projectId)
            }
            if (role) {
                // a role exists for the current user and the specified project/institution (or the user has a role with a null project and null institution
                // indicating that they can validate tasks from any project and or institution)
                log.debug("[userHasValidatorRole]: User has the validator role, returning true.")
                return true
            }
        }

        return false
    }

    /**
     * Checks with the ALA user service if a given user has a given role.
     * @param user The user to query
     * @param role the role to query
     * @return true of the user has the role, false if not.
     */
    @Cacheable(value = 'UserHasCasRole', key = { "${user ? (user.id ? user.id.toString() : '-1') : '-1'}-${role ?: '-1'}" })
    boolean hasCasRole(User user, String role) {
        if (!user) return false
        def serviceResults = [:]
        try {
            log.debug("[hasCasRole]: User: ${user}, Role: ${role}")
            serviceResults = authService.getUserDetailsById([user.userId], true)
            def userFromService = serviceResults?.users?.get(user.userId)
            def userRoles = user.userRoles
            log.debug("userRoles: ${userRoles}")
            def roleObjs = userRoles*.role
            log.debug("roleObjs: ${roleObjs}")
            def currentRoles
            if (roleObjs) {
                log.debug("role names: ${roleObjs*.name}")
                currentRoles = (roleObjs*.name + userFromService?.roles).toSet()
            } else {
                currentRoles = userFromService?.roles
            }
            log.debug("[hasCasRole]: ALA service roles: ${currentRoles}")
            if (!currentRoles) return false

            log.debug("[hasCasRole]: role check: [${!currentRoles?.intersect([role])?.isEmpty()}]")
            return !currentRoles?.intersect([role])?.isEmpty()
        } catch (Exception e) {
            log.warn("[hasCasRole]: Couldn't get user details from web service", e)
        }
    }

    String getCurrentUserId() {
        return authService.userId
    }

    String getCurrentUserEmail() {
        return authService.email
    }

    User getCurrentUser() {
        def userId = currentUserId
        if (userId) {
            return User.findByUserId(userId)
        }

        return null
    }

    def isAdmin() {
        return isSiteAdmin()
    }

    def isForumModerator(Project project = null) {

        if (isAdmin() || isInstitutionAdmin(project?.institution)) {
            return true
        }

        return isUserForumModerator(currentUser, project)
    }

    def isUserForumModerator(User user, Project projectInstance) {
        if (!user) return false
        def moderators = getUsersWithRole("forum_moderator", projectInstance, user)
        return moderators.find { it?.userId == user?.userId }
    }

    /**
     * Retrieves a list of all users who have non-admin roles. Only accessible by admins.
     * @param params A map of query parameters
     * @return a map containing the list of user roles and the total number of records for pagination.
     */
    def listUserRoles(Map parameters) {
        if (!isInstitutionAdmin()) {
            return [:]
        }
        def results = new ArrayList<UserRole>();
        def clause = []
        def pValues = [:]
        String institutionClause
        String projectClause

        if (!parameters.max) {
            parameters.max = 25
        }

        if (!parameters.offset) {
            parameters.offset = 0
        }

        if (parameters.institution) {
            clause.add("and (i.id = :institutionId or p.institution_id = :institutionId)")
            pValues.institutionId = parameters.institution
        }

        if (parameters.institutionList && parameters.projectList) {
            institutionClause = " i.id in (" + parameters.institutionList.collect { it.id }.join(",") + ") "
            projectClause = " p.id in (" + parameters.projectList.collect { it.id }.join(",") + ") "
            clause.add(" and (" + institutionClause + " OR " + projectClause + ")")
        }

        if (!Strings.isNullOrEmpty(parameters.q as String)) {
            clause.add(" and p.name ilike '%${parameters.q}%' ")
        }

        if (!Strings.isNullOrEmpty(parameters.userid as String)) {
            clause.add(" and u.user_id = ${parameters.userid} ")
        }

        def query = """\
            select u.id as user_role_id, 
                u.project_id, 
                u.institution_id, 
                u.user_id, 
                role.name, 
                i.name as institution_name, 
                p.name as project_name,
                vp_user.last_name
            from user_role u
                join role on (role.id = u.role_id)
                join vp_user on (vp_user.id = u.user_id)
                left outer join institution i on (i.id = u.institution_id)
                left outer join project p on (p.id = u.project_id)
            where role.name in ('${BVPRole.VALIDATOR}', '${BVPRole.FORUM_MODERATOR}') 
            """.stripIndent()

        clause.each {
            query += it
        }

        query += "order by i.name, role.name, last_name"

        log.debug("Role query: ${query}")

        def sql = new Sql(dataSource)
        def processUser = { def row ->
            UserRole userRole = UserRole.get(row.user_role_id as long)
            results.add(userRole)
        }

        if (pValues) sql.eachRow(query, pValues, parameters.offset as int, parameters.max as int, processUser)
        else sql.eachRow(query, parameters.offset as int, parameters.max as int, processUser)

        def countQuery = "select count(*) as row_count_total from (" + query + ") as countQuery"
        def countRows = pValues ? sql.firstRow(countQuery, pValues) : sql.firstRow(countQuery)

        def returnMap = [userRoleList: results, totalCount: countRows.row_count_total]

        sql.close()
        return returnMap
    }

    /**
     * Returns a list of users who have the specified role. <p>If a project is specified, the users must either have</p>
     * <ul>
     *     <li>A UserRole defined with both the rolename and the specified project</li>
     *     <li>OR A UserRole defined with the rolename and a null project defined (meaning all projects)
     * </ul>
     *
     * @param rolename
     * @param projectInstance
     * @return
     */
    List<User> getUsersWithRole(String rolename, Project projectInstance = null, User user = null) {

        def results = new ArrayList<User>()

        def role = Role.findByName(rolename)
        if (!role) {
            throw new RuntimeException("No such role - " + rolename)
        }

        def c = UserRole.createCriteria()
        def list = c {
            and {
                eq("role", role)
                if (user) eq("user", user)
                or {
                    and {
                        isNull("project")
                        isNull("institution")
                    }
                    eq("project", projectInstance)
                    eq("institution", projectInstance?.institution)
                }
            }
        }

        list.each {
            if (!results.contains(it.user)) {
                results << it.user
            }
        }

        return results
    }

    private static INTERESTING_REQUEST_PARAMETERS = ["id", "projectId", "taskId", "topicId", "messageId", "userId"]

    def recordUserActivity(String userId, HttpServletRequest request, GrailsParameterMap params) {

//        if (!grailsApplication.config.bvp.user.activity.monitor.enabled) {
//            return
//        }

        def action = new StringBuilder(request.requestURI)
        def valuePairs = []
        INTERESTING_REQUEST_PARAMETERS.each { paramName ->
            if (params[paramName]) {
                valuePairs << "${paramName}=${params[paramName]}"
            }
        }
        if (valuePairs) {
            action.append("(")
            action.append(valuePairs.join(", "))
            action.append(")")
        }

        def now = new Date()
        def ip = request.remoteAddr
        _userActivityQueue.add(new UserActivity(userId: userId, lastRequest: action.toString(), timeFirstActivity: now, timeLastActivity: now, ip: ip))
    }

    @NotTransactional
    def flushActivityRecords() {

        if (!grailsApplication.config.bvp.user.activity.monitor.enabled) {
            return
        }

        int activityCount = 0
        UserActivity activity

        while (activityCount < 100 && (activity = _userActivityQueue.poll()) != null) {
            if (activity) {
                UserActivity.withNewTransaction {
                    def existing = UserActivity.findByUserId(activity.userId)
                    if (existing) {
                        // update the existing one
                        existing.timeLastActivity = activity.timeLastActivity
                        existing.lastRequest = activity.lastRequest
                        existing.ip = activity.ip
                    } else {
                        activity.save()
                    }
                }
                activityCount++
            }
        }
    }

    /**
     * Remove all user activity records older then a specified number of seconds
     */
    def purgeUserActivity(int seconds) {

        if (!grailsApplication.config.bvp.user.activity.monitor.enabled) {
            return
        }

        long millis = new Date().getTime() - (seconds * 1000)

        def targetDate = new Date(millis)
        // find all user activity records whose timeLastActivity is older than this time...
        def c = UserActivity.createCriteria()
        def oldRecords = c.list {
            lt("timeLastActivity", targetDate)
        }
        int purgeCount = 0
        oldRecords.each { userActivity ->
            purgeCount++
            userActivity.delete(flush: true)
        }
        if (purgeCount) {
            log.info("${purgeCount} activity records purged from database")
        }
    }

    /**
     * Get the user details for a list of user ids
     */
    def detailsForUserIds(List<String> userIds) {
        if (!userIds) {
            return []
        }

        boolean addSystem = false
        if (userIds.contains('system')) {
            userIds = userIds.findAll { it != 'system' }
            addSystem = true
        }

        UserDetailsFromIdListResponse serviceResults
        try {
            serviceResults = authService.getUserDetailsById(userIds)
        } catch (Exception e) {
            log.warn("couldn't get user details from web service", e)
        }

        def results
        def missingIds

        if (serviceResults && !serviceResults.success) {
            log.error("Error in user id list for getUserDetailsById call: {} with ids: {}", serviceResults.message, userIds)
        }

        if (serviceResults && serviceResults.success) {
            results = serviceResults.users*.value
            missingIds = serviceResults.invalidIds.collect { String.valueOf(it) }
        } else {
            results = []
            missingIds = userIds
        }

        if (missingIds) {
            results.addAll(getMissingUserIdsAsUserDetails(missingIds))
        }
        if (addSystem) {
            results.add(new UserDetails(-1, 'system', '', 'system', 'system', false, [] as Set))
        }

        results.sort { it.userId }

        results
    }

    private def getMissingUserIdsAsUserDetails(List<String> ids) {
        User.withCriteria {
            'in' 'userId', ids
            projections {
                property 'userId'
                property 'firstName'
                property 'lastName'
                property 'email'
            }
        }.collect { new UserDetails( firstName: it[1], lastName: it[2], userId: it[0], userName: it[3] ) }
    }

    List<String> getEmailAddressesForIds(List<String> userIds) {
        detailsForUserIds(userIds)*.userName
    }

    List<String> getDisplayNamesForIds(List<String> userIds) {
        detailsForUserIds(userIds)*.displayName
    }

    /**
     * Get either an email and displayName for a numeric user id.  This method prefers to use the auth service
     * unless it's unavailable, then it falls back to a database query.
     *
     * @param userid The ALA userid to lookup
     * @param prop The property to get (either 'email' or 'displayName']
     */
    def propertyForUserId(String userid, String prop) {
        if (prop != 'email' && prop != 'displayName' && prop != 'organisation') log.warn("propertyForUserId: Unknown property requested \"${prop}\"")
        detailsForUserId(userid)[prop]
    }

    /**
     * Get both email and displayName for a numeric user id.  Preferring to use the auth service
     * unless it's unavailable, then fall back to database
     *
     * @param userid The ALA userid to lookup
     */
    def detailsForUserId(String userid) {
        if (!userid) return [displayName: '', email: '']
        else if ('system' == userid) return [displayName: userid, email: userid]

        def details = null

        try {
            details = authService.getUserForUserId(userid)
        } catch (Exception e) {
            log.warn("couldn't get user details from web service", e)
        }

        if (details) return [displayName: details?.displayName ?: '', email: details?.userName ?: '']
        else {
            def user = User.findByUserId(userid)
            return user ? [displayName: user.displayName ?: '', email: user.email ?: ''] : [displayName: '', email: '']
        }
    }

    def idForUserProperty(String propertyName, String propertyValue) {
        def values = User.withCriteria {
            eq propertyName, propertyValue
            projections {
                property 'userId'
            }
        }
        values.size() > 0 ? values[0] : ''
    }

    void updateAllUsers() {
        List<User> updates = []
        def users = User.all

        def ids = users*.userId
        UserDetailsFromIdListResponse results
        try {
            results = authService.getUserDetailsById(ids, true)
        } catch (Exception e) {
            log.warn("couldn't get user details from web service", e)
        }


        if (results) {
            users.each {
                UserDetails result = results.users[it.userId]
                if (result && (result.firstName != it.firstName || result.lastName != it.lastName || result.userName != it.email || result.organisation != it.organisation)) {
                    it.firstName = result.firstName
                    it.lastName = result.lastName
                    it.email = result.userName
                    it.organisation = result.organisation
                    updates << it
                }
            }
        }

        if (updates) {
//            def dbIds = User.saveAll(updates)
            updates*.save()
            def dbIds = updates*.id
            log.debug("Updated ids ${dbIds}")
        }
    }

    // Retrieves all the data required for the notebook functionality
    Map appendNotebookFunctionalityToModel(Map model) {
        Stopwatch sw = Stopwatch.createStarted()
        final query = freemarkerService.runTemplate(UserController.ALA_HARVESTABLE, [userId: model.userInstance.userId])
        final agg = UserController.SPECIES_AGG_TEMPLATE

        def speciesList2 = fullTextIndexService.rawSearch(query, SearchType.COUNT, agg) { SearchResponse searchResponse ->
            searchResponse.aggregations.get('fields').aggregations.get('speciesfields').aggregations.get('species').buckets.collect { [ it.key, it.docCount ] }
        }.sort { m -> m[1] }
        def totalSpeciesCount = speciesList2.size()
        sw.stop()
        log.debug("notebookMainFragment.speciesList2 ${sw.toString()}")
        log.debug("specieslist2: ${speciesList2}")

        sw.reset().start()
        def fieldObservationQuery = freemarkerService.runTemplate(UserController.FIELD_OBSERVATIONS, [userId: model.userInstance.userId])
        def fieldObservationCount = fullTextIndexService.rawSearch(fieldObservationQuery, SearchType.COUNT, fullTextIndexService.hitsCount)

        sw.stop()
        log.debug("notbookMainFragment.fieldObservationCount ${sw.toString()}")

        sw.reset().start()
        def c = Transcription.createCriteria()
        def expeditions = c {
            eq("fullyTranscribedBy", model.userInstance.userId)
            projections {
                task {
                    countDistinct("project")
                }

            }
        }
        sw.stop()

        log.debug("notebookMainFragment.projectCount ${sw.toString()}")

        sw.reset().start()

        final matchAllQuery = UserController.MATCH_ALL

        def userCount = fullTextIndexService.rawSearch(query, SearchType.COUNT, fullTextIndexService.hitsCount)
        def totalCount = fullTextIndexService.rawSearch(matchAllQuery, SearchType.COUNT, fullTextIndexService.hitsCount)
        def userPercent = "0"
        if (totalCount > 0) {
            userPercent = String.format('%.2f', (userCount / totalCount) * 100)
        }

        sw.stop()
        log.debug("notbookMainFragment.percentage ${sw.toString()}")

        return model << [
                totalSpeciesCount: totalSpeciesCount,
                speciesList: speciesList2,
                fieldObservationCount: fieldObservationCount,
                expeditionCount: expeditions ? expeditions[0] : 0,
                userPercent: userPercent
        ]
    }

    /**
     * Generates a hash for encoding user information. Generates an MD5 hash.
     * Returns null if no user exists or no hash suffix exists in the {@link User} class.
     *
     * @param user the User object
     * @return the md5 hash
     */
    def getUserHash(User user) {
        if (!user) return null
        if (!User.HASH_SUFFIX) return null
        def userHash = "${user.id}+${User.HASH_SUFFIX}".toString()
        return MessageDigest.getInstance("MD5").digest(userHash.bytes).encodeHex().toString()
    }
}
