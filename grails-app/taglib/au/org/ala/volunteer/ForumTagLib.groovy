package au.org.ala.volunteer

import grails.gorm.PagedResultList
import groovy.xml.MarkupBuilder

class ForumTagLib {

    static namespace = 'vpf'

    def authService
    def userService
    def forumService
    def markdownService
    def taskService

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
                def projectTopic = topic as ProjectForumTopic
                projectInstance = projectTopic.project
            } else if (topic.instanceOf(TaskForumTopic)) {
                def taskTopic = topic as TaskForumTopic
                projectInstance = taskTopic.task.project
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
                                mb.img(style: 'vertical-align: middle', src: resource(dir: '/images', file: 'lock.png'))
                                mkp.yield("Topic is locked")
                            } else {
                                mb.button(id:'btnReply', class:'btn') {
                                    mb.img(src:resource(dir:'images', file:'reply.png')) {
                                        mkp.yieldUnescaped("&nbsp;Post Reply")
                                    }
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

                        tr(class: rowClasses.join(" "), messageId: reply.id) {
                            td(class: "forumNameColumn") {
                                a(class: 'forumUsername', href: createLink(controller: 'user', action: 'show', id: reply.user.id), name:'message_' + reply.id) {
                                    mkp.yield(reply.user.displayName)
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

                                    button(class:'btn editMessageButton') {
                                        mkp.yield("Edit")
                                    }

                                    // if this is the first message in the topic, you can't delete it
                                    // Only the first message as a null replyTo
                                    if (reply.replyTo != null) {
                                        button(class:'btn deleteMessageButton') {
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

        def totalCount = attrs.totalCount
        if (!totalCount && (topics instanceof PagedResultList)) {
            totalCount = topics?.totalCount
        }

        def mb = new MarkupBuilder(out)
        Project projectInstance = null
        if (!topics) {
            mb.div {
                mkp.yield("No topics found")
            }
            return
        }

        if (topics.size() > 0 && !paginateAction) {
            def first = topics[0] as ForumTopic
            if (first) {
                if (first.instanceOf(ProjectForumTopic)) {
                    projectInstance = (first as ProjectForumTopic).project
                    paginateAction = 'projectForum'
                } else if (first.instanceOf(TaskForumTopic)) {
                    projectInstance = (first as TaskForumTopic).task?.project
                    paginateAction = 'projectForum'
                }
            }
        }

        def topicCounts = [:]
        topics.each { topic ->
            def replyCount = ForumMessage.countByTopic(topic)
            topicCounts[topic] = replyCount
        }

        mb.div(class: 'topicTable', style: 'margin-bottom: 15px') {
            table(class: "forum-table", style: "margin-bottom: 5px") {
                thead {
                    tr {
                        mkp.yieldUnescaped(sortableColumn(colspan:2, class:"button", property:"title", title: "Topic", action:paginateAction, params:params))
                        mkp.yieldUnescaped(sortableColumn(class:"button", property:"replies", title: "Replies", action:paginateAction, params:params))
                        mkp.yieldUnescaped(sortableColumn(class:"button", property:"views", title: "Views", action:paginateAction, params:params))
                        mkp.yieldUnescaped(sortableColumn(class:"button", property:"creator", title: "Posted&nbsp;by", action:paginateAction, params:params))
                        mkp.yieldUnescaped(sortableColumn(class:"button", property:"dateCreated", title: "Posted", action:paginateAction, params:params))
                        mkp.yieldUnescaped(sortableColumn(class:"button", property:"lastReplyDate", title: "Last reply", action:paginateAction, params:params))
                        th {
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
                                td(style: "width: 40px; padding: 0px") {
                                    span(style: 'color:green') {
                                        mkp.yieldUnescaped("&nbsp;")
                                        if (topic.sticky) {
                                            i(class:'icon-asterisk', title:'This topic is sticky') { mkp.yieldUnescaped("&nbsp;") }
                                        }
                                        if (topic.locked) {
                                            i(class:'icon-lock', title:'This topic is locked') { mkp.yieldUnescaped("&nbsp;") }
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
                                td {
                                    mkp.yield(topicCounts[topic] - 1)
                                }
                                td {
                                    mkp.yield(topic.views ?: 0)
                                }
                                td {
                                    span() {
                                        mkp.yield(topic.creator?.displayName)
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
                                td {
                                    def replyLink = topic.locked ? "#" : createLink(controller: 'forum', action: 'postMessage', params: [topicId: topic.id])
                                    def attrMap = [class: 'btn btn-small', href: replyLink]
                                    if (topic.locked) {
                                        attrMap['disabled'] = 'true'
                                    }
                                    a(attrMap) {
                                        mkp.yield("Reply")
                                    }
                                    if (userService.isForumModerator(projectInstance)) {
                                        a(class: 'btn btn-small', href: createLink(controller: 'forum', action: 'editTopic', params: [topicId: topic.id])) {
                                            mkp.yield("Edit")
                                        }
                                        a(class: 'btn btn-small btn-danger', href: createLink(controller: 'forum', action: 'deleteTopic', params: [topicId: topic.id])) {
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
                    mkp.yieldUnescaped(paginate(total: totalCount, action: paginateAction, params: params))
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

        def mb = new MarkupBuilder(out)

        mb.nav(id: 'breadcrumb') {
            ol {
                li {
                    a(href: createLink(uri: '/')) {
                        mkp.yield(message(code: 'default.home.label'))
                    }
                }
                if (projectInstance) {
                    li {
                        a(href: createLink(controller: 'project', action: 'index', id: projectInstance.id)) {
                            mkp.yield(projectInstance.featuredLabel)
                        }
                    }
                    li {
                        a(href: createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectInstance.id])) {
                            mkp.yield(message(code: 'forum.project.forum', default: 'Project Forum'))
                        }
                    }
                }
                if (taskInstance) {
                    li {
                        a(href: createLink(controller: 'forum', action: 'projectForum', params: [projectId: taskInstance.project.id])) {
                            mkp.yield(message(code: 'forum.project.forum', default: 'Project Forum'))
                        }
                    }

                    li {
                        a(href: createLink(controller: 'task', action: 'show', id: taskInstance.id)) {
                            mkp.yield("task " + taskInstance.externalIdentifier)
                        }
                    }

                }
                if (!projectInstance && !taskInstance) {
                    li {
                        a(href: createLink(controller: 'forum', action: 'index')) {
                            mkp.yield(message(code: "default.forum.label", default: "Forum"))
                        }
                    }
                    li {
                        a(href: createLink(controller: 'forum', action: 'index',params:[selectedTab: 1])) {
                            mkp.yield(message(code: "default.generaldiscussion.label", default: "General Discussion"))
                        }
                    }
                }
                if (attrs.lastLabel) {
                    if (topic) {
                        li {
                            a(href: createLink(controller: 'forum', action: 'viewForumTopic', id: topic.id)) {
                                mkp.yield(topic.title)
                            }
                        }
                    }
                    li(class: 'last') {
                        mkp.yield(attrs.lastLabel)
                    }
                } else {
                    if (topic) {
                        mkp.yield(topic.title)
                    }
                }

            }

        }

        if (topic) {
            mb.h1() {
                if (taskInstance) {
                    mkp.yield(message(code: 'forum.taskTopic.heading', default: 'Task Topic - {0}', args: [taskInstance.externalIdentifier]))
                }
                if (projectInstance) {
                    mkp.yield(message(code: 'forum.projectTopic.heading', default: '{0} Forum Topic - {1}', args: [projectInstance.featuredLabel, topic.title]))
                }
                if (!projectInstance && !taskInstance) {
                    mkp.yield(message(code: 'forum.generalDiscussionTopic.heading', default: 'General Discussion Topic - {0}', args: [topic.title]))
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
                def topic = TaskForumTopic.findByTask(task)
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
        def projectInstance = attrs.project as Project

        if (projectInstance) {
            def topics = forumService.getTaskTopicsForProject(projectInstance)
            out << topicTable([topics: topics, totalCount: topics?.totalCount], body)
        }
    }

    /**
     * @attr task
     */
    def taskSummary = { attrs, body ->
        def task = attrs.task as Task
        def templateFields = TemplateField.findAllByTemplate(task.project.template)?.collectEntries { [it.fieldType.toString(), it] }

        if (task) {
            def multimedia = task.multimedia.size() > 0 ? task.multimedia.first() : null
            if (multimedia) {
                def imageMetaData = taskService.getImageMetaData(task)
                def imageSize = imageMetaData[multimedia.id]
                def mb = new MarkupBuilder(out)
                def fields = Field.findAllByTask(task)
                mb.table(style: 'width:100%') {
                    tr {
                        td {
                            if (multimedia) {
                                def url = grailsApplication.config.server.url + multimedia.filePath
                                div(class: 'imageContainer', style: 'float: left; width: 600px; height: 400px') {
                                    div(class: 'pan-image', style: 'margin-top: 0px; padding-top: 0px') {
                                        mb.img(src: url, alt: 'Task image', "image-height": imageSize?.height, "image-width": imageSize?.width) {
                                            div(class: 'map-control') {
                                                a(id: 'panleft', href: '#left', class: 'left') { mkp.yield("Left") }
                                                a(id: 'panright', href: '#right', class: 'right') { mkp.yield("Right") }
                                                a(id: 'panup', href: '#up', class: 'up') { mkp.yield("Up") }
                                                a(id: 'pandown', href: '#down', class: 'down') { mkp.yield("Down") }
                                                a(id: 'zoomin', href: '#zoom', class: 'zoom') { mkp.yield("Zoom") }
                                                a(id: 'zoomout', href: '#zoom_out', class: 'back') { mkp.yield("Back") }
                                            }

                                        }
                                    }
                                }
                            }
                        }
                        td {
                            div(style: 'height: 400px; overflow-y: scroll') {
                                table(style: 'width: 100%') {
                                    thead {
                                        tr {
                                            th { mkp.yield("Field Name") }
                                            th { mkp.yield("Field Value") }
                                        }
                                    }
                                    tbody {
                                        for (Field field : fields) {
                                            if (!field.superceded && field.value) {
                                                tr {
                                                    td {
                                                        def name = templateFields[field.name]?.label ?: field.name
                                                        mkp.yield(name)
                                                    }
                                                    td {
                                                        mkp.yield(field.value)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
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
                                        mkp.yield(message.user.displayName)
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
