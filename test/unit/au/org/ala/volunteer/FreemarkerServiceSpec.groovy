package au.org.ala.volunteer

import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
@TestFor(FreemarkerService)
class FreemarkerServiceSpec extends Specification {

    def freemarkerService

    def setup() {
    }

    def cleanup() {
    }

    void "test same instance from same script"() {
        def templateText = '''{
  "constant_score": {
    "filter": {
          "term":  { "fullyTranscribedBy": "${userId}" }
    }
  }
}'''
        def t1 = freemarkerService.getTemplate(templateText)
        def t2 = freemarkerService.getTemplate(templateText)

        assertTrue(t1 == t2)
    }
}
