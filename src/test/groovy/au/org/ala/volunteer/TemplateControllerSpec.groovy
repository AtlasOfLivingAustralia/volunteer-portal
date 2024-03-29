package au.org.ala.volunteer

import grails.testing.gorm.DataTest
import grails.testing.web.controllers.ControllerUnitTest

//import grails.test.mixin.Mock
//import grails.test.mixin.TestFor
import spock.lang.Specification

//@TestFor(TemplateController)
//@Mock(Template)
class TemplateControllerSpec extends Specification implements ControllerUnitTest<TemplateController>, DataTest {

    boolean admin = false

    void setup() {
        mockDomain(Template)
        def userServiceStub = Stub(UserService) {
            isAdmin() >> admin
        }

        controller.userService = userServiceStub
    }

    def "Test a user without Admin permission cannot save a template"() {
        when:"The save action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'

            controller.save()

        then: "User is redirected to the home page"
            view == "/notPermitted"
    }

    def "Test a user without Admin permission cannot update a template"() {
        when:"The update action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'

            controller.update()

        then: "User is redirected to the home page"
            view == "/notPermitted"
    }

    def "Test a user without Admin permission cannot clone a template"() {
        when:"The cloneTemplate action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'

            controller.cloneTemplate()

        then: "User is redirected to the home page"
            view == "/notPermitted"
    }
}
