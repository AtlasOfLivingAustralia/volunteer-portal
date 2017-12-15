package au.org.ala.volunteer

import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
@TestFor(SanitizerService)
class SanitizerServiceSpec extends Specification {

    def setup() {
    }

    def cleanup() {
    }

    void "test scripts are removed"() {
        when:
        def html = service.sanitize("<p>hello<script>alert(1);</script></p>")
        then:
        html == '<p>hello</p>'
    }
}
