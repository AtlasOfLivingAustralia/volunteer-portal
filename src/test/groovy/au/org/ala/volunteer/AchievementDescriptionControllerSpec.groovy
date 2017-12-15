package au.org.ala.volunteer


import grails.test.mixin.*
import spock.lang.*

@TestFor(AchievementDescriptionController)
@Mock(AchievementDescription)
class AchievementDescriptionControllerSpec extends Specification {

    def setup() {
        controller.achievementService = Stub(AchievementService)
        controller.userService = Stub(AchievementService)
    }

    def populateValidParams(params) {
        assert params != null
        // TODO: Populate valid properties like...
        params["name"] = 'badge'
        params['description'] = 'badge'
        params['badge'] = 'badge'
        params['enabled'] = 'false'
        params['type'] = AchievementType.ELASTIC_SEARCH_QUERY
        params['searchQuery'] = '''{
    "filtered" : {
        "filter" : {
            "range" : {
                "dateFullyValidated" : {
                    "gt" : now-2M
                }
            }
        }
    }
}'''
        params['count'] = '50'
        params['aggregationQuery'] = null
        params['aggregationType'] = null
        params['code'] = ''

    }

    void "Test the index action returns the correct model"() {

        when: "The index action is executed"
        controller.index(null)

        then: "The model is correct"
        !model.achievementDescriptionInstanceList
        model.achievementDescriptionInstanceCount == 0
    }

    void "Test the create action returns the correct model"() {
        when: "The create action is executed"
        controller.create()

        then: "The model is correctly created"
        model.achievementDescriptionInstance != null
    }

    void "Test the save action correctly persists an instance"() {

        when: "The save action is executed with an invalid instance"
        request.contentType = FORM_CONTENT_TYPE
        request.method = 'POST'
        def achievementDescription = new AchievementDescription()
        achievementDescription.validate()
        controller.save(achievementDescription)

        then: "The create view is rendered again with the correct model"
        model.achievementDescriptionInstance != null
        view == 'create'

        when: "The save action is executed with a valid instance"
        response.reset()
        populateValidParams(params)
        achievementDescription = new AchievementDescription(params)

        controller.save(achievementDescription)

        then: "A redirect is issued to the show action"
        response.redirectedUrl == '/admin/achievements/show/1'
        controller.flash.message != null
        AchievementDescription.count() == 1
    }

    void "Test that the show action returns the correct model"() {
        when: "The show action is executed with a null domain"
        request.method = 'GET'
        controller.show(null)

        then: "A 404 error is returned"
        response.status == 404

        when: "A domain instance is passed to the show action"
        response.reset()
        populateValidParams(params)
        def achievementDescription = new AchievementDescription(params)
        achievementDescription.id = 2
        controller.show(achievementDescription)

        then: "A model is populated containing the domain instance"
        response.redirectUrl == '/admin/achievements/edit/2'
    }

    void "Test that the edit action returns the correct model"() {
        when: "The edit action is executed with a null domain"
        controller.edit(null)

        then: "A 404 error is returned"
        response.status == 404

        when: "A domain instance is passed to the edit action"
        populateValidParams(params)
        def achievementDescription = new AchievementDescription(params)
        controller.edit(achievementDescription)

        then: "A model is populated containing the domain instance"
        model.achievementDescriptionInstance == achievementDescription
    }

    void "Test the update action performs an update on a valid domain instance"() {
        when: "Update is called for a domain instance that doesn't exist"
        request.contentType = FORM_CONTENT_TYPE
        request.method = 'PUT'
        controller.update(null)

        then: "A 404 error is returned"
        response.redirectedUrl == '/admin/achievements/index'
        flash.message != null


        when: "An invalid domain instance is passed to the update action"
        response.reset()
        def achievementDescription = new AchievementDescription()
        achievementDescription.validate()
        controller.update(achievementDescription)

        then: "The edit view is rendered again with the invalid instance"
        view == 'edit'
        model.achievementDescriptionInstance == achievementDescription

        when: "A valid domain instance is passed to the update action"
        response.reset()
        populateValidParams(params)
        achievementDescription = new AchievementDescription(params).save(flush: true)
        controller.update(achievementDescription)

        then: "A redirect is issues to the show action"
        response.redirectedUrl == "/admin/achievements/edit/${achievementDescription.id}"
        flash.message != null
    }

    void "Test that the delete action deletes an instance if it exists"() {
        when: "The delete action is called for a null instance"
        request.contentType = FORM_CONTENT_TYPE
        request.method = 'DELETE'
        controller.delete(null)

        then: "A 404 is returned"
        response.redirectedUrl == '/admin/achievements/index'
        flash.message != null

        when: "A domain instance is created"
        response.reset()
        populateValidParams(params)
        def achievementDescription = new AchievementDescription(params).save(flush: true)

        then: "It exists"
        AchievementDescription.count() == 1

        when: "The domain instance is passed to the delete action"
        controller.delete(achievementDescription)

        then: "The instance is deleted"
        AchievementDescription.count() == 0
        response.redirectedUrl == '/admin/achievements/index'
        flash.message != null
    }
}
