package au.org.ala.volunteer

import com.vladsch.flexmark.util.ast.Node;
import com.vladsch.flexmark.html.HtmlRenderer;
import com.vladsch.flexmark.parser.Parser;
import grails.orm.PagedResultList
import groovy.xml.MarkupBuilder
import org.hibernate.Hibernate

class ForumTagLib {

    static namespace = 'vpf'

    UserService userService
    MultimediaService multimediaService
    ProjectService projectService
    MarkdownService markdownService
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
     * Constrcts the list of forum topic messages.
     * @attr topic the Forum topic to display
     */
    def topicMessageList = { attrs, body ->
        def topic = attrs.topic as ForumTopic

        if (topic) {
            def replies = forumService.getTopicMessages(topic, params)
            def mb = new MarkupBuilder(out)

            replies.each { ForumMessage reply ->
                attrs.user = reply.user
                attrs.messageId = reply.id

                printMessageRow(attrs, false, reply)
            }
        }
    }

    /**
     * Retrieves the project record from the forum topic if applicable.
     * @param topic the topic to query
     * @return the project record
     */
    private def getProjectFromTopic(ForumTopic topic) {
        Project projectInstance = null
        if (topic.instanceOf(ProjectForumTopic)) {
            def projectTopic = topic as ProjectForumTopic
            projectInstance = projectTopic.project
        } else if (topic.instanceOf(TaskForumTopic)) {
            def taskTopic = topic as TaskForumTopic
            projectInstance = Project.get(taskTopic.task.project.id)
        }

        projectInstance
    }

    /**
     * Prints a forum message row.
     * @param attrs the taglib attributes
     * @param isPreview true if the message is a message being previewed
     * @param message optional message object to display
     * @return
     */
    private def printMessageRow(attrs, isPreview, message = null) {
        def user = attrs.user as User
        def canEdit = false
        def authorIsModerator = false
        def isEdit = attrs.isEdit ? attrs.isEdit == "true" : false
        def topicId

        def forumMessage
        if (isEdit) {
            forumMessage = attrs.forumMessage as ForumMessage
        } else {
            if (message) {
                forumMessage = message as ForumMessage
            }
        }
        topicId = forumMessage != null ? forumMessage.topic.id : 0L

        def messageText
        if (isPreview) {
            messageText = attrs.messageText as String
        } else {
            messageText = forumMessage.text
            canEdit = forumService.isMessageEditable(forumMessage as ForumMessage, userService.currentUser)
            def project = getProjectFromTopic(attrs.topic as ForumTopic)
            authorIsModerator = userService.isAdmin() ?: userService.isUserForumModerator(user, project)
        }

        log.debug("ForumTagLib | messageText: ${messageText}")

        if (user) {
            def userProps = userService.detailsForUserId(user.userId)
            def mb = new MarkupBuilder(out)

            mb.li(class: "forum-post__list-item ${isEdit ? 'hr-spacer' : ''}") {
                article('data-topic-id': topicId) {
                    div(class: 'forum-post__header') {
                        h2(class: 'forum-post__heading') {
                            if (isPreview) {
                                if (isEdit) {
                                    def postUserProps = userService.detailsForUserId(forumMessage.user.userId as String)
                                    mkp.yield(postUserProps.displayName + " - PREVIEW")
                                } else {
                                    mkp.yield(userProps.displayName + " - PREVIEW")
                                }
                            } else {
                                a(href: createLink(controller: 'user', action: 'show', id: forumMessage.user.id), title: "Open user's notebook in new window", target: "_blank") {
                                    mkp.yield(userProps.displayName)
                                }
                            }
                        }
                        time(class: 'forum-post__date-time') {
                            if (isPreview) {
                                if (isEdit) {
                                    mkp.yieldUnescaped(formatDate(date: forumMessage.date, format: DateConstants.DATE_FORUM_POST))
                                } else {
                                    mkp.yieldUnescaped(formatDate(date: new Date(), format: DateConstants.DATE_FORUM_POST))
                                }
                            } else {
                                mkp.yieldUnescaped(formatDate(date: forumMessage.date, format: DateConstants.DATE_FORUM_POST))
                            }
                        }
                    }

                    if (isEdit && !forumMessage.replyTo) {
                        mkp.yieldUnescaped("<div data-topic-id='${topicId}' class='forum-post__text message-text'>")
                    } else {
                        mkp.yieldUnescaped("<div data-message-id='${attrs.messageId}' class='forum-post__text message-text'>")
                    }
                    String processedMarkdown = messageText.replace("\n", "  \n")
                    mkp.yieldUnescaped(markdownService.renderMarkdown(processedMarkdown ?: ""))
                    mkp.yieldUnescaped("</div>")
                    log.debug("authorIsModerator: ${authorIsModerator}")

                    if (!isPreview) {
                        log.debug("Not a preview")
                        def timeLeft = forumService.messageEditTimeLeft(forumMessage as ForumMessage, userService.currentUser)
                        log.debug("timeleft to edit: ${timeLeft}")

                        mkp.yieldUnescaped("<div class='forum-post__footer' data-message-id='${forumMessage.id}'>")

                        if (canEdit) {
                            log.debug("Can edit post")
                            mkp.yieldUnescaped("<button class='fa fa-pencil message-icon edit-message' title='Edit message'></button>")

                            if ((forumMessage as ForumMessage).replyTo) {
                                log.debug("Message is a reply")
                                mkp.yieldUnescaped("<button class='fa fa-trash message-icon delete-message' title='Delete message'></button>")
                            } else {
                                log.debug("Message is not a reply")
                                if (authorIsModerator) {
                                    log.debug("Moderator has ability to delete")
                                    mkp.yieldUnescaped("<button class='fa fa-trash message-icon delete-topic' title='Delete topic'></button>")
                                }
                            }
                        }

                        mkp.yieldUnescaped("<button class='fa fa-quote-right message-icon message-quote' title='Click to quote this message'></button>")
                        mkp.yieldUnescaped("</div>")

                        if (timeLeft) {
                            div(class: 'forum-post__footer forum-post__edit-warning') {
                                mkp.yield("You have ${timeLeft.minutes} minutes to edit or delete this message.")
                            }
                        }
                    }
                 }
            }
        }
    }

    /**
     * Previews a message
     * @attr user The user viewing the message
     * @attr isEdit true if the message is being edited
     * @attr messageText the message content (i.e. being previewed)
     * @attr forumMessage (optional) the forum message object being edited
     */
    def messagePreview = { attrs, body ->
        log.debug("ForumTagLib | attrs: ${attrs}")

        printMessageRow(attrs, true)
    }

    /**
     * Constructs the row for replying to a topic, including the text area.
     * @attr newPost true if it's a new topic
     * @attr user the user object posting the new message
     * @attr topic the topic record if editing or replying to an existing topic
     * @attr forumMessage required if editing a forum message
     * @attr isEdit true if editing a forum message
     */
    def topicReplyBox = {attrs, body ->
        def user = attrs.user as User
        def topic
        def forumMessage = attrs.forumMessage as ForumMessage
        def isEdit = attrs.isEdit ? attrs.isEdit == "true" : false
        def newPost = attrs.newPost ? attrs.newPost == "true" : false
        def isWatching = false

        // If coming from edit, it seems to not know the subclass
        if (isEdit) {
            topic = ForumTopic.get(attrs.topic.id as long)
        } else {
            topic = attrs.topic
        }

        if (!newPost) {
            isWatching = forumService.isUserWatchingTopic(user, topic)
        }

        if (user) {
            def userProps = userService.detailsForUserId(user.userId)
            def mb = new MarkupBuilder(out)

            mb.li(class: "forum-post__list-item") {
                label(for: 'post', class: 'forum-post__header') {
                    span(class: 'forum-post__heading') {
                        if (isEdit) {
                            def postAuthorProps = userService.detailsForUserId(forumMessage.user.userId)
                            mkp.yield(postAuthorProps.displayName)
                        } else {
                            mkp.yield(userProps.displayName)
                        }
                    }
                    if (!isEdit) {
                        time(class: 'forum-post__date-time') {
                            mkp.yieldUnescaped(formatDate(date: new Date(), format: DateConstants.DATE_FORUM_POST))
                        }
                    }
                }

                // Message text is either blank, a query string parameter or the message text.
                def messageText = params.messageText ?: ""
                if (isEdit) {
                    messageText = params.messageText ?: forumMessage.text
                }
                mkp.yieldUnescaped("<textarea type=\"text\" id=\"messageText\" name=\"messageText\" class=\"forum-post__textarea\">${messageText}</textarea>")

                if (newPost) {
                    div(class: 'forum-post-button-row') {
                        mkp.yieldUnescaped("<div data-watched='${isWatching ? 'true' : 'false'}' class='forum-post-buttons--justify-left toggleWatch'>")
                        mkp.yieldUnescaped("<span class=\"fa fa-star-o forum-post-watched forum-post-not-watched\" title=\"${message(code: 'forumTopic.watched.watch', default: 'Click to watch')}\"></span>")
                        mkp.yieldUnescaped("</div>")

                        div(class: 'forum-post-helplinks') {
                            mb.a(href: createLink(controller: 'forum', action: 'markdownHelp'), target: '_blank') {
                                mkp.yield(message(code: 'forum.newpost.markdownhelp.link', default: 'Markdown help'))
                                mkp.yieldUnescaped("<span class='fa fa-external-link message-icon-small'></span>")
                            }
                        }
                    }
                }

                div(class: 'forum-post-button-row') {

                    if (!newPost) {
                        mkp.yieldUnescaped("<div data-topic-id=\"${topic.id}\" data-watched='${isWatching ? 'true' : 'false'}' class='forum-post-buttons--justify-left toggleWatch'>")
                        if (isWatching) {
                            mkp.yieldUnescaped("<span class=\"fa fa-star forum-post-watched\" title=\"${message(code: 'forumTopic.watched.stopwatching', default: 'Click to stop watching')}\"></span>")
                        } else {
                            mkp.yieldUnescaped("<span class=\"fa fa-star-o forum-post-watched forum-post-not-watched\" title=\"${message(code: 'forumTopic.watched.watch', default: 'Click to watch')}\"></span>")
                        }
                        mkp.yieldUnescaped("</div>")
                    } else {
                        // Forum Topic Type
                        div(class: 'forum-post-buttons--new-post-type hr-spacer') {
                            div(class: 'filter-nav__label') {
                               label(class: 'forum-post__title_label') {
                                   mkp.yield(message(code: 'forum.newpost.topictype.label', default: 'Mark as:'))
                               }
                            }
                            mkp.yieldUnescaped("<a href=\"#\" class=\"filter-topic-link \"><span class=\"pill pill--bg-question pill--bg-selected\" data-topic-type=\"question\" data-topic-type-id=\"${ForumTopicType.Question.ordinal()}\" title=\"Question Topics\">Question</span></a>")
                            mkp.yieldUnescaped("<a href=\"#\" class=\"filter-topic-link\"><span class=\"pill pill--bg-announcement-unselected\" data-topic-type=\"announcement\" data-topic-type-id=\"${ForumTopicType.Announcement.ordinal()}\" title=\"Announcement Topics\">Announcement</span></a>")
                            mkp.yieldUnescaped("<a href=\"#\" class=\"filter-topic-link\"><span class=\"pill pill--bg-discussion-unselected\" data-topic-type=\"discussion\" data-topic-type-id=\"${ForumTopicType.Discussion.ordinal()}\" title=\"Discussion Topics\">Discussion</span></a>")
                        }
                    }

                    div(class: 'forum-post-buttons') {
                        if (newPost) {
                            mb.input(type: 'submit', class: 'forum-post-button', name: '_action_insertForumTopic', value: message(code: 'forum.newpost.save', default: 'Save message'))
                        } else if (isEdit) {
                            mb.input(type: 'submit', class: 'forum-post-button', name: '_action_previewMessageEdit', value: message(code: 'forum.reply.preview', default: 'Preview'))
                            mb.input(type: 'submit', class: 'forum-post-button', name: '_action_updateTopicMessage', value: message(code: 'forum.reply.comment', default: 'Comment'))
                        } else {
                            mb.input(type: 'submit', class: 'forum-post-button', name: '_action_previewMessage', value: message(code: 'forum.reply.preview', default: 'Preview'))
                            mb.input(type: 'submit', class: 'forum-post-button', name: '_action_saveNewTopicMessage', value: message(code: 'forum.reply.comment', default: 'Comment'))
                        }

                        if (!newPost) {
                            if (topic.topicType == ForumTopicType.Question && !topic.isAnswered) {
                                String buttonLabel = "${message(code: 'forum.project.reply.comment.answered', default: 'Comment and mark as ')}"
                                buttonLabel += "<div class=\"pill pill--bg-answered\">Answered</div>"
                                mb.button(type: 'submit', class: 'forum-post-button', name: '_action_saveNewTopicMessageAnswered') {
                                    mkp.yieldUnescaped(buttonLabel)
                                }
                            }
                        }
                    }
                }
            }
        }

    }

    /**
     * @deprecated
     * @param topic
     */
    def topicMessagesTable = { attrs, body ->

        def topic = attrs.topic as ForumTopic
//        Parser parser = Parser.builder().build();

        if (topic) {

            Project projectInstance = null
            if (topic.instanceOf(ProjectForumTopic)) {
                def projectTopic = topic as ProjectForumTopic
                projectInstance = projectTopic.project
            } else if (topic.instanceOf(TaskForumTopic)) {
                def taskTopic = topic as TaskForumTopic
                projectInstance = taskTopic.task.project
                projectInstance.attach()
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

                            // Process the markdown into HTML and sanitize.
                            td() { mkp.yieldUnescaped(markdownService.renderMarkdown(reply.text ?: "")) }

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
     * Deprecated topic list
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
                                        def imageUrl = projectFeaturedImage + "?" + projectService.cacheBust((topic as ProjectForumTopic).project)
                                        //delegate.img(src: (topic as ProjectForumTopic).project.featuredImage, width: '40')
                                        delegate.img(src: imageUrl, width: '40')
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
        def topic = attrs.topic //as ForumTopic

        if (topic) {
            if (topic.instanceOf(ProjectForumTopic)) {
                def unproxyObject = Hibernate.unproxy(topic)
                projectInstance = unproxyObject.project
            } else if (topic.instanceOf(TaskForumTopic)) {
                def unproxyObject = Hibernate.unproxy(topic)
                taskInstance = unproxyObject.task
            }
        } else {
            projectInstance = attrs.projectInstance as Project
            taskInstance = attrs.taskInstance as Task
        }

        pageScope.crumbs = []
        if (projectInstance) {
            pageScope.crumbs << [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance.featuredLabel]
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index', params: [projectId: projectInstance.id]), label: message(code: 'forum.project.forum', default: 'Expedition Forum')]
        }

        if (taskInstance) {
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index', params: [projectId: taskInstance.project.id]), label: message(code: 'forum.project.forum', default: 'Expedition Forum')]
            pageScope.crumbs << [link: createLink(controller: 'task', action: 'show', id: taskInstance.id), label: "Task - " + taskInstance.externalIdentifier]
        }

        if (!projectInstance && !taskInstance) {
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index'), label: message(code: "default.forum.label", default: "Forum")]
//            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index',params:[selectedTab: 1]), label: message(code: "default.generaldiscussion.label", default: "General Discussion")]
        }

        if (attrs.lastLabel) {
            if (topic) {
                pageScope.crumbs << [link: createLink(controller: 'forum', action: 'viewForumTopic', id: topic.id), label: topic.title]
            }
        }

        def mb = new MarkupBuilder(out)
        String pageTitle = attrs.title

        if (topic) {
            pageTitle = topic.title as String
        }

        mb.h1() {
            mkp.yieldUnescaped(pageTitle)
            if (taskInstance || projectInstance) {
                // External link icon
                def link = ""
                String title = ""
                if (taskInstance) {
                    link = createLink(controller: 'task', action: 'show', id: taskInstance.id)
                    title = "Open task in new window"
                } else if (projectInstance) {
                    link = createLink(controller: 'project', action: 'index', id: projectInstance.id)
                    title = "Open expedition in new window"
                }
                a(href: link, target: "_blank", title: title) {
                    span(class: 'forum-post-page-header__external-link') {
                        mkp.yieldUnescaped("<svg width=\"28\" height=\"28\" viewBox=\"0 0 28 28\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">")
                        mkp.yieldUnescaped("<path d=\"M25.8031 0H17.15C16.4562 0 15.8939 0.562293 15.8939 1.25611C15.8939 1.94992 16.4562 2.51222 17.15 2.51222H22.9102L10.5832 14.8392C10.0924 15.3297 10.0924 16.1252 10.5832 16.6157C10.8284 16.8609 11.15 16.9837 11.4713 16.9837C11.7925 16.9837 12.1141 16.8609 12.3594 16.6157L24.547 4.42775V9.9089C24.547 10.6027 25.1093 11.165 25.8031 11.165C26.4969 11.165 27.0592 10.6027 27.0592 9.9089V1.25611C27.0592 0.562293 26.4969 0 25.8031 0Z\" fill=\"#020202\" />")
                        mkp.yieldUnescaped("<path d=\"M21.4582 12.6504C20.7644 12.6504 20.2021 13.2127 20.2021 13.9065V23.8166C20.2021 24.2706 19.8187 24.654 19.3647 24.654H3.34962C2.89563 24.654 2.51222 24.2706 2.51222 23.8166V7.80153C2.51222 7.34753 2.89563 6.96412 3.34962 6.96412H13.2947C13.9885 6.96412 14.5508 6.40183 14.5508 5.70801C14.5508 5.0142 13.9885 4.4519 13.2947 4.4519H3.34962C1.50256 4.4519 0 5.95447 0 7.80153V23.8166C0 25.6637 1.50256 27.1662 3.34962 27.1662H19.3647C21.2118 27.1662 22.7143 25.6637 22.7143 23.8166V13.9065C22.7143 13.213 22.152 12.6504 21.4582 12.6504Z\" fill=\"#020202\" />")
                        mkp.yieldUnescaped("</svg>")
                    }
                }
            }
        }
        if (taskInstance || projectInstance) {
            mb.div {
                mkp.yieldUnescaped(message(code: 'forum.project.heading', default: 'from: {0}', args: [taskInstance ? taskInstance.project.name : projectInstance.name]))
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
        def topics = attrs.topics

        if (topics) {
            out << topicTable([topics: topics.topics, totalCount: topics?.totalCount, paginateAction: 'projectForum'], body)
        }
    }

    /**
     * Prints a series of topics that are from the Forum Search
     * @attr messages
     * @attr totalCount
     * @attr hideUsername
     * @attr paginateAction
     * @attr paginateController
     */
    def messagesTable = { attrs, body ->
        def messages = attrs.messages as List<ForumMessage>
//        Parser parser = Parser.builder().build();

        if (messages) {
            def mb = new MarkupBuilder(out)

            mb.table(class: 'forum-table table table-striped table-condensed table-bordered', style:'width: 100%') {
                tbody {
                    ForumTopic lastTopic = null

                    for (ForumMessage message : messages) {
                        def userProps = userService.detailsForUserId(message.user?.userId)
                        Project projectInstance = null
                        Task taskInstance = null
                        def topic = message.topic

                        if (topic.instanceOf(ProjectForumTopic)) {
                            def unproxyObject = Hibernate.unproxy(topic)
                            projectInstance = unproxyObject.project
                        } else if (topic.instanceOf(TaskForumTopic)) {
                            def unproxyObject = Hibernate.unproxy(topic)
                            taskInstance = unproxyObject.task
                            projectInstance = taskInstance.project
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

                            // Process the markdown into HTML and sanitize.
                            td(style:'vertical-align: middle') { mkp.yieldUnescaped(markdownService.renderMarkdown(message.text ?: "")) }
                        }
                    }
                }
            }
            mb.div(class: 'pagination') {
                mkp.yieldUnescaped(paginate(controller: attrs.paginateController, action: attrs.paginateAction, total: attrs.totalCount, params: params))
            }

        } else {
            out << "You have not posted any messages to the Forum"
        }


    }

    /**
     * Prints a list of projects for a select form element along with the number of topics linked to that project
     * grouped into institution.
     * @attr projectFilterList list of projects. Expects the following properties: [projectId, institutionName, projectName, topicCount]
     * @attr currentSelectedProject the ID of the project that is currently selected so that the select can display this project as the currently displayed option.
     */
    def projectSelectOptions = { attrs ->
        //log.debug("Project Select Options")
        def institution = ""
        def output = "<option value>- Select an Expedition -</option>"
        def currentSelectedProject = attrs.currentSelectedProject ? attrs.currentSelectedProject as Long : null
        //log.debug("currentSelectedProject: ${currentSelectedProject}")

        attrs.projectFilterList.each { Map row ->
            long projectId = currentSelectedProject ? row.projectId as long : 0L
            if (institution != row.institutionName) {
                institution = row.institutionName
                if (output.length() > 0) output += "</optgroup>"
                output += "<optgroup label='${institution}'>"
            }

            //log.debug("Is this the matching project ID ${row.projectId}: ${currentSelectedProject == projectId}")
            def option = "<option value='${row.projectId}' ${currentSelectedProject == row.projectId ? 'selected' : ''}>${row.projectName} (${row.topicCount} topics)</option>"
            output += option
        }

        out << output
    }
}
