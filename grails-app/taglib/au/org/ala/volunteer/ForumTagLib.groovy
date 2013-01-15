package au.org.ala.volunteer

import groovy.xml.MarkupBuilder

class ForumTagLib {

    static namespace = 'vpf'

    def authService
    def userService
    def forumService
    def markdownService

    /**
     * @param project
     */
    def ifModerator = { attrs, body ->
        if (userService.isForumModerator(attrs.project as Project) ) {
            out << body()
        }
    }

    /**
     * @param topic
     */
    def topicMessagesTable = { attrs, body ->

        def topic = attrs.topic as ForumTopic

        if (topic) {

            def replies = forumService.getTopicMessages(topic, params)

            def mb = new MarkupBuilder(out)
            boolean striped = false

            mb.table(class:'forum-table') {
                thead {
                    tr {
                        th { mkp.yield(topic.title) }
                        th { mkp.yield("${replies.size() - 1} replies") }
                    }
                }
                tbody {
                    replies.each { reply ->
                        tr(class: striped ? 'striped' : '') {
                            td(class:"forumNameColumn") {
                                span(class:'forumUsername') {
                                    mkp.yield(reply.user.displayName)
                                }
                                br {}
                                span(class:'forumMessageDate') {
                                    mkp.yield(formatDate(date: reply.date, format: 'dd MMM, yyyy HH:mm:ss'))
                                }
                            }
                            td { mkp.yieldUnescaped(markdownService.markdown(reply.text)) }
                        }
                        striped = !striped
                    }
                }
            }
        }
    }

    /**
     * @attr topics
     */
    def topicTable = { attrs, body ->
        def topics = attrs.topics as List<ForumTopic>
        def paginateAction = "generalDiscussion"

        Project projectInstance = null
        if (topics.size() > 0) {
            def first = topics[0] as ForumTopic
            if (first) {
                if (first.instanceOf(ProjectForumTopic)) {
                    projectInstance = (first as ProjectForumTopic).project
                    paginateAction = 'projectForum'
                } else if (first.instanceOf(TaskForumTopic)) {
                    projectInstance = (first as TaskForumTopic).task?.project
                    paginateAction = 'taskForum'
                }
            }
        }

        def topicCounts = [:]
        topics.each { topic ->
            def replyCount = ForumMessage.countByTopic(topic)
            topicCounts[topic] = replyCount
        }

        def mb = new MarkupBuilder(out)
        boolean striped = false

        mb.div(class: 'topicTable') {
            table(class: "forum-table") {
                thead {
                    tr {
                        th(colspan:'2') {
                            mkp.yield("Topic")
                        }
                        th {
                            mkp.yield("Replies")
                        }
                        th {
                            mkp.yield("Views")
                        }
                        th {
                            mkp.yield("Posted by")
                        }
                        th {
                            mkp.yield("Posted")
                        }
                        th {
                            mkp.yield("Last reply")
                        }
                        th {
                            mkp.yield("")
                        }
                    }
                }
                tbody {
                    if (topics.size() == 0) {
                        tr {
                            td(colspan:'7') {
                                mkp.yield("There are no topics in this forum yet.")
                            }
                        }
                    } else {
                        for (ForumTopic topic : topics) {
                            tr(class:"${topic.priority}${topic.sticky ? ' sticky' : ''}", topicId:topic.id) {
                                td(style:'width: 20px; padding: 0px') {
                                    if (topic.sticky) {
                                        img(src:resource(dir:'images', file:'forum_sticky_topic.png')) {}
                                    }
                                }
                                td{
                                    a(href:createLink(controller:'forum', action:'viewForumTopic', id:topic.id)) {
                                        mkp.yield(topic.title)
                                    }
                                }
                                td {
                                   mkp.yield(topicCounts[topic] - 1)
                                }
                                td {
                                    mkp.yield(topic.views ?: 0)
                                }
                                td {
                                    mkp.yield(topic.creator?.displayName)
                                }
                                td {
                                    mkp.yield(formatDate(date: topic.dateCreated, format: DateConstants.DATE_TIME_FORMAT))
                                }
                                td {
                                    mkp.yield(formatDate(date: topic.lastReplyDate, format: DateConstants.DATE_TIME_FORMAT))
                                }
                                td {
                                    a(class:'button', href:createLink(controller:'forum', action:'postMessage', params:[topicId: topic.id])) {
                                        mkp.yield("Reply")
                                    }
                                    if (userService.isForumModerator(projectInstance)) {
                                        a(class:'button', href:createLink(controller: 'forum', action:'editTopic', params:[topicId: topic.id])) {
                                            mkp.yield("Edit")
                                        }
                                        a(class:'button', href:createLink(controller: 'forum', action:'deleteTopic', params:[topicId: topic.id])) {
                                            mkp.yield("Delete")
                                        }

                                    }
                                }

                            }
                        }
                    }
                }
            }
            div(class:'paginateButtons') {
                mkp.yieldUnescaped(paginate(total: topics.totalCount, action: paginateAction, params: params))
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

        mb.nav(id:'breadcrumb') {
            ol {
                if (projectInstance) {
                    li {
                        a(href:createLink(controller: 'project', action: 'index', id: projectInstance.id)) {
                            mkp.yield(projectInstance.featuredLabel)
                        }
                    }
                    li {
                        a(href:createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectInstance.id])) {
                            mkp.yield(message(code:'forum.project.forum', default:'Project Forum'))
                        }
                    }
                }
                if (!projectInstance && !taskInstance) {
                    li {
                        a(href:createLink(controller: 'forum', action:'index')) {
                            mkp.yield(message(code:"default.forum.label", default:"Forum"))
                        }
                    }
                    li {
                        a(href:createLink(controller: 'forum', action:'generalDiscussion')) {
                            mkp.yield(message(code:"default.generaldiscussion.label", default:"General Discussion"))
                        }
                    }
                }
                if (attrs.lastLabel) {
                    if (topic) {
                        li {
                            a(href:createLink(controller: 'forum', action:'viewForumTopic', id :topic.id)) {
                                mkp.yield(topic.title)
                            }
                        }
                    }
                    li(class:'last') {
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
                    mkp.yield(message(code:'forum.taskTopic.heading', default:'Task Topic - {0}', args: [taskInstance.externalIdentifier]))
                }
                if (projectInstance) {
                    mkp.yield(message(code:'forum.projectTopic.heading', default:'{0} Forum Topic - {1}', args: [projectInstance.featuredLabel, topic.title]))
                }
                if (!projectInstance && !taskInstance) {
                    mkp.yield(message(code:'forum.generalDiscussionTopic.heading', default:'General Discussion Topic - {0}', args: [topic.title]))
                }
            }
        }

    }

}
