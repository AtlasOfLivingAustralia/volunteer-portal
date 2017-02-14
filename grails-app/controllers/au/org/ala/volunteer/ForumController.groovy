package au.org.ala.volunteer

import grails.converters.JSON
import org.apache.commons.httpclient.HttpStatus

class ForumController {

    def forumService
    def userService
    def markdownService
    def projectService
    def fieldService
    def taskService

    def index() {
        redirect(controller: 'forum', action: 'app')
    }

    def ajaxRecentTopicsList() {
        def results = forumService.getFeaturedTopics(params)
        Map resp = [featuredTopics: results.topics, totalCount: results.totalCount]
        respond(resp, model: resp, view: 'ajaxRecentTopicsList')
    }

    def projectForum() {
        def model = null
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
                    isWatching = !!projectWatchList.users.find { it.id == userInstance.id }
                }

                model = [projectInstance: projectInstance, topics: topics, isWatching: isWatching]
            }
        }

        if(model){
            respond(model, model: model, view: 'projectForum')
        } else {
            def message = "Project with id ${params.projectId} could not be found!"
            withFormat {
                html {
                    flash.message = message;
                    redirect(controller: 'forum', action:'index')
                }
                json {
                    render(text: [message: message] as JSON, status: HttpStatus.SC_BAD_REQUEST)
                }
            }
        }
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

        def model = [projectInstance: projectInstance, taskInstance: taskInstance, catalogNumber: catalogNumber, isModerator:  userService?.isForumModerator()]
        respond(model, model: model, view: 'addForumTopic');
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

        def model = [topic:topic, taskInstance: taskInstance, projectInstance: projectInstance];
        respond model, model: model, view: 'editTopic'
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

        withFormat{
            html redirect(action: 'redirectTopicParent', id: topic.id)
            json {render text: ['topicId': topic.id] as JSON}
        }

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

        Map model = [topic: topic, userInstance: userInstance, projectInstance: projectInstance, taskInstance: taskInstance, isWatched: isWatching]
        withFormat {
            html { render(view: 'viewForumTopic', model: model) }
            json {
                def title = '';
                def messages = forumService.getTopicMessages(topic, params)
                if (taskInstance) {
                    title = "Task Topic - ${taskInstance.externalIdentifier}"
                }
                if (projectInstance) {
                    title = "${projectInstance.featuredLabel} Forum Topic - ${topic.title}"
                }
                if (!projectInstance && !taskInstance) {
                    title = "General Discussion Topic - ${topic.title}"
                }

                def fields = null
                def templateFields = null
                def imageMetaData = null
                def sampleImage = false

                if(taskInstance){
                    fields = Field.findAllByTask(taskInstance)?.sort { it.name };
                    templateFields = TemplateField.findAllByTemplate(taskInstance?.project?.template)?.collectEntries {
                        [it.fieldType.toString(), it]
                    }

                    def multimedia = null
                    multimedia = taskInstance.multimedia.first();
                    imageMetaData = taskService.getImageMetaData(multimedia, 0)


                    if(!imageMetaData){
                        def sampleFile = grailsApplication.mainContext.getResource("images/sample-task.jpg").file
                        def sampleUrl = resource(dir:'/images', file:'sample-task.jpg')
                        imageMetaData = taskService.getImageMetaDataFromFile(sampleFile, sampleUrl, 0)
                        sampleImage = true
                    }
                }

                model.putAll([ messages: messages, title: title, fields: fields, templateFields: templateFields, imageMetaData: imageMetaData, sampleImage: sampleImage])
                render(text: model as JSON)
            }
        }
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
            def messages = ForumMessage.findAllByTopic(topic)?.sort { it.date }

            def fields = null
            def templateFields = null
            def imageMetaData = null
            def sampleImage = false
            def title
            if (taskInstance) {
                title = "Task Topic - ${taskInstance.externalIdentifier}"
            }
            if (projectInstance) {
                title = "${projectInstance.featuredLabel} Forum Topic - ${topic.title}"
            }
            if (!projectInstance && !taskInstance) {
                title = "General Discussion Topic - ${topic.title}"
            }

            if(taskInstance){
                fields = Field.findAllByTask(taskInstance)?.sort { it.name };
                templateFields = TemplateField.findAllByTemplate(taskInstance?.project?.template)?.collectEntries {
                    [it.fieldType.toString(), it]
                }

                def multimedia = null
                multimedia = taskInstance.multimedia.first();
                imageMetaData = taskService.getImageMetaData(multimedia, 0)


                if(!imageMetaData){
                    def sampleFile = grailsApplication.mainContext.getResource("images/sample-task.jpg").file
                    def sampleUrl = resource(dir:'/images', file:'sample-task.jpg')
                    imageMetaData = taskService.getImageMetaDataFromFile(sampleFile, sampleUrl, 0)
                    sampleImage = true
                }
            }

            def model = [topic: topic, replyTo: replyTo, userInstance: userService.currentUser, isWatched: isWatched, taskInstance: taskInstance, projectInstance: projectInstance, messages: messages, title: title, fields: fields, templateFields: templateFields, imageMetaData: imageMetaData, sampleImage: sampleImage]
            respond(model, model: model, view: 'postMessage')
        } else {

            withFormat{
                html {
                    redirect(controller:'forum', action: 'index')
                }
                json {
                    render(text: [message: "Could not find topic ${params.int("topicId")}"] as JSON, status: HttpStatus.SC_BAD_REQUEST)
                }
            }
        }
    }

    def editMessage() {
        def message = ForumMessage.get(params.int("messageId"))
        def isWatched = forumService.isUserWatchingTopic(userService.currentUser, message?.topic)

        def model = [forumMessage: message, isWatched: isWatched, userInstance: userService.currentUser, messageText: params.messageText ?: message.text]
        respond(model, model: model, view: 'editMessage');
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
            def model = [topic: topic, replyTo: replyTo, userInstance: userService.currentUser, isWatched: isWatched, messageText: params.messageText, markDownText: markdownService.markdown(params.messageText)]
            respond(model, model: model, view: 'postMessage')
        }
    }

    def previewMessageEdit() {
        def message = ForumMessage.get(params.int("messageId"))
        def isWatched = forumService.isUserWatchingTopic(userService.currentUser, message?.topic)
        def model = [forumMessage: message, isWatched: isWatched, userInstance: userService.currentUser, messageText: params.messageText, markDownText: markdownService.markdown(params.messageText?:'')]
        respond(model, model: model, view:'editMessage')
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
        withFormat{
            html redirect(action:'viewForumTopic', id: message?.topic?.id)
            json {
                render(text: [topicId: message?.topic?.id ] as JSON)
            }
        }

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
        withFormat{
            html redirect(action:'viewForumTopic', id: message?.topic?.id)
            json {
                render(text: [topicId: message?.topic?.id] as JSON)
            }
        }

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
                withFormat{
                    html {
                        redirect(action: 'viewForumTopic', id: topic?.id)
                    }
                    json {
                        render(text: [topicId: topic?.id] as JSON)
                    }
                }

                return
            }
        } else {
            errors << "Message text must not be empty"
        }

        if(errors.size()){
            def errorMessage = formatMessages(errors)
            flash.message = errorMessage
            withFormat{
                html {
                    render(view:'postMessage', model: [topic: topic, replyTo: replyTo, userInstance: userService.currentUser], params: [messageText: params.messageText])
                }
                json {
                    render(text: [message: errorMessage] as JSON, status: HttpStatus.SC_BAD_REQUEST)
                }
            }
        }
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
        def topics = [topics:results.topics, totalCount: results.totalCount]
        respond(topics, view: 'ajaxGeneralTopicsList', model: topics)
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

        def model = [projectInstance: projectInstance, topics: topics, totalCount: topics.totalCount]
        respond(model, model: model, view: 'ajaxProjectTaskTopicList')
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

        def model = [query: query, results: results, totalCount: results.totalCount]
        respond(model, model: model, view: 'searchForums')
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

        def resp = [projectSummaryList: projectSummaryList, forumStats: forumStats]
        respond(resp, model: resp, view:'ajaxProjectForumsList');
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

        def watched = [topics: topics]
        respond(watched, view: 'ajaxWatchedTopicsList', model: watched)
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
        def totalCount = messages.totalCount
        def xformMessages = messages.groupBy { it.topic }.collect {
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
        }
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
            
            def watchList = ProjectForumWatchList.findByProject(projectInstance)
            if (!watchList) {
                watchList = new ProjectForumWatchList(project: projectInstance)
                watchList.save(failOnError: true)
            }

            if (watch) {
                if (!watchList.containsUser(user)) {
                    watchList.addToUsers(user)
                }
                results.message = "You will be sent a notification email when messages are posted to this project"
            } else {
                if (watchList.containsUser(user)) {
                    watchList.removeFromUsers(user)
                }
                results.message = "You will no longer be sent notification emails when messages are posted to this project"
            }

            watchList.save()
            results.success = true;
        }
        
        render(results as JSON)
    }

    def app (){

    }
}
