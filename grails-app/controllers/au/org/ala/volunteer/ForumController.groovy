package au.org.ala.volunteer

import grails.converters.JSON

class ForumController {

    def forumService
    def userService
    def markdownService
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
                def cleanedParams = params - [max: params.max, offset: params.offset]
                def topics = forumService.getProjectForumTopics(projectInstance, false, params.int('selectedTab') == 1 ? cleanedParams : params)

                def userInstance = userService.currentUser
                def isWatching = false

                def projectWatchList = ProjectForumWatchList.findByProject(projectInstance)
                if (projectWatchList) {
                    isWatching = projectWatchList.users.find { it.id == userInstance.id }
                }

                return [projectInstance: projectInstance, topics: topics, isWatching: isWatching]
            }
        }

        flash.message = message(code: "forum.project_with_id_x_cannot_be_found", args: [params.projectId])
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
            flash.message = message(code: "forum.topic_id_missing_or_not_found")
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
            flash.message = message(code: "forum.you_do_not_have_sufficient_privilleges")
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
            flash.message = message(code: "forum.you_do_not_have_sufficient_privilleges")
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
            messages << message(code: "forum.you_must_enter_a_title")
        }

        if (!text) {
            messages << message(code: "forum.you_must_enter_a_message")
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
            topic = new TaskForumTopic(task: taskInstance, title: title, creator: userService.currentUser, dateCreated: new Date(), priority: priority, locked: locked, sticky: sticky, featured: featured)
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
            topic = new ProjectForumTopic(project: projectInstance, title: title, creator: userService.currentUser, dateCreated: new Date(), priority: priority, locked: locked, sticky: sticky, featured: featured)
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

        forumService.scheduleNewTopicNotification(topic, firstMessage)

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
            flash.message = message(code: "forum.you_do_not_have_sufficient_privilleges")
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

    private String formatMessages(List messages, String title = message(code: "forum.the_following_errors_have_occured")) {
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

            Project projectInstance = null
            Task taskInstance = null
            if (topic.instanceOf(ProjectForumTopic)) {
                projectInstance = (topic as ProjectForumTopic).project
            } else if (topic.instanceOf(TaskForumTopic)) {
                taskInstance = (topic as TaskForumTopic).task
            }

            def isWatched = forumService.isUserWatchingTopic(userService.currentUser, topic)

            [topic: topic, replyTo: replyTo, userInstance: userService.currentUser, isWatched: isWatched, taskInstance: taskInstance, projectInstance: projectInstance]
        } else {
            redirect(controller:'forum', action: 'index')
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
            forumService.deleteMessage(message)
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
            def maxSize = ForumMessage.constrainedProperties['text']?.maxSize ?: Integer.MAX_VALUE

            text = markdownService.sanitize(text)

            if (text.length() > maxSize) {
                errors << message(code: "forum.the_text_is_too_long", args: [maxSize] )
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
            errors << message(code: "forum.message_text_must_not_be_empty")
        }

        flash.message = formatMessages(errors)
        render view:'postMessage', model: [topic: topic, replyTo: replyTo, userInstance: userService.currentUser], params: [messageText: params.messageText]
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
            flash.message = message(code: "forum.no_task_found_with_matching_id")
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
            flash.message =message(code: "forum.you_must_supply_search_criteria")
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

        if (sort && !ForumTopic.declaredFields.find { it.name == sort }) {
            sort = 'title'
        }

        def c = ForumTopic.createCriteria()
        def topics = []
        if (idList) {
            topics = c.list(sort: sort, order: params.order) {
                inList('id', idList)
            }
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
        def id = params.int("id")
        def userInstance = User.get(id)
        def messages = forumService.getMessagesForUser(userInstance, params)
        [userInstance: userInstance, messages: messages]
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
        items << [effect: message(code: "forum.markdown.italics"), description:message(code: "forum.markdown.italics.description"), code:'_text to italicise__ or *text to italicise*']
        items << [effect: message(code: "forum.markdown.bold"), description:message(code: "forum.markdown.bold.description"), code:'__text to embolden__ or **text to embolden**']
        items << [effect: message(code: "forum.markdown.headings"), description:message(code: "forum.markdown.headings.description"), code:'### Heading 3\n#### Heading 4']
        items << [effect: message(code: "forum.markdown.headings_alternate"), description:message(code: "forum.markdown.headings_alternate.description"), code:'Heading 1\n=========\nHeading 2\n---------']
        items << [effect: message(code: "forum.markdown.line_break"), description:message(code: "forum.markdown.line_break.description"), code:'line1\n  \nline2']
        items << [effect: message(code: "forum.markdown.links"), description:message(code: "forum.markdown.links.description"), code:'[Google!](http://google.com)']
        items << [effect: message(code: "forum.markdown.horizontal_rules"), description:message(code: "forum.markdown.horizontal_rules.description"), code:'***']
        def listDemo = """
&nbsp;&nbsp;* Item 1
&nbsp;&nbsp;* Item 2
&nbsp;&nbsp;&nbsp;&nbsp;* Subitem 2.1
&nbsp;&nbsp;&nbsp;&nbsp;* Subitem 2.2
        """
        items << [effect: message(code: "forum.markdown.lists"), description:message(code: "forum.markdown.lists.description"), code:listDemo]
        def blockQuoteDemo = """
> ${message(code: "forum.markdown.this_is_some_quoted_text")}
> > ${message(code: "forum.markdown.this_has_been_quoted_twice")}
"""
        items << [effect: message(code: "forum.markdown.block_quotes"), description:message(code: "forum.markdown.block_quotes.description"), code:blockQuoteDemo]

        [items: items]
    }

    def ajaxWatchProject() {
        def projectInstance = Project.get(params.int("projectId"))
        def results = [success: false, message:'']

        def user = userService.currentUser
        
        if (user && projectInstance && params.containsKey("watch")) {
            def watch = params.boolean("watch")
            
            def watchList = ProjectForumWatchList.findByProject(projectInstance)
            if (!watchList) {
                watchList = new ProjectForumWatchList(project: projectInstance)
                watchList.save(failOnError: true)
            }

            if (watch) {
                if (!watchList.containsUser(user)) {
                    watchList.addToUsers(user)
                }
                results.message = message(code: "forum.you_will_be_sent_a_notification_email")
            } else {
                if (watchList.containsUser(user)) {
                    watchList.removeFromUsers(user)
                }
                results.message = message(code: "forum.you_will_no_longer_be_sent_notifications")
            }

            watchList.save()
            results.success = true;
        }
        
        render(results as JSON)
    }

}
