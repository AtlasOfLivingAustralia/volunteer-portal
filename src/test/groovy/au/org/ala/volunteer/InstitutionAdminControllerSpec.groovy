package au.org.ala.volunteer



import grails.test.mixin.*
import spock.lang.*

@TestFor(InstitutionAdminController)
@Mock([Institution, Project])
class InstitutionAdminControllerSpec extends Specification {

    def populateValidParams(params) {
        assert params != null
        // TODO: Populate valid properties like...
        //params["name"] = 'someValidName'
        params['name'] = 'name'
        params['contactName'] = 'contactName'
        params['contactEmail'] = 'contact@email.com'
        params['contactPhone'] = 'contactPhone'
        params['collectoryUid'] = 'collectoryUid'
        params['shortDescription'] = 'shortDescription'
        params['description'] = 'description'
        params['acronym'] = 'ACR'
        params['websiteUrl'] = 'http://website.url'
        params['imageCaption'] = 'imageCaption'
        params['themeColour'] = '#000000'
    }

    void "Test the index action returns the correct model"() {

        when:"The index action is executed"
            controller.index()

        then:"The model is correct"
            !model.institutionInstanceList
            model.institutionInstanceCount == 0
    }

    void "Test the create action returns the correct model"() {
        when:"The create action is executed"
            controller.create()

        then:"The model is correctly created"
            model.institutionInstance!= null
    }

    void "Test the save action correctly persists an instance"() {

        when:"The save action is executed with an invalid instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'POST'
            def institution = new Institution()
            institution.validate()
            controller.save(institution)

        then:"The create view is rendered again with the correct model"
            model.institutionInstance!= null
            view == 'create'

        when:"The save action is executed with a valid instance"
            response.reset()
            populateValidParams(params)
            institution = new Institution(params)

            controller.save(institution)

        then:"A redirect is issued to the show action"
            response.redirectedUrl == '/admin/institutions/edit/1'
            Institution.count() == 1
    }

    void "Test that the edit action returns the correct model"() {
        when:"The edit action is executed with a null domain"
            controller.edit(null)

        then:"A 404 error is returned"
            response.status == 404

        when:"A domain instance is passed to the edit action"
            populateValidParams(params)
            def institution = new Institution(params)
            controller.edit(institution)

        then:"A model is populated containing the domain instance"
            model.institutionInstance == institution
    }

    void "Test the update action performs an update on a valid domain instance"() {
        when:"Update is called for a domain instance that doesn't exist"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'PUT'
            controller.update(null)

        then:"A 404 error is returned"
            response.redirectedUrl == '/admin/institutions/index'
            flash.message != null


        when:"An invalid domain instance is passed to the update action"
            response.reset()
            def institution = new Institution()
            institution.validate()
            controller.update(institution)

        then:"The edit view is rendered again with the invalid instance"
            view == 'edit'
            model.institutionInstance == institution

        when:"A valid domain instance is passed to the update action"
            response.reset()
            populateValidParams(params)
            institution = new Institution(params).save(flush: true)
            controller.update(institution)

        then:"A redirect is issues to the show action"
            response.redirectedUrl == "/admin/institutions/edit/1"
    }

    void "Test that the delete action deletes an instance if it exists"() {
        when:"The delete action is called for a null instance"
            request.contentType = FORM_CONTENT_TYPE
            request.method = 'DELETE'
            controller.delete(null)

        then:"A 404 is returned"
            response.redirectedUrl == '/admin/institutions/index'
            flash.message != null

        when:"A domain instance is created"
            response.reset()
            populateValidParams(params)
            def institution = new Institution(params).save(flush: true)

        then:"It exists"
            Institution.count() == 1

        when:"The domain instance is passed to the delete action"
            controller.delete(institution)

        then:"The instance is deleted"
            Institution.count() == 0
            response.redirectedUrl == '/admin/institutions/index'
            flash.message != null
    }
}
