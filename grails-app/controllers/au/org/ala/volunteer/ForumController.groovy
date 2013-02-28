package au.org.ala.volunteer

import grails.converters.JSON

class ForumController {

    def forumService
    def userService
    def markdownService
    def authService
    def projectService
    def fieldService

    def index() {
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
                def topics = forumService.getProjectForumTopics(projectInstance, false, params)
                return [projectInstance: projectInstance, topics: topics]
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

        def title = params.title
        def text = params.text

        def messages = []

        if (!title) {
            messages << "You must enter a title for your forum topic"
        }

        if (!text) {
            messages << "You must enter a message for your forum topic"
        }

        if (messages) {
            flash.message = formatMessages(messages)
            redirect(action: 'addForumTopic', params: params)
            return
        }

        def locked = false
        def sticky = false
        def priority = ForumTopicPriority.Normal
        def featured = false


        ForumTopic topic = null
        if (params.taskId) {
            def taskInstance = Task.get(params.int("taskId"))
            if (taskInstance) {
                if (userService.isForumModerator(taskInstance.project)) {
                    locked = params.locked == 'on'
                    sticky = params.sticky == 'on'
                    priority = Enum.valueOf(ForumTopicPriority.class, params.priority as String)
                    featured = params.featured == 'on'
                }
            }
            topic = new TaskForumTopic(task: taskInstance, title: title, creator: userService.currentUser, dateCreated: new Date(), priority: priority, locked: locked, sticky: sticky)
        } else if (params.projectId) {
            def projectInstance = Project.get(params.int("projectId"))
            if (projectInstance) {
                if (userService.isForumModerator(projectInstance)) {
                    locked = params.locked == 'on'
                    sticky = params.sticky == 'on'
                    priority = Enum.valueOf(ForumTopicPriority.class, params.priority as String)
                    featured = params.featured == 'on'
                }
            }
            topic = new ProjectForumTopic(project: projectInstance, title: title, creator: userService.currentUser, dateCreated: new Date(), priority: priority, locked: locked, sticky: sticky)
        } else {
            // new general discussion topic
            if (userService.isForumModerator(null)) {
                locked = params.locked == 'on'
                sticky = params.sticky == 'on'
                priority = Enum.valueOf(ForumTopicPriority.class, params.priority as String)
                featured = params.featured == 'on'
            }
            topic = new SiteForumTopic(title: title, creator: userService.currentUser, dateCreated: new Date(), priority: priority, locked: locked, sticky: sticky, featured: featured)
        }

        // SO that it gets sorted correctly!
        topic.lastReplyDate = topic.dateCreated

        topic.save(flush: true, failOnError: true)

        def firstMessage = new ForumMessage(topic: topic, text: text, date: topic.dateCreated, user: topic.creator)
        firstMessage.save(flush: true, failOnError: true)

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
        def topic = ForumTopic.get(params.id)
        if (topic) {
            topic.lock()
            topic.views++
            topic.save()
        }

        Project projectInstance = null
        Task taskInstance = null
        if (topic.instanceOf(ProjectForumTopic)) {
            projectInstance = (topic as ProjectForumTopic).project
        } else if (topic.instanceOf(TaskForumTopic)) {
            taskInstance = (topic as TaskForumTopic).task
        }

        def userInstance = userService.currentUser
        def isWatching = forumService.isUserWatchingTopic(userInstance, topic)

        [topic: topic, userInstance: userInstance, projectInstance: projectInstance, taskInstance: taskInstance, isWatched: isWatching]
    }

    def postMessage() {
        def topic = ForumTopic.get(params.int("topicId"))
        if (topic) {
            ForumMessage replyTo = null
            if (params.replyTo) {
               replyTo = ForumMessage.get(params.int("replyTo"))
            } else {
               replyTo = forumService.getFirstMessageForTopic(topic)
            }

            def isWatched = forumService.isUserWatchingTopic(userService.currentUser, topic)

            [topic: topic, replyTo: replyTo, userInstance: userService.currentUser, isWatched: isWatched]
        }

    }

    def editMessage() {
        def message = ForumMessage.get(params.int("messageId"))
        def isWatched = forumService.isUserWatchingTopic(userService.currentUser, message?.topic)

        [forumMessage: message, isWatched: isWatched, userInstance: userService.currentUser, messageText: params.messageText ?: message.text]
    }

    def previewMessage() {
        def topic = ForumTopic.get(params.topicId)
        if (topic) {
            ForumMessage replyTo = null
            if (params.replyTo) {
                replyTo = ForumMessage.get(params.int("replyTo"))
            } else {
                replyTo = forumService.getFirstMessageForTopic(topic)
            }
            def isWatched = forumService.isUserWatchingTopic(userService.currentUser, topic)
            render view:'postMessage', model: [topic: topic, replyTo: replyTo, userInstance: userService.currentUser, isWatched: isWatched], params: [messageText: params.messageText]
        }
    }

    def previewMessageEdit() {
        def message = ForumMessage.get(params.int("messageId"))
        def isWatched = forumService.isUserWatchingTopic(userService.currentUser, message?.topic)
        render view:'editMessage', model: [forumMessage: message, isWatched: isWatched, userInstance: userService.currentUser, messageText: params.messageText]
    }

    def updateTopicMessage() {

        def message = ForumMessage.get(params.int("messageId"))
        def currentUser = userService.currentUser
        if (message && currentUser) {
            if (!forumService.isMessageEditable(message, currentUser)) {
                throw new RuntimeException("You do not have sufficient privileges to edit this message!")
            }
            message.text = params.messageText
            if (params.watchTopic == 'on') {
                forumService.watchTopic(currentUser, message.topic)
            } else {
                forumService.unwatchTopic(currentUser, message.topic)
            }
        }
        redirect(action:'viewForumTopic', id: message?.topic?.id)
    }

    def deleteTopicMessage() {
        def message = ForumMessage.get(params.int("messageId"))
        def currentUser = userService.currentUser
        if (message && currentUser) {
            if (!forumService.isMessageEditable(message, currentUser)) {
                throw new RuntimeException("You do not have sufficient privileges to edit this message!")
            }
            message.delete()
        }
        redirect(action:'viewForumTopic', id: message?.topic?.id)
    }

    def saveNewTopicMessage() {
        def topic = ForumTopic.get(params.topicId)
        def user = userService.currentUser
        ForumMessage replyTo = null
        if (params.replyTo) {
            replyTo = ForumMessage.get(params.int("replyTo"))
        }

        if (replyTo == null) {
            replyTo = forumService.getFirstMessageForTopic(topic)
        }

        def errors = []

        if (topic && params.messageText && user) {

            def text = params.messageText as String
            def maxSize = ForumMessage.constraints.text.getAppliedConstraint( 'maxSize' ).maxSize

            text = markdownService.sanitize(text)

            if (text.length() > maxSize) {
                errors << "The message text is too long. It needs to be less than ${maxSize} characters"
            }

            if (!errors) {
                ForumMessage message = new ForumMessage(topic: topic, user: user, replyTo: replyTo, date: new Date(), text: params.messageText)
                message.save(flush:true, failOnError: true)

                def currentUser = userService.currentUser

                if (params.watchTopic == 'on') {
                    forumService.watchTopic(currentUser, topic)
                } else {
                    forumService.unwatchTopic(currentUser, topic)
                }

                forumService.scheduleTopicNotification(topic, message)

                redirect(action: 'viewForumTopic', id: topic?.id)
                return
            }
        } else {
            errors << "Message text must not be empty"
        }

        flash.message = formatMessages(errors)
        render view:'postMessage', model: [topic: topic, replyTo: replyTo, userInstance: userService.currentUser], params: [messageText: params.messageText]
    }

    def deleteTopic() {
        def topic = ForumTopic.get(params.int("topicId"))
        if (!topic || !checkModerator(topic)) {
            return
        }
        def topicSet = new HashSet<ForumTopic>()
        topicSet.add(topic)
        def c = UserForumWatchList.createCriteria()

        def watchLists = c.list {
            topics {
                eq('id', topic.id)
            }
        }

        watchLists?.each {
            it.removeFromTopics(topic)
            it.save(flush: true)
        }

        topic.delete(flush: true)
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
        [projectInstance: projectInstance]
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
        def results =[success: 'false']
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

        ProjectSummaryList projectSummaryList = projectService.getProjectSummaryList(params)

        [projectSummaryList: projectSummaryList]
    }

    def ajaxWatchedTopicsList() {

        def user = userService.currentUser
        UserForumWatchList watchList = UserForumWatchList.findByUser(user)
        def idList = watchList?.topics?.collect { it.id }

        def sort = params.sort

        if (sort && !ForumTopic.declaredFields.find { it.name == sort }) {
            sort = 'title'
        }

        def c = ForumTopic.createCriteria()
        def topics = c.list(sort: sort, order: params.order) {
            inList('id', idList)
        }

        if (params.sort == 'id') {
            // we are actually supposed to sort by number of replies. Number of replies is actually a calculated field (the number
            // of messages - 1, so can't sort in the criteria, so do it manually...
            topics.sort { topic ->
                 topic.messages?.size()
            }

            if (params.order == 'desc') {
                topics = topics.reverse()
            }
        }

        [topics: topics]
    }

    def userCommentsFragment() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        def userInstance = User.get(params.int("userId"))
        def messages = forumService.getMessagesForUser(userInstance, params)
        [userInstance: userInstance, messages: messages]
    }

}
