package au.org.ala.volunteer

import grails.transaction.NotTransactional
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap

import javax.servlet.http.HttpServletRequest
import java.util.concurrent.ConcurrentLinkedQueue

class UserService {

    def authService
    def logService
    def grailsApplication

    static transactional = true

    private static Queue<UserActivity> _userActivityQueue = new ConcurrentLinkedQueue<UserActivity>()

    /**
     * Register the current user in the system.
     */
    def registerCurrentUser = {
        def userId = authService.username()
        def displayName = authService.displayName()
        logService.log("Checking user is registered: " + userId + ", " + displayName)
        if (userId) {
            if (User.findByUserId(userId) == null) {
                User user = new User()
                user.userId = userId
                user.created = new Date()
                user.displayName = displayName
                user.save(flush: true)
            }
        }
    }

    def getUserCounts = {

        User.executeQuery("""
            select displayName, (transcribedCount + validatedCount) as score, id
            from User
            where (transcribedCount + validatedCount) > 0
            order by (transcribedCount + validatedCount) desc
        """)

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

    /**
     * returns true if the current user can validate tasks from the specified project
     * @param project
     * @return
     */
    public boolean isValidator(Project project) {
        def userId = authService.username()

        if (!userId) {
            return false;
        }

        // If there the user has been granted the ALA-AUTH roles then these override everything
        if (authService.userInRole(CASRoles.ROLE_ADMIN) || authService.userInRole(CASRoles.ROLE_VALIDATOR)) {
            return true
        }

        // Otherwise check the intra app roles...

        // If project is null, return true if the user can validate in any project
        // If project is not null, return true only if they are validator for that project, or if they have a null project in their validator role (meaning 'all projects')

        def user = User.findByUserId(userId)
        if (user) {
            def validatorRole = Role.findByNameIlike("validator")
            def role = user.userRoles.find {
                it.role.id == validatorRole.id && (it.project == null || project == null || it.project.id == project?.id)
            }
            if (role) {
                // a role exists for the current user and the specified project (or the user has a role with a null project
                // indicating that they can validate tasks from any project
                return true;
            }
        }

        return false;

    }

    public User getCurrentUser() {
        def userId = authService.username()

        if (userId) {
            return User.findByUserId(userId)
        }

        return null
    }

    def isAdmin() {
        def userId = authService.username()

        if (!userId) {
            return false
        }

        if (authService.userInRole(CASRoles.ROLE_ADMIN)) {
            return true
        }

        return false
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

        if (!grailsApplication.config.bvp.user.activity.monitor.enabled) {
            return
        }

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
        _userActivityQueue.add(new UserActivity(userId: userId, lastRequest: action.toString(), timeFirstActivity: now, timeLastActivity: now))
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
                    } else {
                        activity.save()
                    }
                }
                activityCount++
            }
        }

        if (activityCount) {
            logService.log("${activityCount} activity records flushed to database")
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
            logService.log("${purgeCount} activity records purged from database")
        }
    }
}
