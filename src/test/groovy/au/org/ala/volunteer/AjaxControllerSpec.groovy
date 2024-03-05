package au.org.ala.volunteer

import au.org.ala.userdetails.UserDetailsFromIdListResponse
import au.org.ala.volunteer.helper.FlybernateSpec
import au.org.ala.web.AuthService
import au.org.ala.web.UserDetails
import grails.testing.web.controllers.ControllerUnitTest
import groovy.util.logging.Slf4j

import org.grails.web.json.JSONArray
import org.grails.web.json.JSONObject

import static au.org.ala.volunteer.helper.TaskDataHelper.setupProject
import static au.org.ala.volunteer.helper.TaskDataHelper.setupTasks
import static au.org.ala.volunteer.helper.TaskDataHelper.transcribe

@Slf4j
class AjaxControllerSpec extends FlybernateSpec implements ControllerUnitTest<AjaxController> {

    String userId = 'u1'
    Project project
    List<Task> tasks

    void setup() {
        project = setupProject()
        tasks = setupTasks(project, 10)
        tasks.take(5).collect { task -> transcribe(task, userId, [:]) }
        controller.authService = Stub(AuthService)
        controller.authService.getUserDetailsById(_, _) >> { List<String> ids, boolean includeProps -> new UserDetailsFromIdListResponse(true, '', ['ud1' : new UserDetails(1L, 'First', 'Second', 'ud1@ud1.com', 'ud1', false, '', '', 'organisation', 'Canberra', 'ACT', '', ['ROLE_USER'] as Set)], []) }
        controller.taskService = Stub(TaskService)
        controller.fieldService = Stub(FieldService)
        controller.exportService = Stub(ExportService)
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

    def "test json dwc export"() {
        setup:
        request.setParameters(['id': "${project.id}".toString()])

        when:
        controller.expeditionDwcJson()

        then:
        def json = response.json
        log.debug("json: ${json}")
        json instanceof JSONObject
    }
}
