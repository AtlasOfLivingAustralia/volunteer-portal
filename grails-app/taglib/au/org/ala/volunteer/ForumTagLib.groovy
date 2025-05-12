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

            def option = "<option value='${row.projectId}' ${currentSelectedProject == row.projectId ? 'selected' : ''}>${row.projectName} (${row.topicCount} topics)</option>"
            output += option
        }

        out << output
    }
}
