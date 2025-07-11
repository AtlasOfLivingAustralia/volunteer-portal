package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import com.google.common.base.Strings
import grails.converters.JSON
import grails.gorm.transactions.Transactional
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType
import org.springframework.dao.DataIntegrityViolationException

import java.text.DecimalFormat
import java.util.regex.Pattern

import static org.springframework.http.HttpStatus.NO_CONTENT

class UserController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def taskService
    def userService
    def forumService
    def authService
    def fullTextIndexService
    def freemarkerService
    def fieldService
    def achievementService

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
        redirect(action: "adminList", params: params)
    }

    def myStats() {
      userService.registerCurrentUser()
      def currentUser = userService.currentUserId
      def userInstance = User.findByUserId(currentUser)
      redirect(action: "show", id: userInstance.id, params: params )
    }

    /**
     * Lists users with an opt-out record.
     */
    def listOptOut() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }
        params.max = Math.min(params.max ? params.int('max') : 20, 100)

        def userList = UserOptOut.list(params)
        def userListCount = UserOptOut.list().size()

        [userList: userList, userListCount: userListCount]
    }

    /**
     * Deletes a user's opt-out record.
     * @param userOptOut the opt-out record to delete.
     */
    @Transactional
    def deleteOptOut(UserOptOut userOptOut) {
        if (!userOptOut || !userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def name = userOptOut.user.displayName
        userOptOut.delete(flush: true, failOnError: true)
        flash.message = message(code: 'optout.deleted.message', args: [name]) as String
        redirect(action: 'listOptOut')
    }

    /**
     * Adds a new user opt-out request.
     */
    @Transactional
    def addUserOptOut() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def userId = params.userId?.toString()
        def user = User.findByUserId(userId)

        if (!user) {
            log.error("Add user opt-out: No user found for ${params.userId}")
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'user.label', default: 'User'), userId]) as String
            redirect(action: 'listOptOut')
            return
        }

        UserOptOut opt = new UserOptOut(user: user)
        opt.dateCreated = new Date()
        log.debug("New opt-out: ${opt}")
        opt.save(failOnError: true, flush: true)

        flash.message = message(code: 'optout.created.message', args: [user.displayName]) as String
        redirect(action: 'listOptOut')
    }

    def list() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }

        []
    }

    def adminList() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }
        params.max = Math.min(params.max ? params.int('max') : 25, 100)
        if (!params.sort) {
            // set default sort and order
            params.sort = params.sort ? params.sort : "lastName" //"transcribedCount"
            params.order = "asc"
        }

        def userList
        def totalCount = 0

        def closure = {
            if (params.q) {
                or {
                    ilike("displayName", '%' + params.q + '%')
                    ilike("email", '%' + params.q + '%')
                }
            }
            if (params.labelFilter) {
                and {
                    labels {
                        eq("id", params.long('labelFilter'))
                    }
                }
            }
        }

        userList = User.createCriteria().list(params) {
            closure.delegate = delegate
            closure()
        } as List

        def countResult = User.createCriteria().get {
            closure.delegate = delegate
            closure()
            projections {
                countDistinct('id')
            }
        }
        totalCount = countResult

        def currentUser = userService.currentUserId

        LabelCategory userCategory = LabelCategory.findByName('user')
        def userLabels = Label.findAllByCategory(userCategory)

        [userInstanceList: userList, userInstanceTotal: totalCount, currentUser: currentUser, userLabels: userLabels]
    }

    /**
     * AJAX endpoint for listing users
     * @return
     */
    def listUsersForJson() {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }

        def term = params.term
        def search = "%${term}%"
        def users = User.withCriteria {
            or {
                ilike 'displayName', search
                ilike 'email', search
            }
            maxResults 20
            order "displayName", "desc"
        } as List<User>

        // Don't divulge email addresses.
        def userList = users.collect { user ->
            [id: user.id, userId: user.userId, displayName: "${user.displayName} (${user.id})"]
        }

        render userList as JSON
    }

    /**
     * Not used.
     * @deprecated
     */
    def project() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def projectInstance = Project.get(params.long('id'))
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
                def userId = it[0] as String
                def count = it[1] as int
                def user = User.findByUserId(userId)
                if (user) {
                    user.transcribedCount = count
                    userList.add(user)
                }
            }

            def currentUser = userService.currentUserId
            render(view: "list", model: [userInstanceList: userList, userInstanceTotal: userCount,
                                         currentUser: currentUser, projectInstance: projectInstance])
        } else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'project.label', default: 'Project'), params.id]) as String
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
        def project = Project.get(params.int("projectId"))
        def user = User.get(params.long('id'))

        def results = taskService.getTaskViewList(selectedTab, user, project, (params.q as String) ?: '',
                params.int('offset', 0), params.int('max', 10),
                params.sort as String, params.order as String)

        def isValidator = userService.isValidator(project)

        results.viewList.each { Map it ->
            long projectId = it.projectId != null ? it.projectId as long : 0L
            long institutionId = it.institutionId != null ? it.institutionId as long : 0L
            it['isValidator'] = userService.isValidatorForProjectId(projectId, institutionId)
        }

        def result = new TaskListResult(
                viewList                : results.viewList as List,
//                recentValidatedTaskCount: recentValidatedTaskCount,
                totalMatchingTasks      : results.totalMatchingTasks as int,
                selectedTab             : selectedTab,
                projectInstance         : project,
                userInstance            : user,
                isValidator             : isValidator
        )

        log.debug("$result")
        respond(result)
    }

    /**
     * Displays the User notebook.
     * @param user the user to display
     */
    def show(User user) {
        def currentUser = userService.currentUserId
        def filter = params.filter as String

        if (!user) {
            flash.message = message(code: 'default.not.found.message',
                    args: [message(code: 'user.label', default: 'User'), params.id]) as String
            render(view: '/notPermitted')
            return
        }

        def project = null
        if (params.projectId) {
            project = Project.get(params.long('projectId'))
        }

        def achievements = user.achievementAwards
        def score = WebUtils.formatNumberWithCommas(userService.getUserScore(user))
        def transcribedScore = WebUtils.formatNumberWithCommas(user.transcribedCount ?: 0)
        def validatedScore = WebUtils.formatNumberWithCommas(user.validatedCount ?: 0)

        Stopwatch sw = Stopwatch.createStarted()
        def taskList = taskService.getNotebookTaskList(filter, user, project,
                params.int('offset', 0), params.int('max', 10),
                params.sort as String, params.order as String)
        sw.stop()
        log.debug("User.show()#taskList ${sw.toString()}")

        Map myModel = [
                userInstance         : user,
                currentUser          : currentUser,
                project              : project,
                achievements         : achievements,
                score                : score,
                transcribedScore     : transcribedScore,
                validatedScore       : validatedScore,
                viewTaskList         : taskList.viewList,
                totalMatchingTasks   : taskList.totalMatchingTasks,
                isValidator          : userService.isValidator(project),
                isAdmin              : userService.isAdmin()
        ]

        render(view: 'show', model: userService.appendNotebookFunctionalityToModel(myModel))
    }

    /**
     * Displays a list of achievements for the user.
     */
    def achievements() {
        def currentUser = userService.currentUser

        if (!currentUser) {
            // flash.message = "Missing user id, or user not found!"
            render(view: '/notPermitted')
            return
        }

        def achievementList = achievementService.getAchievementsWithCounts(currentUser)

        render view: 'achievements', model: [currentUser: currentUser, achievementList: achievementList]
    }

    def edit() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def user = User.get(params.int("id"))

        if (!user) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'user.label', default: 'User'), params.id]) as String
            redirect(action: "adminList")
            return
        }

        def roles = userService.getRoleInfoForUser(user)
        def category = LabelCategory.findByName('user')
        def userLabelList = Label.findAllByCategory(category)

        return [userInstance: user, roles: roles, userDetails: authService.getUserForUserId(user.getUserId()), userLabelList: userLabelList]
    }

    @Transactional
    def addUserLabel(User user) {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def label = Label.findById(params['tag'])
        if (!label) {
            flash.message = message(code: 'default.not.found.message',
                    args: [message(code: 'default.label.label', default: 'Tag'), params.id]) as String
            redirect(action: "edit", params: [id: params.id])
            return
        }

        user.labels.add(label)
        user.save(flush: true, failOnError: true)

        flash.message = message(code: 'user.label.added', args: [label.value]) as String
        redirect(action: "edit", params: [id: params.id])
    }

    @Transactional
    def deleteLabel () {
        def userId = params['userId']
        if (userId.isLong()) {
            def user = User.findById(userId.toLong())
            def labels = user.labels
            def labelIdToRemove = params['selectedLabelId']
            if (labelIdToRemove && labelIdToRemove.isLong()) {
                user.labels = labels.grep {label ->
                    label.id != labelIdToRemove.toLong()
                }
                user.save(flush: true)
                render status: NO_CONTENT
            }
        }
    }

    @Transactional
    def update() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def user = User.get(params.long('id'))
        def currentUser = userService.currentUserId
        if (user && currentUser && (userService.isAdmin() || currentUser == user.userId)) {
            if (params.version) {
                def version = params.version.toLong()
                if (user.version > version) {
                    user.errors.rejectValue("version", "default.optimistic.locking.failure",
                            [message(code: 'user.label', default: 'User')] as Object[],
                            "Another user has updated this User while you were editing")
                    render(view: "edit", model: [userInstance: user])
                    return
                }
            }
            //user.properties = params
            bindData(user, params)
            if (!user.hasErrors() && user.save(flush: true)) {
                flash.message = message(code: 'default.updated.message',
                         args: [message(code: 'user.label', default: 'User'), user.id]) as String
                redirect(action: "show", id: user.id)
            }
            else {
                render(view: "edit", model: [userInstance: user])
            }
        }
        else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'user.label', default: 'User'), params.id]) as String
            redirect(action: "adminList")
        }
    }

    @Transactional
    def delete() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def user = User.get(params.long('id'))
        def currentUser = userService.currentUserId
        if (user && currentUser && userService.isAdmin()) {
            try {
                user.delete(flush: true)
                flash.message = message(code: 'default.deleted.message',
                         args: [message(code: 'user.label', default: 'User'), params.id]) as String
                redirect(action: "adminList")
            } catch (DataIntegrityViolationException e) {
                String message = message(code: 'default.not.deleted.message',
                          args: [message(code: 'user.label', default: 'User'), params.id]) as String
                flash.message = message
                log.error(message, e)
                redirect(action: "show", id: params.id)
            }
        } else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'user.label', default: 'User'), params.id]) as String
            redirect(action: "adminList")
        }
    }

    /**
     * @deprecated
     * @return
     */
    def editRoles() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def user = User.get(params.long('id'))
        user.userRoles = sortUserRoles (user)

        def currentUser = userService.currentUserId
        if (!user || !currentUser) {
            flash.message = "User not found!"
            redirect(action: "list")
            return
        }

        if (!userService.isAdmin()) {
            flash.message = "You have insufficient priviliges to manage the roles for this user!"
            render(view: '/notPermitted')
        }

        [userInstance: user,
         currentUser: currentUser,
         roles: Role.findAllByNameInList([BVPRole.FORUM_MODERATOR, BVPRole.VALIDATOR]),
         institutions: Institution.list (sort: 'name', order: 'asc'),
         projects: Project.list(sort: 'name', order: 'asc')]
    }

    private def sortUserRoles (def userInstance) {
        return userInstance.userRoles.sort {a, b ->
            a.role.name <=> b.role.name ?: a.project?.name <=> b.project?.name ?: a.institution?.name <=> b.institution?.name
        }
    }

    /**
     * @deprecated
     */
    def deleteRoles() {
        if (!userService.isAdmin()) {
            render status: 403
            return
        }
        def userRoleId = params.selectedUserRoleId as long
        def userRole = UserRole.get(userRoleId)
        if (userRole) {
            userRole.delete(flush: true)
        }
        render ([status: "success"] as JSON)
    }

    /**
     * @deprecated
     */
    def addRoles() {
        def currentUser = userService.getCurrentUser()

        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
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
        def userRole = new UserRole(user: userInstance, role: role, project: selectedProject, institution: selectedInstitution, createdBy: currentUser)
        userRole.save(flush: true, failOnError: true)
        userInstance.addToUserRoles(userRole)
        userInstance.userRoles = sortUserRoles (userInstance)
        render template:'userRoles', model: [userInstance: userInstance]
    }

    def notebook() {
        userService.registerCurrentUser()
        def user = userService.currentUser
        if (params.int("id")) {
            user = User.get(params.int("id"))
        }

        if (!user) {
            //flash.message = "User not found!"
            render(view: "/notPermitted")
            return
        }

        forward(action: 'show', id: user.id)
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

        final query = """
{
    "query": {
        "bool": {
            "must": [
                {
                    "term": { 
                        "transcriptions.fullyTranscribedBy": "${userInstance.userId}" 
                    }
                },
                {
                    "term": { 
                        "fields.name": "decimalLongitude" 
                    }
                },
                {
                    "term": { 
                        "fields.name": "decimalLatitude" 
                    }
                }
            ]
        }
    }
}"""
        // Elastic Search max value.
        final int MAX_SEARCH = 10000
        def searchResponse = fullTextIndexService.rawSearch(query, SearchType.QUERY_THEN_FETCH, MAX_SEARCH, fullTextIndexService.rawResponse)
        sw.stop()
        log.debug("ajaxGetPoints| fullTextIndexService.rawSearch(): ${sw.toString()}")
        sw.reset().start()

        // Regex for detecting traditional latitude/longitude. We will convert to decimal for Google Maps.
        def regex = Pattern.compile(/(((\d+)°)?)(((\d+)')?)(((\d+)")?)([NnSsEeWw])/)

        def data = searchResponse.hits.hits.collect { hit ->
            def field = hit.source['fields']

            def pt = field.findAll { value ->
                value['name'] == 'decimalLongitude' || value['name'] == 'decimalLatitude'
            }.collectEntries { value ->
                //def dVal = value['value'] as String
                def dVal = fieldService.convertLocationToDecimal(value['value'] as String)
                log.debug("ajaxGetPoints| dVal: ${value['value']}")

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

    /**
     * Converts a string value to a BigDecimal, returning 0 if the value isn't parseable.
     * @param input the value to convert
     * @return a BigDecimal or 0 if null/empty.
     */
    def getBigDecimalFromString(String input) {
        if (!Strings.isNullOrEmpty(input) && !input.equalsIgnoreCase("null")) {
            return new BigDecimal(input.toInteger().intValue())
        } else {
            return new BigDecimal(0)
        }
    }

    def notebookMainFragment() {
        def user = User.get(params.int("id"))
        //def simpleTemplateEngine = new SimpleTemplateEngine()
        Stopwatch sw = Stopwatch.createStarted()
        def c = Transcription.createCriteria()
        def expeditions = c {
            eq("fullyTranscribedBy", user.userId)
            projections {
                countDistinct("project")
            }
        }
        sw.stop()

        log.debug("notebookMainFragment.projectCount ${sw.toString()}")

        sw.reset().start()
        def score = userService.getUserScore(user)
        sw.stop()
        log.debug("notebookMainFragment.getUserScore ${sw.toString()}")

        sw.reset().start()
        def recentAchievements = AchievementAward.findAllByUser(user, [sort:'awarded', order:'desc', max: 3])
        sw.stop()
        log.debug("notebookMainFragment.recentAchievements ${sw.toString()}")

        sw.reset().start()
        final String query = freemarkerService.runTemplate(ALA_HARVESTABLE, [userId: user.userId])
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
        def fieldObservationQuery = freemarkerService.runTemplate(FIELD_OBSERVATIONS, [userId: user.userId])
        def fieldObservationCount = fullTextIndexService.rawSearch(fieldObservationQuery, SearchType.COUNT, fullTextIndexService.hitsCount)

        sw.stop()
        log.debug("notbookMainFragment.fieldObservationCount ${sw.toString()}")

        sw.reset().start()
        final validatedQuery = freemarkerService.runTemplate(VALIDATED_TASKS_FOR_USER, [userId: user.userId])
        def validatedCount = fullTextIndexService.rawSearch(validatedQuery, SearchType.COUNT, fullTextIndexService.hitsCount)
        sw.stop()
        log.debug("notbookMainFragment.validatedCount ${sw.toString()}")

        [userInstance: user, expeditionCount: expeditions ? expeditions[0] : 0, score: score,
         recentAchievements: recentAchievements, speciesList: speciesList2, fieldObservationCount: fieldObservationCount,
         validatedCount: validatedCount, userPercent: userPercent, totalSpeciesCount: totalSpeciesCount
        ]
    }

    def badgesFragment() {
        def user = User.get(params.int("id"))
        //def achievements = achievementService.calculateAchievements(userInstance)
        def achievements = user.achievementAwards
        def sortedAchievements = achievements.sort { a,b -> b.awarded.compareTo(a.awarded) }
        def score = userService.getUserScore(user)
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

        [userInstance: user, achievements: sortedAchievements, score: score, allAchievements: otherAchievements]
    }

    def recentTasksFragment() {
        def user = User.get(params.int("id"))
        def tasks = taskService.getRecentlyTranscribedTasks(user?.userId,
                ['max' : 5, 'sort':'dateFullyTranscribed', order:'desc'])

        [userInstance: user, recentTasks: tasks]
    }

    def socialFragment() {
        def user = User.get(params.int("id"))

        def recentPosts = forumService.getRecentPostsForUser(user, 5)
        def watchedTopics = UserForumWatchList.findByUser(user)?.topics

        def messages = ForumMessage.findAllByUser(user)
        def friends =  messages.unique({ it.topic.creator })*.topic.creator

        if (friends.contains(user)) {
            friends.remove(user)
        }

        [userInstance: user, recentPosts: recentPosts, watchedTopics: watchedTopics, friends: friends]
    }

    def transcribedTasksFragment() {
        def user = User.get(params.int("id"))

        [userInstance: user]
    }

    def savedTasksFragment() {
        def user = User.get(params.int("id"))

        [userInstance: user]
    }

    def validatedTasksFragment() {
        def user = User.get(params.int("id"))

        [userInstance: user]
    }
}
