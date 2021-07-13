package au.org.ala.volunteer

import grails.test.mixin.Mock
import grails.test.mixin.TestFor
import spock.lang.Specification

@TestFor(ProjectController)
@Mock(Project)
class ProjectControllerSpec extends Specification {

    boolean admin = false

    void setup() {
        def userServiceStub = Stub(UserService) {
            isAdmin() >> admin
        }

        def projectServiceStub = Stub(ProjectService) {
            isAdminForProject(_) >> admin
        }

        controller.userService = userServiceStub
        controller.projectService = projectServiceStub
    }

    def "Test a user without Admin permission cannot update a project"() {
        when:"The update action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'

            controller.update()

        then: "User is redirected to the home page"
            response.redirectedUrl == "/"
    }

    def "Test a user without Admin permission cannot delete a project"() {
        when:"The delete action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'

            controller.delete()

        then: "User is redirected to the home page"
            response.redirectedUrl == "/"
    }

    def "Test a user without admin permission cannot call WizardAutosave"() {
        when:"The wizardAutosave action is executed with a valid ID"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'
            String id = "ABCDEF"

            controller.wizardAutosave(id)

        then: "User is redirected to the home page"
            response.status == 403
    }

    def "Test a user without admin permission cannot call WizardImageUpload"() {
        when:"The wizardImageUpload action is executed with a valid ID"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'
            String id = "ABCDEF"

            controller.wizardImageUpload(id)

        then: "User is redirected to the home page"
            response.status == 403
    }

    def "Test a user without admin permission cannot call WizardClearImage"() {
        when:"The wizardClearImage action is executed with a valid ID"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'
            String id = "ABCDEF"

            controller.wizardClearImage(id)

        then: "User is redirected to the home page"
            response.status == 403
    }
}
