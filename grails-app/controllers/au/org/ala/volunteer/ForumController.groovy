package au.org.ala.volunteer

import grails.converters.JSON
import grails.gorm.transactions.Transactional
import org.apache.commons.lang.StringUtils

class ForumController {

    def forumService
    def userService
    def projectService
    def fieldService
    def markdownService

    def index() {
        def currentUser = userService.currentUser
        def filter = params.filter as String
        def searchQuery = params.q as String
        def watched = "true".equalsIgnoreCase(params.watched as String)

        if (!currentUser) {
            flash.message = message(code: 'default.not.found.message',
                    args: [message(code: 'user.label', default: 'User'), params.id]) as String
            render(view: '/notPermitted')
            return
        }

        def project = null
        if (params.projectId) {
            project = Project.get(params.long('projectId'))
        }

        def forumTopics = forumService.getForumTopics(project, currentUser, searchQuery, filter, watched,
                params.int('offset', 0),
                params.int('max', 30),
                params.sort as String,
                params.order as String)

        def projectFilterList = projectService.getProjectsWithTopicCounts()

        [topicList: forumTopics.topicList, topicCount: forumTopics.topicCount, project: project, projectFilterList: projectFilterList]
    }

    def ajaxRecentTopicsList() {
        def results = forumService.getFeaturedTopics(params)
        [featuredTopics: results.topics, totalCount: results.totalCount]
    }

    def projectForum() {

        def projectId = params.int("projectId")

        if (!params.max) {
            params.max = 10
        }

        if (projectId) {
            def projectInstance = Project.get(projectId)
            if (projectInstance) {
                def cleanedParams = params - [max: params.max, offset: params.offset]
                def topics = forumService.getProjectForumTopics(projectInstance, false, params.int('selectedTab') == 1 ? cleanedParams : params)

                def userInstance = userService.currentUser
                def isWatching = false

                if (userInstance) {
                    def projectWatchList = ProjectForumWatchList.findByProject(projectInstance)
                    if (projectWatchList) {
                        isWatching = projectWatchList.users.any { it != null && it.id == userInstance.id }
                    }
                }

                return [projectInstance: projectInstance, topics: topics, isWatching: isWatching]
            }
        }

        flash.message = "Project with id ${params.projectId} could not be found!"
        redirect(controller: 'forum', action:'index')
    }

    def addForumTopic() {

        // A new forum topic can belong to either a project, a task (and therefore by association, also a project),
        // or neither, in which case it is a general discussion topic.
        // The same view collects the new topic data regardless, and depending on if a task or project is submitted,
        // the insertForumTopic action will decide to which 'forum' to attach the topic.

        // so for this reason we inject either a task, a project, or neither into the view here...
        def projectInstance = Project.get(params.int("projectId"))
        def taskInstance = Task.get(params.int("taskId"))

        // if there is a task id, we may also need it's catalog number
        def catalogNumber = ''
        if (taskInstance) {
            catalogNumber = fieldService.getFieldForTask(taskInstance, "catalogNumber")?.value
        }

        return [projectInstance: projectInstance, taskInstance: taskInstance, catalogNumber: catalogNumber]
    }

    def editTopic() {
        def topic = ForumTopic.get(params.int("topicId"))

        if (topic == null) {
            flash.message = "Topic id missing or topic not found!"
            redirect(action:'index')
            return
        }

        Project projectInstance = null
        Task taskInstance = null
        def allowed = false
        if (topic.instanceOf(ProjectForumTopic)) {
            projectInstance = (topic as ProjectForumTopic).project
            allowed = userService.isForumModerator(projectInstance)
        } else if (topic.instanceOf(TaskForumTopic)) {
            taskInstance = (topic as TaskForumTopic).task
            allowed = userService.isForumModerator(taskInstance.project)
        } else {
            allowed = userService.isForumModerator(null)
        }

        if (!allowed) {
            flash.message = "You do not have sufficient privileges to edit this topic"
            redirect(action: 'redirectTopicParent', id: topic.id)
            return
        }

        [topic:topic, taskInstance: taskInstance, projectInstance: projectInstance]
    }

    public redirectTopicParent() {

        def topic = ForumTopic.get(params.int("id"))

        if (topic) {
            if (topic.instanceOf(ProjectForumTopic)) {
                def projectInstance = (topic as ProjectForumTopic).project
                redirect(controller: 'forum', action: 'projectForum', params: [projectId: projectInstance.id])
            } else if (topic.instanceOf(TaskForumTopic)) {
                def taskInstance = (topic as TaskForumTopic).task
                redirect(controller: 'forum', action: 'projectForum', params: [projectId: taskInstance.project.id])
            } else {
                redirect(controller: 'forum', action: 'index', params:[selectedTab: 1])
            }
        } else {
            redirect(controller: 'forum', action: 'index')
        }
    }

    def editProjectTopic() {
        def topic = ProjectForumTopic.get(params.int("topicId"))
        if (!topic || !userService.isForumModerator(topic.project)) {
            flash.message = "You do not have sufficient privileges to edit this topic"
            redirect controller:'forum', action: 'projectForum', params:[projectId: topic?.project?.id]
            return
        }
        [topic: topic, user: userService.currentUser]
    }

    def insertForumTopic() {

        def parameters = [title: params.title, text: params.text]
        def messages = []

        if (!parameters.title) {
            messages << "You must enter a title for your forum topic"
        }

        if (!parameters.text) {
            messages << "You must enter a message for your forum topic"
        }

        if (messages) {
            flash.message = formatMessages(messages)
            redirect(action: 'addForumTopic', params: params)
            return
        }

        parameters.locked = false
        parameters.sticky = false
        parameters.priority = ForumTopicPriority.Normal
        parameters.featured = false

        ForumTopic topic = null
        if (params.taskId) {
            def task = Task.get(params.int("taskId"))
            if (task) {
                if (userService.isForumModerator(task.project)) {
                    parameters.locked = params.locked == 'on'
                    parameters.sticky = params.sticky == 'on'
                    if (params.priotity) {
                        parameters.priority = Enum.valueOf(ForumTopicPriority.class, params.priority as String)
                    }
                    parameters.featured = params.featured == 'on'
                }
            }
            topic = forumService.createForumTopic(task, parameters)
        } else if (params.projectId) {
            def project = Project.get(params.int("projectId"))
            if (project) {
                if (userService.isForumModerator(project)) {
                    parameters.locked = params.locked == 'on'
                    parameters.sticky = params.sticky == 'on'
                    if (params.priotity) {
                        parameters.priority = Enum.valueOf(ForumTopicPriority.class, params.priority as String)
                    }
                    parameters.featured = params.featured == 'on'
                }
            }
            topic = forumService. createForumTopic(project, parameters)
        } else {
            // new general discussion topic
            if (userService.isForumModerator(null)) {
                parameters.locked = params.locked == 'on'
                parameters.sticky = params.sticky == 'on'
                if (params.priotity) {
                    parameters.priority = Enum.valueOf(ForumTopicPriority.class, params.priority as String)
                }
                parameters.featured = params.featured == 'on'
            }
            topic = forumService.createForumTopic(parameters)
        }

        if (params.watchTopic == 'on') {
            forumService.watchTopic(topic.creator, topic)
        }

        redirect(action: 'redirectTopicParent', id: topic.id)
    }

    private boolean checkModerator(ForumTopic topic = null) {

        def project = null
        if (topic?.instanceOf(ProjectForumTopic)) {
            project = (topic as ProjectForumTopic)?.project
        } else if (topic?.instanceOf(TaskForumTopic)) {
            project = (topic as TaskForumTopic)?.task?.project
        }

        if (!userService.isForumModerator(project)) {
            flash.message = "You do not have sufficient privileges to edit this topic"
            redirect controller:'forum', action: 'projectForum', params:[projectId: project?.id]
            return false
        }

        return true
    }

    @Transactional
    def updateTopic() {

        def topic = ForumTopic.get(params.int('topicId'))
        if (!topic || !checkModerator(topic)) {
            return
        }

        def locked = params.locked == 'on'
        def sticky = params.sticky == 'on'
        def priority = Enum.valueOf(ForumTopicPriority.class, params.priority as String)
        def featured = params.featured == 'on'

        topic.title = params.title
        topic.sticky = sticky
        topic.locked = locked
        topic.priority = priority
        topic.featured = featured

        topic.save(flush: true, failOnError: true)

        redirect(action: 'redirectTopicParent', id: topic?.id)
    }

    private String formatMessages(List messages, String title = "The following errors have occurred:") {
        def sb = new StringBuilder("${title}<ul>")
        messages.each {
            sb << "<li>" + it + "</li>"
        }
        sb << "<ul>"
        return sb.toString()
    }

    def viewForumTopic() {
        def topic = ForumTopic.get((params.id ?: params.topicId) as long)
        if (topic) {
            forumService.incrementTopicView(topic)
        } else {
            // No longer exists.
            flash.message = "Topic not found, either deleted or incorrect ID."
            redirect(controller: 'forum', action:'index')
            return
        }

//        Project projectInstance = null
//        Task taskInstance = null
//        if (topic.instanceOf(ProjectForumTopic)) {
//            projectInstance = (topic as ProjectForumTopic).project
//        } else if (topic.instanceOf(TaskForumTopic)) {
//            taskInstance = (topic as TaskForumTopic).task
//        }

//        def userInstance = userService.currentUser
//        def isWatching = forumService.isUserWatchingTopic(userInstance, topic)
//
//        ForumMessage replyTo = null
//        if (params.replyTo) {
//            replyTo = ForumMessage.get(params.int("replyTo"))
//        } else {
//            replyTo = forumService.getFirstMessageForTopic(topic)
//        }

        def topicValues = getTopicParameters(topic)

        [topic: topic, userInstance: topicValues.user, projectInstance: topicValues.projectInstance,
         taskInstance: topicValues.taskInstance, isWatched: topicValues.isWatching, replyTo: topicValues.replyTo]
    }

    def postMessage() {
        def topic = ForumTopic.get(params.int("topicId"))
        if (topic) {
//            ForumMessage replyTo = null
//            if (params.replyTo) {
//               replyTo = ForumMessage.get(params.int("replyTo"))
//            } else {
//               replyTo = forumService.getFirstMessageForTopic(topic)
//            }
//
//            Project projectInstance = null
//            Task taskInstance = null
//            if (topic.instanceOf(ProjectForumTopic)) {
//                projectInstance = (topic as ProjectForumTopic).project
//            } else if (topic.instanceOf(TaskForumTopic)) {
//                taskInstance = (topic as TaskForumTopic).task
//            }
//
//            def isWatched = forumService.isUserWatchingTopic(userService.currentUser, topic)

            def topicValues = getTopicParameters(topic)

            [topic: topic, replyTo: topicValues.replyTo, userInstance: userService.currentUser,
             isWatched: topicValues.isWatched, taskInstance: topicValues.taskInstance,
             projectInstance: topicValues.projectInstance]
        } else {
            redirect(controller:'forum', action: 'index')
        }

    }

    def editMessage() {
        def message = ForumMessage.get(params.int("messageId"))
        def isWatched = forumService.isUserWatchingTopic(userService.currentUser, message?.topic)

        [forumMessage: message, isWatched: isWatched, userInstance: userService.currentUser,
         messageText: params.messageText ?: message.text]
    }

    def previewMessage() {
        def topic = ForumTopic.get(params.topicId)
        if (topic) {
//            ForumMessage replyTo = null
//            if (params.replyTo) {
//                replyTo = ForumMessage.get(params.int("replyTo"))
//            } else {
//                replyTo = forumService.getFirstMessageForTopic(topic)
//            }

//            def isWatched = forumService.isUserWatchingTopic(userService.currentUser, topic)
//
//            Project projectInstance = null
//            Task taskInstance = null
//            if (topic.instanceOf(ProjectForumTopic)) {
//                projectInstance = (topic as ProjectForumTopic).project
//            } else if (topic.instanceOf(TaskForumTopic)) {
//                taskInstance = (topic as TaskForumTopic).task
//            }
            def topicValues = getTopicParameters(topic)

            log.debug("previewMessage | ${params}")

            render view:'viewForumTopic',
                    model: [topic: topic, replyTo: topicValues.replyTo, userInstance: userService.currentUser,
                            projectInstance: topicValues.projectInstance, taskInstance: topicValues.taskInstance,
                            isWatching: topicValues.isWatched],
                    params: [messageText: markdownService.sanitizeMarkdown(params.messageText)]
        }
    }

    def previewMessageEdit() {
        def message = ForumMessage.get(params.int("messageId"))
        def isWatched = forumService.isUserWatchingTopic(userService.currentUser, message?.topic)
        render view:'editMessage', model: [forumMessage: message,
                                           isWatched: isWatched,
                                           userInstance: userService.currentUser,
                                           messageText: markdownService.sanitizeMarkdown(params.messageText)]
    }

    @Transactional
    def updateTopicMessage() {

        def message = ForumMessage.get(params.int("messageId"))
        def currentUser = userService.currentUser
        def text = params.messageText as String

        def errors = []
        if ((message && !StringUtils.isEmpty(text)) && currentUser) {
            if (!forumService.isMessageEditable(message, currentUser)) {
                throw new RuntimeException("You do not have sufficient privileges to edit this message!")
            }

            def maxSize = ForumMessage.constrainedProperties['text']?.maxSize ?: Integer.MAX_VALUE
            text = markdownService.sanitizeMarkdown(text)

            if (message.text.length() > maxSize) {
                errors << "The message text is too long. It needs to be less than ${maxSize} characters"
            }

            if (params.watchTopic == 'on') {
                forumService.watchTopic(currentUser, message.topic)
            } else {
                forumService.unwatchTopic(currentUser, message.topic)
            }
        } else {
            errors << "Message text must not be empty"
        }

        if (!errors) {
            //message.save(flush: true, failOnError: true)
            message.text = text
            message.save(flush: true, failOnError: true)
            flash.message = "Message was successfully updated."
            redirect(action: 'viewForumTopic', id: message?.topic?.id)
            return
        }

        flash.message = formatMessages(errors)
        render view:'editMessage', model: [forumMessage: message,
                                           userInstance: userService.currentUser,
                                           isWatched: (params.watchTopic == 'on'),
                                           messageText: params.messageText]
        //redirect(action:'viewForumTopic', id: message?.topic?.id)
    }

    def deleteTopicMessage() {
        def message = ForumMessage.get(params.int("messageId"))
        def topicId = message?.topic?.id
        def currentUser = userService.currentUser
        if (message && currentUser) {
            if (!forumService.isMessageEditable(message, currentUser)) {
                throw new RuntimeException("You do not have sufficient privileges to edit this message!")
            }
            forumService.deleteMessage(message)
        }

        flash.message = "Message was successfully deleted."

        if (topicId) {
            redirect(action: 'viewForumTopic', id: topicId)
        } else {
            redirect(action: 'index')
        }
    }

    def saveNewTopicMessageAnswered() {
        def topic = ForumTopic.get(params.topicId as long)

        if (!topic) {
            flash.message = "No topic found. No access"
            redirect (controller: 'forum', action: 'index')
            return
        }

        params.isAnswered = true

        def topicValues = saveTopicMessage(topic)
        if (topicValues.errors?.size() > 0) {
            flash.message = formatMessages(errors)
            render view:'viewForumTopic',
                    model: [topic: topic, replyTo: replyTo, userInstance: userService.currentUser,
                            projectInstance: topicValues.projectInstance, taskInstance: topicValues.taskInstance, isWatched: topicValues.isWatched],
                    params: [messageText: params.messageText]
        } else {
            redirect(action: 'viewForumTopic', id: topic?.id)
        }
    }

    def saveNewTopicMessage() {
        def topic = ForumTopic.get(params.topicId as long)

        if (!topic) {
            flash.message = "No topic found. No access"
            redirect (controller: 'forum', action: 'index')
            return
        }

        def topicValues = saveTopicMessage(topic)

        if (topicValues.errors?.size() > 0) {
            flash.message = formatMessages(errors)
            render view:'viewForumTopic',
                    model: [topic: topic, replyTo: replyTo, userInstance: userService.currentUser,
                            projectInstance: topicValues.projectInstance, taskInstance: topicValues.taskInstance, isWatched: topicValues.isWatched],
                    params: [messageText: params.messageText]
        } else {
            redirect(action: 'viewForumTopic', id: topic?.id)
        }
    }

    /**
     *
     * @param topic
     * @param topicValues
     * @return
     */
    private def saveTopicMessage(ForumTopic topic) {
        def topicValues = getTopicParameters(topic) as Map
        def msgParams = [:]
        msgParams.user = topicValues.user
        msgParams.watchTopic = params.watchTopic
        msgParams.replyTo = topicValues.replyTo

        if ((params.isAnswered && Boolean.valueOf(params.isAnswered as String)) || topicValues.isAnswered) {
            msgParams.isAnswered = true
            topicValues.isAnswered = true
        }

        if (!params.messageText) {
            topicValues.errors << "Message text must not be empty"
            return topicValues
        }

        def text = params.messageText as String
        def maxSize = ForumMessage.constrainedProperties['text']?.maxSize ?: Integer.MAX_VALUE

        if (text.length() > maxSize) {
            topicValues.errors << "The message text is too long. It needs to be less than ${maxSize} characters"
            return topicValues
        }

        msgParams.text = markdownService.sanitizeMarkdown(text)
        forumService.addForumMessage(topic, msgParams)

        return topicValues
    }

//    def saveNewTopicMessage() {
//        def topic = ForumTopic.get(params.topicId as long)
//        def msgParams = [:]
//        ForumMessage replyTo = null
//        msgParams.user = userService.currentUser
//        msgParams.watchTopic = params.watchTopic
//
//        if (params.isAnswered && Boolean.valueOf(params.isAnswered as String)) {
//            msgParams.isAnswered = true
//        }
//
//        if (params.replyTo) {
//            replyTo = ForumMessage.get(params.int("replyTo"))
//            msgParams.replyTo = replyTo
//            if (!msgParams.replyTo) msgParams.replyTo = forumService.getFirstMessageForTopic(topic)
//        }
//
//        def errors = []
//        if (topic && params.messageText && msgParams.user) {
//
//            def text = params.messageText as String
//            def maxSize = ForumMessage.constrainedProperties['text']?.maxSize ?: Integer.MAX_VALUE
//            msgParams.text = markdownService.sanitizeMarkdown(text)
//
//            if (text.length() > maxSize) {
//                errors << "The message text is too long. It needs to be less than ${maxSize} characters"
//            }
//
//            if (!errors) {
//                forumService.addForumMessage(topic, msgParams)
//                redirect(action: 'viewForumTopic', id: topic?.id)
//                return
//            }
//        } else {
//            errors << "Message text must not be empty"
//        }
//
//        def topicValues = getTopicParameters(topic)
//
//        flash.message = formatMessages(errors)
//        render view:'viewForumTopic',
//                model: [topic: topic, replyTo: replyTo, userInstance: userService.currentUser,
//                        projectInstance: topicValues.projectInstance, taskInstance: topicValues.taskInstance, isWatched: topicValues.isWatched],
//                params: [messageText: params.messageText]
//    }

    /**
     * Helper method to get parameters for view topic views that are commonly used.
     * @param topic the topic being viewed.
     * @return a Map of parameters: Project, Task, isWatched (boolean), replyTo (ForumMessage) and User.
     */
    private def getTopicParameters(ForumTopic topic) {
        Project projectInstance = null
        Task taskInstance = null
        if (topic.instanceOf(ProjectForumTopic)) {
            projectInstance = (topic as ProjectForumTopic).project
        } else if (topic.instanceOf(TaskForumTopic)) {
            taskInstance = (topic as TaskForumTopic).task
        }

        def isWatched = forumService.isUserWatchingTopic(userService.currentUser, topic)

        ForumMessage replyTo = null
        if (params.replyTo) {
            replyTo = ForumMessage.get(params.int("replyTo"))
        } else {
            replyTo = forumService.getFirstMessageForTopic(topic)
        }

        [projectInstance: projectInstance, taskInstance: taskInstance, user: userService.currentUser, replyTo: replyTo, isWatched: isWatched]
    }

    def deleteTopic() {
        def topic = ForumTopic.get(params.int("topicId"))
        if (!topic || !checkModerator(topic)) {
            return
        }

        forumService.deleteTopic(topic)
        redirect(action: 'redirectTopicParent', id: topic.id)
    }

    def ajaxGeneralTopicsList() {
        def results = forumService.getGeneralDiscussionTopics(false, params)
        [topics:results.topics, totalCount: results.totalCount]
    }

    def taskTopic() {
        def task = Task.get(params.int("taskId"))

        if (!task) {
            flash.message = "No task found with matching id, or task id missing from request!"
            redirect(controller: 'forum', action:'index')
        }

        def topic = TaskForumTopic.findByTask(task)
        if (topic) {
            redirect(controller: 'forum', action: 'viewForumTopic', id: topic.id)
            return
        }
        // task topic does not exist - redirect to new topic...
        redirect(controller:'forum', action: 'addForumTopic', params: [taskId: task.id])
    }

    def ajaxProjectTaskTopicList() {
        def projectInstance = Project.get(params.int("projectId"))
        def topics = projectInstance ? forumService.getTaskTopicsForProject(projectInstance, params) : []

        [projectInstance: projectInstance, topics: topics]
    }

    def searchForums() {
        def query = params.query as String
        if (!query) {
            flash.message ="You must supply a search criteria"
            redirect(controller: 'forum', action: 'index')
            return
        }

        def searchParams = [offset: params.offset ?: 0, max: params.max ?: 10]

        def results = forumService.searchForums(query, false, searchParams)

        [query: query, results: results]
    }

    def ajaxWatchTopic() {
        def topic = ForumTopic.get(params.int("topicId"))
        def watch = params.boolean("watch")
        def results = [success: 'false']
        if (topic) {
            def userInstance = userService.currentUser
            if (watch) {
                forumService.watchTopic(userInstance, topic)
            } else {
                forumService.unwatchTopic(userInstance, topic)
            }
            results.success = 'true'
        }

        render(results as JSON)
    }

    def ajaxProjectForumsList() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        params.sort = params.sort ?: 'completed'

        ProjectSummaryList projectSummaryList = projectService.getProjectSummaryList(params, false)

        def forumStats = [:]

        projectSummaryList.projectRenderList.each {
            def stat = [:]
            stat.projectTopicCount = ProjectForumTopic.countByProject(it.project)
            stat.taskTopicCount = forumService.countTaskTopics(it.project)

            forumStats[it.project] = stat
        }

        [projectSummaryList: projectSummaryList, forumStats: forumStats]
    }

    def ajaxWatchedTopicsList() {

        def user = userService.currentUser
        UserForumWatchList watchList = UserForumWatchList.findByUser(user)
        def idList = watchList?.topics?.collect { it.id }

        def sort = params.sort
        if (!sort) {
            sort = 'id'
        }

        def order = params.order
        if (!order) {
            'desc'
        }

        if (sort && !ForumTopic.declaredFields.find { it.name == sort }) {
            sort = 'title'
            order = 'asc'
        }

        def topics = []
        if (idList) {
            def query = """
                SELECT DISTINCT topic
                FROM ForumTopic topic
                WHERE id in (:idList)
            """

            if (sort != 'id') {
                query = query.toString() + " order by " + sort + " " + order
            }
            topics = ForumTopic.executeQuery(query, [idList: idList])
        }

        if (sort == 'id') {
            // we are actually supposed to sort by number of replies. Number of replies is actually a calculated field (the number
            // of messages - 1, so can't sort in the criteria, so do it manually...
            topics.sort { topic ->
                 topic.messages?.size()
            }

            if (order == 'desc') {
                topics = topics.reverse()
            }
        }

        [topics: topics]
    }

    def userComments() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        def id = params.int("id")
        def userInstance = User.get(id)
        def messages = forumService.getMessagesForUser(userInstance, params)
        def totalCount = messages?.totalCount ?: 0
        def xformMessages = messages?.groupBy { it.topic }?.collect {
            def topic = it.key
            def tms = it.value
            [ topicTask: (topic instanceof TaskForumTopic) ? topic.task : null, // the default json renderer doesn't put the task or project fields in the output but I don't really care about fixing this properly right now.
              topicProject: (topic instanceof ProjectForumTopic) ? topic.project : (topic instanceof TaskForumTopic) ? topic.task.project : null,
              topic: topic,
              messages: tms.collect {[
                      message: it,
                      userProps: userService.detailsForUserId(it.user?.userId),
                      isUserForumModerator: userService.isUserForumModerator(it.user, it.topic instanceof ProjectForumTopic ? it.topic.project : null ) as Boolean
                  ]}
            ]
        } ?: []
        render([totalCount: totalCount, messages: xformMessages] as JSON)
    }

    def markdownHelp() {

        def items = []
        items << [effect: 'Italics/Emphasis', description:'Surround text with either _ or *', code:'_text to italicise__ or *text to italicise*']
        items << [effect: 'Bold/Heavy Emphasis', description:'Surround text with either __ or **', code:'__text to embolden__ or **text to embolden**']
        items << [effect: 'Headings', description:'HTML heading levels can be produced by prepending a number of "#" characters', code:'### Heading 3\n#### Heading 4']
        items << [effect: 'Headings (alternate)', description:'H1 and H2 headings can also by produced by underlining text with either "=" or "-" characters', code:'Heading 1\n=========\nHeading 2\n---------']
        items << [effect: 'Line break or empty line', description:'End a line with two spaces', code:'line1\n  \nline2']
        items << [effect: 'Links/External URLS', description:'Links to other documents can be included using the following syntax<br/>[link text here](link address here)', code:'[Google!](http://google.com)']
        items << [effect: 'Horizontal rules', description:'Horizontal rules are created by placing three or more hyphens, asterisks, or underscores on a line by themselves', code:'***']
        def listDemo = """
&nbsp;&nbsp;* Item 1
&nbsp;&nbsp;* Item 2
&nbsp;&nbsp;&nbsp;&nbsp;* Subitem 2.1
&nbsp;&nbsp;&nbsp;&nbsp;* Subitem 2.2
        """
        items << [effect: 'Lists', description:'Lists can be formed with two leading spaces and an "*". Subitems are indented from the parents by an additional two spaces.', code:listDemo]
        def blockQuoteDemo = """
> this is some quoted text
> > this has been quoted twice
"""
        items << [effect: 'Block quotes', description:'Block quotes are produced when lines and paragraphs are preceded by "&gt;"', code:blockQuoteDemo]

        [items: items]
    }

    def ajaxWatchProject() {
        def projectInstance = Project.get(params.int("projectId"))
        def results = [success: false, message:'']

        def user = userService.currentUser
        
        if (user && projectInstance && params.containsKey("watch")) {
            def watch = params.boolean("watch")

            forumService.watchProject(user, projectInstance, watch)
            if (watch) {
                results.message = "You will be sent a notification email when messages are posted to this project"
            } else {
                results.message = "You will no longer be sent notification emails when messages are posted to this project"
            }

            results.success = true;
        }
        
        render(results as JSON)
    }

}
