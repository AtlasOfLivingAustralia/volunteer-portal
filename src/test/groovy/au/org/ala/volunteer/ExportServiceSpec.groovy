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

//        mockDomain(Field, [field])
//        mockDomain(Task, [task])
//        mockDomain(Project, [project])
    }

    private void setupData() {

        List fieldNames = ['scientificName', 'occurenceRemarks']

        Template template = new Template(viewParams:[exportGroupByIndex:true])
        project = new Project(tasks:new HashSet(), name:"test project", template: template)
        Task task = new Task(id:1, transcriptions: new HashSet())
        Transcription transcription = new Transcription(id:1, task:task)
        task.transcriptions.add(transcription)

        fieldNames.each {
            fields << new Field(task:task, transcription: transcription, name:it, value:it+'_value')
        }

        task.project = project
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
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> [['occurenceRemarks', 1]]
        1 * taskService.getUserMapFromTaskList(taskList) >> [:]

        //and:
        //results.size() == 1 // One row, not counting headers
        //results[0]['occurenceRemarks'] == 'value'
    }
}
