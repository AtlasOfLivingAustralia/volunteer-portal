package au.org.ala.volunteer

import grails.test.mixin.Mock
import grails.test.mixin.TestFor
import spock.lang.Specification

import static au.org.ala.volunteer.helper.TaskDataHelper.*

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
@TestFor(ValidationService)
@Mock([Task, Project, Template, Field, ViewedTask, Transcription])
class ValidationServiceSpec extends Specification {


    Task task
    Set taskSet
    FieldSyncService fieldSyncService

    def setup() {

        Project project = setupProject()
        task = addTask(project, 1)
       // task.project.template.viewParams.transcriptionsPerTask = "3"
        task.project.transcriptionsPerTask = 3
        task.project.thresholdMatchingTranscriptions = 3
        task.save()

        taskSet = new HashSet()
        taskSet << task.id


        fieldSyncService = Mock(FieldSyncService)
        service.fieldSyncService = fieldSyncService
    }

    Map fields() {
        ["name":"test", "name2":"value2", "name3":"value3"]
    }

    def cleanup() {
    }

    void "A task with no fields or Transcriptions should not be auto-validated"() {
        when:
        service.autoValidate(taskSet)

        then:
        Task task = Task.get(task.id)
        !task.isValid
    }

    void "Tasks not fully transcribed should not be auto-validated"() {

        setup:
        transcribe(task, "1234", fields())

        when:
        service.autoValidate(taskSet)

        then:
        Task task = Task.get(task.id)
        !task.isValid
    }

    void "Fully transcribed Tasks with all transcriptions the same should be auto-validated"() {
        setup:
        for (int i=0; i<3; i++) {
            transcribe(task, Integer.toString(i), fields())
        }

        when:
        service.autoValidate(taskSet)

        then:
        Task task = Task.get(task.id)
        task.isValid == true
        task.fullyValidatedBy == UserService.SYSTEM_USER
        1 * fieldSyncService.syncFields(task, _, UserService.SYSTEM_USER, false, true, true)

    }

    void "Fully transcribed Tasks with the number of matching transcriptions less than the threshold should not be auto-validated"() {
        setup: "2 Tasks are transcribed with the same fields, the 3rd has one value different"
        for (int i=0; i<2; i++) {
            transcribe(task, Integer.toString(i), fields())
        }
        Map fields = fields()
        fields.name = "different"
        transcribe(task, "2", fields)

        when:
        service.autoValidate(taskSet)

        then:
        Task task = Task.get(task.id)
        !task.isValid == true
        task.fullyValidatedBy == null
        task.numberOfMatchingTranscriptions == 2

    }

    void "Fully transcribed Tasks with no matching transcriptions should not be auto-validated"() {
        setup: "No tasks are transcribed with the same fields"
        for (int i=0; i<3; i++) {
            Map fields = fields()
            fields.name = "name $i"
            transcribe(task, Integer.toString(i), fields)
        }

        when:
        service.autoValidate(taskSet)

        then:
        Task task = Task.get(task.id)
        !task.isValid == true
        task.fullyValidatedBy == null
        task.numberOfMatchingTranscriptions == 0

    }

    void "The transcriberNotes and validatorNotes fields should be excluded from transcription comparisons"() {
        setup: "3 Tasks are transcribed with the same fields except for the transcriberNotes and validatorNotes"

        Map fields = fields()
        for (int i=0; i<3; i++) {
            fields.put("transcriberNotes", "Transcriber $i")
            fields.put("validatorNotes", "Validator $i")
            transcribe(task, Integer.toString(i), fields)
        }

        when:
        service.autoValidate(taskSet)

        then:
        Task task = Task.get(task.id)
        task.isValid == true
        task.fullyValidatedBy == "system"
    }

    void "A Task should be auto-validated if the matching transcription threshold is met, even if the required number of transcriptions has not yet been reached"() {
        setup: "Require two matching transcriptions and transcribe the task twice"
        task.project.thresholdMatchingTranscriptions = 2
        for (int i=0; i<2; i++) {
            transcribe(task, Integer.toString(i), fields())
        }
        when:
        service.autoValidate(taskSet)

        then:
        Task task = Task.get(task.id)
        task.isFullyTranscribed == true
        task.isValid == true
        task.numberOfMatchingTranscriptions == 2
        task.fullyValidatedBy == "system"
    }

    void "A Task should be auto-validatable after the number of matching transcription threshold is met"() {
        setup: "Require two matching transcriptions and transcribe the task twice, but differently"
        task.project.thresholdMatchingTranscriptions = 2
        for (int i=0; i<2; i++) {
            Map fields = fields()
            fields.name = "name $i"
            transcribe(task, Integer.toString(i), fields)
        }

        expect: "The task should be eligible for auto-validation"
        service.shouldAutoValidate(task) == true

        when:
        service.autoValidate(taskSet)

        then: "But it should not be validated"
        Task task = Task.get(task.id)
        task.isFullyTranscribed == false
        !task.isValid
        !task.numberOfMatchingTranscriptions
        !task.fullyValidatedBy
    }

}
