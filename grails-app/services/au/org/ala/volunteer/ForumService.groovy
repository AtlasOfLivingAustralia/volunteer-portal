package au.org.ala.volunteer

import grails.orm.PagedResultList
import grails.gorm.transactions.Transactional
import groovy.time.TimeDuration
import groovy.util.logging.Slf4j
import org.hibernate.Hibernate
import org.hibernate.criterion.CriteriaSpecification

@Transactional
@Slf4j
class ForumService {

    def grailsApplication
    def userService
    def settingsService
    def forumNotifierService
    def dataSource

    def getProjectForumTopics(Project project, boolean includeDeleted = false, Map params = null) {
        def max = params.max ?: 10
        def offset = params.offset ?: 0
        def sort = params.sort ?: "lastReplyDate"
        def leOrder = params.order ?: "desc"

        if (sort == "replies") {
            def hql = """
                SELECT distinct topic
                FROM ProjectForumTopic topic
                WHERE project_id = :projectId
                ORDER BY sticky desc, priority desc, size(topic.messages) ${leOrder}
            """
            def topics = ForumTopic.executeQuery(hql, [projectId: project.id], [max: max, offset: offset])

            return [topics: topics, totalCount: ForumTopic.count() ]
        }

        // All other sort types (other than replies)
        def select = """
            SELECT DISTINCT topic
            FROM ProjectForumTopic topic
            WHERE project_id = :projectId
        """

        def includeDeletedClause = ""
        if (includeDeleted) {
            includeDeletedClause = " AND deleted = true "
        } else {
            includeDeletedClause = """
                AND (deleted IS NULL OR deleted = false) 
            """
        }

        def sortClause = """
            ORDER BY sticky DESC, priority DESC, ${sort} ${leOrder}
        """

        select += (includeDeletedClause + sortClause)

        def results = ForumTopic.executeQuery(select, [projectId: project.id], [max: max, offset: offset])

        def totalCount = ForumTopic.createCriteria().get {
            projections {
                countDistinct 'id'
            }
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
        } as Integer

        return [topics: results, totalCount: totalCount ]
    }

    def getGeneralDiscussionTopics(boolean includeDeleted = false, Map params = null) {
        def max = params?.max ?: 15
        def offset = params?.offset ?: 0
        def sort = params?.sort ?: "lastReplyDate"
        if (sort == "creator") sort = "creator.displayName"
        def leOrder = params?.order ?: "desc"

        def deleteClause = ""
        if (!includeDeleted) {
            deleteClause = "WHERE (deleted IS NULL OR deleted = false) "
        }

        def topicQuery = """
            SELECT topic
            FROM SiteForumTopic topic
            :deleteClause
        """
        topicQuery = topicQuery.replace(":deleteClause", deleteClause)

        def countQuery = """
            SELECT COUNT(DISTINCT topic.id) as topicCount
            FROM SiteForumTopic topic
            :deleteClause
        """
        countQuery = countQuery.replace(":deleteClause", deleteClause)

        def sortClause = "ORDER BY sticky DESC, priority DESC, "
        if (sort == 'replies') {
            sortClause = sortClause + "size(topic.messages) " + leOrder
        } else {
            sortClause = sortClause + sort + " " + leOrder
        }

        def topics = ForumTopic.executeQuery(topicQuery + sortClause, [max: max, offset: offset]) as List<ForumTopic>
        def totalCount = ForumTopic.executeQuery(countQuery)?.first()

        return [topics: topics, totalCount: totalCount]
    }

    def getTaskTopicsForProject(Project projectInstance, Map params = null) {
        def topics = [:]

        def topicIdList = TaskForumTopic.createCriteria().list(max: params?.max ?: 10, offset: params?.offset ?: 0) {
            projections {
                distinct 'id'
            }
            task {
                eq("project", projectInstance)
            }
        }

        def totalCount = TaskForumTopic.createCriteria().get {
            projections {
                countDistinct 'id'
            }
            task {
                eq("project", projectInstance)
            }
        } as Integer

        topics.topics = TaskForumTopic.getAll(topicIdList)
        topics.totalCount = totalCount
        topics
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

    public void watchProject(User user, Project projectInstance, boolean watch) {
        def watchList = ProjectForumWatchList.findByProject(projectInstance)
        if (!watchList) {
            watchList = new ProjectForumWatchList(project: projectInstance)
            watchList.save(failOnError: true)
        }

        if (watch) {
            if (!watchList.containsUser(user)) {
                watchList.addToUsers(user)
            }
        } else {
            if (watchList.containsUser(user)) {
                watchList.removeFromUsers(user)
            }
        }

        watchList.save()
    }

    public void scheduleTopicNotification(ForumTopic topic, ForumMessage lastMessage) {

        // Only schedule notifications if the forum is enabled. This should be unnecessary as notifications
        // won't be generated if the forum is deactivated
        if (FrontPage.instance().enableForum) {
            if (settingsService.getSetting(SettingDefinition.BatchForumNotificationMessages)) {
                // Do the notifications asynchronously
                def interestedUsers = forumNotifierService.getUsersInterestedInTopic(topic)
                log.info("Interested users in topic ${topic.id}: " + interestedUsers.collect { it.userId })
                interestedUsers.each { user ->
                    def message = new ForumTopicNotificationMessage(user:  user, topic: topic, message: lastMessage)
                    message.save(failOnError: true)
                }
            } else {
                // Send the notifications right now!
                forumNotifierService.notifyInterestedUsersImmediately(topic, lastMessage)
            }
        }
    }

    public void scheduleNewTopicNotification(ForumTopic topic, ForumMessage firstMessage) {
        // Only schedule notifications if the forum is enabled. This should be unnecessary as notifications
        // won't be generated if the forum is deactivated
        if (FrontPage.instance().enableForum) {
            if (settingsService.getSetting(SettingDefinition.BatchForumNotificationMessages)) {
                // Do the notifications asynchronously
                def interestedUsers = forumNotifierService.getModeratorsForTopic(topic)
                log.info("Interested users in topic ${topic.id}: " + interestedUsers.collect { it.userId })
                interestedUsers.each { user ->
                    def message = new ForumTopicNotificationMessage(user:  user, topic: topic, message: firstMessage)
                    message.save(failOnError: true)
                }
            } else {
                // Send the notifications right now!
                forumNotifierService.notifyNewTopicImmediately(topic, firstMessage)
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
        def topics = []
        if (params.projectId) {
            topics = ProjectForumTopic.where {
                project.id == params.projectId
            }.list()*.id
        }
        if (params.projectId && !topics) return null
        def c = ForumMessage.createCriteria()
        def results = c.list(max:params?.max, offset: params?.offset) {
            if (topics) {
                topic {
                    'in'('id', topics)
                }
            }
            eq("user", user)
            order('date', 'desc')
            order("topic")

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
                ORDER BY featured asc, size(topic.messages) 
            """
            def topics = ForumTopic.executeQuery(hql + leOrder, [max: max, offset: offset])
            return [topics: topics, totalCount: topics.size()]
        } else {
            def hql = """
                SELECT topic
                FROM ForumTopic topic
                WHERE lastReplyDate IS NOT NULL
                ORDER BY featured asc,  
            """
            def topics = ForumTopic.executeQuery(hql + sort + ' ' + leOrder, [max: max, offset: offset])
            return [topics: topics, totalCount: topics.size()]
        }
    }

    def isMessageEditable(ForumMessage message, User user) {

        if (!message || !user) {
            return false
        }

        def result = false
        def projectInstance = null
        if (message.topic.instanceOf(ProjectForumTopic)) {
            def unproxyObject = Hibernate.unproxy(message.topic)
            projectInstance = Project.get(((ProjectForumTopic) unproxyObject).project.id)
        } else if (message.topic.instanceOf(TaskForumTopic)) {
            def unproxyObject = Hibernate.unproxy(message.topic)
            projectInstance = Project.get(((TaskForumTopic) unproxyObject).task.project.id)
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
            it.topics.remove(topic)
            it.save(flush: true, failOnError: true)
        }

        // Also clear any pending notification messages that may reference this topic
        def notifications = ForumTopicNotificationMessage.findAllByTopic(topic)
        notifications.each {
            it.delete(flush: true, failOnError: true)
        }

        // finally delete the topic
        topic.delete(flush: true, failOnError: true)
    }

    def deleteProjectForumWatchlist(Project project) {
        def pfwl = ProjectForumWatchList.findByProject(project)

        // copy users set
        if (pfwl) {
            def users = pfwl.users.toList()
            users.each { user ->
                pfwl.removeFromUsers(user)
                pfwl.users.remove(user)
            }

            pfwl.save(flush: true, failOnError: true)
            pfwl.delete(flush: true, failOnError: true)
        }
    }

    def deleteMessage(ForumMessage message) {
        // Clear any pending notification messages that may reference this message
        def notifications = ForumTopicNotificationMessage.findAllByMessage(message)
        notifications.each {
            it.delete(flush: true)
        }

        // Does the message have any replies that need to be reassigned
        // Get the list of replies and reassign their reply to ID to the original post.
        def messageList = getMessageReplies(message)
        def op = getFirstMessageForTopic(message.topic)
        messageList.each {msg ->
            msg.replyTo = op
            msg.save(flush: true)
        }

        // Remove message from topic then delete
        ForumTopic forumTopic = message.topic
        forumTopic.removeFromMessages(message)
        forumTopic.discard()
        message.delete(flush: true)
    }

    /**
     * Returns a list of all forum messages that are replies to a given message.
     * @param message the message to query on
     * @return a list of messages that are replies to a given message.
     */
    def getMessageReplies(ForumMessage message) {
        def replies = []
        if (message) {
            replies = ForumMessage.findAllByReplyTo(message)
        }
        replies
    }

    def countTaskTopics(Project projectInstance) {
        def tasks = Task.findAllByProject(projectInstance)
        def c = TaskForumTopic.createCriteria()

        if (tasks) {
            def results = c.get {
                projections {
                    count("id")
                }
                inList('task', tasks)
            }
            return results
        }
        return null
    }

    def getRecentPostsForUser(User user, int count = 5) {

        def c = ForumMessage.createCriteria()

        c.list(max: count) {
            eq('user', user)
            or {
                isNull("deleted")
                eq("deleted", false)
            }
            order("date", "desc")
        }

    }

    def createForumTopic(Task task, Map parameters) {
        return createForumTopicOfAnyType(task, null, parameters)
    }

    def createForumTopic(Project project, Map parameters) {
        return createForumTopicOfAnyType(null, project, parameters)
    }

    def createForumTopic(Map parameters) {
        return createForumTopicOfAnyType(null, null, parameters)
    }

    private def createForumTopicOfAnyType(Task task, Project project, Map parameters) {
        ForumTopic topic = null
        if (task && !project) {
            // Task forum topic
            topic = new TaskForumTopic(task: task, title: parameters.title, creator: userService.currentUser,
                    dateCreated: new Date(), priority: parameters.priority as ForumTopicPriority,
                    locked: parameters.locked, sticky: parameters.sticky, featured: parameters.featured)
        } else if (!task && project) {
            // Project forum topic
            topic = new ProjectForumTopic(project: project, title: parameters.title, creator: userService.currentUser,
                    dateCreated: new Date(), priority: parameters.priority as ForumTopicPriority,
                    locked: parameters.locked, sticky: parameters.sticky, featured: parameters.featured)
        } else {
            // Site forum topic
            topic = new SiteForumTopic(title: parameters.title, creator: userService.currentUser,
                    dateCreated: new Date(), priority: parameters.priority as ForumTopicPriority,
                    locked: parameters.locked, sticky: parameters.sticky, featured: parameters.featured)
        }

        topic.lastReplyDate = topic.dateCreated
        topic.save(flush: true, failOnError: true)

        def firstMessage = new ForumMessage(topic: topic, text: parameters.text, date: topic.dateCreated, user: topic.creator)
        firstMessage.save(flush: true, failOnError: true)

        scheduleNewTopicNotification(topic, firstMessage)

        topic
    }

    /**
     * Adds a forum message to the topic.
     * @param topic the topic to add the message to
     * @param parameters the parameters of the message.
     * @return the newly created forum message
     */
    def addForumMessage(ForumTopic topic, Map parameters) {
        if (!topic) return
        ForumMessage message = new ForumMessage(topic: topic, user: parameters.user as User,
                replyTo: parameters.replyTo as ForumMessage, date: new Date(), text: parameters.text)
        message.save(flush:true, failOnError: true)

        parameters.watchTopic == 'on' ? watchTopic(parameters.user as User, topic) : unwatchTopic(parameters.user as User, topic)
        scheduleTopicNotification(topic, message)

        message
    }

    /**
     * Increments the view count of a forum topic
     * @param topic the topic to update
     */
    void incrementTopicView(ForumTopic topic) {
        if (!topic) return
        def hql = """
                UPDATE ForumTopic
                SET views = views + 1
                WHERE id = :id
            """
        ForumTopic.executeUpdate(hql, [id: topic.id])
    }
}
