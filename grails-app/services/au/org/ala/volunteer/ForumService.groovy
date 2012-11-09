package au.org.ala.volunteer

import grails.orm.PagedResultList

class ForumService {

    static transactional = true

    def logService
    def groovyPageRenderer
    def emailService

    PagedResultList getProjectForumTopics(Project project, boolean includeDeleted = false, Map params = null) {
        def c = ProjectForumTopic.createCriteria()
        def results = c.list(max:params?.max, offset: params?.offset) {
            and {
                eq("project", project)
                if (includeDeleted) {
                    eq("deleted", true)
                } else {
                    or {
                        isNull("deleted")
                        eq("deleted", false)
                    }
                }
            }
            and {
                order("sticky", "desc")
                order("priority", "desc")
                order("dateCreated", "desc")
            }
            if (params?.max) {
                maxResults(params.max as Integer)
            }
            if (params?.offset) {
                firstResult(params.offset as Integer)
            }
        }
        return results as PagedResultList
    }

    PagedResultList getTopicMessages(ForumTopic topic, Map params = null) {
        def c = ForumMessage.createCriteria()
        def results = c.list(max:params?.max, offset: params?.offset) {
            eq("topic", topic)
            and {
                order("date", "asc")
            }
            if (params?.max) {
                maxResults(params.max as Integer)
            }
            if (params?.offset) {
                firstResult(params.offset as Integer)
            }
        }
        return results as PagedResultList
    }

    public ForumMessage getFirstMessageForTopic(ForumTopic topic) {
        def c = ForumMessage.createCriteria()
        def result = c {
            eq('topic', topic)
            min('dateCreated')
        }
        return result.first()
    }

    public boolean isUserWatchingTopic(User user, ForumTopic topic) {
        def userWatchList = UserForumWatchList.findByUser(user)
        if (userWatchList && userWatchList.topics) {
            def existing = userWatchList.topics.find {
                it.id == topic.id
            }
            return existing != null
        }
        return false
    }

    public void watchTopic(User user, ForumTopic topic) {
        if (user && topic) {
            def userWatchList = UserForumWatchList.findByUser(user)
            if (!userWatchList) {
                userWatchList = new UserForumWatchList(user: user)
            }
            if (userWatchList && !userWatchList.topics?.contains(topic)) {
                userWatchList.addToTopics(topic)
            }
            userWatchList.save(flush: true)
        }
    }

    public void unwatchTopic(User user, ForumTopic topic) {
        def userWatchList = UserForumWatchList.findByUser(user)
        if (userWatchList && userWatchList.topics.contains(topic)) {
            userWatchList.topics.remove(topic)
        }
    }

    public void scheduleTopicNotification(ForumTopic topic, ForumMessage lastMessage) {

        def c = UserForumWatchList.createCriteria()

        def watchLists = c {
            topics {
                eq('id', topic.id)
            }
        }

        watchLists.each { watchList ->
            println 'saving new notification message1'
            def message = new ForumTopicNotificationMessage(user:  watchList.user, topic: topic, message: lastMessage)
            if (!message.save(failOnError:  true)) {
                println "failed"
            }
            println 'saving new notification message2'
        }
    }

    def processPendingNotifications() {
        def messageList = ForumTopicNotificationMessage.list()
        if (messageList) {
            def userMap = messageList.groupBy { it.user }
            logService.log("Forum Topic Notification Sender: ${messageList.size()} message(s) found across ${userMap.keySet().size()} user(s).")
            userMap.keySet().each { user ->
                def messages = userMap[user]?.sort { it.message.date }
                def message = groovyPageRenderer.render(view: '/forum/topicNotificationMessage', model: [messages: messages])
                emailService.sendMail(user.userId, "BVP Forum notification", message)
            }

            // now clean up the notification list
            messageList.each {
                it.delete()
            }
        }
    }



}
