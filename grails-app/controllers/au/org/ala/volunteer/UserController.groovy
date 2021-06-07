package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.converters.JSON
import grails.gorm.transactions.Transactional
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType
import org.springframework.dao.DataIntegrityViolationException

class UserController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def taskService
    def userService
    def forumService
    def authService
    def fullTextIndexService
    def freemarkerService

    static final ALA_HARVESTABLE = '''{
  "constant_score": {
    "filter": {
      "and": [
        { "term": { "project.harvestableByAla": true } },
        { "term": { "transcriptions.fullyTranscribedBy": "${userId}" } }
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
        { "term": { "transcriptions.fullyTranscribedBy": "${userId}" } }
      ]
    }
  }
}'''

    static final VALIDATED_TASKS_FOR_USER = '''{
  "constant_score": {
    "filter": {
      "and": [
        { "term": { "isValid": true } },
        { "term": { "transcriptions.fullyTranscribedBy": "${userId}" } }
      ]
    }
  }
}'''

    def index() {
        redirect(action: "list", params: params)
    }

    def myStats() {
      userService.registerCurrentUser()
      def currentUser = userService.currentUserId
      def userInstance = User.findByUserId(currentUser)
      redirect(action: "show", id: userInstance.id, params: params )
    }

    def list() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        if (!params.sort) {
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
        [userInstanceList: userList, userInstanceTotal: userList.totalCount, currentUser: currentUser]
    }

    def project() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }

        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            params.max = Math.min(params.max ? params.int('max') : 10, 100)
            if (!params.sort) {
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
            render(view: "list", model: [userInstanceList: userList, userInstanceTotal: userCount, currentUser: currentUser, projectInstance: projectInstance])
        } else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        }
    }

    def unreadValidatedTasks() {
        def projId = params.long('projId')
        def project = null
        if (projId) {
            project = Project.get(projId)
        }
        def userId = params.get('userId', userService.currentUser?.userId)
        def results = [count: taskService.countUnreadValidatedTasks(project, userId)]
        respond(results)
    }

    def taskListFragment() {

        def selectedTab = params.int("selectedTab", 1)
        def projectInstance = Project.get(params.int("projectId"))
        def userInstance = User.get(params.id)

        def results = taskService.getTaskViewList(selectedTab, userInstance, projectInstance, params.q ?: '', params.int('offset', 0), params.int('max', 10), params.sort, params.order)
//        def recentValidatedTaskCount = 0

//        if (userInstance.userId == userService.currentUserId) {
//            recentValidatedTaskCount = taskService.countUnreadValidatedTasks(projectInstance, userInstance.userId)
//        }

        def isValidator = userService.isValidator(projectInstance)

        results.viewList.each {
            it['isValidator'] = userService.isValidatorForProjectId(it.projectId, it.institutionId)
        }

        def result = new TaskListResult(
                viewList                : results.viewList,
//                recentValidatedTaskCount: recentValidatedTaskCount,
                totalMatchingTasks      : results.totalMatchingTasks,
                selectedTab             : selectedTab,
                projectInstance         : projectInstance,
                userInstance            : userInstance,
                isValidator             : isValidator
        )

        log.debug("$result")
        respond(result)
    }

    def show(User userInstance) {

        //def userInstance = User.get(params.int("id"))
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
            totalTranscribedTasks = taskService.countUserTranscriptionsForProject(userInstance.getUserId(), projectInstance)
        } else {
            totalTranscribedTasks = userInstance.transcribedCount
        }

        def achievements = userInstance.achievementAwards

        def score = userService.getUserScore(userInstance)

        int selectedTab = (params.int("selectedTab") == null) ? 1 : params.int("selectedTab")

        if (!userInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect(action: "list")
        } else {
            Map myModel = [
                    userInstance         : userInstance,
                    currentUser          : currentUser,
                    project              : projectInstance,
                    totalTranscribedTasks: totalTranscribedTasks,
                    achievements         : achievements,
                    validatedCount       : taskService.countValidUserTranscriptionsForProject(userInstance.getUserId(), projectInstance),
                    score                : score,
                    selectedTab          : selectedTab,
                    isValidator          : userService.isValidator(projectInstance),
                    isAdmin              : userService.isAdmin()
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

    @Transactional
    def update() {
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

    @Transactional
    def delete() {
        def userInstance = User.get(params.id)
        def currentUser = userService.currentUserId
        if (userInstance && currentUser && userService.isAdmin()) {
            try {
                userInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
                redirect(action: "list")
            } catch (DataIntegrityViolationException e) {
                String message = "${message(code: 'default.not.deleted.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
                flash.message = message
                log.error(message, e)
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect(action: "list")
        }
    }

    def editRoles() {

        def userInstance = User.get(params.id)
        userInstance.userRoles = sortUserRoles (userInstance)

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

        [userInstance: userInstance, currentUser: currentUser, roles: Role.findAllByNameNotEqual('site_admin'), institutions: Institution.list (sort: 'name', order: 'asc'), projects: Project.list(sort: 'name', order: 'asc')]
    }

    private def sortUserRoles (def userInstance) {
        return userInstance.userRoles.sort {a, b ->
            a.role.name <=> b.role.name ?: a.project?.name <=> b.project?.name ?: a.institution?.name <=> b.institution?.name
        }
    }

    def deleteRoles() {
        if (!userService.isAdmin()) {
            render status: 403
            return
        }
        def userRoleId = params.selectedUserRoleId
        def userRole = UserRole.get(userRoleId)
        if (userRole) {
            userRole.delete(flush: true)
        }
        render ([status: "success"] as JSON)
    }

    def addRoles() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def userInstance = User.get(params.long("id"))
        if (!userInstance) {
            flash.message = "User not found!"
            redirect(action: "list")
            return
        }
        def selectedProject = null
        def selectedInstitution = null
        def selectedValue = params.int("selectedValue")
        if (params.byoption == "project") {
            selectedProject = Project.get(selectedValue)
        } else {
            selectedInstitution = Institution.get(selectedValue)
        }
        def role = Role.get(params.long("role")) //Role.list()[0]
        def userRole = new UserRole(user: userInstance, role: role, project: selectedProject, institution: selectedInstitution)
        userRole.save(flush: true, failOnError: true)
        userInstance.addToUserRoles(userRole)
        userInstance.userRoles = sortUserRoles (userInstance)
        render template:'userRoles', model: [userInstance: userInstance]
    }

    def notebook() {
        userService.registerCurrentUser()
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
        Stopwatch sw = Stopwatch.createStarted()
        def userInstance = User.get(params.int("id"))
        sw.stop()
        log.debug("ajaxGetPoints| User.get(): ${sw.toString()}")
        sw.reset().start()

        Long taskCount = Transcription.countByFullyTranscribedBy(userInstance.userId)
        sw.stop()
        log.debug("ajaxGetPoints| Transcription.countByFullyTranscribedBy(): ${sw.toString()}")
        sw.reset().start()

        final query = """{
  "constant_score": {
    "filter": {
      "and": [
        { "term": { "transcriptions.fullyTranscribedBy": "${userInstance.userId}" } },
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
        log.debug("ajaxGetPoints| fullTextIndexService.rawSearch(): ${sw.toString()}")
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
        log.debug("ajaxGetPoints| generateResults: ${sw.toString()}")

        render(data as JSON)
    }

    def notebookMainFragment() {
        def userInstance = User.get(params.int("id"))
        //def simpleTemplateEngine = new SimpleTemplateEngine()
        Stopwatch sw = Stopwatch.createStarted()
        def c = Transcription.createCriteria()
        def expeditions = c {
            eq("fullyTranscribedBy", userInstance.userId)
            projections {
                countDistinct("project")
            }
        }
        sw.stop()

        log.debug("notebookMainFragment.projectCount ${sw.toString()}")

        sw.reset().start()
        def score = userService.getUserScore(userInstance)
        sw.stop()
        log.debug("notebookMainFragment.getUserScore ${sw.toString()}")

        sw.reset().start()
        def recentAchievements = AchievementAward.findAllByUser(userInstance, [sort:'awarded', order:'desc', max: 3])
        sw.stop()
        log.debug("notebookMainFragment.recentAchievements ${sw.toString()}")

        sw.reset().start()
        final query = freemarkerService.runTemplate(ALA_HARVESTABLE, [userId: userInstance.userId])
        final agg = SPECIES_AGG_TEMPLATE

        def speciesList2 = fullTextIndexService.rawSearch(query, SearchType.COUNT, agg) { SearchResponse searchResponse ->
            searchResponse.aggregations.get('fields').aggregations.get('speciesfields').aggregations.get('species').buckets.collect { [ it.key, it.docCount ] }
        }.sort { m -> m[1] }
        def totalSpeciesCount = speciesList2.size()
        sw.stop()
        log.debug("notebookMainFragment.speciesList2 ${sw.toString()}")
        log.debug("specieslist2: ${speciesList2}")

        sw.reset().start()

        final matchAllQuery = MATCH_ALL

        def userCount = fullTextIndexService.rawSearch(query, SearchType.COUNT, hitsCount)
        def totalCount = fullTextIndexService.rawSearch(matchAllQuery, SearchType.COUNT, hitsCount)
        def userPercent = String.format('%.2f', (userCount / totalCount) * 100)

        sw.stop()
        log.debug("notbookMainFragment.percentage ${sw.toString()}")

        sw.reset().start()
        def fieldObservationQuery = freemarkerService.runTemplate(FIELD_OBSERVATIONS, [userId: userInstance.userId])
        def fieldObservationCount = fullTextIndexService.rawSearch(fieldObservationQuery, SearchType.COUNT, fullTextIndexService.hitsCount)

        sw.stop()
        log.debug("notbookMainFragment.fieldObservationCount ${sw.toString()}")

        sw.reset().start()
        final validatedQuery = freemarkerService.runTemplate(VALIDATED_TASKS_FOR_USER, [userId: userInstance.userId])
        def validatedCount = fullTextIndexService.rawSearch(validatedQuery, SearchType.COUNT, fullTextIndexService.hitsCount)
        sw.stop()
        log.debug("notbookMainFragment.validatedCount ${sw.toString()}")

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
        otherAchievements = AchievementDescription.withCriteria(sort: 'name') {
            eq 'enabled', true
            if (awardedIds) {
                not {
                    'in'('id', awardedIds)
                }
            }
        }

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
