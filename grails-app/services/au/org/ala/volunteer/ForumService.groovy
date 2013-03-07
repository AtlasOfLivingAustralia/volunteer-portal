package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationCookieUtils
import grails.gorm.DetachedCriteria
import grails.orm.PagedResultList
import groovy.time.TimeDuration
import org.codehaus.groovy.grails.orm.hibernate.GrailsHibernateTemplate

class ForumService {

    static transactional = true

    def logService
    def groovyPageRenderer
    def emailService
    def sessionFactory
    def grailsApplication
    def userService
    def settingsService

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
                order("lastReplyDate", "desc")
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

    def getGeneralDiscussionTopics(boolean includeDeleted = false, Map params = null) {

        def max = params?.max ?: 10
        def offset = params?.offset ?: 0
        def sort = params?.sort ?: "lastReplyDate"
        def leOrder = params?.order ?: "desc"

        if (sort == 'replies') {

            def hql = """
                SELECT topic
                FROM ForumTopic topic
                ORDER BY sticky desc, priority desc, size(topic.messages) ${leOrder}
            """
            def topics = ForumTopic.executeQuery(hql, [max: max, offset: offset])


            return [topics: topics, totalCount: ForumTopic.count() ]
        } else {
            def c = SiteForumTopic.createCriteria()
            def results = c.list(max:max, offset: offset) {
                and {
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
                    order(sort, leOrder)
                }
                if (params?.max) {
                    maxResults(params.max as Integer)
                }
                if (params?.offset) {
                    firstResult(params.offset as Integer)
                }
            }
            return [topics: results, totalCount: results.totalCount ]
        }
    }

    PagedResultList getTaskTopicsForProject(Project projectInstance, Map params = null) {

//        def c = TaskForumTopic.where {
//            task.project == projectInstance
//        }
//
//        def results = c.list(max: params?.max ?: 10, offset: params?.offset ?: 0)

        // This is not the best - because of a bug in Grails (2.2.0) using a criteria builder that queries an associated property
        // (i.e. Task.Project == projectInstance), the results are not being returned in a PageResultList, which is what we need
        // So instead we have to return the list of tasks (which could be huge!), and use that list in a query
        // Hopefully this will be corrected soon!
        def tasks = Task.findAllByProject(projectInstance)
        def c = TaskForumTopic.createCriteria()


        if (tasks) {
            def results = c.list(max: params?.max ?: 10, offset: params?.offset ?: 0 ) {
                inList('task', tasks)
            }
            return results
        }
        return null
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
        return result ? result.first() : null
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

        // Only schedule notifications if the forum is enabled. This should be unnecessary as notifications
        // won't be generated if the forum is deactivated
        if (FrontPage.instance().enableForum) {

            def c = UserForumWatchList.createCriteria()

            def watchLists = c {
                topics {
                    eq('id', topic.id)
                }
            }

            List<User> interestedUsers = []

            watchLists.each { watchList ->
                if (!interestedUsers.contains(watchList.user)) {
                    def message = new ForumTopicNotificationMessage(user:  watchList.user, topic: topic, message: lastMessage)
                    if (!message.save(failOnError:  true)) {
                        println "failed"
                    }
                    interestedUsers << watchList.user
                }
            }
            // Now the forum moderators and admins...
            def mods = getModeratorsForTopic(topic)
            mods.each { mod ->
                if (!interestedUsers.contains(mod)) {
                    def message = new ForumTopicNotificationMessage(user:  mod, topic: topic, message: lastMessage)
                    interestedUsers << mod
                }
            }

        }

    }

    List<User> getModeratorsForTopic(ForumTopic topic) {
        List<User> results = []

        Project projectInstance = null

        if (topic?.instanceOf(ProjectForumTopic)) {
            projectInstance = (topic as ProjectForumTopic).project
        } else if (topic?.instanceOf(TaskForumTopic)) {
            projectInstance = (topic as TaskForumTopic).task?.project
        }

        return userService.getUsersWithRole("forum_moderator", projectInstance)
    }

    def processPendingNotifications() {
        // Only process notifications if the forum is enabled...
        if (FrontPage.instance().enableForum && settingsService.getSetting(SettingDefinition.ForumNotificationsEnabled)) {
            logService.log("Processing Forum Message Notifications")
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

    PagedResultList searchForums(String query, boolean searchTitlesOnly, Map params = null) {

        def q = "%" + query + "%"
        def c = ForumMessage.createCriteria()
        def results = c.list(max:params?.max, offset: params?.offset) {
            or {
                ilike("text", q)
                and {
                    topic {
                        ilike("title", q)
                    }
                    isNull("replyTo")
                }
            }
            order("topic", "date")
        }

        return results as PagedResultList
    }

    PagedResultList getMessagesForUser(User user, Map params = null) {
        def c = ForumMessage.createCriteria()
        def results = c.list(max:params?.max, offset: params?.offset) {
            eq("user", user)
            order("topic", "date")
        }

        return results as PagedResultList
    }

    def getFeaturedTopics(Map params = null) {

        int max = params?.max as Integer ?: 10
        int offset = params?.offset as Integer ?: 0
        String sort = params?.sort ?: 'lastReplyDate'
        String leOrder = params?.order ?: 'desc'

        if (sort == 'replies') {
            def hql = """
                SELECT topic
                FROM ForumTopic topic
                ORDER BY featured asc, size(topic.messages) ${leOrder}
            """
            def topics = ForumTopic.executeQuery(hql, [max: max, offset: offset])
            return [topics: topics, totalCount: topics.size()]
        } else {
            def c = ForumTopic.createCriteria()
            def results = c.list(max: max, offset: offset) {
                isNotNull('lastReplyDate')
                order("featured", "asc")
                order(sort, leOrder)
            }
            return [topics: results, totalCount: results.totalCount]
        }
    }

    def isMessageEditable(ForumMessage message, User user) {

        if (!message || !user) {
            return false
        }

        def result = false
        def projectInstance = null
        if (message.topic.instanceOf(ProjectForumTopic)) {
            def projectTopic = message.topic as ProjectForumTopic
            projectInstance = projectTopic.project
        } else if (message.topic.instanceOf(TaskForumTopic)) {
            def taskTopic = message.topic as TaskForumTopic
            projectInstance = taskTopic.task.project
        }

        if (userService.isForumModerator(projectInstance)) {
            return true
        }

        if (message.user.userId == user.userId) {
            // This is the author of the message. The author has a limited window to edit/delete their messages

            int timeout = settingsService.getSetting(SettingDefinition.ForumMessageEditWindow)
            use (groovy.time.TimeCategory) {
                if (message.date >= timeout.seconds.ago) {
                    result = true
                }
            }
        }

        return result
    }

    def messageEditTimeLeft(ForumMessage message, User user) {

        if (!message || !user) {
            return null
        }

        TimeDuration result = null
        if (message.user.userId == user.userId) {
            int timeout = settingsService.getSetting(SettingDefinition.ForumMessageEditWindow)
            use (groovy.time.TimeCategory) {
                if (message.date >= timeout.seconds.ago) {
                    def now = new Date()
                    def expireTime = message.date + timeout.seconds
                    result = expireTime - now
                }
            }
        }
        return result

    }

    def deleteTopic(ForumTopic topic) {
        if (!topic) {
            return false
        }

        // Clear this topic out of any watch lists...
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

        // Also clear any pending notification messages that may reference this topic
        def notifications = ForumTopicNotificationMessage.findAllByTopic(topic)
        notifications.each {
            it.delete(flush: true)
        }

        // finally delete the topic
        topic.delete(flush: true)
    }

    def deleteMessage(ForumMessage message) {
        // Clear any pending notification messages that may reference this message
        def notifications = ForumTopicNotificationMessage.findAllByMessage(message)
        notifications.each {
            it.delete(flush: true)
        }

        message.delete(flush: true)
    }

}
