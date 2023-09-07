package au.org.ala.volunteer

import grails.testing.web.interceptor.InterceptorUnitTest


//import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.web.ControllerUnitTestMixin} for usage instructions
 */
//@TestFor(AchievementsInterceptor)
class AchievementsInterceptorSpec extends Specification implements InterceptorUnitTest<AchievementsInterceptor> {

    def setup() {
    }

    def cleanup() {

    }

    void "Test achievements interceptor matching"() {
        when:"A request matches the interceptor"
            withRequest(controller:"achievements")

        then:"The interceptor does match"
            interceptor.doesMatch()
    }
}
