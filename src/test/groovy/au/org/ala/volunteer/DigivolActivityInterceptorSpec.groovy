package au.org.ala.volunteer


import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.web.ControllerUnitTestMixin} for usage instructions
 */
@TestFor(DigivolActivityInterceptor)
class DigivolActivityInterceptorSpec extends Specification {

    def setup() {
    }

    def cleanup() {

    }

    void "Test AjaxController interceptor matching"() {
        when:"A request matches the interceptor"
            withRequest(controller:"ajax")

        then:"The interceptor does match"
            interceptor.doesMatch() == false
    }

    void "Test unreadValidatedTasks interceptor matching"() {
        when:"A request matches the interceptor"
        withRequest(controller:"user", action: 'unreadValidatedTasks')

        then:"The interceptor does match"
        interceptor.doesMatch() == false
    }
}
