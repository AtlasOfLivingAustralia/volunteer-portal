package au.org.ala.volunteer

import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class ForumControllerSpec extends Specification implements ControllerUnitTest<ForumController> {

    def setup() {
        controller.forumService = Stub(ForumService) {
            isUserWatchingTopic(_ as User, _ as ForumTopic) >> false
        }
        controller.userService = Stub(UserService) {
            getCurrentUser() >> null
        }
        controller.markdownService = Mock(MarkdownService)
    }

    void "previewMessageEdit skips markdown sanitization for quoted reply preview"() {
        given:
        GroovyMock(ForumMessage, global: true)
        def topic = Stub(ForumTopic) {
            getTitle() >> 'Topic title'
        }
        def message = Stub(ForumMessage) {
            getTopic() >> topic
        }
        ForumMessage.get(_ as Integer) >> message
        params.messageId = '1'
        params.messageText = '> Chris wrote:\n>\n> Hah!'
        params.isQuotedReply = 'true'

        when:
        controller.previewMessageEdit()

        then:
        0 * controller.markdownService.sanitizeMarkdown(_)
        view == '/forum/editMessage'
        model.messageText == params.messageText
    }

    void "previewMessageEdit sanitizes markdown for non-quoted preview"() {
        given:
        GroovyMock(ForumMessage, global: true)
        def topic = Stub(ForumTopic) {
            getTitle() >> 'Topic title'
        }
        def message = Stub(ForumMessage) {
            getTopic() >> topic
        }
        ForumMessage.get(_ as Integer) >> message
        params.messageId = '1'
        params.messageText = 'Plain text'
        params.isQuotedReply = 'false'

        when:
        controller.previewMessageEdit()

        then:
        1 * controller.markdownService.sanitizeMarkdown('Plain text') >> 'Sanitized text'
        view == '/forum/editMessage'
        model.messageText == 'Sanitized text'
    }

    void "previewMessageEdit skips sanitization when quote markdown is detected"() {
        given:
        GroovyMock(ForumMessage, global: true)
        def topic = Stub(ForumTopic) {
            getTitle() >> 'Topic title'
        }
        def message = Stub(ForumMessage) {
            getTopic() >> topic
        }
        ForumMessage.get(_ as Integer) >> message
        params.messageId = '1'
        params.messageText = '> Chris Dunstall (AM) wrote:\n>\n> Hah!'
        params.isQuotedReply = 'false'

        when:
        controller.previewMessageEdit()

        then:
        0 * controller.markdownService.sanitizeMarkdown(_)
        view == '/forum/editMessage'
        model.messageText == params.messageText
        model.isQuotedReply == true
    }
}






