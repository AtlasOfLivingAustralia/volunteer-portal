package au.org.ala.volunteer

import grails.testing.services.ServiceUnitTest
import groovy.util.logging.Slf4j
import spock.lang.Specification

@Slf4j
class MarkdownServiceSpec extends Specification implements ServiceUnitTest<MarkdownService>{

    SanitizerService sanitizerService

    def setup() {

    }

    def cleanup() {
    }

    void "test render markdown"() {
        given:
            def markdown = "This is **Sparta**"
            def genHtml = "<p>This is <strong>Sparta</strong></p>\n"
            sanitizerService = Mock(SanitizerService)
            service.sanitizerService = sanitizerService

        when:
            def output = service.renderMarkdown(markdown)

        then:
            1 * sanitizerService.sanitize(genHtml) >> "<p>This is <strong>Sparta</strong></p>\n"
            log.info("Output: ${output}")
            output == "<p>This is <strong>Sparta</strong></p>\n"
    }

    void "test sanitize markdown"() {
        given:
            def markdown = "This is<script>alert(1);</script> **Sparta**"
            def genHtml = "<p>This is<script>alert(1);</script> <strong>Sparta</strong></p>\n"
            sanitizerService = Mock(SanitizerService)
            service.sanitizerService = sanitizerService

        when:
            def output = service.sanitizeMarkdown(markdown)

        then:
            1 * sanitizerService.sanitize(genHtml) >> "<p>This is <strong>Sparta</strong></p>\n"
            log.info("Output: ${output}")
            output == "This is **Sparta**\n"
    }
}
