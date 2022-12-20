package au.org.ala.volunteer

import au.org.ala.userdetails.UserDetailsFromIdListResponse
import au.org.ala.web.AuthService
import au.org.ala.web.UserDetails
import grails.test.hibernate.HibernateSpec
import grails.testing.web.controllers.ControllerUnitTest

//import grails.test.mixin.TestFor
import org.grails.web.json.JSONArray
import org.grails.web.json.JSONObject

import static au.org.ala.volunteer.helper.TaskDataHelper.setupProject
import static au.org.ala.volunteer.helper.TaskDataHelper.setupTasks
import static au.org.ala.volunteer.helper.TaskDataHelper.transcribe

//@TestFor(AjaxController)
class AjaxControllerSpec extends HibernateSpec implements ControllerUnitTest<AjaxController> {

    String userId = 'u1'
    Project project
    List<Task> tasks

    void setup() {
        project = setupProject()
        tasks = setupTasks(project, 10)
        tasks.take(5).collect { task -> transcribe(task, userId, [:]) }
        controller.authService = Stub(AuthService)
        controller.authService.getUserDetailsById(_, _) >> { List<String> ids, boolean includeProps -> new UserDetailsFromIdListResponse(true, '', ['ud1' : new UserDetails(1L, 'First', 'Second', 'ud1@ud1.com', 'ud1', false, '', '', 'organisation', 'Canberra', 'ACT', '', ['ROLE_USER'] as Set)], []) }
    }

    def "test transcription feed"() {
        setup:

        when:
        controller.transcriptionFeed('','',0,'')

        then:
        def json = response.json
        json instanceof JSONObject
        json.numFound == 5
        json.items instanceof JSONArray
        json.items.size() == 5
    }

}
