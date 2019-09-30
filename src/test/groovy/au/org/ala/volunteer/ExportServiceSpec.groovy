package au.org.ala.volunteer

import grails.plugins.csv.CSVMapReader
import grails.test.mixin.TestFor
import grails.web.mapping.LinkGenerator
import org.grails.plugins.testing.GrailsMockHttpServletResponse
import spock.lang.Specification

import java.text.DateFormat
import java.text.SimpleDateFormat

@TestFor(ExportService)
class ExportServiceSpec extends Specification {

    FieldService fieldService
    TaskService taskService
    GrailsMockHttpServletResponse response
    Project project
    LinkGenerator grailsLinkGenerator

    List taskOrTranscriptionFields = ['taskID', 'taskUrl', 'transcriberID', 'validatorID', 'externalIdentifier', 'exportComment', 'validationStatus', 'dateTranscribed', 'dateValidated']
    DateFormat dateTimeFormat
    DateFormat dateFormat
    String defaultUserId = '1234'
    Date defaultTranscriptionDate

    def setup() {
        fieldService = Mock(FieldService)
        service.fieldService = fieldService
        taskService = Mock(TaskService)
        service.taskService = taskService
        response = new GrailsMockHttpServletResponse()
        grailsLinkGenerator = Mock(LinkGenerator)
        service.grailsLinkGenerator = grailsLinkGenerator
        dateTimeFormat = new SimpleDateFormat()
        dateFormat = new SimpleDateFormat('dd-MMM-yyyy')
        dateTimeFormat = new SimpleDateFormat('dd-MMM-yyyy HH:mm:ss')
        defaultTranscriptionDate = dateTimeFormat.parse("01-Mar-2019 10:30:00")
        setupData()
    }

    private void setupData() {

        // This is necessary as the export uses the domain object ids and they can't be assigned
        // without the mocking framework.
        Template template = new Template(viewParams:[exportGroupByIndex:true])
        project = new Project(tasks:new HashSet(), name:"test project", template: template)
        mockDomain(Project, [project])
    }

    private Task createTask() {
        Task task = new Task(transcriptions: new HashSet(), project:project)
        project.tasks.add(task)
        mockDomain(Task, [task])

        task
    }

    private List<Field> transcribeTask(Task task, List<Map> allFieldData, String userId = defaultUserId, Date transcriptionDate = defaultTranscriptionDate ) {
        Transcription transcription = new Transcription(id:2, task:task, project:project, fullyTranscribedBy: userId, dateFullyTranscribed: transcriptionDate)
        mockDomain(Transcription, [transcription])
        task.transcriptions.add(transcription)
        List fields = []

        allFieldData.each { fieldData ->
            Field field = fields.findAll{it.name == fieldData.name}?.max{it.recordIdx}
            int recordIndex = field ? field.recordIdx + 1 : 0
            fields << new Field(task:task, transcription: transcription, name:fieldData.name, value:fieldData.value, recordIdx: recordIndex)
        }

        fields
    }

    def "All project task data can be exported in CSV form for single transcription projects"() {
        setup:
        String userId = '1234'
        Task task = createTask()
        List fields = transcribeTask(task, [[name:"occurenceRemarks", value:"occurenceRemarks_value"]])
        List<Task> taskList = [project.tasks as List]
        List<String> fieldNames = taskOrTranscriptionFields + ["occurenceRemarks"]

        when:
        service.export_default(project, taskList, fieldNames, fields, response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> [['occurenceRemarks', 0]]
        1 * taskService.getUserMapFromTaskList(taskList) >> [(userId):[displayName:"Test user"]]

        and:
        results.size() == 1 // One row, not counting headers
        results[0]['taskID'] == task.id as String
        results[0]['occurenceRemarks'] == 'occurenceRemarks_value'
    }

    def "Tasks with repeating fields can be exported in CSV form for single transcription projects"() {
        setup:
        String userId = '1234'
        Task task = createTask()
        List fields = transcribeTask(task, [
                [name:"occurenceRemarks", value:"occurenceRemarks_value_1"],
                [name:"occurenceRemarks", value:"occurenceRemarks_value_2"],
                [name:"occurenceRemarks", value:"occurenceRemarks_value_3"]])

        List<Task> taskList = [project.tasks as List]
        List<String> fieldNames = taskOrTranscriptionFields + ["occurenceRemarks"]

        when:
        service.export_default(project, taskList, fieldNames, fields, response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> [['occurenceRemarks', 2]]
        1 * taskService.getUserMapFromTaskList(taskList) >> [(userId):[displayName:"Test user"]]

        and:
        results.size() == 1 // One row, not counting headers
        results[0]['taskID'] == task.id as String
        results[0]['occurenceRemarks_0'] == 'occurenceRemarks_value_1'
        results[0]['occurenceRemarks_1'] == 'occurenceRemarks_value_2'
        results[0]['occurenceRemarks_2'] == 'occurenceRemarks_value_3'
    }

    def "Task fields can be exported in CSV form for a single transcription project"() {
        setup:
        String today = dateFormat.format(new Date())
        Date transcriptionDate = dateTimeFormat.parse('01-Jul-2019 10:30:00')
        Task task = createTask()
        task.externalIdentifier = 'external id'
        String userId = '1234'
        List<Task> taskList = [project.tasks as List]
        List<String> fieldNames = taskOrTranscriptionFields
        List fields = transcribeTask(task, [], userId, transcriptionDate)

        when:
        service.export_default(project, taskList, fieldNames, fields, response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> []
        1 * taskService.getUserMapFromTaskList(taskList) >> [(userId):[displayName:"Test user"]]

        and:
        results.size() == 1 // One row, not counting headers
        results[0]['taskID'] == task.id as String
        results[0]['taskUrl'] == ''
        results[0]['transcriberID'] == 'Test user'
        results[0]['validatorID'] == ''
        results[0]['externalIdentifier'] == 'external id'
        results[0]['exportComment'] == "Fully transcribed by Test user. Exported on ${today} from DigiVol (https://volunteer.ala.org.au)"
        results[0]['validationStatus'] == ''
        results[0]['dateTranscribed'] == '01-Jul-2019 10:30:00'
        results[0]['dateValidated'] == ''
    }


}
