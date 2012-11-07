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
    def topicTable = { attrs, body ->

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

}
