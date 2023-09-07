package au.org.ala.volunteer

import grails.testing.services.ServiceUnitTest

//import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
//@TestFor(FreemarkerService)
class FreemarkerServiceSpec extends Specification implements ServiceUnitTest<FreemarkerService> {

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
        def t1 = service.getTemplate(templateText)
        def t2 = service.getTemplate(templateText)

        assertTrue(t1.is(t2))
    }
}
