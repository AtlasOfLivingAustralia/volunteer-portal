package au.org.ala.volunteer

import org.elasticsearch.action.search.SearchType
import spock.lang.Specification
import grails.test.mixin.*
import grails.test.mixin.web.ControllerUnitTestMixin
import spock.lang.Shared

@TestFor(FullTextIndexService)
@TestMixin(ControllerUnitTestMixin)
class FullTextIndexServiceSpec extends Specification {

    @Shared
    Task task1

    void setupSpec() {
        mockDomain(Field)
        mockDomain(Transcription)
    }

    def setup() {
    }

    def cleanup() {
       // service.deleteTask(123)
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

        then:
        assert response != null
        assert response.id == "123"
        assert response.type == "task"


        def result = service.rawSearch(query, SearchType.fromString("query_then_fetch"), "", service.elasticSearchToJsonString)
        assert result != null
        Map jsonMap = new groovy.json.JsonSlurper().parseText(result)

        assert jsonMap?.hits?.total == 1

        assert jsonMap?.hits?.hits._source.transcriptions[0].size == 4

    }


}