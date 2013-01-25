package au.org.ala.volunteer

import grails.gorm.DetachedCriteria
import grails.orm.PagedResultList
import org.codehaus.groovy.grails.orm.hibernate.GrailsHibernateTemplate

class ForumService {

    static transactional = true

    def logService
    def groovyPageRenderer
    def emailService
    def sessionFactory
    def grailsApplication
    def userService

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

    PagedResultList getGeneralDiscussionTopics(boolean includeDeleted = false, Map params = null) {
        def c = SiteForumTopic.createCriteria()
        def results = c.list(max:params?.max, offset: params?.offset) {
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

        def results = c.list(max: params?.max ?: 10, offset: params?.offset ?: 0 ) {
            inList('task', tasks)
        }
        return results
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

    PagedResultList searchForums(String query, boolean searchTitlesOnly, Map params = null) {

        def c = ForumMessage.createCriteria()
        def results = c.list(max:params?.max, offset: params?.offset) {
            ilike("text", "%" + query + "%")
            projection {
                groupProperty("topic")
            }
        }

        return results as PagedResultList
    }



}
