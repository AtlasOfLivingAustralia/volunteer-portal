package au.org.ala.volunteer

import grails.testing.gorm.DataTest
import grails.testing.services.ServiceUnitTest
import org.elasticsearch.action.search.SearchType
import spock.lang.Specification
//import grails.test.mixin.*
//import grails.test.mixin.web.ControllerUnitTestMixin
import spock.lang.Shared

//@TestFor(FullTextIndexService)
//@TestMixin(ControllerUnitTestMixin)
//@Mock([Field, Transcription])
class FullTextIndexServiceSpec extends Specification implements ServiceUnitTest<FullTextIndexService>, DataTest {

    @Shared
    Task task1

    void setupSpec() {
        mockDomains(Field, Transcription)
//        mockDomain(Transcription)
    }

    def setup() {
    }

    def cleanup() {
    }

    def setupTask() {
        Project project1 = new Project(name: 'Test Project')
        project1.id = 1

        task1 = new Task(project: project1, transcriptions: [], fields: [])
        task1.id = 123

        transcribeTask(task1, 'user1', new Date() - 40)
        transcribeTask(task1, 'user1', new Date() - 50)
        transcribeTask(task1, 'user1', new Date() - 8)
        transcribeTask(task1, 'user1', new Date() - 30)

    }

    def transcribeTask(Task task, String user, Date dateTranscribe) {
        Transcription transcription = new Transcription(task: task, fullyTranscribedBy: user, dateFullyValidated: dateTranscribe)
        task.transcriptions.add(transcription)
    }


    void "test task is indexed and search is working"() {

        setup:
        String query = """{
  "constant_score": {
    "filter": {
      "term": {
        "transcriptions.fullyTranscribedBy": 'user1'
      }
    }
  }
}"""

        setupTask()
        service.initialize()

        when:
        def response = service.indexTask(task1)
        def flushResponse = service.flush()

        then:
        assert response != null
        assert response.id == "123"
        assert response.type == "task"
        assert flushResponse != null


        when:
        def result = service.rawSearch(query, SearchType.fromString("query_then_fetch"), "", service.elasticSearchToJsonString)

        then:
        assert result != null

     /*   when:
        Map jsonMap = new groovy.json.JsonSlurper().parseText(result)

        then:
        assert jsonMap?.hits?.total == 1

        assert jsonMap?.hits?.hits._source.transcriptions[0].size == 4 */

        when:
        def deleteResponse = service.deleteTask(123)

        then:
        assert deleteResponse != null

    }


}
