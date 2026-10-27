package au.org.ala.volunteer

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

            replies.eachWithIndex { ForumMessage reply, int index ->
                attrs.user = reply.user
                attrs.messageId = reply.id

                printMessageRow(attrs, false, (index == replies.size() - 1), reply)
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
    private def printMessageRow(attrs, isPreview, isLastMessage, message = null) {
        def user = attrs.user as User
        def canEdit = false
        def authorIsModerator = false
        def isEdit = attrs.isEdit ? attrs.isEdit == "true" : false
        def topicId
        def isLocked = false

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
            isLocked = forumMessage.topic.locked

            // If the topic is locked, only admins can edit messages
            if (isLocked) canEdit = false
            if (userService.isAdmin()) canEdit = true
        }

        log.debug("ForumTagLib | messageText: ${messageText}")

        if (user) {
            def userProps = userService.detailsForUserId(user.userId)
            def mb = new MarkupBuilder(out)

            mb.div([class: "card shadow-sm border ${isLastMessage ? '' : 'mb-3'}"] + (topicId ? ['data-topic-id': topicId] : [:])) {
                div(class: "card-header bg-light d-flex justify-content-between align-items-center py-2 px-3 border-bottom") {
                    mkp.yieldUnescaped(cl.gravatarImage(user: user, size: 43, cssClass: "rounded me-3 img-fluid"))
                    strong(class: "text-dark me-auto") {
                        if (isPreview) {
                            if (isEdit) {
                                def postUserProps = userService.detailsForUserId(forumMessage?.user?.userId as String)
                                mkp.yield("${postUserProps.displayName} - PREVIEW")
                            } else {
                                mkp.yield("${userProps.displayName} - PREVIEW")
                            }
                        } else {
                            a(href: createLink(controller: 'user', action: 'show', id: forumMessage.user.id), class: 'author-name', title: "Open user's notebook in new window", target: "_blank") {
                                mkp.yield(userProps.displayName)
                            }
                        }
                    }
                    time(class: "text-muted small font-monospace") {
                        if (isPreview) {
                            if (isEdit) {
                                mkp.yieldUnescaped(formatDate(date: forumMessage?.date, format: DateConstants.DATE_FORUM_POST))
                            } else {
                                mkp.yieldUnescaped(formatDate(date: new Date(), format: DateConstants.DATE_FORUM_POST))
                            }
                        } else {
                            mkp.yieldUnescaped(formatDate(date: forumMessage?.date, format: DateConstants.DATE_FORUM_POST))
                        }
                    }
                }

                def divParams = [:]
                if (isEdit && !forumMessage?.replyTo) {
                    divParams['data-topic-id'] = topicId
                } else {
                    divParams['data-message-id'] = attrs.messageId
                }

                div([class: "card-body p-3"] + divParams) {
                    div(class: "card-text text-secondary mb-0 message-text") {
                        boolean quotePreview = isPreview && (attrs.isQuotedReply?.toString() == 'true')
                        String processedMarkdown = quotePreview ? (messageText ?: "") : messageText?.replace("\n", "  \n")
                        mkp.yieldUnescaped(markdownService.renderMarkdown(processedMarkdown ?: ""))
                    }
                }
                if (!isPreview) {
                    def timeLeft = forumService.messageEditTimeLeft(forumMessage as ForumMessage, userService.currentUser)
                    div(class: "card-footer bg-white d-flex justify-content-end gap-2 py-1 px-3 border-top-0", 'data-message-id':"${forumMessage?.id}") {
                        if (timeLeft) {
                            div(class: "text-danger small me-auto") {
                                mkp.yield("You have ${timeLeft.minutes} minutes to edit or delete this message.")
                            }
                        }
                        if (canEdit) {
                            button(class: "btn btn-link btn-sm text-muted text-decoration-none px-1 edit-message") {
                                i(class: "fa fa-pencil me-1", title: "Edit message", aria: "Edit message") {
                                    mkp.yield("")
                                }
                                mkp.yield(" Edit")
                            }

                            if ((forumMessage as ForumMessage).replyTo) {
                                button(class: "btn btn-link btn-sm text-muted text-decoration-none px-1 delete-message") {
                                    i(class: "fa fa-times me-1", title: "Delete message", aria: "Delete message") {
                                        mkp.yield("")
                                    }
                                    mkp.yield(" Delete")
                                }
                            } else {
                                log.debug("Message is not a reply")
                                if (authorIsModerator) {
                                    log.debug("Moderator has ability to delete")
                                    button(class: "btn btn-link btn-sm text-muted text-decoration-none px-1 delete-topic") {
                                        i(class: "fa fa-times me-1", title: "Delete topic", aria: "Delete topic") {
                                            mkp.yield("")
                                        }
                                        mkp.yield(" Delete")
                                    }
                                }
                            }
                        }
                        if (!isLocked) {
                            button(class: "btn btn-link btn-sm text-muted text-decoration-none px-1 message-quote") {
                                i(class: "fa fa-quote-right me-1") {
                                    mkp.yield("")
                                }
                                mkp.yield(" Quote")
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

        printMessageRow(attrs, true, false)
    }

    /**
     * Constructs the row for replying to a topic, including the text area.
     * @attr newPost true if it's a new topic
     * @attr user the user object posting the new message
     * @attr topic the topic record if editing or replying to an existing topic
     * @attr forumMessage (optional) the forum message object being edited (required when editing a message)
     * @attr isEdit true if editing a forum message
     */
    def topicReplyBox = {attrs, body ->
        def user = attrs.user as User
        def topic
        def projectId = attrs.projectId ? attrs.projectId as Long : null
        def forumMessage = attrs.forumMessage as ForumMessage ? attrs.forumMessage as ForumMessage : null
        def isEdit = attrs.isEdit ? attrs.isEdit == "true" : false
        def newPost = attrs.newPost ? attrs.newPost == "true" : false
        def includeTopicTitle = attrs.includeTopicTitle ? Boolean.valueOf(attrs.includeTopicTitle as String) == true : false
        log.debug("ForumTagLib | topicReplyBox | attrs: ${attrs} | isEdit: ${isEdit} | newPost: ${newPost} | includeTopicTitle: ${includeTopicTitle}")
        def isProjectWatching = false
        def isWatching = false

        // If coming from edit, it seems to not know the subclass
        if (isEdit) {
            topic = ForumTopic.get(attrs.topic.id as long)
        } else {
            topic = attrs.topic as ForumTopic
        }

        if (!newPost) {
            isWatching = forumService.isUserWatchingTopic(user, topic as ForumTopic)
            isProjectWatching = forumService.isUserWatchingProject(user, getProjectFromTopic(topic as ForumTopic))
        } else if (projectId) {
            def projectInstance = Project.get(projectId as long)
            isProjectWatching = forumService.isUserWatchingProject(user, projectInstance)
            log.debug("ForumTagLib | topicReplyBox | newPost | projectId: ${projectId} | isProjectWatching: ${isProjectWatching}")
        }

        if (user) {
            def userProps = userService.detailsForUserId(user.userId)
            def mb = new MarkupBuilder(out)

            mb.div(class: "card shadow-sm border") {
                div(class: "card-header bg-light d-flex justify-content-between align-items-center py-2 px-3 border-bottom") {
                    strong(class: "text-dark") {
                        if (isEdit) {
                            def postAuthorProps = userService.detailsForUserId(forumMessage.user.userId)
                            mkp.yield(postAuthorProps.displayName)
                        } else {
                            mkp.yield(userProps.displayName)
                        }
                    }
                    if (!isEdit) {
                        time(class: 'text-muted small font-monospace') {
                            mkp.yieldUnescaped(formatDate(date: new Date(), format: DateConstants.DATE_FORUM_POST))
                        }
                    }
                }
                div(class: "card-body p-3") {
                    if (includeTopicTitle) {
                        div(class: "form-floating mb-1") {
                            def topicTitle = params.title ?: ""
                            if (isEdit) {
                                topicTitle = params.title ?: forumMessage.topic.title
                            }
                            input(type: "text", class: "form-control border shadow-inner", placeholder: "Topic title", id: "title", name: "title", value: topicTitle)
                            label(for: "title", class: "text-muted") {
                                mkp.yield("Topic title")
                            }
                        }
                    }
                    // Text Editor Interface Layout Row Component
                    div(class: "form-floating mb-1") {
                        // Message text is either blank, a query string parameter or the message text.
                        def messageText = params.messageText ?: ""
                        if (isEdit) {
                            messageText = params.messageText ?: forumMessage.text
                        }

                        def textAreaParams = [
                            class: "form-control border shadow-inner",
                            placeholder: "Leave a reply here",
                            name: "messageText",
                            id: "messageText",
                            style: "height: 180px; resize: vertical;"
                        ]
                        textarea(textAreaParams) {
                            mkp.yield(messageText)
                        }
                        label(for: "messageText", class: "text-muted") {
                            mkp.yield("Type your reply content or solution updates...")
                        }
                    }

                    div(class: "d-flex justify-content-between align-items-center flex-wrap gap-3 mb-3") {
                        def allowTopicType = newPost || (isEdit && forumMessage?.replyTo == null && userService.isAdmin())
                        if (allowTopicType) {
                            div(class: 'd-flex mt-2 gap-2 align-items-center') {
                                span(class: "text-muted fs-7 me-1") {
                                    mkp.yield("Mark thread as:")
                                }

                                def currentTopicType = newPost ? ForumTopicType.Question.ordinal() : forumMessage.topic.topicType.ordinal()
                                div(class: "btn-group btn-group-sm", role: "group", ariaLabel: "Topic type") {
                                    [ForumTopicType.Question, ForumTopicType.Discussion, ForumTopicType.Announcement].eachWithIndex { topicType, i ->
                                        String id = "topicType-${topicType.name().toLowerCase()}"
                                        String checked = i == currentTopicType ? ' checked="checked"' : ''
                                        mkp.yieldUnescaped("<input type=\"radio\" class=\"btn-check\" name=\"topicType\" id=\"${id}\" value=\"${topicType.ordinal()}\"${checked}>")
                                        mkp.yieldUnescaped("<label class=\"btn btn-outline-secondary btn-sm\" for=\"${id}\">${topicType.name()}</label>")
                                    }

                                }
                            }
                        }
                        div(class: 'd-flex gap-2 ms-auto') {
                            mb.a(href: createLink(controller: 'forum', action: 'markdownHelp'), target: '_blank') {
                                mkp.yield(message(code: 'forum.newpost.markdownhelp.link', default: 'Markdown help'))
                                mkp.yieldUnescaped("<span class='fa fa-external-link ms-2'></span>")
                            }
                        }
                    }

                    // FOOTER ACTIONS CONTROL BAR STRIP
                    def divParams = [:]
                    divParams['id'] = "forumTopicFooterActions"
                    divParams['data-watched'] = isWatching ? 'true' : 'false'
                    if (!newPost) {
                        divParams['data-topic-id'] = topic.id
                    }
                    div([class: "d-flex justify-content-between align-items-center flex-wrap gap-3"] + divParams) {
                        if (isProjectWatching) {
                            span(class: "d-inline-block", tabindex: "0", 'data-bs-toggle': "tooltip", 'data-bs-title': "You are watching this expedition forum, you cannot watch individual topics.") {
                                button(class: "btn btn-outline-warning btn-sm disabled d-flex align-items-center gap-1 me-1",
                                        'aria-disabled': isProjectWatching, id: 'toggleWatch', type: "button") {
                                    i(class: "watchIcon fa fa-star") {
                                        mkp.yield("")
                                    }
                                    span(class: "watch-button-label") {
                                        mkp.yield("Unwatch topic")
                                    }
                                }
                            }
                        } else {
                            button(class: "btn btn-outline-warning btn-sm ${isProjectWatching ? 'disabled' : ''} d-flex align-items-center gap-1 me-1",
                                    'aria-disabled': isProjectWatching, id: 'toggleWatch', type: "button") {
                                def watchedIcon = (isWatching || isProjectWatching) ? "fa-star" : "fa-star-o"
                                i(class: "watchIcon fa ${watchedIcon}") {
                                    mkp.yield("")
                                }
                                def label = (isWatching || isProjectWatching) ? "Unwatch topic" : "Watch topic"
                                span(class: "watch-button-label") {
                                    mkp.yield(label)
                                }
                            }
                        }

                        // Consolidated Form Action Triggers
                        if (newPost) {
                            input(type: 'submit', class: 'btn btn-primary', name: '_action_insertForumTopic', value: message(code: 'forum.newpost.save', default: 'Save topic'))
                        } else if (isEdit) {
                            mb.input(type: 'submit', class: 'btn btn-outline-secondary ms-auto', name: '_action_previewMessageEdit', value: message(code: 'forum.reply.preview', default: 'Preview'))
                            mb.input(type: 'submit', class: 'btn btn-primary', name: '_action_updateTopicMessage', value: message(code: 'forum.reply.comment', default: 'Update'))
                        } else {
                            div(class: "d-flex gap-2") {
                                mb.input(type: 'submit', class: 'btn btn-outline-secondary ms-auto', name: '_action_previewMessage', value: message(code: 'forum.reply.preview', default: 'Preview'))
                                mb.input(type: 'submit', class: 'btn btn-primary', name: '_action_saveNewTopicMessage', value: message(code: 'forum.reply.comment', default: 'Reply'))
                                // Integrated Custom Colored Answer Action Button
                                if (topic.topicType == ForumTopicType.Question && !topic.isAnswered) {
                                    String buttonLabel = "${message(code: 'forum.project.reply.comment.answered', default: 'Reply and mark as ')}"
                                    button(type: "submit", class: "btn btn-success px-3 fw-bold shadow-sm d-inline-flex align-items-center gap-2", name: '_action_saveNewTopicMessageAnswered') {
                                        span(buttonLabel)
                                        span(class: "badge bg-white text-success rounded-1 px-2 py-0.5 text-uppercase tracking-wider font-monospace fs-7 fw-bold") {
                                            mkp.yield("Answered")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
/*
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
                        // Forum Topic Type. Real radios named `topicType`, so the value posts
                        // with the form and needs no hidden field or JS to mirror it.
                        div(class: 'forum-post-buttons--new-post-type hr-spacer') {
                            div(class: 'filter-nav__label') {
                               label(class: 'forum-post__title_label') {
                                   mkp.yield(message(code: 'forum.newpost.topictype.label', default: 'Mark as:'))
                               }
                            }
                            mkp.yieldUnescaped("<div class=\"btn-group\" role=\"group\" aria-label=\"Topic type\">")
                            [ForumTopicType.Question, ForumTopicType.Announcement, ForumTopicType.Discussion].eachWithIndex { topicType, i ->
                                String id = "topicType-${topicType.name().toLowerCase()}"
                                String checked = i == 0 ? ' checked="checked"' : ''
                                mkp.yieldUnescaped("<input type=\"radio\" class=\"btn-check\" name=\"topicType\" id=\"${id}\" value=\"${topicType.ordinal()}\"${checked}>")
                                mkp.yieldUnescaped("<label class=\"btn btn-outline-secondary\" for=\"${id}\">${topicType.name()}</label>")
                            }
                            mkp.yieldUnescaped("</div>")
                        }
                    }

                    div(class: 'forum-post-buttons') {
                        if (newPost) {
                            mb.input(type: 'submit', class: 'forum-post-button', name: '_action_insertForumTopic', value: message(code: 'forum.newpost.save', default: 'Save topic'))
                        } else if (isEdit) {
                            mb.input(type: 'submit', class: 'forum-post-button', name: '_action_previewMessageEdit', value: message(code: 'forum.reply.preview', default: 'Preview'))
                            mb.input(type: 'submit', class: 'forum-post-button', name: '_action_updateTopicMessage', value: message(code: 'forum.reply.comment', default: 'Update'))
                        } else {
                            mb.input(type: 'submit', class: 'forum-post-button', name: '_action_previewMessage', value: message(code: 'forum.reply.preview', default: 'Preview'))
                            mb.input(type: 'submit', class: 'forum-post-button', name: '_action_saveNewTopicMessage', value: message(code: 'forum.reply.comment', default: 'Reply'))
                        }

                        if (!newPost && !isEdit) {
                            if (topic.topicType == ForumTopicType.Question && !topic.isAnswered) {
                                String buttonLabel = "${message(code: 'forum.project.reply.comment.answered', default: 'Reply and mark as ')}"
                                buttonLabel += "<div class=\"badge badge--answered\">Answered</div>"
                                mb.button(type: 'submit', class: 'forum-post-button', name: '_action_saveNewTopicMessageAnswered') {
                                    mkp.yieldUnescaped(buttonLabel)
                                }
                            }
                        }
                    }
                }
            }
 */
        }

    }

    def forumTopicHeader = {attrs, body ->
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

        def isModerator = userService.isAdmin() ?: userService.isUserForumModerator(userService.currentUser, projectInstance)

        // Construct the breadcrumbs
        pageScope.crumbs = []
        pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index'), label: message(code: "default.forum.label", default: "Forum")]
        if (projectInstance) {
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index', params: [projectId: projectInstance.id]), label: message(code: 'forum.project.forum', default: 'Expedition Forum')]
        } else if (taskInstance) {
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index', params: [projectId: taskInstance.project.id]), label: message(code: 'forum.project.forum', default: 'Expedition Forum')]
        }

        if (attrs.lastLabel) {
            if (topic) {
                pageScope.crumbs << [link: createLink(controller: 'forum', action: 'viewForumTopic', id: topic.id), label: topic.title]
            }
        }

        // Render the header
        def mb = new MarkupBuilder(out)
        String pageTitle = attrs.title
        if (topic) {
            pageTitle = topic.title as String
        }

        def topicTypeStyle = topic ? topic.topicType.name().toLowerCase() : ForumTopicType.Discussion.name().toLowerCase()

        def returnButton = {
            def params = projectInstance ? [projectId: projectInstance?.id] : [:]
            def returnLink = createLink(controller: 'forum', action: 'index', params: params)
            mb.a(href: returnLink, class: "btn btn-sm btn-outline-secondary ms-auto") {
                i(class: "fa fa-arrow-left me-1", style: "display: inline-flex;") {
                    mkp.yieldUnescaped("&nbsp;")
                }
                mkp.yield("Return to forum")
            }
        }

        def modActionButton = {
            mb.button([class: "btn btn-sm btn-outline-secondary ms-auto dropdown-toggle", type: "button", id: "forumTopicModActionsDropdown", 'data-bs-toggle': "dropdown", 'aria-expanded': "false"]) {
                mkp.yield("Moderator Actions")
            }
            def noActions = true
            mb.ul(class: "dropdown-menu") {
                if (topic && topic.topicType == ForumTopicType.Question && !topic.isAnswered) {
                    li() {
                        a(class: "dropdown-item", href: createLink(controller: 'forum', action: 'toggleTopicAnswered', id: topic.id, params: [answered: true])) {
                            mkp.yield("Set topic as Answered")
                        }
                    }
                    noActions = false
                } else if (topic && topic.topicType == ForumTopicType.Question && topic.isAnswered) {
                    li() {
                        a(class: "dropdown-item", href: createLink(controller: 'forum', action: 'toggleTopicAnswered', id: topic.id, params: [answered: false])) {
                            mkp.yield("Set topic as Unanswered")
                        }
                    }
                    noActions = false
                }
                if (userService.isAdmin() && topic) {
                    li() {
                        a(class: "dropdown-item", href: createLink(controller: 'forum', action: 'toggleTopicLocked', id: topic.id, params: [locked: !topic.locked])) {
                            mkp.yield(topic.locked ? "Unlock topic" : "Lock topic")
                        }
                    }
                    noActions = false
                }
                if (noActions) {
                    li() {
                        a(class: "dropdown-item disabled", href: "#") {
                            mkp.yield("No actions available")
                        }
                    }
                }
            }
        }

        mb.div(class: "card border-0 shadow-sm bg-white px-4 py-2 mb-4 mt-2") {
            div(class: "d-flex align-items-center gap-2 my-2") {
                if (topic || taskInstance || projectInstance) {
                    if (topic) {
                        if (topic?.isAnswered) {
                            span(class: "badge badge--answered border-answered rounded px-2.5 py-1.5 text-uppercase font-monospace") {
                                mkp.yield(topic ? "Answered" : ForumTopicType.Discussion.name())
                            }
                        } else {
                            span(class: "badge badge--${topicTypeStyle} border-${topicTypeStyle} rounded px-2.5 py-1.5 text-uppercase font-monospace") {
                                mkp.yield(topic ? topic.topicType.name() : ForumTopicType.Discussion.name())
                            }
                        }
                    }

                    if (taskInstance || projectInstance) {
                        small(class: "text-muted") {
                            span(class: "fw-medium text-dark") {
                                mkp.yield(taskInstance ? taskInstance.project.name : projectInstance.name)
                            }
                        }
                    }

                    returnButton()
                }
            }

            div(class: "d-flex align-items-center justify-content-between w-100") {
                h1(class: "h4 fw-bold text-dark mb-0 d-inline-flex align-items-center gap-2 flex-wrap me-2") {
                    if (topic?.locked) {
                        span(class: "btn btn-sm btn-outline-secondary py-1 d-inline-flex align-items-center gap-1") {
                            mkp.yieldUnescaped("<i class=\"fa fa-lock\" title=\"Topic is locked\" aria-label=\"Topic is locked\"></i>")
                        }
                    }
                    span() {
                        mkp.yieldUnescaped(pageTitle)
                    }
                    // External link icon
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
                        a(href: link, class: "text-muted small", target: "_blank", title: title) {
                            i(class: "fa fa-external-link fs-6", style: "display: inline-flex;") {
                                mkp.yieldUnescaped("&nbsp;")
                            }
                        }
                    }
                }

                if (!topic && !taskInstance && !projectInstance) {
                    returnButton()
                } else if (topic) {
                    modActionButton()
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
        pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index'), label: message(code: "default.forum.label", default: "Forum")]
        if (projectInstance) {
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index', params: [projectId: projectInstance.id]), label: message(code: 'forum.project.forum', default: 'Expedition Forum')]
        } else if (taskInstance) {
            pageScope.crumbs << [link: createLink(controller: 'forum', action: 'index', params: [projectId: taskInstance.project.id]), label: message(code: 'forum.project.forum', default: 'Expedition Forum')]
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
                        mkp.yieldUnescaped("<img src='${resource(dir: 'images', file: 'external_link.svg')}' alt='Open in new window' />")
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
     * Creates a button to create or view a forum topic for a task.
     * @attr task the task to create a topic for
     * @attr label the label for the button
     * @attr class the CSS class for the button
     * @attr style the CSS style for the button
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
     * Prints a list of projects for a select form element along with the number of topics linked to that project
     * grouped into institution.
     * @attr projectFilterList list of projects. Expects the following properties: [projectId, institutionName, projectName, topicCount]
     * @attr currentSelectedProject the ID of the project that is currently selected so that the select can display this project as the currently displayed option.
     */
    def projectSelectOptions = { attrs ->
        def institution = ""
        def output = "<option value>- Select an Expedition -</option>"
        def currentSelectedProject = attrs.currentSelectedProject ? attrs.currentSelectedProject as Long : null

        attrs.projectFilterList.each { Map row ->
            long projectId = currentSelectedProject ? row.projectId as long : 0L
            if (institution != row.institutionName) {
                institution = row.institutionName
                if (output.length() > 0) output += "</optgroup>"
                output += "<optgroup label='${institution}'>"
            }

            def option = "<option value='${row.projectId}' ${currentSelectedProject == row.projectId ? 'selected' : ''}>${row.projectName}</option>"
            output += option
        }

        out << output
    }
}
