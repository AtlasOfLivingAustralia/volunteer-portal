package au.org.ala.volunteer

import grails.testing.gorm.DataTest
import grails.testing.web.controllers.ControllerUnitTest

//import grails.test.mixin.Mock
//import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.web.ControllerUnitTestMixin} for usage instructions
 */
//@TestFor(InstitutionMessageController)
//@Mock([InstitutionMessage, Institution, MessageRecipient])
class InstitutionMessageControllerSpec extends Specification implements ControllerUnitTest<InstitutionMessageController>, DataTest {

    boolean admin = false
    long institutionId = 123456789L
    long userId = 38462921L

    def setup() {
        mockDomains(InstitutionMessage, Institution, MessageRecipient)
        config.grails.serverURL = "/"

        def userServiceStub = Stub(UserService) {
            isAdmin() >> false
//            getAdminInstitutionList() >> []
        }
        controller.userService = userServiceStub

        def institutionMessageServiceStub = Stub(InstitutionMessageService) {
            sendMessage(_) >> 0
        }

        controller.institutionMessageService = institutionMessageServiceStub

//        controller.metaClass.getFormInfo = { ->
//            return [recipientTypeList: [], institutionSelectList: []]
//        }
    }

//    def populateValidParams(params) {
//        assert params != null
//        params['institution'] = institutionId
//        params['body'] = 'value'
//        params['subject'] = 'subject'
//        params['includeContact'] = 'on'
//        params['recipientType'] = 'user'
//        params['recipient'] = userId
//    }

    def "Test a user without Admin permission cannot save a message"() {
        when:"The save action is executed with a valid instance"
        request.contentType = FORM_CONTENT_TYPE
        request.method = 'POST'

        controller.save()

        then: "User is redirected to the home page"
        view == "/notPermitted"
    }

    def "Test a user without Admin permission cannot access the message admin"() {
        when:"The index action is executed with a valid instance"
            controller.index()

        then: "User is redirected to the home page"
        view == "/notPermitted"
    }

    def "Test a user without Admin permission cannot update a message"() {
        when:"The update action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'

            controller.update()

        then: "User is redirected to the home page"
        view == "/notPermitted"
    }

    def "Test a user without Admin permission cannot delete a message"() {
        when:"The delete action is executed with a valid instance"
        controller.delete()

        then: "User is redirected to the home page"
        view == "/notPermitted"
    }

}
