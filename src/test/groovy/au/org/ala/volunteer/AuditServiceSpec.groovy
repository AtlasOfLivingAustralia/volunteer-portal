package au.org.ala.volunteer

import au.org.ala.volunteer.helper.FlybernateSpec
import grails.test.hibernate.HibernateSpec
import grails.testing.services.ServiceUnitTest

//import grails.test.mixin.TestFor

import static au.org.ala.volunteer.helper.TaskDataHelper.*

//@TestFor(AuditService)
class AuditServiceSpec extends FlybernateSpec implements ServiceUnitTest<AuditService> {

    String userId = 'u1'
    Project project
    void setup() {
        project = setupProject()
    }

    void "a Task with no views will not be reported as locked"() {
        setup:
        Task task = addTask(project, 0)

        expect:
        service.isTaskLockedForTranscription(task, userId) == false
    }

    void "a Task with a non-recent view will not be locked for our user"() {
        setup:
        Task task = addTask(project, 0)

        when:
        view(task, 'u2', false)

        then:
        service.isTaskLockedForTranscription(task, userId) == false
    }

    void "a Task with a recent view will be locked for our user"() {
        setup:
        Task task = addTask(project, 0)

        when:
        view(task, 'u2')

        then:
        service.isTaskLockedForTranscription(task, userId) == true
    }

    void "a Task recently viewed by our user will not be locked for them"() {
        setup:
        Task task = addTask(project, 0)

        when:
        view(task, 'u2')

        then:
        service.isTaskLockedForTranscription(task, userId) == true
    }

    void "a Task should not be locked for a user if the number of views is less than the number of required transcriptions"() {
        setup:
        int transcriptionsPerTask = 3
        //project.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        project.transcriptionsPerTask = transcriptionsPerTask
        Task task = addTask(project, 0)

        when: "the Task has been viewed and transcribed twice"
        transcribe(task, 'u2')
        transcribe(task, 'u3')

        then: "the Task can be viewed by our user"
        service.isTaskLockedForTranscription(task, userId) == false


        when: "the Task has been viewed by 2 distinct users"
        task = addTask(project, 1)

        view(task, 'u2')
        view(task, 'u3')

        then: "the Task can be viewed by our user"
        service.isTaskLockedForTranscription(task, userId) == false

        when: "the Task has been viewed by 2 distinct users, but more than once"
        task = addTask(project, 2)

        view(task, 'u2')
        view(task, 'u2')
        view(task, 'u3')

        then: "the Task can be viewed by our user"
        service.isTaskLockedForTranscription(task, userId) == false

    }

    void "a Task should not be locked for a user if they have already transcribed it"() {
        int transcriptionsPerTask = 3
        project.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        Task task = addTask(project, 0)

        when: "the Task has been viewed and transcribed twice"
        transcribe(task, 'u2')
        transcribe(task, 'u3')
        transcribe(task, userId)

        then: "the Task can be viewed by our user"
        service.isTaskLockedForTranscription(task, userId) == false
    }

    void "a Task should be locked if it has a number of distinct, recent user views equal to the number of required transcriptions"() {
        int transcriptionsPerTask = 3
        project.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        Task task = addTask(project, 0)

        when: "the Task has been viewed a3 times recently"
        view(task, 'u2')
        view(task, 'u3')
        view(task, 'u4')

        then: "the Task is locked to our user"
        service.isTaskLockedForTranscription(task, userId) == true
    }

    void "a Task should be locked if it has a number of distinct user views equal to the number of required transcriptions, unless the user is one of the recent viewers"() {
        int transcriptionsPerTask = 3
        //project.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        project.transcriptionsPerTask = transcriptionsPerTask
        Task task = addTask(project, 0)

        when: "the Task has been viewed 3 times recently, but our user is one of the viewers"
        view(task, 'u2')
        view(task, 'u3')
        view(task, userId)

        then: "the Task is not locked to our user"
        service.isTaskLockedForTranscription(task, userId) == false
    }

    void "a Task should not be locked if it has a number of distinct, user views equal to the number of required transcriptions but one or more views have timed out"() {
        int transcriptionsPerTask = 3
        //project.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        project.transcriptionsPerTask = 3
        Task task = addTask(project, 0)

        when: "the Task has been viewed recently twice, and once more than the locking period ago"
        view(task, 'u2')
        view(task, 'u3')
        view(task, 'u4', false)

        then: "the Task is not locked to our user"
        service.isTaskLockedForTranscription(task, userId) == false
    }

}
