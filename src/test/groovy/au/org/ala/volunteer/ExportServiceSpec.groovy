package au.org.ala.volunteer

import grails.plugins.csv.CSVMapReader
import grails.testing.gorm.DataTest
import grails.testing.services.ServiceUnitTest

//import grails.test.mixin.TestFor
import grails.web.mapping.LinkGenerator
import org.grails.plugins.testing.GrailsMockHttpServletResponse
import spock.lang.Specification

import java.text.DateFormat
import java.text.SimpleDateFormat

//@TestFor(ExportService)
class ExportServiceSpec extends Specification implements ServiceUnitTest<ExportService>, DataTest {

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
        grailsApplication.config.exportCSVThreadPoolSize = 1
        service.grailsApplication = grailsApplication
        taskService = Mock(TaskService)
        service.taskService = taskService
        response = new GrailsMockHttpServletResponse()
        grailsLinkGenerator = Mock(LinkGenerator)
        service.grailsLinkGenerator = grailsLinkGenerator
        dateTimeFormat = new SimpleDateFormat()
        dateFormat = new SimpleDateFormat('dd-MMM-yyyy')
        dateTimeFormat = new SimpleDateFormat('dd/MM/yyyy HH:mm:ss')
        defaultTranscriptionDate = dateTimeFormat.parse("01/03/2019 10:30:00"/*'01-Mar-2019 10:30:00'*/)
        setupData()
    }

    private void setupData() {

        // This is necessary as the export uses the domain object ids and they can't be assigned
        // without the mocking framework.
        Template template = new Template(viewParams:[exportGroupByIndex:true])
        project = new Project(tasks:new HashSet(), name:"test project", template: template)
        mockDomain(Project, [project])
    }

    private Task createTask(String externalIdentifier = '') {
        Task task = new Task(transcriptions: new HashSet(), project:project, externalIdentifier: externalIdentifier)
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

    def "Test non parrallel writes is working for larger tasks"() {
        setup:
        project.transcriptionsPerTask = 2
        String userA = 'userA'
        String userB = 'userB'

        List allFields = new ArrayList()

        int numOfTasks = 100
        for (int i= 1; i <= numOfTasks; i++) {
            Task task = createTask("image${i}.jpq")
            List fields1 = transcribeTask(task, [[name:"scientificName", value:"Magpie"], [name:"individualCount", value:"10"]], userA)
            allFields.addAll(fields1)
            List fields2 = transcribeTask(task, [[name:"scientificName", value:"Crow"], [name:"individualCount", value:"5"]], userB)
            allFields.addAll(fields2)
        }

        List<Task> taskList = project.tasks as List
        List<String> fieldNames = taskOrTranscriptionFields + ["scientificName", "individualCount"]

        when:
        service.export_default(project, taskList, fieldNames, allFields, response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> [['scientificName', 0], ['individualCount', 0]]
        1 * taskService.getUserMapFromTaskList(taskList) >> [(userA):[displayName:userA], (userB):[displayName:userB]]

        and:
        results.size() == 200
        for (int i= 1; i <= numOfTasks; i++) {
            results.findAll { it.externalIdentifier == "image${i}.jpq" }.size() == 2
        }
        results.findAll{it.transcriberID == userA}.size() == numOfTasks
        results.findAll{it.transcriberID == userB}.size() == numOfTasks
    }

    def "Test parrallel writes is working for larger tasks"() {
        setup:
        grailsApplication.config.exportCSVThreadPoolSize = 10
        service.grailsApplication = grailsApplication

        project.transcriptionsPerTask = 2
        String userA = 'userA'
        String userB = 'userB'

        List allFields = new ArrayList()

        int numOfTasks = 100
        for (int i= 1; i <= numOfTasks; i++) {
            Task task = createTask("image${i}.jpq")
            List fields1 = transcribeTask(task, [[name:"scientificName", value:"Magpie"], [name:"individualCount", value:"10"]], userA)
            allFields.addAll(fields1)
            List fields2 = transcribeTask(task, [[name:"scientificName", value:"Crow"], [name:"individualCount", value:"5"]], userB)
            allFields.addAll(fields2)
        }

        List<Task> taskList = project.tasks as List
        List<String> fieldNames = taskOrTranscriptionFields + ["scientificName", "individualCount"]

        when:
        service.export_default(project, taskList, fieldNames, allFields, response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> [['scientificName', 0], ['individualCount', 0]]
        1 * taskService.getUserMapFromTaskList(taskList) >> [(userA):[displayName:userA], (userB):[displayName:userB]]

        and:
        results.size() == 200
        for (int i= 1; i <= numOfTasks; i++) {
            results.findAll { it.externalIdentifier == "image${i}.jpq" }.size() == 2
        }
        results.findAll{it.transcriberID == userA}.size() == 100
        results.findAll{it.transcriberID == userB}.size() == 100
    }

    def "All project transcription tasks data can be exported in CSV form for multiple transcription project"() {
        setup:
        project.transcriptionsPerTask = 2
        String userA = 'userA'
        String userB = 'userB'
        Task birdTask = createTask()
        Task kangarooTask = createTask()
        List birdFields1 = transcribeTask(birdTask, [[name:"scientificName", value:"Magpie"], [name:"individualCount", value:"10"]], userA)
        List birdFields2 = transcribeTask(birdTask, [[name:"scientificName", value:"Crow"], [name:"individualCount", value:"5"]], userB)
        List kangarooFields1 = transcribeTask(kangarooTask, [[name:"scientificName", value:"Red Kangaroo"], [name:"individualCount", value:"2"]], userA)
        List kangarooFields2 = transcribeTask(kangarooTask, [[name:"scientificName", value:"Red Kangaroo"], [name:"individualCount", value:"2"]], userB)

        List<Task> taskList = project.tasks as List
        List<String> fieldNames = taskOrTranscriptionFields + ["scientificName", "individualCount"]

        when:
        service.export_default(project, taskList, fieldNames, birdFields1 + birdFields2 + kangarooFields1 + kangarooFields2, response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> [['scientificName', 0], ['individualCount', 0]]
        1 * taskService.getUserMapFromTaskList(taskList) >> [(userA):[displayName:userA], (userB):[displayName:userB]]

        and:
        results.size() == 4 // not counting headers
        results.findAll{it.transcriberID == userA && it.taskID == birdTask.id.toString() && it.scientificName == 'Magpie'}.size() == 1
        results.findAll{it.transcriberID == userA && it.taskID == kangarooTask.id.toString() && it.scientificName == 'Red Kangaroo'}.size() == 1
        results.findAll{it.transcriberID == userB && it.taskID == birdTask.id.toString() && it.scientificName == 'Crow'}.size() == 1
        results.findAll{it.transcriberID == userB && it.taskID == kangarooTask.id.toString() && it.scientificName == 'Red Kangaroo'}.size() == 1
    }

    def "Partially transcribed project tasks data can be exported in CSV form for multiple transcription project"() {
        setup:
        project.transcriptionsPerTask = 2
        String userA = 'userA'
        String userB = 'userB'
        Task birdTask = createTask()
        Task kangarooTask = createTask()
        List birdFields1 = transcribeTask(birdTask, [[name:"scientificName", value:"Magpie"], [name:"individualCount", value:"10"]], userA)
        List kangarooFields1 = transcribeTask(kangarooTask, [[name:"scientificName", value:"Red Kangaroo"], [name:"individualCount", value:"2"]], userB)

        List<Task> taskList = project.tasks as List
        List<String> fieldNames = taskOrTranscriptionFields + ["scientificName", "individualCount"]

        when:
        service.export_default(project, taskList, fieldNames, birdFields1 + kangarooFields1, response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> [['scientificName', 0], ['individualCount', 0]]
        1 * taskService.getUserMapFromTaskList(taskList) >> [(userA):[displayName:userA], (userB):[displayName:userB]]

        and:
        results.size() == 2 //not counting headers
        results.findAll{it.transcriberID == userA && it.taskID == birdTask.id.toString() && it.scientificName == 'Magpie'}.size() == 1
        results.findAll{it.transcriberID == userB && it.taskID == kangarooTask.id.toString()  && it.scientificName == 'Red Kangaroo'}.size() == 1
    }

    def "For multiple transcription project with tasks that have not been transcribed, data can be exported in CSV"() {
        setup:
        project.transcriptionsPerTask = 2
        String macpieImage = 'macpieImage.jpg'
        String kangarooImage = 'kangarooImage.jpg'
        Task birdTask = createTask(macpieImage)
        Task kangarooTask = createTask(kangarooImage)

        List<Task> taskList = project.tasks as List
        List<String> fieldNames = taskOrTranscriptionFields

        when:
        service.export_default(project, taskList, fieldNames, [], response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> []
        1 * taskService.getUserMapFromTaskList(taskList) >> [:]

        and:
        results.size() == 2
        results.find{it.taskID == kangarooTask.id.toString()}.externalIdentifier == kangarooImage
        results.find{it.taskID == birdTask.id.toString()}.externalIdentifier == macpieImage
    }

    def "For single transcription project with tasks that have not been transcribed, data can be exported in CSV"() {
        setup:
        project.transcriptionsPerTask = 1
        String macpieImage = 'macpieImage.jpg'
        Task birdTask = createTask(macpieImage)

        List<Task> taskList = project.tasks as List
        List<String> fieldNames = taskOrTranscriptionFields

        when:
        service.export_default(project, taskList, fieldNames, [], response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> []
        1 * taskService.getUserMapFromTaskList(taskList) >> [:]

        and:
        results.size() == 1
        results[0].externalIdentifier == macpieImage
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
        Date transcriptionDate = dateTimeFormat.parse('01/07/2019 10:30:00')
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

    def "Export filename is checked for unsupported characters and has them removed"() {
        setup:
        project.transcriptionsPerTask = 1
        project.featuredLabel = 'Test\\/:*?"\'<>|][.;{}&%#@!'
        String macpieImage = 'macpieImage.jpg'
        Task birdTask = createTask(macpieImage)

        List<Task> taskList = project.tasks as List
        List<String> fieldNames = taskOrTranscriptionFields

        when:
        service.export_default(project, taskList, fieldNames, [], response)
        List results = new CSVMapReader(new StringReader(response.text)).readAll()

        then:
        1 * fieldService.getMaxRecordIndexByFieldForProject(project) >> []
        1 * taskService.getUserMapFromTaskList(taskList) >> [:]

        and:
        response.getHeader("Content-Disposition") == "attachment;filename=Project-Test-DwC.csv"
    }
}
