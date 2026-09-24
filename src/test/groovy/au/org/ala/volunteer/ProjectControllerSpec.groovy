package au.org.ala.volunteer

import grails.testing.gorm.DataTest
import grails.testing.web.controllers.ControllerUnitTest

//import grails.test.mixin.Mock
//import grails.test.mixin.TestFor
import spock.lang.Specification

//@TestFor(ProjectController)
//@Mock(Project)
class ProjectControllerSpec extends Specification implements ControllerUnitTest<ProjectController>, DataTest {

    boolean admin = false

    void setup() {
        mockDomain(Project)
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
            view == "/notPermitted"
    }

    def "Test a user without Admin permission cannot delete a project"() {
        when:"The delete action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'

            controller.delete()

        then: "User is redirected to the home page"
            view == "/notPermitted"
    }






}
