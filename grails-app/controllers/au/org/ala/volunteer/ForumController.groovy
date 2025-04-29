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

    public static final String SESSION_KEY_PROJECT_ID = "forum_project_id"

    /**
     * Displays the forum index page.
     * @return a map with the topic list, topic count, project, and project filter list.
     */
    def index() {
        def currentUser = userService.currentUser
        def filter = params.filter as String
        def searchQuery = params.q as String
        def watched = params.boolean("watched") == true
        String pageTitle = message(code: 'default.forum.label', default: 'DigiVol Forum')

        if (!currentUser) {
            flash.message = message(code: 'default.not.found.message',
                    args: [message(code: 'user.label', default: 'User'), params.id]) as String
            render(view: '/notPermitted')
            return
        }

        def project = null
        if (params.projectId) {
            project = Project.get(params.long('projectId'))
            pageTitle = message(code: 'default.forum.expedition.label', default: 'Project Forum')
            session[SESSION_KEY_PROJECT_ID] = project.id
        } else if (params.watched) {
            pageTitle = message(code: 'forum.watched.label', default: 'Watched Topics')
        } else {
            session.removeAttribute(SESSION_KEY_PROJECT_ID)
        }

        def forumTopics = forumService.getForumTopics(project, currentUser, searchQuery, filter, watched,
                params.int('offset', 0),
                params.int('max', 30),
                params.sort as String,
                params.order as String)

        def projectFilterList = projectService.getProjectsWithTopicCounts()

        def watchingProjectForum = false
        if (project) {
            watchingProjectForum = forumService.isUserWatchingProject(currentUser, project)
            log.debug("Watching project forum: ${watchingProjectForum}")
        }

        [topicList: forumTopics.topicList, topicCount: forumTopics.topicCount, project: project,
            projectFilterList: projectFilterList, watchingProjectForum: watchingProjectForum, listPageTitle: pageTitle]
    }

    def expeditions() {
        def currentUser = userService.currentUser
        if (!currentUser) {
            flash.message = message(code: 'default.not.found.message',
                    args: [message(code: 'user.label', default: 'User'), params.id]) as String
            render(view: '/notPermitted')
            return
        }

        def forumProjectsWatched = forumService.getForumProjectWatchList(currentUser)
        [forumProjectWatched: forumProjectsWatched]
    }

    /**
     * Prepares the view for adding a new forum topic.
     * @return a map with the project instance, task instance, catalog number, and user instance.
     */
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

        return [projectInstance: projectInstance, taskInstance: taskInstance, catalogNumber: catalogNumber, userInstance: userService.currentUser]
    }

    /**
     * Prepares the view for editing a topic.
     * @return a map with the topic, task instance, and project instance.
     */
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

    /**
     * Redirects to the parent of the topic.
     * @return redirect to the parent topic.
     */
    def redirectTopicParent() {
        def topic = ForumTopic.get(params.int("id"))

        if (topic) {
            if (topic.instanceOf(ProjectForumTopic)) {
                def projectInstance = (topic as ProjectForumTopic).project
                redirect(controller: 'forum', action: 'projectForum', params: [projectId: projectInstance.id])
            } else if (topic.instanceOf(TaskForumTopic)) {
                def taskInstance = (topic as TaskForumTopic).task
                redirect(controller: 'forum', action: 'projectForum', params: [projectId: taskInstance.project.id])
            } else {
                redirect(controller: 'forum', action: 'index')
            }
        } else {
            redirect(controller: 'forum', action: 'index')
        }
    }

    /**
     * Inserts a new forum topic.
     */
    def insertForumTopic() {
        log.debug("Forum params: ${params}")
        def parameters = [title: params.title, text: params.messageText]
        def messages = []

        if (!parameters.title) {
            messages << "You must enter a title for your forum topic"
        }

        if (!parameters.text) {
            messages << "You must enter a message for your forum topic"
        }

        if (messages) {
            log.debug("Error messages: ${messages}")
            flash.message = formatMessages(messages)
            params.remove('action')
            params.remove('_action_insertForumTopic')
            redirect(action: 'addForumTopic', params: params)
            return
        }

        parameters.locked = false
        parameters.sticky = false
        parameters.priority = ForumTopicPriority.Normal
        parameters.topicType = ForumTopicType.getInstance(params.int('topicType'))
        parameters.featured = false
        log.debug("topicType: ${parameters.topicType}")

        ForumTopic topic = null
        if (params.taskId) {
            def task = Task.get(params.int("taskId"))
            topic = forumService.createForumTopic(task, parameters)
        } else if (params.projectId) {
            def project = Project.get(params.int("projectId"))
            topic = forumService. createForumTopic(project, parameters)
        } else {
            // new general discussion topic
            topic = forumService.createForumTopic(parameters)
        }

        if (params.watched == 'true' || params.watchTopic == 'on') {
            forumService.watchTopic(topic.creator, topic)
        }

        if (session[SESSION_KEY_PROJECT_ID]) {
            redirect(controller: 'forum', action: 'index', params: [projectId: session[SESSION_KEY_PROJECT_ID]])
        } else {
            redirect(controller: 'forum', action: 'index')
        }
    }

    /**
     * Checks if the user is a moderator of the topic.
     * @param topic the topic to check.
     * @return true if the user is a moderator, false otherwise.
     */
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

    /**
     * Updates a topic.
     */
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

    /**
     * Formats a list of messages into a string.
     * @param messages the list of messages to format.
     * @param title the title to use for the message.
     * @return a formatted string with the messages.
     */
    private String formatMessages(List messages, String title = "The following errors have occurred:") {
        def sb = new StringBuilder("${title}<ul>")
        messages.each {
            sb << "<li>" + it + "</li>"
        }
        sb << "<ul>"
        return sb.toString()
    }

    /**
     * Prepares the view for a forum topic.
     */
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

        def topicValues = getTopicParameters(topic)

        [topic: topic, userInstance: topicValues.user, projectInstance: topicValues.projectInstance,
         taskInstance: topicValues.taskInstance, isWatched: topicValues.isWatching, replyTo: topicValues.replyTo]
    }

    /**
     * Prepares the edit message view.
     */
    def editMessage() {
        def message = ForumMessage.get(params.int("messageId"))
        def isWatched = forumService.isUserWatchingTopic(userService.currentUser, message?.topic)

        def topicValues = getTopicParameters(message.topic)
        def isEditingTopic = !message.replyTo
        log.debug("Editing topic: ${isEditingTopic}")

        [forumMessage: message, isWatched: isWatched, userInstance: userService.currentUser, taskInstance: topicValues.taskInstance,
            projectInstance: topicValues.projectInstance, messageText: params.messageText ?: message.text, isEditingTopic: isEditingTopic]
    }

    /**
     * Previews a message.
     */
    def previewMessage() {
        def topic = ForumTopic.get(params.long("topicId"))
        if (topic) {
            def topicValues = getTopicParameters(topic)

            render view:'viewForumTopic',
                    model: [topic: topic, replyTo: topicValues.replyTo, userInstance: userService.currentUser,
                            projectInstance: topicValues.projectInstance, taskInstance: topicValues.taskInstance,
                            isWatching: topicValues.isWatched],
                    params: [messageText: markdownService.sanitizeMarkdown(params.messageText)]
        }
    }

    /**
     * Previews a message edit.
     */
    def previewMessageEdit() {
        def message = ForumMessage.get(params.int("messageId"))
        def isWatched = forumService.isUserWatchingTopic(userService.currentUser, message?.topic)
        def title = message?.topic?.title
        if (params.title) {
            title = params.title
        }
        render view:'editMessage',
               model: [forumMessage: message, isWatched: isWatched, isEditingTopic: params.isEditingTopic,
                    title: title, userInstance: userService.currentUser, messageText: markdownService.sanitizeMarkdown(params.messageText)]
    }

    /**
     * Updates a topic message.
     */
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

        if (params.title) {
            def topic = message.topic
            topic.title = params.title
            topic.save(flush: true, failOnError: true)
        }

        if (!errors) {
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
    }

    /**
     * Deletes a topic message.
     */
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

    /**
     * Saves a new topic message as Answered
     */
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

    /**
     * Saves a new topic message
     */
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
     * Saves a topic message.
     * @param topic the topic to save to.
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

    /**
     * Helper method to get parameters for view topic views that are commonly used.
     * @param topic the topic being viewed.
     * @return a Map of parameters: Project, Task, isWatched (boolean), replyTo (ForumMessage) and User.
     */
    private def getTopicParameters(ForumTopic topic) {
        Project projectInstance = null
        Task taskInstance = null

        def topicInstance = ForumTopic.get(topic.id)

        if (topicInstance.instanceOf(ProjectForumTopic)) {
            projectInstance = (topicInstance as ProjectForumTopic).project
        } else if (topicInstance.instanceOf(TaskForumTopic)) {
            taskInstance = (topicInstance as TaskForumTopic).task
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

    /**
     * Deletes a topic.
     */
    def deleteTopic() {
        def topic = ForumTopic.get(params.int("topicId"))
        if (!topic || !checkModerator(topic)) {
            return
        }

        forumService.deleteTopic(topic)
        redirect(action: 'redirectTopicParent', id: topic.id)
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

    /**
     * Watch or unwatch a topic.
     * @return JSON object with success and message.
     */
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

    /**
     * Returns a list of markdown help items.
     * @return a list of items with the following properties:
     * - effect: the effect of the markdown
     */
    def markdownHelp() {
        def items = []
        items << [effect: 'Italics/Emphasis', description:'Surround text with either _ or *', code:'_text to italicise__ or *text to italicise*']
        items << [effect: 'Bold/Heavy Emphasis', description:'Surround text with either __ or **', code:'__text to embolden__ or **text to embolden**']
        items << [effect: 'Headings', description:'HTML heading levels can be produced by prepending a number of "#" characters', code:'### Heading 3\n#### Heading 4']
        items << [effect: 'Headings (alternate)', description:'H1 and H2 headings can also by produced by underlining text with either "=" or "-" characters', code:'Heading 1\n=========\nHeading 2\n---------']
        items << [effect: 'Line break or empty line', description:'End a line with two spaces', code:'line1\n  \nline2']
        items << [effect: 'Links/External URLS', description:'Links to other documents can be included using the following syntax<br/>[link text here](link address here)', code:'[Google!](http://google.com)']
        items << [effect: 'Horizontal rules', description:'Horizontal rules are created by placing three or more hyphens, asterisks, or underscores on a line by themselves', code:'***']
        def listDemo = """\
            &nbsp;&nbsp;* Item 1
            &nbsp;&nbsp;* Item 2
            &nbsp;&nbsp;&nbsp;&nbsp;* Subitem 2.1
            &nbsp;&nbsp;&nbsp;&nbsp;* Subitem 2.2
        """.stripIndent()
        items << [effect: 'Lists', description:'Lists can be formed with two leading spaces and an "*". Subitems are indented from the parents by an additional two spaces.', code:listDemo]
        def blockQuoteDemo = """\
            > this is some quoted text
            > > this has been quoted twice
        """.stripIndent()
        items << [effect: 'Block quotes', description:'Block quotes are produced when lines and paragraphs are preceded by "&gt;"', code:blockQuoteDemo]

        [items: items]
    }

    /**
     * Watch or unwatch a project.
     * @return JSON object with success and message.
     */
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
