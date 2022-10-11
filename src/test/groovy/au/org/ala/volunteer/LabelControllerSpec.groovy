package au.org.ala.volunteer

import grails.test.mixin.*
import spock.lang.*

@TestFor(LabelController)
@Mock(Label)
class LabelControllerSpec extends Specification {

    boolean admin = true

    def setup() {
        controller.userService = Stub(UserService)
        controller.userService.isAdmin(_) >> { admin }
    }

    def populateValidParams(params) {
        assert params != null
        params['category'] = 'category'
        params['value'] = 'value'
    }

    void "Test the index action returns the correct model"() {

        when:"The index action is executed"
            controller.index()

        then:"The model is correct"
            !model.labelInstanceList
            model.labelInstanceCount == 0
    }

    void "Test the save action correctly persists an instance"() {

        when:"The save action is executed with an invalid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'
            def label = new Label()
            label.validate()
            controller.save(label)

        then:"The index view is rendered again with the correct model"
            model.labelInstance!= null
            view == 'index'

        when:"The save action is executed with a valid instance"
            response.reset()
            populateValidParams(params)
            label = new Label(params)

            controller.save(label)

        then:"A redirect is issued to the show action"
            response.redirectedUrl == '/admin/label/index'
            controller.flash.message != null
            Label.count() == 1
    }

    void "Test the update action performs an update on a valid domain instance"() {
        when:"Update is called for a domain instance that doesn't exist"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'PUT'
            controller.update(null)

        then:"A 404 error is returned"
            response.redirectedUrl == '/admin/label/index'
            flash.message != null


        when:"An invalid domain instance is passed to the update action"
            response.reset()
            def label = new Label()
            label.validate()
            controller.update(label)

        then:"The edit view is rendered again with the invalid instance"
            view == 'index'
            model.labelInstance == label

        when:"A valid domain instance is passed to the update action"
            response.reset()
            populateValidParams(params)
            label = new Label(params).save(flush: true)
            controller.update(label)

        then:"A redirect is issues to the show action"
            response.redirectedUrl == "/admin/label/index"
            flash.message != null
    }

    void "Test that the delete action deletes an instance if it exists"() {
        when:"The delete action is called for a null instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'
            controller.delete(null)

        then:"A 404 is returned"
            response.redirectedUrl == '/admin/label/index'
            flash.message != null

        when:"A domain instance is created"
            response.reset()
            populateValidParams(params)
            def label = new Label(params).save(flush: true)

        then:"It exists"
            Label.count() == 1

        when:"The domain instance is passed to the delete action"
            controller.delete(label)

        then:"The instance is deleted"
            Label.count() == 0
            response.redirectedUrl == '/admin/label/index'
            flash.message != null
    }

    void "Test a user without Admin permission cannot save a label"() {
        given:"The Collaborating service is a spy"
            def userServiceStub = Stub(UserService) {
                isAdmin() >> false
            }

        and:"The spy service is set on the controller"
            controller.userService = userServiceStub

        when:"The save action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'
            populateValidParams(params)
            def label = new Label(params)
            controller.save(label)

        then: "A 403 status is returned (forbidden)"
            response.status == 403
    }

    void "Test a user without Admin permission cannot update a label"() {
        given:"The Collaborating service is a spy"
            def userServiceStub = Stub(UserService) {
                isAdmin() >> false
            }

        and:"The spy service is set on the controller"
            controller.userService = userServiceStub

        when:"The update action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'PUT'
            def label = new Label(category: 'category', value: 'value').save(flush: true)
            controller.update(label)

        then: "A 403 status is returned (forbidden)"
            response.status == 403
    }

    void "Test a user without Admin permission cannot delete a label"() {
        given:"The Collaborating service is a spy"
            def userServiceStub = Stub(UserService) {
                isAdmin() >> false
            }

        and:"The spy service is set on the controller"
            controller.userService = userServiceStub

        when:"The delete action is executed with a valid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'
            populateValidParams(params)
            def label = new Label(params)
            controller.delete(label)

        then: "A 403 status is returned (forbidden)"
            response.status == 403
    }
}
