package au.org.ala.volunteer

import grails.converters.JSON
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import java.text.SimpleDateFormat

class UserController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def grailsApplication
    def taskService
    def userService
    def achievementService
    def logService
    def fieldService
    def forumService
    def authService

    def index = {
        redirect(action: "list", params: params)
    }

    def logout = {
        logService.log "Invalidating Session (UserController.logout): ${session.id}"
        session.invalidate()
        redirect(url:"${params.casUrl}?url=${params.appUrl}")
    }

    def myStats = {
      userService.registerCurrentUser()
      def currentUser = userService.currentUserId
      def userInstance = User.findByUserId(currentUser)
      redirect(action: "show", id: userInstance.id, params: params )
    }

    def list = {

        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        if (!params.sort){
          // set default sort and order
          params.sort = params.sort ? params.sort : "transcribedCount"
          params.order = "desc"
        }

        def userList

        if (params.q) {
            // TODO Migrate away from database email addresses
            def c = User.createCriteria()
            userList = c.list(params) {
                or {
                    ilike("displayName", '%' + params.q + '%')
                    ilike("email", '%' + params.q + '%')
                }
            }
        } else {
            userList = User.list(params)
        }

        def currentUser = userService.currentUserId
        [userInstanceList: userList, userInstanceTotal: userList.totalCount, currentUser: currentUser ]
    }

    def project = {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            params.max = Math.min(params.max ? params.int('max') : 10, 100)
            if(!params.sort){
              params.sort = params.sort ? params.sort : "displayName"
              params.order = "asc"
            }
            //def userList = User.list(params)
            def userList = []
            def userIds = taskService.getUserIdsAndCountsForProject(projectInstance, params)
            def userCount = taskService.getUserIdsAndCountsForProject(projectInstance, new HashMap<String, Object>()).size()
            userIds.each {
                // iterate over each user and assign to a role.
                def userId = it[0]
                def count = it[1]
                def user = User.findByUserId(userId)
                if (user) {
                    user.transcribedCount = count
                    userList.add(user)
                }
            }

            def currentUser = userService.currentUserId
            render(view: "list", model:[userInstanceList: userList, userInstanceTotal: userCount, currentUser: currentUser, projectInstance: projectInstance])
        } else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
    }

    def create = {
        def userInstance = new User()
        userInstance.properties = params
        return [userInstance: userInstance]
    }

    def save = {
        def userInstance = new User(params)
        if (userInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'user.label', default: 'User'), userInstance.id])}"
            redirect(action: "show", id: userInstance.id)
        }
        else {
            render(view: "create", model: [userInstance: userInstance])
        }
    }

    /**
     * Creates a list of task information (in the form of a list of maps) that is suitable for rendering in a view.
     * Takes into account pagination and search request parameters to return a map containing the total number of
     * matching tasks, as well as the list of currently visible tasks (paginated)
     *
     * @param tasks
     * @param params
     * @return
     */
    private createViewList(List<Task> tasks, GrailsParameterMap params) {

        if (!tasks) {
            return [totalMatchingTasks: 0, viewList: []]
        }

        params.max = Math.min(params.max ? params.int('max') : 10, 50)
        params.offset = params.int('offset') ?: 0
        params.order = params.order ?: ""

        if (!params.sort) {
            params.sort = "lastEdit"
            params.order = "desc"
        }

        def c = Field.createCriteria();
        def fields = c {
            projections {
                property("value")
                property("task")
                and {
                    "in"( "task", tasks)
                    eq("name", "catalogNumber")
                }
            }
        }

//        def cc = Field.createCriteria()
//        def dates = cc {
//            projections {
//                max("updated")
//                groupProperty("task")
//            }
//
//        }

        def fieldsByTask = fields.groupBy { it[1] }
//        def datesByTask = dates.groupBy { it[1] }

        def viewList = []

        def sdf = new SimpleDateFormat("dd MMM, yyyy HH:mm:ss")

        for (Task t : tasks) {
            def taskRow = [id: t.id, externalIdentifier:t.externalIdentifier, fullyTranscribedBy: t.fullyTranscribedBy, projectId: t.projectId, project: t.project, projectName: t.project.name, dateTranscribed: t.dateFullyTranscribed ?: t.dateLastUpdated, dateValidated: t.dateFullyValidated]

            List<Field> taskFields = fieldsByTask[t]
            def catalogNumber = taskFields?.get(0)?.getAt(0)

            taskRow.catalogNumber = catalogNumber

            def status = ""
            if (t.isValid == true) {
                status = "Validated"
            } else if (t.isValid == false) {
                status = "Invalidated"
            } else if (t.fullyTranscribedBy?.length() > 0) {
                status = "Transcribed"
            } else {
                status = "Saved"
            }

            taskRow.status = status

            // This pseudo column concatenates all the searchable columns to make row filtering easier.

            def dateStr = (t.dateFullyTranscribed ? sdf.format(t.dateFullyTranscribed) : "")
            dateStr += ";" + (t.dateFullyValidated ? sdf.format(t.dateFullyValidated) : "")
            dateStr += ";" + (t.dateLastUpdated ? sdf.format(t.dateLastUpdated) : "")

            def sb = new StringBuilder(128)
            sb.append(catalogNumber).append(";").append(status).append(";").append(t.project.name).append(";")
            sb.append(t.externalIdentifier).append(";").append(dateStr).append(";").append(t.id)
            taskRow.searchColumn = sb.toString().toLowerCase()

            viewList.add(taskRow)
        }

        // Filtering...
        if (params.q) {
            def q = params.q.toLowerCase()
            viewList = viewList.findAll {
                it.searchColumn?.find("\\Q${q}\\E")
            }
        }

        def totalMatchingTasks = viewList.size()

        // Sorting
        if (params.sort) {
            viewList = viewList.sort { it[params.sort] }
            if (params.order == 'asc') {
                viewList = viewList.reverse();
            }
        }

        if (viewList && viewList.size() >= params.int("offset")) {
            viewList = viewList[params.int("offset")..Math.min(viewList.size() - 1, params.int("offset") + params.int("max") - 1)]
        }

        [totalMatchingTasks: totalMatchingTasks, viewList: viewList]
    }

    def taskListFragment = {

        def selectedTab = params.int("selectedTab") ?: 0
        def projectInstance = Project.get(params.int("projectId"))
        def userInstance = User.get(params.id)

        def tasks = []

        switch (selectedTab) {
            case 0:
                if (projectInstance) {
                    tasks = Task.findAllByProjectAndFullyTranscribedBy(projectInstance, userInstance.userId)
                } else {
                    tasks = Task.findAllByFullyTranscribedBy(userInstance.userId)
                }  
                break;
            case 1:
                if (projectInstance) {
                    tasks = taskService.getRecentlySavedTasksByProject(userInstance.userId, projectInstance,[:])
                } else {
                    tasks = taskService.getRecentlySavedTasks(userInstance.userId, [:])
                }
                break;
            case 2:
                if (projectInstance) {
                    tasks = Task.findAllByProjectAndFullyValidatedBy(projectInstance, userInstance.userId)
                } else {
                    tasks = Task.findAllByFullyValidatedBy(userInstance.userId)
                }
        }

        def results = createViewList(tasks, params)

        def isValidator = userService.isValidator(projectInstance)

        [viewList: results.viewList, totalMatchingTasks: results.totalMatchingTasks, selectedTab: selectedTab, projectInstance: projectInstance, userInstance: userInstance]

    }

    def show = {

        def userInstance = User.get(params.int("id"))
        def currentUser = userService.currentUserId

        if (!userInstance) {
            flash.message = "Missing user id, or user not found!"
            redirect(action: 'list')
            return
        }

        def projectInstance = null
        if (params.projectId) {
            projectInstance = Project.get(params.projectId)
        }

        int totalTranscribedTasks

        if (projectInstance) {
            totalTranscribedTasks = Task.countByFullyTranscribedByAndProject(userInstance.getUserId(), projectInstance)
        } else {
            totalTranscribedTasks = userInstance.transcribedCount
        }

        def achievements = []
        if (FrontPage.instance().showAchievements) {
            achievements = achievementService.calculateAchievements(userInstance)
        }

        def score = userService.getUserScore(userInstance)

        int selectedTab = params.int("selectedTab") ?: 0

        if (!userInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect(action: "list")
        } else {
            [   userInstance: userInstance, currentUser: currentUser, project: projectInstance, totalTranscribedTasks: totalTranscribedTasks,
                achievements: achievements, validatedCount: userService.getValidatedCount(userInstance, projectInstance), score:score, selectedTab: selectedTab
            ]
        }
    }

    def edit() {

        def userInstance = User.get(params.int("id"))

        if (!userInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect(action: "list")
        }


        if (!userService.isAdmin()) {
            flash.message = "You do not have permission to edit this user page (ROLE_ADMIN required)"
            redirect(action: "show", id: userInstance.id)

        }
        
        def roles = UserRole.findAllByUser(userInstance)
        
        return [userInstance: userInstance, roles: roles, userDetails: authService.getUserForUserId(userInstance.getUserId())]
    }

    def update = {
        def userInstance = User.get(params.id)
        def currentUser = userService.currentUserId
        if (userInstance && currentUser && (userService.isAdmin() || currentUser == userInstance.userId)) {
            if (params.version) {
                def version = params.version.toLong()
                if (userInstance.version > version) {
                    
                    userInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'user.label', default: 'User')] as Object[], "Another user has updated this User while you were editing")
                    render(view: "edit", model: [userInstance: userInstance])
                    return
                }
            }
            userInstance.properties = params
            if (!userInstance.hasErrors() && userInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'user.label', default: 'User'), userInstance.id])}"
                redirect(action: "show", id: userInstance.id)
            }
            else {
                render(view: "edit", model: [userInstance: userInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def userInstance = User.get(params.id)
        def currentUser = userService.currentUserId
        if (userInstance && currentUser && userService.isAdmin()) {
            try {
                userInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect(action: "list")
        }
    }

    def editRoles = {

        def userInstance = User.get(params.id)
        def currentUser = userService.currentUserId
        if (!userInstance || !currentUser) {
            flash.message = "User not found!"
            redirect(action: "list")
            return
        }

        if (!userService.isAdmin()) {
            flash.message = "You have insufficient priviliges to manage the roles for this user!"
            redirect(action: "show")
        }

        [userInstance: userInstance, currentUser: currentUser, roles: Role.list(), projects: Project.list()]
    }

    def updateRoles = {
        def userInstance = User.get(params.id)

        if (!userInstance) {
            flash.message = "User not found!"
            redirect(action: "list")
            return
        }

        if (!userService.isAdmin()) {
            flash.message = "You have insufficient priviliges to manage the roles for this user!"
            redirect(action: "show")
            return
        }

        def roleAction = params.selectedUserRoleAction
        def userRoleId = params.selectedUserRoleId
        if (roleAction == 'delete' && userRoleId) {
            def userRole = UserRole.get(userRoleId)
            if (userRole) {
                userRole.delete(flush: true)
            }
        } else if (roleAction == 'addRole') {
            def role = Role.list()[0]
            def userRole = new UserRole(user: userInstance, role: role, project: null)
            userInstance.addToUserRoles(userRole)
        } else if (roleAction == 'update') {
            // This is an update....
            def userRoles = UserRole.findAllByUser(userInstance)
            userRoles.each { userRole ->
                def roleId = params.int("userRole_${userRole.id}_role")
                def projectId = params.int("userRole_${userRole.id}_project")
                println "Testing userRole ${userRole.id} against role: ${roleId} and project: ${projectId}"
                boolean changed = false;
                if (userRole.role.id != roleId) {
                    changed = true;
                }
                if (userRole.project?.id != projectId) {
                    changed = true;
                }

                if (changed) {
                    println "UserRole ${userRoleId} has changed - updating and saving."
                    userRole.role = Role.get(roleId)
                    userRole.project = Project.get(projectId)

                    userRole.save(flush: true, failOnError: true)
                }

            }
        }

        redirect(action: 'editRoles', id: userInstance?.id)

    }

    def dashboard() {

        def userInstance = userService.currentUser
        if (params.int("id")) {
            userInstance = User.get(params.int("id"))
        }

        if (!userInstance) {
            flash.message = "User not found!"
            redirect(action: "list")
            return
        }

        [userInstance: userInstance]
    }

    def ajaxGetPoints() {

        def userInstance = User.get(params.int("id"))
        def tasks = Task.findAllByFullyTranscribedBy(userInstance.userId)

        def data = []
        tasks.each { task ->
            def point = fieldService.getPointForTask(task)
            if (point) {
                data << [lat:point.lat, lng:point.lng, taskId: task.id]
            }
        }

        render(data as JSON)
    }

    def dashboardMainFragment() {
        def userInstance = User.get(params.int("id"))
        def c = Task.createCriteria()
        def expeditions = c {
            eq("fullyTranscribedBy", userInstance.userId)
            projections {
                countDistinct("project")
            }
        }

        def score = userService.getUserScore(userInstance)

        def achievements = achievementService.calculateAchievements(userInstance)
        def userAchievements = Achievement.findAllByUser(userInstance, [sort:'dateAchieved', order:'desc'])

        def recentAchievement
        if (userAchievements) {
            def top = userAchievements[0]

            recentAchievement = achievements.find { it.name == top.name }
            if (recentAchievement) {
                recentAchievement.date = top.dateAchieved
            }
        }

        def speciesCriteria = Field.createCriteria()
        def species = speciesCriteria.list(max: 5) {
            and {
                eq("transcribedByUserId", userInstance.userId)
                eq("superceded", false)
                ilike("name", "scientificName")
                isNotNull("value")
                ne("value", "")
            }
            projections {
                groupProperty("value")
                count("value","count")
                order("count", "desc")
            }

        }

        [userInstance: userInstance, expeditionCount: expeditions ? expeditions[0] : 0, score: score, recentAchievement: recentAchievement, topSpecies: species ]
    }

    def badgesFragment() {
        def userInstance = User.get(params.int("id"))
        def achievements = achievementService.calculateAchievements(userInstance)
        def score = userService.getUserScore(userInstance)
        def allAchievements = achievementService.getAllAchievements()

        [userInstance: userInstance, achievements: achievements, score: score, allAchievements: allAchievements]
    }

    def recentTasksFragment() {
        def userInstance = User.get(params.int("id"))
        def tasks = taskService.getRecentlyTranscribedTasks(userInstance?.userId, ['max' : 5, 'sort':'dateFullyTranscribed', order:'desc'])

        [userInstance: userInstance, recentTasks: tasks]
    }

    def socialFragment() {
        def userInstance = User.get(params.int("id"))

        def recentPosts = forumService.getRecentPostsForUser(userInstance, 5)
        def watchedTopics = UserForumWatchList.findByUser(userInstance)?.topics

        def messages = ForumMessage.findAllByUser(userInstance)
        def friends =  messages.unique({ it.topic.creator })*.topic.creator

        if (friends.contains(userInstance)) {
            friends.remove(userInstance)
        }

        [userInstance: userInstance, recentPosts: recentPosts, watchedTopics: watchedTopics, friends: friends]
    }

    def transcribedTasksFragment() {
        def userInstance = User.get(params.int("id"))

        [userInstance: userInstance]
    }
}
