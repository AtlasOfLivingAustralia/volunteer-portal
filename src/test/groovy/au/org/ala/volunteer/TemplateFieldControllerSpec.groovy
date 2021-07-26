package au.org.ala.volunteer

import grails.test.mixin.Mock
import grails.test.mixin.TestFor
import spock.lang.Specification

@TestFor(TemplateFieldController)
@Mock(TemplateField)
class TemplateFieldControllerSpec extends Specification {

    boolean admin = false

    void setup() {
        def userServiceStub = Stub(UserService) {
            isAdmin() >> admin
        }

        controller.userService = userServiceStub
    }

    def "Test a user without Admin permission cannot save a template field"() {
        when:"The save action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'

            controller.save()

        then: "User is redirected to the home page"
            view == "/notPermitted"
    }

    def "Test a user without Admin permission cannot update a template field"() {
        when:"The update action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'

            controller.update()

        then: "User is redirected to the home page"
            view == "/notPermitted"
    }

    def "Test a user without Admin permission cannot delete a template field"() {
        when:"The delete action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'

            controller.delete()

        then: "User is redirected to the home page"
            view == "/notPermitted"
    }
}
