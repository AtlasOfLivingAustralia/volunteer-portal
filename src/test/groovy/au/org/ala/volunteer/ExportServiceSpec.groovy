package au.org.ala.volunteer

import grails.plugins.csv.CSVMapReader
import grails.test.mixin.TestFor
import org.grails.plugins.testing.GrailsMockHttpServletResponse
import spock.lang.Specification

@TestFor(ExportService)
class ExportServiceSpec extends Specification {

    FieldService fieldService
    TaskService taskService
    GrailsMockHttpServletResponse response
    Project project
    List fields = []

    List specialExportFields = ['taskID', 'validationStatus', 'dateTranscribed', 'dateValidated']

    def setup() {
        fieldService = Mock(FieldService)
        service.fieldService = fieldService
        taskService = Mock(TaskService)
        service.taskService = taskService
        response = new GrailsMockHttpServletResponse()

        setupData()
    }

    private void setupData() {

        List fieldNames = ['scientificName', 'occurenceRemarks']

        // This is necessary as the export uses the domain object ids and they can't be assigned
        // without the mocking framework.
        Template template = new Template(viewParams:[exportGroupByIndex:true])
        project = new Project(tasks:new HashSet(), name:"test project", template: template)
        mockDomain(Project, [project])

        Task task = new Task(id:1, transcriptions: new HashSet(), project:project)
        mockDomain(Task, [task])
        Transcription transcription = new Transcription(id:2, task:task, project:project)
        mockDomain(Transcription, [transcription])
        task.transcriptions.add(transcription)

        fieldNames.each {
            fields << new Field(task:task, transcription: transcription, name:it, value:it+'_value', recordIdx: 0)
        }
        project.tasks.add(task)

    }

    def "Project task data can be exported in CSV form"() {
        setup:
        List<Task> taskList = [project.tasks as List]
        List<String> fieldNames = specialExportFields + ["occurenceRemarks"]

        when:
        service.export_default(project, taskList, fieldNames, false, response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getAllFieldsWithTasks(taskList) >> fields
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> [['occurenceRemarks', 0]]
        1 * taskService.getUserMapFromTaskList(taskList) >> [:]

        and:
        results.size() == 1 // One row, not counting headers
        results[0]['occurenceRemarks'] == 'occurenceRemarks_value'
    }
}
