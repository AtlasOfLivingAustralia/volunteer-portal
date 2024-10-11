package au.org.ala.volunteer

import grails.testing.gorm.DataTest
import grails.testing.web.controllers.ControllerUnitTest

//import grails.test.mixin.*
import spock.lang.*

//@TestFor(LabelController)
//@Mock(Label)
class LabelControllerSpec extends Specification implements ControllerUnitTest<LabelController>, DataTest {

    boolean admin = true

    def setup() {
        mockDomain(Label)
        mockDomain(LabelCategory)

        def userServiceStub = Stub(UserService) {
            isAdmin() >> admin
            currentUser >> new User([id: 123L])
        }
        controller.userService = userServiceStub

        def labelAdminServiceStub = Stub(LabelAdminService) {
            isLabelInUse(_) >> true
            getLabelUsage(_) >> [:]
        }
        controller.labelAdminService = labelAdminServiceStub
    }

    def populateValidLCParams(params) {
        assert params != null
        params['name'] = 'name'
        params['updatedDate'] = new Date()
        params['createdBy'] = 0L
    }

    void "Test the index action returns the correct model"() {
        when:"The index action is executed"
            controller.index()

        then:"The model is correct"
            !model.labelInstanceList
            model.labelInstanceCount == 0
    }

    def "Test a user without Admin permission cannot save a message"() {
        given:"The user is not a site admin"
        def userServiceStub = Stub(UserService) {
            isAdmin() >> false
            currentUser >> new User([id: 123L])
        }

        and:"The spy service is set on the controller"
        controller.userService = userServiceStub

        when:"The save action is executed with a valid instance"
        request.contentType = FORM_CONTENT_TYPE
        request.method = 'POST'

        controller.saveNewLabel()

        then: "User is redirected to the home page"
        view == "/notPermitted"
    }

    def "Test a category can be created"() {
        when:"The save action is executed with an invalid instance"
        request.contentType = FORM_CONTENT_TYPE
        request.method = 'POST'
//        def labelCategory = new LabelCategory()
        controller.saveCategory()

        then:"The index view is rendered again with the correct model"
        view == '/label/createCategory'

//        when:"The save action is executed with a valid instance"
//        response.reset()
//        populateValidLCParams(params)
////        labelCategory = new LabelCategory(params as Map)
//        controller.saveCategory()
//
//        then:"A redirect is issued to the category action"
//        response.redirectedUrl == '/admin/label/index'
//        controller.flash.message != null
    }
}
