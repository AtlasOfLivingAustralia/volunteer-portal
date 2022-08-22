package au.org.ala.volunteer

import com.naleid.grails.MarkdownService
import grails.gorm.transactions.Transactional
import grails.orm.PagedResultList
import groovy.xml.MarkupBuilder

class ForumTagLib {

    static namespace = 'vpf'

    UserService userService
    MarkdownService markdownService
    TaskService taskService
    MultimediaService multimediaService
    ProjectService projectService
    @Lazy ForumService forumService = grailsApplication.mainContext.getBean('forumService')

    /**
     * @param project
     */
    def ifModerator = { attrs, body ->
        if (userService.isForumModerator(attrs.project as Project)) {
            out << body()
        }
    }

    /**
     * @param topic
     */
    def topicMessagesTable = { attrs, body ->

        def topic = attrs.topic as ForumTopic

        if (topic) {

            Project projectInstance = null
            if (topic.instanceOf(ProjectForumTopic)) {
                log.debug("Project topic")
                def projectTopic = topic as ProjectForumTopic
                projectInstance = projectTopic.project
            } else if (topic.instanceOf(TaskForumTopic)) {
                log.debug("Task topic")
                def taskTopic = topic as TaskForumTopic
                projectInstance = taskTopic.task.project
                projectInstance.attach()
                log.debug("Project in taglib: ${projectInstance}")
                log.debug("Institution in taglib: ${projectInstance?.institution}")
            }

            def replies = forumService.getTopicMessages(topic, params)

            def mb = new MarkupBuilder(out)
            boolean striped = false

            mb.table(class: 'forum-table') {
                thead {
                    tr {
                        th(colspan: '2') {
                            mkp.yield(topic.title)
                        }
                        th(style: 'text-align: right; vertical-align: middle; width: 150px') {
                            if (topic.locked) {
                                mb.img(style: 'vertical-align: middle', src: resource(file: '/lock.png'))
                                mkp.yield("Topic is locked")
                            } else {
                                mb.a(id:'btnReply', class:'btn btn-primary') {
                                    mb.i(class: 'fa fa-reply') {mkp.yieldUnescaped("&nbsp;")}
                                    mkp.yield("Post Reply")

                                }
                            }
                        }
                    }

                    tr {
                        th {}
                        th { mkp.yield("${replies.size() - 1} " + (replies.size() == 2 ? 'reply' : "replies")) }
                        th(style: 'text-align: right') {
                        }
                    }
                }
                tbody {
                    replies.each { ForumMessage reply ->
                        // work out if this topic is editable...
                        def canEdit = forumService.isMessageEditable(reply, userService.currentUser)
                        def authorIsModerator = userService.isUserForumModerator(reply.user, projectInstance)

                        def rowClasses= []
                        if (striped) {
                            rowClasses << 'striped'
                        }
                        if (authorIsModerator) {
                            rowClasses << 'author-is-moderator-row'
                        }

                        def userProps = userService.detailsForUserId(reply.user.userId)

                        tr(class: rowClasses.join(" "), messageId: reply.id) {
                            td(class: "forumNameColumn") {
                                a(class: 'forumUsername', href: createLink(controller: 'user', action: 'show', id: reply.user.id), name:'message_' + reply.id) {
                                    mkp.yield(userProps.displayName)
                                }
                                if (authorIsModerator) {
                                    i(class:'icon-star-empty') { mkp.yieldUnescaped("&nbsp;") }
                                }
                                br {}
                                span(class: 'forumMessageDate') {
                                    mkp.yield(formatDate(date: reply.date, format: 'dd MMM, yyyy HH:mm:ss'))
                                }
                            }
                            def message = markdownService.sanitize(reply.text ?: "")
                            td() { mkp.yieldUnescaped(markdownService.markdown(message)) }
                            td(style:'text-align: right') {
                                if (canEdit) {

                                    def timeLeft = forumService.messageEditTimeLeft(reply, userService.currentUser)
                                    if (timeLeft) {
                                        small(style:'color: orange') {
                                            mkp.yield("You have ${timeLeft.minutes} minutes to change or delete this message")
                                        }
                                        br {}
                                    }

                                    button(class:'btn btn-default editMessageButton') {
                                        mkp.yield("Edit")
                                    }

                                    // if this is the first message in the topic, you can't delete it
                                    // Only the first message as a null replyTo
                                    if (reply.replyTo != null) {
                                        button(class:'btn btn-danger deleteMessageButton') {
                                            mkp.yield("Delete")
                                        }
                                    }
                                }
                            }
                        }
                        striped = !striped
                    }
                }
            }
        }
    }

    /**
     * @attr topics
     * @attr totalCount
     * @attr paginateAction
     * @attr hidePageButtons
     */
    def topicTable = { attrs, body ->
        def topics = attrs.topics as List<ForumTopic>
        def paginateAction = attrs.paginateAction ?: "index"
        def hidePageButtons = attrs.hidePageButtons
        Project projectInstance = attrs.projectInstance as Project ?: null

        def totalCount = attrs.totalCount
        // TODO Fix grails.orm.PagedResultList vs grails.gorm.PagedResultList after upgrade to Grails 2.4.4
        // see https://jira.grails.org/browse/GRAILS-8413
        if (!totalCount && (topics instanceof PagedResultList || topics instanceof grails.gorm.PagedResultList)) {
            totalCount = topics?.totalCount
        }

        def mb = new MarkupBuilder(out)
      //  Project projectInstance = null
        if (!topics) {
            mb.div {
                mkp.yield("No topics found")
            }
            return
        }

        def topicCounts = [:]
        topics.each { topic ->
            def replyCount = ForumMessage.countByTopic(topic)
            topicCounts[topic] = replyCount
        }

        mb.div(class: 'table-responsive') {
            table(class: "table table-striped table-hover table-condensed") {
                thead {
                    tr {
                        mkp.yieldUnescaped(sortableColumn(colspan:2, class:"button", property:"title", title: "Topic", action:paginateAction, params:params))
                        mkp.yieldUnescaped(sortableColumn(class:"button", property:"replies", title: "Replies", action:paginateAction, params:params))
                        mkp.yieldUnescaped(sortableColumn(class:"button", property:"views", title: "Views", action:paginateAction, params:params))
                        mkp.yieldUnescaped(sortableColumn(class:"button", property:"creator", title: "Posted&nbsp;by", action:paginateAction, params:params))
                        mkp.yieldUnescaped(sortableColumn(class:"button", property:"dateCreated", title: "Posted", action:paginateAction, params:params))
                        mkp.yieldUnescaped(sortableColumn(class:"button", property:"lastReplyDate", title: "Last reply", action:paginateAction, params:params))
                        th(class: 'text-center') {
                            mkp.yield("")
                        }
                    }
                }
                tbody {
                    if (topics.size() == 0) {
                        tr {
                            td(colspan: '8') {
                                mkp.yield("There are no topics in this forum yet.")
                            }
                        }
                    } else {
                        for (ForumTopic topic : topics) {

                            def userProps = userService.detailsForUserId(topic.creator?.userId)
                            def authorIsModerator = userService.isUserForumModerator(topic.creator, projectInstance)
                            def rowClasses= []
                            rowClasses << topic.priority
                            if (topic.sticky) {
                                rowClasses << "sticky"
                            }
                            if (authorIsModerator) {
                                rowClasses << "author-is-moderator-row"
                            }

                            tr(class: rowClasses.join(" "), topicId: topic.id) {
                                td(style: "width: ${topic instanceof ProjectForumTopic ? '100' : '60'}px;", class: 'text-center') {
                                    span(style: 'color:green') {
                                        if (topic.sticky) {
                                            i(class:'fa fa-asterisk', title:'This topic is sticky') { mkp.yieldUnescaped("&nbsp;") }
                                        }
                                        if (topic.locked) {
                                            i(class:'fa fa-lock', title:'This topic is locked') { mkp.yieldUnescaped("&nbsp;") }
                                        }
                                    }
                                    if (topic instanceof ProjectForumTopic) {
                                        def projectFeaturedImage = projectService.getFeaturedImage((topic as ProjectForumTopic).project)
                                        //delegate.img(src: (topic as ProjectForumTopic).project.featuredImage, width: '40')
                                        delegate.img(src: projectFeaturedImage, width: '40')
                                    } else if (topic instanceof TaskForumTopic) {
                                        def mm = (topic as TaskForumTopic).task.multimedia?.first()
                                        if (mm) {
                                            delegate.img(src: multimediaService.getImageThumbnailUrl(mm), width: '40')
                                        }
                                    }
                                }
                                td {
                                    a(href: createLink(controller: 'forum', action: 'viewForumTopic', id: topic.id)) {
                                        mkp.yield(topic.title)
                                    }
                                    if (topic.featured) {
                                        sup {
                                            mkp.yield("Featured Topic")
                                        }
                                    }
                                }
                                td(class: 'text-center') {
                                    mkp.yield(topicCounts[topic] - 1)
                                }
                                td(class: 'text-center') {
                                    mkp.yield(topic.views ?: 0)
                                }
                                td {
                                    span() {
                                        mkp.yield(userProps.displayName)
                                        if (authorIsModerator) {
                                            i(class:'icon-star-empty') { mkp.yieldUnescaped("&nbsp;") }
                                        }
                                    }
                                }
                                td {
                                    mkp.yield(formatDate(date: topic.dateCreated, format: DateConstants.DATE_TIME_FORMAT))
                                }
                                td {
                                    if (topic.lastReplyDate != topic.dateCreated) {
                                        mkp.yield(formatDate(date: topic.lastReplyDate, format: DateConstants.DATE_TIME_FORMAT))
                                    }
                                }
                                td(class: 'text-right', style: 'width:180px;') {
                                    def replyLink = topic.locked ? "#" : createLink(controller: 'forum', action: 'postMessage', params: [topicId: topic.id])
                                    def attrMap = [class: 'btn btn-sm btn-default', href: replyLink]
                                    if (topic.locked) {
                                        attrMap['disabled'] = 'true'
                                    }
                                    a(attrMap) {
                                        mkp.yield("Reply")
                                    }
                                    if (userService.isForumModerator(projectInstance)) {
                                        a(class: 'btn btn-sm btn-default', href: createLink(controller: 'forum', action: 'editTopic', params: [topicId: topic.id])) {
                                            mkp.yield("Edit")
                                        }
                                        a(class: 'btn btn-sm btn-danger', href: createLink(controller: 'forum', action: 'deleteTopic', params: [topicId: topic.id])) {
                                            mkp.yield("Delete")
                                        }

                                    }
                                }

                            }
                        }
                    }
                }
            }
            if (!hidePageButtons) {
                div(class: 'pagination') {
                    mkp.yieldUnescaped(paginate(total: totalCount, action: paginateAction, params: params + [selectedTab: 1]))
                }
            }
        }

    }

    /**
     * @attr topic
     * @attr projectInstance
     * @attr taskInstance
     * @attr lastLabel
     */
    def forumNavItems = { attrs, body ->

        Project projectInstance = null
        Task taskInstance = null
        def topic = attrs.topic as ForumTopic

        if (topic) {
            if (topic.instanceOf(ProjectForumTopic)) {
                projectInstance = (topic as ProjectForumTopic).project
            } else if (topic.instanceOf(TaskForumTopic)) {
                taskInstance = (topic as TaskForumTopic).task
            }
        } else {
            projectInstance = attrs.projectInstance as Project
            taskInstance = attrs.taskInstance as Task
        }

        pageScope.crumbs = []
        if (projectInstance) {
            pageScope.crumbs << [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance.featuredLabel]
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectInstance.id]), label: message(code: 'forum.project.forum', default: 'Expedition Forum')]
        }

        if (taskInstance) {
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'projectForum', params: [projectId: taskInstance.project.id]), label: message(code: 'forum.project.forum', default: 'Expedition Forum')]
            pageScope.crumbs << [link: createLink(controller: 'task', action: 'show', id: taskInstance.id), label: "Task - " + taskInstance.externalIdentifier]
        }

        if (!projectInstance && !taskInstance) {
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index'), label: message(code: "default.forum.label", default: "Forum")]
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index',params:[selectedTab: 1]), label: message(code: "default.generaldiscussion.label", default: "General Discussion")]
        }

        if (attrs.lastLabel) {
            if (topic) {
                pageScope.crumbs << [link: createLink(controller: 'forum', action: 'viewForumTopic', id: topic.id), label: topic.title]
            }
        }

        def mb = new MarkupBuilder(out)

        if (topic) {
            mb.h1() {
                if (taskInstance) {
                    mkp.yieldUnescaped(message(code: 'forum.taskTopic.heading', default: 'Task Topic - {0}', args: [taskInstance.externalIdentifier]))
                }
                if (projectInstance) {
                    mkp.yieldUnescaped(message(code: 'forum.projectTopic.heading', default: '{0} Forum Topic - {1}', args: [projectInstance.featuredLabel, topic.title]))
                }
                if (!projectInstance && !taskInstance) {
                    mkp.yieldUnescaped(message(code: 'forum.generalDiscussionTopic.heading', default: 'General Discussion Topic - {0}', args: [topic.title]))
                }
            }
        }

    }

    /**
     * @attr task
     * @attr label
     * @attr class
     * @attr style
     */
    def taskTopicButton = { attrs, body ->
        if (FrontPage.instance().enableForum) {

            def task = attrs.task as Task
            if (task) {
                // See if there is already a topic for this task, If there is, change the wording of the button
                TaskForumTopic topic = null
                if (task.attached) {
                    topic = TaskForumTopic.findByTask(task)
                }
                def defaultLabel = topic ? 'View Forum Topic' : 'Create Forum Topic'
                def label = attrs.label ?: defaultLabel
                def mb = new MarkupBuilder(out)
                mb.a(href: createLink(controller: 'forum', action: 'taskTopic', params: [taskId: task.id]), class: 'btn ' + attrs.class, style: attrs.style ?: '', target: 'forumWindow') {
                    mkp.yield(label)
                }
            }
        }
    }

    /**
     * @attrs project
     */
    def taskTopicsTable = { attrs, body ->
        def topics = attrs.topics as PagedResultList

        if (topics) {
            out << topicTable([topics: topics, totalCount: topics?.totalCount, paginateAction: 'projectForum'], body)
        }
    }

    /**
     * @attr messages
     * @attr hideUsername
     * @attr paginateAction
     * @attr paginateController
     */
    def messagesTable = { attrs, body ->
        def messages = attrs.messages

        if (messages) {
            def mb = new MarkupBuilder(out)

            mb.table(class: 'forum-table table table-striped table-condensed table-bordered', style:'width: 100%') {
                tbody {
                    ForumTopic lastTopic = null

                    for (ForumMessage message : messages) {
                        def userProps = userService.detailsForUserId(message.user?.userId)
                        Project projectInstance = null
                        Task taskInstance = null
                        if (message.topic.instanceOf(ProjectForumTopic)) {
                            def projectTopic = message.topic as ProjectForumTopic
                            projectInstance = projectTopic.project
                        } else if (message.topic.instanceOf(TaskForumTopic)) {
                            def taskTopic = message.topic as TaskForumTopic
                            taskInstance = taskTopic.task
                            projectInstance = taskTopic.task.project
                        }

                        def authorIsModerator = userService.isUserForumModerator(message.user, projectInstance)

                        def rowClasses = []
                        if (authorIsModerator) {
                            rowClasses << "author-is-moderator-row"
                        }

                        if (lastTopic != message.topic) {
                            lastTopic = message.topic
                            tr(style: "background-color: #f0f0e8; color: black; height: 15px;") {
                                th(colspan: '2') {
                                    h4(style:'padding-bottom: 10px') {
                                        mkp.yield("Topic: ")
                                        a(href: createLink(controller: 'forum', action: 'viewForumTopic', id: lastTopic.id)) {
                                            mkp.yield(lastTopic.title)
                                        }
                                        if (projectInstance) {
                                            mkp.yield("  Project:")
                                            a(href: createLink(controller: 'project', action: 'index', id: projectInstance.id)) {
                                                mkp.yield(projectInstance.featuredLabel)
                                            }
                                        }
                                        if (taskInstance) {
                                            mkp.yieldUnescaped("&nbsp;Task:")
                                            a(href: createLink(controller: 'task', action: 'show', id: taskInstance.id)) {
                                                mkp.yield(taskInstance.externalIdentifier)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        tr(class: rowClasses.join(" ")) {
                            td(class: "forumNameColumn") {
                                if (!attrs.hideUsername) {
                                    a(class: 'forumUsername', href: createLink(controller: 'user', action: 'show', id: message.user.id)) {
                                        mkp.yield(userProps.displayName)
                                    }
                                }
                                br {}
                                span(class: 'forumMessageDate') {
                                    mkp.yield(formatDate(date: message.date, format: 'dd MMM, yyyy HH:mm:ss'))
                                }
                                if (authorIsModerator) {
                                    br {}
                                    span(class: 'moderator-label') {
                                        mkp.yield("Moderator")
                                    }
                                }
                            }
                            def messageText = markdownService.sanitize(message.text ?: "")
                            td(style:'vertical-align: middle') { mkp.yieldUnescaped(markdownService.markdown(messageText)) }
                        }
                    }
                }
            }
            mb.div(class: 'pagination') {
                mkp.yieldUnescaped(paginate(controller: attrs.paginateController, action: attrs.paginateAction, total: messages.totalCount, params: params))
            }

        } else {
            out << "You have not posted any messages to the Forum"
        }


    }

}
