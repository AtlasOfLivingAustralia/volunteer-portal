package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.converters.JSON
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType
import java.text.SimpleDateFormat

class UserController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def grailsApplication
    def taskService
    def userService
    def logService
    def forumService
    def authService
    def fullTextIndexService
    def freemarkerService
    def auditService

    static final ALA_HARVESTABLE = '''{
  "constant_score": {
    "filter": {
      "and": [
        { "term": { "project.harvestableByAla": true } },
        { "term": { "fullyTranscribedBy": "${userId}" } }
      ]
    }
  }
}'''

    static final SPECIES_AGG_TEMPLATE = '''
{
  "fields": {
    "nested": {
      "path": "fields"
    },
    "aggs": {
      "speciesfields" : {
        "filter" : { "term" : { "fields.name" : "scientificName" } },
        "aggs" : {
          "species" : {
            "terms" : { "field" : "fields.value", "size": 0 }
          }
        }
      }
    }
  }
}
'''

    static final MATCH_ALL = '{ "constant_score" : { "query": { "match_all": { } } } }'

    static final FIELD_OBSERVATIONS = '''{
  "constant_score": {
    "filter": {
      "and": [
        { "term": { "project.projectType": "fieldnotes" } },
        { "term": { "fullyTranscribedBy": "${userId}" } }
      ]
    }
  }
}'''

    static final VALIDATED_TASKS_FOR_USER = '''{
  "constant_score": {
    "filter": {
      "and": [
        { "term": { "isValid": true } },
        { "term": { "fullyTranscribedBy": "${userId}" } }
      ]
    }
  }
}'''

    def index = {
        redirect(action: "list", params: params)
    }

    def logout = {
        log.info "Invalidating Session (UserController.logout): ${session.id}"
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
            String validator = User.findAllByUserId(t.fullyValidatedBy).displayName.toString().replace('[', '').replace(']', '')

            def taskRow = [id: t.id, externalIdentifier:t.externalIdentifier, fullyTranscribedBy: t.fullyTranscribedBy,
                           fullyValidatedBy: validator, projectId: t.projectId, project: t.project, projectName: t.project.name, dateTranscribed: t.dateFullyTranscribed ?: t.dateLastUpdated, dateValidated: t.dateFullyValidated]

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
            sb.append(t.externalIdentifier).append(";").append(dateStr).append(";").append(t.id).append(";").append(validator)
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

        def selectedTab = (params.int("selectedTab") == null) ? 1 : params.int("selectedTab")
        def projectInstance = Project.get(params.int("projectId"))
        def userInstance = User.get(params.id)

        def tasks = []
        def recentValidatedTaskCount = 0

        if (userInstance.userId == userService.currentUserId) {
            tasks = taskService.getRecentValidatedTasks(projectInstance, userInstance.userId)
            recentValidatedTaskCount = taskService.unReadList?.size()
        }

        switch (selectedTab) {
            case 1:
                if (projectInstance) {
                    tasks = Task.findAllByProjectAndFullyTranscribedBy(projectInstance, userInstance.userId)
                } else {
                    tasks = Task.findAllByFullyTranscribedBy(userInstance.userId)
                }  
                break;
            case 2:
                if (projectInstance) {
                    tasks = taskService.getRecentlySavedTasksByProject(userInstance.userId, projectInstance,[:])
                } else {
                    tasks = taskService.getRecentlySavedTasks(userInstance.userId, [:])
                }
                break;
            case 3:
                if (projectInstance) {
                    tasks = Task.findAllByProjectAndFullyValidatedBy(projectInstance, userInstance.userId)
                } else {
                    tasks = Task.findAllByFullyValidatedBy(userInstance.userId)
                }
        }

        def results = createViewList(tasks, params)

        def isValidator = userService.isValidator(projectInstance)

        [viewList: results.viewList, recentValidatedTaskCount: recentValidatedTaskCount,  totalMatchingTasks: results.totalMatchingTasks, selectedTab: selectedTab, projectInstance: projectInstance, userInstance: userInstance]

    }

    def notificationsFragment() {
        def userInstance = User.get(params.int("id"))

        [userInstance: userInstance]
    }

    def show = {

        def userInstance = User.get(params.int("id"))
        def currentUser = userService.currentUserId

        if (!userInstance) {
            flash.message = "Missing user id, or user not found!"
            redirect(action: 'list')
            return
        }

        // TODO Refactor this into a Service
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

        def achievements = userInstance.achievementAwards

        def score = userService.getUserScore(userInstance)

        int selectedTab = (params.int("selectedTab") == null) ? ((userInstance.userId == currentUser)? 0: 1) : params.int("selectedTab")

        if (!userInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect(action: "list")
        } else {
            Map myModel = [   userInstance: userInstance, currentUser: currentUser, project: projectInstance, totalTranscribedTasks: totalTranscribedTasks,
                achievements: achievements, validatedCount: userService.getValidatedCount(userInstance, projectInstance), score:score, selectedTab: selectedTab,
            ]

            userService.appendNotebookFunctionalityToModel(myModel)
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

    def notebook() {

        def userInstance = userService.currentUser
        if (params.int("id")) {
            userInstance = User.get(params.int("id"))
        }

        if (!userInstance) {
            flash.message = "User not found!"
            redirect(action: "list")
            return
        }

        forward(action: 'show', id: userInstance.id)
    }

    def ajaxGetPoints() {
        Stopwatch sw = new Stopwatch();
        sw.start()
        def userInstance = User.get(params.int("id"))
        sw.stop()
        log.info("ajaxGetPoints| User.get(): ${sw.toString()}")
        sw.reset().start()

        Long taskCount = Task.countByFullyTranscribedBy(userInstance.userId)
        sw.stop()
        log.info("ajaxGetPoints| Task.countByFullyTranscribedBy(): ${sw.toString()}")
        sw.reset().start()

        final query = """{
  "constant_score": {
    "filter": {
      "and": [
        { "term": { "fullyTranscribedBy": "${userInstance.userId}" } },
        { "nested" :
          {
            "path" : "fields",
            "filter" : { "term" : { "name": "decimalLongitude"}}
          }
        },
        { "nested" :
          {
            "path" : "fields",
            "filter" : { "term" : { "name": "decimalLongitude"}}
          }
        }
      ]
    }
  }
}"""

        def searchResponse = fullTextIndexService.rawSearch(query, SearchType.QUERY_THEN_FETCH, taskCount.intValue(), fullTextIndexService.rawResponse)
        sw.stop()
        log.info("ajaxGetPoints| fullTextIndexService.rawSearch(): ${sw.toString()}")
        sw.reset().start()

        def data = searchResponse.hits.hits.collect { hit ->
            def field = hit.source['fields']

            def pt = field.findAll { value ->
                value['name'] == 'decimalLongitude' || value['name'] == 'decimalLatitude'
            }.collectEntries { value ->
                def dVal = value['value']

                if (value['name'] == 'decimalLongitude') {
                    [lng: dVal]
                } else {
                    [lat: dVal]
                }
            }
            pt.put('taskId', hit.source['id'])
            pt
        }

        sw.stop()
        log.info("ajaxGetPoints| generateResults: ${sw.toString()}")

        render(data as JSON)
    }

    def showChangedFields () {
        def task =  Task.get(params.id)

        def fields = taskService.getChangedFields(task)

        auditService.auditTaskViewing(task, userService.currentUser.userId)

        [task: task, recordValues: fields.recordValues]
    }

    def notebookMainFragment() {
        Stopwatch sw = new Stopwatch();
        def userInstance = User.get(params.int("id"))
        //def simpleTemplateEngine = new SimpleTemplateEngine()
        def c = Task.createCriteria()
        sw.start()
        def expeditions = c {
            eq("fullyTranscribedBy", userInstance.userId)
            projections {
                countDistinct("project")
            }
        }
        sw.stop()

        log.info("notebookMainFragment.projectCount ${sw.toString()}")

        sw.reset().start()
        def score = userService.getUserScore(userInstance)
        sw.stop()
        log.info("notebookMainFragment.getUserScore ${sw.toString()}")

        sw.reset().start()
        def recentAchievements = AchievementAward.findAllByUser(userInstance, [sort:'awarded', order:'desc', max: 3])
        sw.stop()
        log.info("notebookMainFragment.recentAchievements ${sw.toString()}")

        sw.reset().start()
        final query = freemarkerService.runTemplate(ALA_HARVESTABLE, [userId: userInstance.userId])
        final agg = SPECIES_AGG_TEMPLATE

        def speciesList2 = fullTextIndexService.rawSearch(query, SearchType.COUNT, agg) { SearchResponse searchResponse ->
            searchResponse.aggregations.get('fields').aggregations.get('speciesfields').aggregations.get('species').buckets.collect { [ it.key, it.docCount ] }
        }.sort { m -> m[1] }
        def totalSpeciesCount = speciesList2.size()
        sw.stop()
        log.info("notebookMainFragment.speciesList2 ${sw.toString()}")
        log.info("specieslist2: ${speciesList2}")

        sw.reset().start()

        final matchAllQuery = MATCH_ALL

        def userCount = fullTextIndexService.rawSearch(query, SearchType.COUNT, hitsCount)
        def totalCount = fullTextIndexService.rawSearch(matchAllQuery, SearchType.COUNT, hitsCount)
        def userPercent = String.format('%.2f', (userCount / totalCount) * 100)

        sw.stop()
        log.info("notbookMainFragment.percentage ${sw.toString()}")

        sw.reset().start()
        def fieldObservationQuery = freemarkerService.runTemplate(FIELD_OBSERVATIONS, [userId: userInstance.userId])
        def fieldObservationCount = fullTextIndexService.rawSearch(fieldObservationQuery, SearchType.COUNT, fullTextIndexService.hitsCount)

        sw.stop()
        log.info("notbookMainFragment.fieldObservationCount ${sw.toString()}")

        sw.reset().start()
        final validatedQuery = freemarkerService.runTemplate(VALIDATED_TASKS_FOR_USER, [userId: userInstance.userId])
        def validatedCount = fullTextIndexService.rawSearch(validatedQuery, SearchType.COUNT, fullTextIndexService.hitsCount)
        sw.stop()
        log.info("notbookMainFragment.validatedCount ${sw.toString()}")

        [userInstance: userInstance, expeditionCount: expeditions ? expeditions[0] : 0, score: score,
         recentAchievements: recentAchievements, speciesList: speciesList2, fieldObservationCount: fieldObservationCount,
         validatedCount: validatedCount, userPercent: userPercent, totalSpeciesCount: totalSpeciesCount
        ]
    }

    def badgesFragment() {
        def userInstance = User.get(params.int("id"))
        //def achievements = achievementService.calculateAchievements(userInstance)
        def achievements = userInstance.achievementAwards
        def sortedAchievements = achievements.sort { a,b -> b.awarded.compareTo(a.awarded) }
        def score = userService.getUserScore(userInstance)
        def awardedIds = achievements*.achievement*.id.toList()
        def otherAchievements
        if (awardedIds) otherAchievements = AchievementDescription.findAllByIdNotInListAndEnabled(awardedIds, true, [sort: 'name'])
        else otherAchievements = AchievementDescription.findAllByEnabled(true, [sort: 'name'])

        [userInstance: userInstance, achievements: sortedAchievements, score: score, allAchievements: otherAchievements]
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

    def savedTasksFragment() {
        def userInstance = User.get(params.int("id"))

        [userInstance: userInstance]
    }

    def validatedTasksFragment() {
        def userInstance = User.get(params.int("id"))

        [userInstance: userInstance]
    }
}
