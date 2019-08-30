package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationUtils
import au.org.ala.userdetails.UserDetailsFromIdListResponse
import au.org.ala.web.UserDetails
import com.google.common.base.Stopwatch
import grails.transaction.NotTransactional
import grails.transaction.Transactional
import groovy.sql.Sql
import grails.web.servlet.mvc.GrailsParameterMap
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.web.context.request.RequestContextHolder

import javax.servlet.http.HttpServletRequest
import java.sql.Connection
import java.util.concurrent.ConcurrentLinkedQueue

@Transactional
class UserService {

    def authService
    def logService
    def grailsApplication
    def emailService
    //def CustomPageRenderer customPageRenderer
    def groovyPageRenderer
    def messageSource
    def freemarkerService
    def fullTextIndexService

    private static Queue<UserActivity> _userActivityQueue = new ConcurrentLinkedQueue<UserActivity>()

    /**
     * Register the current user in the system.
     */
    def registerCurrentUser() {
        def userId = authService.userId
        def displayName = authService.displayName
        def firstName = AuthenticationUtils.getPrincipalAttribute(RequestContextHolder.currentRequestAttributes().request, AuthenticationUtils.ATTR_FIRST_NAME)
        def lastName = AuthenticationUtils.getPrincipalAttribute(RequestContextHolder.currentRequestAttributes().request, AuthenticationUtils.ATTR_LAST_NAME)
        log.info("Checking user is registered: ${displayName} (UserId=${userId})")
        if (userId) {
            if (User.findByUserId(userId) == null) {
                log.info("Registering new user: ${displayName} (UserId=${userId})")
                User user = new User()
                user.userId = userId
                user.email = currentUserEmail
                user.created = new Date()
                user.firstName = firstName
                user.lastName = lastName
                user.save(flush: true)
                // Notify admins that a new user has registered
                notifyNewUser(user)
            }
        }
    }

    @NotTransactional
    private void notifyNewUser(User user) {
        def interestedUsers = getUsersWithRole(BVPRole.SITE_ADMIN)
        def messageBody = groovyPageRenderer.render(view: '/user/newUserRegistrationMessage', model: [user: user])
        def messageSubject = messageSource.getMessage("userService.new_user_notification", null, "DigiVol", LocaleContextHolder.locale)

        interestedUsers.each {
            emailService.pushMessageOnQueue(detailsForUserId(it.userId).email, messageSubject, messageBody)
        }
    }

    def getUserCounts(List<String> ineligibleUsers = []) {
        def args = ineligibleUsers ? [ineligibleUsers: ineligibleUsers] : [:]
        def users = User.executeQuery("""
            select new map(concat(firstName, ' ', lastName) as displayName, email as email, transcribedCount as transcribed, validatedCount as validated, (transcribedCount + validatedCount) as total, userId as userId, id as id)
            from User
            where (transcribedCount + validatedCount) > 0
            ${ ineligibleUsers ? 'and userId not in (:ineligibleUsers)' : ''}
            order by (transcribedCount + validatedCount) desc
        """, args)
        def deets = authService.getUserDetailsById(users.collect { it['userId'] })
        if (deets) {
            users.each {
                def deet = deets.users.get(it['userId'])
                if(deet){
                    it['displayName'] = deet.displayName
                    it['email'] = deet.userName // this is actually the email address
                }
            }
        }
        return users;
    }

    def getUserScore(User user) {
        return (user.transcribedCount ?: 0) + (user.validatedCount ?: 0)
    }

    long getValidatedCount(User user, Project project = null) {
        def vc = Task.createCriteria();
        return vc {
            projections {
                count('id')
            }
            and {
                eq('fullyTranscribedBy', user.getUserId())
                eq('isValid', true)
                if (project) {
                    eq("project", project)
                }
            }
        }[0]
    }

    public boolean isInstitutionAdmin(Institution institution) {

        def userId = getCurrentUserId()

        if (!userId) {
            return false;
        }

        if (isSiteAdmin()) {
            return true
        }

        // to do - check the institution admin roles for this user

        return false
    }

    public boolean isSiteAdmin() {

        def userId = getCurrentUserId()

        if (!userId) {
            return false;
        }

        // If  the user has been granted the ALA-AUTH ROLE_BVP_ADMIN....
        if (authService.userInRole(CASRoles.ROLE_ADMIN)) {
            return true
        }

        def user = User.findByUserId(userId)
        if (user) {
            def siteAdminRole = Role.findByNameIlike(BVPRole.SITE_ADMIN)
            def userRole = user.userRoles.find { it.role.id == siteAdminRole.id }
            if (userRole) {
                return true
            }
        }

        return false
    }

    /**
     * returns true if the current user can validate tasks from the specified project
     * @param project
     * @return
     */
    public boolean isValidator(Project project) {
        isValidatorForProjectId(project?.id)
    }

    /**
     * returns true if the current user can validate tasks from the specified project
     * @param project
     * @return
     */
    public boolean isValidatorForProjectId(Long projectId) {

        def userId = getCurrentUserId()

        if (!userId) {
            return false;
        }

        // Site administrator can validate anything
        if (isSiteAdmin()) {
            return true
        }

        // If the user has been granted the ALA-AUTH ROLE_VALIDATOR role...
        if (authService.userInRole(CASRoles.ROLE_VALIDATOR)) {
            return true
        }

        // Otherwise check the intra app roles...
        // If project is null, return true if the user can validate in any project
        // If project is not null, return true only if they are validator for that project, or if they have a null project in their validator role (meaning 'all projects')

        def user = User.findByUserId(userId)
        if (user) {
            def validatorRole = Role.findByNameIlike(BVPRole.VALIDATOR)
            def role = user.userRoles.find {
                it.role.id == validatorRole.id && (it.project == null || projectId == null || it.project.id == projectId)
            }
            if (role) {
                // a role exists for the current user and the specified project (or the user has a role with a null project
                // indicating that they can validate tasks from any project)
                return true;
            }
        }

        return false;
    }

    public String getCurrentUserId() {

        registerCurrentUser()

        return authService.userId
    }

    public String getCurrentUserEmail() {
        return authService.email
    }

    public User getCurrentUser() {
        def userId = getCurrentUserId()
        if (userId) {
            return User.findByUserId(userId)
        }

        return null
    }

    def isAdmin() {
        return isSiteAdmin()
    }

    def isForumModerator(Project project = null) {

        if (isAdmin()) {
            return true
        }

        return isUserForumModerator(currentUser, project)
    }

    def isUserForumModerator(User user, Project projectInstance) {
        def moderators = getUsersWithRole("forum_moderator", projectInstance)
        return moderators.find { it.userId == user.userId }
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
    List<User> getUsersWithRole(String rolename, Project projectInstance = null) {

        def results = new ArrayList<User>()

        def role = Role.findByName(rolename)
        if (!role) {
            throw new RuntimeException("No such role - " + rolename)
        }

        def c = UserRole.createCriteria()
        def list = c {
            and {
                eq("role", role)
                or {
                    isNull("project")
                    eq("project", projectInstance)
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
        UserActivity activity;

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

        long millis = new Date().getTime() - (seconds * 1000);

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
        if(userIds.contains("system")){
            userIds.remove("system");
        }

        UserDetailsFromIdListResponse serviceResults
        try {
            serviceResults = authService.getUserDetailsById(userIds)
        } catch (Exception e) {
            log.warn("couldn't get user details from web service", e)
        }

        def results
        def missingIds

        if (serviceResults) {
            results = serviceResults.users*.value
            missingIds = serviceResults.invalidIds.collect { String.valueOf(it) }
        } else {
            results = []
            missingIds = userIds
        }

        if (missingIds) {
            results.addAll(getMissingUserIdsAsUserDetails(missingIds))
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
            if(ids.contains("system")){
                ids.remove("system");
            }
            results = authService.getUserDetailsById(ids, true)
        } catch (Exception e) {
            log.warn("couldn't get user details from web service", e)
        }


        if (results) {
            users.each {
                def result = results.users[it.userId]
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
        Stopwatch sw = Stopwatch.createStarted();
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
        def c = Task.createCriteria()
        def expeditions = c {
            eq("fullyTranscribedBy", model.userInstance.userId)
            projections {
                countDistinct("project")
            }
        }
        sw.stop()

        log.debug("notebookMainFragment.projectCount ${sw.toString()}")

        sw.reset().start()

        final matchAllQuery = UserController.MATCH_ALL

        def userCount = fullTextIndexService.rawSearch(query, SearchType.COUNT, fullTextIndexService.hitsCount)
        def totalCount = fullTextIndexService.rawSearch(matchAllQuery, SearchType.COUNT, fullTextIndexService.hitsCount)
        def userPercent = String.format('%.2f', totalCount>0?((userCount / totalCount) * 100.0):0.0);

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
}
