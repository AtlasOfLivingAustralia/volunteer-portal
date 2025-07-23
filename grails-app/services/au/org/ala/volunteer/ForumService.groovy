package au.org.ala.volunteer

import grails.orm.PagedResultList
import grails.gorm.transactions.Transactional
import groovy.time.TimeDuration
import groovy.util.logging.Slf4j
import org.hibernate.Hibernate
import org.jooq.DSLContext
import org.jooq.SortOrder

import static org.jooq.impl.DSL.concat
import static org.jooq.impl.DSL.select
import static au.org.ala.volunteer.jooq.tables.Project.PROJECT
import static au.org.ala.volunteer.jooq.tables.Task.TASK
import static au.org.ala.volunteer.jooq.tables.ForumTopic.FORUM_TOPIC
import static au.org.ala.volunteer.jooq.tables.ForumMessage.FORUM_MESSAGE
import static au.org.ala.volunteer.jooq.tables.VpUser.VP_USER
import static au.org.ala.volunteer.jooq.tables.UserForumWatchList.USER_FORUM_WATCH_LIST
import static au.org.ala.volunteer.jooq.tables.UserForumWatchListForumTopic.USER_FORUM_WATCH_LIST_FORUM_TOPIC
import static org.jooq.impl.DSL.count as jCount
import static org.jooq.impl.DSL.name
import static org.jooq.impl.DSL.field
import static org.jooq.impl.DSL.selectDistinct
import static org.jooq.impl.DSL.table
import static org.jooq.impl.DSL.coalesce
import static org.jooq.impl.DSL.inline
import static org.jooq.impl.DSL.when
import static org.jooq.impl.DSL.or as jOr

@Transactional
@Slf4j
class ForumService {

    def userService
    def settingsService
    def forumNotifierService
    Closure<DSLContext> jooqContext

    /**
     * Retrieves all forum topics for given filter criteria.
     * @param project a selected project filter
     * @param user the current user (for watched topics)
     * @param searchQuery a search term query filter
     * @param filter the forum topic type filter (Question, discussion, announcement) see {@link ForumTopicType}
     * @param watched flag to retrieve only watched topics
     * @param offset pagination offset
     * @param max max records to select
     * @param sort the sort column
     * @param order the order of the sort.
     * @return a list of forum topics
     */
    def getForumTopics(Project project, User user, String searchQuery, String filter, boolean watched, Integer offset, Integer max, String sort, String order) {
//        log.debug("Retrieving topics for display. Params: [Project: ${project?.id}, User: ${user?.displayName}, searchQuery: ${searchQuery}, filter: ${filter}]")
//        log.debug("Query params: [offset: ${offset}, max: ${max}, sort: ${sort}, order: ${order}]")
        DSLContext create = jooqContext()

        final String FILTER_QUESTION = 'question'
        final String FILTER_ANSWERED = 'answered'
        final String FILTER_ANNOUNCEMENT = 'announcement'
        final String FILTER_DISCUSSION = 'discussion'

        if (!offset) offset = 0
        max = Math.max(Math.min(max ?: 0, 100), 1)

        // Project WITH clause, selects all tasks for a project
        def projectTaskClause = select(TASK.ID, PROJECT.NAME.as("task_project_name"))
            .from(TASK)
            .join(PROJECT).on(PROJECT.ID.eq(TASK.PROJECT_ID))
            .where(TASK.PROJECT_ID.eq(project?.id))
        def projectTaskClauseWith = name("project_tasks").as(projectTaskClause)

        // Search query WITH clause, selects all topics that the search query appears
        def searchWhereFilter = []
        searchWhereFilter.add(FORUM_TOPIC.TITLE.likeIgnoreCase("%${searchQuery}%".toString().toLowerCase()))
        searchWhereFilter.add(FORUM_MESSAGE.TEXT.likeIgnoreCase("%${searchQuery}%".toString().toLowerCase()))
        def searchQueryClause = selectDistinct(FORUM_TOPIC.ID)
            .from(FORUM_TOPIC)
            .join(FORUM_MESSAGE).on(FORUM_MESSAGE.TOPIC_ID.eq(FORUM_TOPIC.ID))
            .where(jOr(searchWhereFilter))
        def searchQueryClauseWith = name("topic_search").as(searchQueryClause)

        // Reply count WITH clause, selects all topics and their reply counts
        def replyCountClause = select(FORUM_TOPIC.ID, jCount(FORUM_MESSAGE.ID).as("replies"))
            .from(FORUM_TOPIC)
            .join(FORUM_MESSAGE).on(FORUM_MESSAGE.TOPIC_ID.eq(FORUM_TOPIC.ID) & FORUM_MESSAGE.REPLY_TO_ID.isNotNull())
            .groupBy(FORUM_TOPIC.ID)
        def replyCountClauseWith = name("topic_replies").as(replyCountClause)

        // Watched WITH clause
        def watchedForumTopicClause = selectDistinct(USER_FORUM_WATCH_LIST_FORUM_TOPIC.FORUM_TOPIC_ID)
            .from(USER_FORUM_WATCH_LIST)
            .join(USER_FORUM_WATCH_LIST_FORUM_TOPIC).on(USER_FORUM_WATCH_LIST_FORUM_TOPIC.USER_FORUM_WATCH_LIST_TOPICS_ID.eq(USER_FORUM_WATCH_LIST.ID))
            .where(USER_FORUM_WATCH_LIST.USER_ID.eq(user.id))
        def watchedForumTopicClauseWith = name("watched_topics").as(watchedForumTopicClause)

        def withClauses = []
        withClauses.add(replyCountClauseWith)
        withClauses.add(watchedForumTopicClauseWith)

        def whereClauses = []
        whereClauses.add(FORUM_TOPIC.DELETED.isNull() | FORUM_TOPIC.DELETED.eq(false))

        // If project filter is selected, add the WHERE clauses linking the Project WITH clause
        if (project) {
            withClauses.add(projectTaskClauseWith)
            def projectWhereClause = []
            projectWhereClause.add(FORUM_TOPIC.TASK_ID.in(
                select(
                    field(name("project_tasks", "id")))
                .from(table(name("project_tasks")))))
            projectWhereClause.add(FORUM_TOPIC.PROJECT_ID.eq(project.id))
            whereClauses.add(jOr(projectWhereClause))
        }

        // If a search query has been answered, filter topics based on search query appearing in title or message
        if (searchQuery) {
            withClauses.add(searchQueryClauseWith)
            whereClauses.add(FORUM_TOPIC.ID.in(
                    select(field(name("topic_search", "id")))
                    .from(table(name("topic_search")))))
        }

        // If viewing only watched topics, filter on watched WITH Clause
        if (watched) {
            whereClauses.add(field(name("watched_topics", "forum_topic_id")).isNotNull())
        }

        // If the topic type filter is selected, filter on topic type
        switch(filter) {
            case FILTER_QUESTION:
                whereClauses.add(FORUM_TOPIC.TOPIC_TYPE.eq(ForumTopicType.Question.ordinal()) & FORUM_TOPIC.IS_ANSWERED.eq(false))
                break
            case FILTER_ANSWERED:
                whereClauses.add(FORUM_TOPIC.TOPIC_TYPE.eq(ForumTopicType.Question.ordinal()) & FORUM_TOPIC.IS_ANSWERED.eq(true))
                break
            case FILTER_ANNOUNCEMENT:
                whereClauses.add(FORUM_TOPIC.TOPIC_TYPE.eq(ForumTopicType.Announcement.ordinal()))
                break
            case FILTER_DISCUSSION:
                whereClauses.add(FORUM_TOPIC.TOPIC_TYPE.eq(ForumTopicType.Discussion.ordinal()))
                break
        }

        def validSorts = [
                'topic': 'title',
                'expedition': 'project_name',
                'type': 'topic_type',
                //'postedBy': 'creator_id',
                'postedBy': 'creator_name',
                'posted': 'date_created',
                'lastReply': 'last_reply_date',
                'views': 'views',
                'replies': 'replies'
        ].withDefault { 'last_reply_date' }
        def sortColumn = [validSorts[sort]]
        if (sort?.equalsIgnoreCase('type')) {
            sortColumn.add('is_answered')
        }
        if (!'asc'.equalsIgnoreCase(order)) order = 'desc'

        // Main query
        def topicQuery = create.with(withClauses)
            .select(FORUM_TOPIC.ID,
                FORUM_TOPIC.TITLE.as("title"),
                FORUM_TOPIC.TOPIC_TYPE.as("topic_type"),
                FORUM_TOPIC.CREATOR_ID.as("creator_id"),
                concat(VP_USER.FIRST_NAME, inline(" "), VP_USER.LAST_NAME).as("creator_name"),
                FORUM_TOPIC.DATE_CREATED.as("date_created"),
                FORUM_TOPIC.LAST_REPLY_DATE.as("last_reply_date"),
                FORUM_TOPIC.IS_ANSWERED.as("is_answered"),
                FORUM_TOPIC.VIEWS.as("views"),
                coalesce(field(name("topic_replies", "replies")), 0).as("replies"),
                PROJECT.NAME.as("project_name"),
                PROJECT.ID.as("project_id"),
                FORUM_TOPIC.TASK_ID.as("task_id"),
                when(field(name("watched_topics", "forum_topic_id")).isNull(), false)
                .otherwise(true).as("is_watched"))
            .from(FORUM_TOPIC)
            .join(VP_USER).on(VP_USER.ID.eq(FORUM_TOPIC.CREATOR_ID))
            .leftOuterJoin(table(name("topic_replies"))).on(field(name("topic_replies", "id")).eq(FORUM_TOPIC.ID))
            .leftOuterJoin(PROJECT).on(PROJECT.ID.eq(FORUM_TOPIC.PROJECT_ID))
            .leftOuterJoin(table(name("watched_topics"))).on(field(name("watched_topics", "forum_topic_id")).eq(FORUM_TOPIC.ID))
            .where(whereClauses)
            .orderBy(FORUM_TOPIC.LAST_REPLY_DATE.desc())

        def forumQuery = select(topicQuery.fields())
            .from(topicQuery)
            .orderBy(sortColumn.collect { topicQuery.field(it).sort('asc'.equalsIgnoreCase(order) ? SortOrder.ASC : SortOrder.DESC) })


        def totalCount = create.fetchCount(forumQuery)

        def result = [:]
        result.topicCount = totalCount

        forumQuery = forumQuery
            .offset(offset)
            .limit(max)

        result.topicList = create.fetch(forumQuery).collect {row ->
            def projectName = row.project_name
            def projectId = row.project_id
            if (!projectName && row.task_id) {
//                log.debug("Getting project name for task ID ${row.task_id}")
                def task = Task.get(row.task_id as long)
//                log.debug("task: ${task}")
                projectName = task.project.name
                projectId = task.project.id
//                log.debug("project name: ${projectName} from project ${task.project}")
            }

            [
                id: row.id,
                title: row.title,
                topicType: ForumTopicType.getInstance(row.topic_type),
                style: ForumTopicType.getInstance(row.topic_type).name().toLowerCase(),
                creator: User.get(row.creator_id as long),
                dateCreated: row.date_created,
                lastReply: row.last_reply_date,
                isAnswered: row.is_answered,
                views: row.views,
                replies: row.replies,
                projectName: projectName,
                projectId: projectId,
                isWatched: row.is_watched
            ]
        }

        result
    }

    /**
     * Retrieves all messages for a given topic.
     * @param topic the topic to retrieve messages for
     * @param params pagination and sorting parameters
     * @return a list of forum messages
     */
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

    /**
     * Retrieves the first message for a given topic.
     * @param topic the topic to retrieve the first message for
     * @return the first message for the topic
     */
    ForumMessage getFirstMessageForTopic(ForumTopic topic) {
        def c = ForumMessage.createCriteria()
        def result = c {
            eq('topic', topic)
            min('dateCreated')
        }
        return result ? result.first() : null
    }

    /**
     * Checks if a user is watching a given topic.
     * @param user the user to check
     * @param topic the topic to check
     * @return true if the user is watching the topic, false otherwise
     */
    boolean isUserWatchingTopic(User user, ForumTopic topic) {
        def userWatchList = UserForumWatchList.findByUser(user)
        if (userWatchList && userWatchList.topics) {
            def existing = userWatchList.topics.find {
                it.id == topic.id
            }
            return existing != null
        }
        return false
    }

    /**
     * Checks if a user is watching a given project.
     * @param user the user to check
     * @param project the project to check
     * @return true if the user is watching the project, false otherwise
     */
    boolean isUserWatchingProject(User user, Project project) {
        def watchList = ProjectForumWatchList.findByProject(project)
        if (watchList && watchList.users) {
            def existing = watchList.users.find {
                it.id == user.id
            }
            return existing != null
        }
        return false
    }

    /**
     * Watches a given topic for a user.
     * @param user the user to watch the topic for
     * @param topic the topic to watch
     */
    void watchTopic(User user, ForumTopic topic) {
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

    /**
     * Unwatches a given topic for a user.
     * @param user the user to unwatch the topic for
     * @param topic the topic to unwatch
     */
    void unwatchTopic(User user, ForumTopic topic) {
        def userWatchList = UserForumWatchList.findByUser(user)
        if (userWatchList && userWatchList.topics.contains(topic)) {
            userWatchList.topics.remove(topic)
        }
    }

    /**
     * Watches a given project for a user.
     * @param user the user to watch the project for
     * @param projectInstance the project to watch
     * @param watch true to watch, false to unwatch
     */
    void watchProject(User user, Project projectInstance, boolean watch) {
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

    /**
     * Schedules a notification for a given topic and message.
     * @param topic the topic to schedule the notification for
     * @param lastMessage the last message in the topic
     */
    void scheduleTopicNotification(ForumTopic topic, ForumMessage lastMessage) {

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

    /**
     * Schedules a notification for a new topic and message.
     * @param topic the topic to schedule the notification for
     * @param firstMessage the first message in the topic
     */
    void scheduleNewTopicNotification(ForumTopic topic, ForumMessage firstMessage) {
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

    /**
     * Checks if a message is editable by the user.
     * @param message the message to check
     * @param user the user to check
     * @return true if the message is editable, false otherwise
     */
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

    /**
     * Returns the time left for a user to edit a message.
     * @param message the message to check
     * @param user the user to check
     * @return the time left to edit the message, or null if not applicable
     */
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

    /**
     * Deletes a forum topic and all associated messages.
     * @param topic the topic to delete
     */
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

        // Finally remove any news item links
        def newsItem = NewsItem.findByTopic(topic)
        if (newsItem) {
            newsItem.topic = null
            newsItem.save(flush: true, failOnError: true)
        }

        // finally delete the topic
        topic.delete(flush: true, failOnError: true)
    }

    /**
     * Deletes a project forum watchlist for a given project.
     * @param project the project to delete the watchlist for
     */
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

    /**
     * Deletes a forum message and reassigns any replies to the original post.
     * @param message the message to delete
     */
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

    /**
     * Returns the most recent posts for a given user.
     * @param user the user to query on
     * @param count the number of posts to return
     * @return a list of the most recent posts for the user
     */
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

    /**
     * Creates a new forum topic for a task.
     * @param task the task to create the topic for
     * @param parameters the parameters of the topic.
     * @return the newly created forum topic
     */
    def createForumTopic(Task task, Map parameters) {
        return createForumTopicOfAnyType(task, null, parameters)
    }

    /**
     * Creates a new forum topic for a project.
     * @param project the project to create the topic for
     * @param parameters the parameters of the topic.
     * @return the newly created forum topic
     */
    def createForumTopic(Project project, Map parameters) {
        return createForumTopicOfAnyType(null, project, parameters)
    }

    /**
     * Creates a new forum topic for a site.
     * @param parameters the parameters of the topic.
     * @return the newly created forum topic
     */
    def createForumTopic(Map parameters) {
        return createForumTopicOfAnyType(null, null, parameters)
    }

    /**
     * Creates a new forum topic of any type (task, project, or site).
     * @param task the task to create the topic for
     * @param project the project to create the topic for
     * @param parameters the parameters of the topic.
     * @return the newly created forum topic
     */
    private def createForumTopicOfAnyType(Task task, Project project, Map parameters) {
        ForumTopic topic = null
        if (task && !project) {
            // Task forum topic
            topic = new TaskForumTopic(task: task, title: parameters.title, creator: userService.currentUser,
                    dateCreated: new Date(), priority: parameters.priority as ForumTopicPriority,
                    topicType: parameters.topicType as ForumTopicType,
                    locked: parameters.locked, sticky: parameters.sticky, featured: parameters.featured)
        } else if (!task && project) {
            // Project forum topic
            topic = new ProjectForumTopic(project: project, title: parameters.title, creator: userService.currentUser,
                    dateCreated: new Date(), priority: parameters.priority as ForumTopicPriority,
                    topicType: parameters.topicType as ForumTopicType,
                    locked: parameters.locked, sticky: parameters.sticky, featured: parameters.featured)
        } else {
            // Site forum topic
            topic = new SiteForumTopic(title: parameters.title, creator: userService.currentUser,
                    dateCreated: new Date(), priority: parameters.priority as ForumTopicPriority,
                    topicType: parameters.topicType as ForumTopicType,
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

        if (parameters.isAnswered) {
            message.isAnswer = true
            topic.isAnswered = true
            topic.save(failOnError: true)
        }

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

    /**
     * Retrieves a list of all projects that the user is watching.
     * @param user the user to query on
     * @return a list of projects that the user is watching, including the last topic for each project
     */
    def getForumProjectWatchList(User user) {
        DSLContext create = jooqContext()
        def watchedForums = []
        def c = ProjectForumWatchList.createCriteria()
        def results = c.list() {
            users {
                eq('userId', user.userId)
            }
        }
        results.each { pfwl ->
            def row = [:]
            row.project = pfwl.project
            // Get last post for project
            def lastPostOrClause = [FORUM_TOPIC.PROJECT_ID.eq(pfwl.project.id as long),
                TASK.PROJECT_ID.eq(pfwl.project.id as long)]

            def lastPostQuery = create.select(FORUM_MESSAGE.ID)
                .from(FORUM_MESSAGE)
                .join(FORUM_TOPIC).on(FORUM_TOPIC.ID.eq(FORUM_MESSAGE.TOPIC_ID))
                .leftOuterJoin(TASK).on(TASK.ID.eq(FORUM_TOPIC.TASK_ID))
                .where(jOr(lastPostOrClause))
                .orderBy(FORUM_MESSAGE.DATE.desc())
                .limit(1)

            def lastPost
            def lastPostResults = create.fetchOne(lastPostQuery)
            if (lastPostResults) {
                lastPost = ForumMessage.get(lastPostResults.id as long)
                if (lastPost) {
                    row.lastTopic = lastPost?.topic
                    row.lastMessage = lastPost
                }
            }

            watchedForums.add(row)
        }
        watchedForums = watchedForums.sort { it.project.name }
        return watchedForums
    }

}
