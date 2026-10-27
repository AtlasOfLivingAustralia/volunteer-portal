package au.org.ala.volunteer

import grails.testing.web.taglib.TagLibUnitTest
import spock.lang.Specification

class ForumTagLibSpec extends Specification implements TagLibUnitTest<ForumTagLib> {

    def setup() {
        tagLib.userService = Stub(UserService) {
            detailsForUserId(_ as String) >> [displayName: 'Chris Dunstall (AM)']
            isAdmin() >> false
            isUserForumModerator(_ as User, _ as Project) >> false
        }
        tagLib.markdownService = Mock(MarkdownService)

        // Minimal stand-in for the core taglib used by gravatarImage call in preview rendering.
        tagLib.metaClass.getCl = {
            [gravatarImage: { Map args -> '' }]
        }
        tagLib.metaClass.formatDate = { Map args -> 'now' }
    }

    void "messagePreview does not inject hard-break markdown for quoted previews"() {
        given:
        def user = new User(userId: '123')
        def quotedMarkdown = '> Chris Dunstall (AM) wrote:\n>\n> Hah!\n>\n> No way!'

        when:
        tagLib.messagePreview.call([user: user, messageText: quotedMarkdown, isQuotedReply: 'true'], {})

        then:
        1 * tagLib.markdownService.renderMarkdown(quotedMarkdown) >> '<blockquote><p>Quoted</p></blockquote>'
    }

    void "messagePreview keeps existing hard-break behavior for non-quoted previews"() {
        given:
        def user = new User(userId: '123')
        def markdown = "line one\nline two"

        when:
        tagLib.messagePreview.call([user: user, messageText: markdown, isQuotedReply: 'false'], {})

        then:
        1 * tagLib.markdownService.renderMarkdown("line one  \nline two") >> '<p>line one<br/>line two</p>'
    }
}





