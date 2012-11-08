package au.org.ala.volunteer

class ForumController {

    def forumService
    def userService
    def markdownService

    def index = { }

    def projectForum = {

        def projectId = params.int("projectId")
        if (projectId) {
            def projectInstance = Project.get(projectId)
            if (projectInstance) {
                def topics = forumService.getProjectForumTopics(projectInstance, false)
                def topicCounts = [:]
                topics.each { topic ->
                    def replyCount = ForumMessage.countByTopic(topic)
                    topicCounts[topic] = replyCount
                }
                return [projectInstance: projectInstance, topics: topics, topicCounts: topicCounts]
            }
        }

        flash.message = "Project with id ${params.projectId} could not be found!"
        redirect(controller: 'forum', action:'index')
    }

    def addProjectTopic = {
        def projectId = params.int("projectId")
        def projectInstance = Project.get(projectId)
        return [projectInstance: projectInstance]
    }

    def editProjectTopic = {
        def topic = ProjectForumTopic.get(params.int("topicId"))
        if (!topic || !userService.isForumModerator(topic.project)) {
            flash.message = "You do not have sufficient privileges to edit this topic"
            redirect controller:'forum', action: 'projectForum', params:[projectId: topic?.project?.id]
            return
        }
        [topic: topic, user: userService.currentUser]
    }

    def insertProjectTopic = {

        def projectId = params.int("projectId")
        if (projectId) {
            def projectInstance = Project.get(projectId)
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
                redirect(action: 'addProjectTopic', params: params)
            }

            def locked = false
            def sticky = false
            def priority = ForumTopicPriority.Normal

            if (userService.isForumModerator(projectInstance)) {
                locked = params.locked == 'on'
                sticky = params.sticky == 'on'
                priority = Enum.valueOf(ForumTopicPriority.class, params.priority as String)
            }

            def topic = new ProjectForumTopic(project: projectInstance, title: title, creator: userService.currentUser, dateCreated: new Date(), priority: priority, locked: locked, sticky: sticky)

            topic.save(flush: true, failOnError: true)

            def firstMessage = new ForumMessage(topic: topic, text: text, date: topic.dateCreated, sticky: false, user: topic.creator)
            firstMessage.save(flush: true, failOnError: true)

            if (params.watchTopic == 'on') {
                forumService.watchTopic(topic.creator, topic)
            }
            redirect(action: 'projectForum', params: [projectId: projectInstance.id])
        }

    }

    private boolean checkModerator(Project project = null) {
        if (!userService.isForumModerator(project)) {
            flash.message = "You do not have sufficient privileges to edit this topic"
            redirect controller:'forum', action: 'projectForum', params:[projectId: project?.id]
            return false
        }
        return true
    }

    def updateProjectTopic = {

        def topic = ProjectForumTopic.get(params.int('topicId'))
        if (!topic || !checkModerator(topic.project)) {
            return
        }

        def locked = params.locked == 'on'
        def sticky = params.sticky == 'on'
        def priority = Enum.valueOf(ForumTopicPriority.class, params.priority as String)

        topic.title = params.title
        topic.sticky = sticky
        topic.locked = locked
        topic.priority = priority

        topic.save(flush: true, failOnError: true)

        redirect(action: 'projectForum', params: [projectId: topic?.project.id])

    }

    private String formatMessages(List messages, String title = "The following errors have occurred:") {
        def sb = new StringBuilder("${title}<ul>")
        messages.each {
            sb << "<li>" + it + "</li>"
        }
        sb << "<ul>"
        return sb.toString()
    }

    def projectForumTopic = {
        def topic = ProjectForumTopic.get(params.id)
        topic.lock()
        topic.views++
        topic.save()
        [topic: topic, userInstance: userService.currentUser, projectInstance: topic.project]
    }

    def postProjectMessage = {
        def topic = ProjectForumTopic.get(params.topicId)
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

    def previewProjectMessage = {
        def topic = ProjectForumTopic.get(params.topicId)
        if (topic) {
            ForumMessage replyTo = null
            if (params.replyTo) {
                replyTo = ForumMessage.get(params.int("replyTo"))
            } else {
                replyTo = forumService.getFirstMessageForTopic(topic)
            }
            def isWatched = forumService.isUserWatchingTopic(userService.currentUser, topic)
            render view:'postProjectMessage', model: [topic: topic, replyTo: replyTo, userInstance: userService.currentUser, isWatched: isWatched], params: [messageText: params.messageText]
        }
    }

    def saveNewProjectMessage = {
        def topic = ProjectForumTopic.get(params.topicId)
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

                redirect(action: 'projectForumTopic', id: topic?.id)
                return
            }
        } else {
            errors << "Message text must not be empty"
        }

        flash.message = formatMessages(errors)
        render view:'postProjectMessage', model: [topic: topic, replyTo: replyTo, userInstance: userService.currentUser], params: [messageText: params.messageText]
    }

    def deleteProjectTopic = {
        def topic = ProjectForumTopic.get(params.int("topicId"))
        if (!topic || !checkModerator(topic.project)) {
            return
        }

        def project = topic.project
        topic.delete(flush: true)

        redirect(controller: 'forum', action: 'projectForum', params: [projectId: project.id])
    }

}
