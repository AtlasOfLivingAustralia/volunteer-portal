package au.org.ala.volunteer

import groovy.xml.MarkupBuilder

class ForumTagLib {

    static namespace = 'vpf'

    def authService
    def userService
    def forumService

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

            mb.table(class:'forum-table') {
                thead {
                    tr {
                        th { mkp.yield(topic.title) }
                        th { mkp.yield("${replies.size()} replies") }
                    }
                }
                tbody {
                    tr {
                        td {
                            mkp.yield(topic.creator.displayName)
                            br {}
                            mkp.yield(formatDate(date: topic.dateCreated, format: 'dd MMM, yyyy HH:mm:ss'))
                        }

                        td { mkp.yield(topic.text) }
                    }
                }
            }
        }
    }

}
