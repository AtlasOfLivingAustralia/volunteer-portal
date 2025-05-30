package au.org.ala.volunteer

import au.org.ala.volunteer.helper.FlybernateSpec
import grails.gorm.DetachedCriteria
import grails.testing.services.ServiceUnitTest
import groovy.util.logging.Slf4j
import static au.org.ala.volunteer.helper.TaskDataHelper.*

@Slf4j
class TaskServiceSpec extends FlybernateSpec implements ServiceUnitTest<TaskService> {

    boolean isRollback() { return false }

    ProjectService projectService
    String userId = '1234'
    Project p

    def setup() {
        p = setupProject()
        service.dataSource = hibernateDatastore.dataSource

        projectService = Mock(ProjectService)
        service.projectService = projectService
        projectService.doesTemplateSupportMultiTranscriptions(_) >> { Project project ->
            return true
        }
    }

    def "regardless of the number of transcriptions per task, the same user shouldn't be assigned a task they've already transcribed"(int transcriptionsPerTask) {
        setup:

       // p.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        p.transcriptionsPerTask = transcriptionsPerTask
        int numberOfTasks = 10
        setupTasks(p, numberOfTasks)

        Set transcribedTasks = new HashSet()
        for (int i=0; i<numberOfTasks; i++) {
            Task task = service.getNextTask(userId, p)

            assert task != null
            assert !transcribedTasks.contains(task.id)

            transcribe(task, userId)
            transcribedTasks.add(task.id)
        }

        when: "All tasks have one transcription by our user"
        Task task = service.getNextTask(userId, p)

        then: "no tasks remain in the project that can be transcribed by our user"
        task == null

        where:
        transcriptionsPerTask | _
        1 | _
        5 | _
    }

    def "when there are multiple transcriptions per task, we should still be able to assign them to our user if all of the transcriptions are not completed for the Task"() {
        setup:

        int transcriptionsPerTask = 5
       // p.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        p.transcriptionsPerTask = transcriptionsPerTask
        int numberOfTasks = 10
        setupTasks(p, numberOfTasks)
        Task.findAllByProject(p).each { Task task ->
            List users = ['u1', 'u2', 'u3', 'u4']
            users.each { String user ->
                transcribe(task, user)
            }
        }

        Set transcribedTasks = new HashSet()
        for (int i=0; i<numberOfTasks; i++) {

            Task task = service.getNextTask(userId, p)

            log.debug("Found task: "+task?.id)
            assert task != null
            assert !transcribedTasks.contains(task.id)

            transcribe(task, userId)
            transcribedTasks.add(task.id)
        }

        when: "All tasks have one transcription by our user"
        Task task = service.getNextTask(userId, p)

        then: "no tasks remain in the project that can be transcribed by our user"
        task == null

    }

    def "When the only Task not fully transcribed has a recent view by a unique user, no Tasks should be allocated to our user"() {

        setup:
        int transcriptionsPerTask = 5
       // p.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        p.transcriptionsPerTask = transcriptionsPerTask
        int numberOfTasks = 10
        setupTasks(p, numberOfTasks)
        Task.findAllByProject(p).each { Task task ->
            List users = ['u1', 'u2', 'u3', 'u4']
            users.each { String user ->
                transcribe(task, user)
            }

            view(task, 'u5')
        }

        when: "Tasks have 4 transcriptions and 1 recent view from a 5th user"
        Task task = service.getNextTask(userId, p)

        then: "No Tasks can be allocated to our user"
        task == null
    }


    def "When all tasks have been viewed but not all transcribed, the user should be allocated a task only if one or more views that haven't resulted in a transcription were more than 2 hours ago"() {

        setup:
        int transcriptionsPerTask = 5
       // p.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        p.transcriptionsPerTask = transcriptionsPerTask
        int numberOfTasks = 10
        setupTasks(p, numberOfTasks)
        Task.findAllByProject(p).each { Task task ->
            List users = ['u1', 'u2', 'u3', 'u4']
            users.each { String user ->
                transcribe(task, user)
            }

            view(task, 'u5', false)
        }

        when: "Tasks have 4 transcriptions and 1 non recent view from a 5th user"
        Task task = service.getNextTask(userId, p)

        then: "The first Task can be allocated to our user"
        task != null
    }

    def "When all tasks have been viewed but not all transcribed, the user should finally be allocated a task they have already viewed, but not transcribed"() {

        setup:
        int transcriptionsPerTask = 5
       // p.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        p.transcriptionsPerTask = transcriptionsPerTask
        int numberOfTasks = 10
        setupTasks(p, numberOfTasks)
        Task.findAllByProject(p).each { Task task ->
            List users = ['u1', 'u2', 'u3', 'u4']
            users.each { String user ->
                transcribe(task, user)
            }

            view(task, userId)
        }

        when: "Tasks have 4 transcriptions and 1 non recent view from a 5th user"
        Task task = service.getNextTask(userId, p)

        then: "The first Task can be allocated to our user"
        task != null
    }

    def "A project can be configured to jump over tasks when allocating a new Task"() {
        int jump = 3
        p.template.viewParams = [jumpNTasks:Integer.toString(jump)]
        int numberOfTasks = 21
        setupTasks(p, numberOfTasks)

        when:
        Task task = service.getNextTask(userId, p)

        then: "the first task will be 2 as the algorithm returns jump results and picks the last one"
        int expectedTaskExternalId = 2
        task.externalIdentifier == Integer.toString(expectedTaskExternalId)

        while (task != null && expectedTaskExternalId < numberOfTasks-jump) {
            expectedTaskExternalId = expectedTaskExternalId + jump

            task = service.getNextTask(userId, p, task.id)

            assert task.externalIdentifier == Integer.toString(expectedTaskExternalId)
        }

    }

    def "The jump should still work when we are running out of Tasks to allocate"() {
        // The allocation algorithm tries to allocate Tasks with less views
        // than transcriptions first, then tries to find ones the user hasn't
        // viewed, but the other user views have timed out.

        int jump = 3
        p.template.viewParams = [jumpNTasks:Integer.toString(jump)]
        int numberOfTasks = 21
        setupTasks(p, numberOfTasks)
        Task.findAllByProject(p).each { Task task ->
            view(task, 'u1', false)
        }

        when:
        Task task = service.getNextTask(userId, p)
        log.debug("Task: ${task}")

        then: "the first task will be 2 as the algorithm returns jump results and picks the last one"
        int expectedTaskExternalId = 2
        log.debug("testing expected task")
        task.externalIdentifier == Integer.toString(expectedTaskExternalId)

        while (task != null && expectedTaskExternalId < numberOfTasks-jump) {
            expectedTaskExternalId = expectedTaskExternalId + jump
            log.debug("Incrementing expected task: ${expectedTaskExternalId}")

            task = service.getNextTask(userId, p, task.id)
            log.debug("Task: ${task}")
            assert task.externalIdentifier == Integer.toString(expectedTaskExternalId)
        }

    }

 /*  def "when there multiple transcriptions for multiple tasks, latest contribution view should be able to be updated"() {
        setup:

        int transcriptionsPerTask = 2
        p.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        int numberOfTasks = 4

        setupTasks(p, numberOfTasks)

        when: "When volunteers transcribe tasks"
            Task.findAllByProject(p).each { Task task ->
                List users = ['u8', 'u7']
                users.each { String user ->
                   // Date randomTranscribedDate = randomDate(start..end)
                    transcribe(task, user)
                }
            }

        then: "Latest Transcribers view is updated as expected"
            def latestTranscribers = Transcription.withCriteria {
                    project {
                        ne('inactive', true)
                    }
                    isNotNull('fullyTranscribedBy')
                    projections {
                        groupProperty('project')
                        groupProperty('fullyTranscribedBy')
                        max('dateFullyTranscribed', 'maxDate')
                    }
                    order('maxDate', 'desc')
                    maxResults(10)
            }
            def latestTranscribersView = LatestTranscribers.withCriteria {
                        project {
                            ne('inactive', true)
                        }
                        order('maxDate', 'desc')
                        maxResults(10)
            }

        latestTranscribers.size() == latestTranscribersView.size()

        latestTranscribers.get(0)[0].name == latestTranscribersView.get(0).project.name
        latestTranscribers.get(0)[1] == 'u7'
        latestTranscribers.get(0)[1] == latestTranscribersView.get(0).fullyTranscribedBy
        latestTranscribers.get(0)[2] == latestTranscribersView.get(0).maxDate

        latestTranscribers.get(1)[0].name == latestTranscribersView.get(1).project.name
        latestTranscribers.get(1)[1] == 'u8'
        latestTranscribers.get(1)[1] == latestTranscribersView.get(1).fullyTranscribedBy
        latestTranscribers.get(1)[2] == latestTranscribersView.get(1).maxDate

   }
*/

    def "processFinishedTasks should mark tasks as fully transcribed if all transcriptions are complete"() {
        setup:
        int transcriptionsPerTask = 5
        p.transcriptionsPerTask = transcriptionsPerTask
        int numberOfTasks = 10
        setupTasks(p, numberOfTasks)
        Task.findAllByProject(p).each { Task task ->
            List users = ['u1', 'u2', 'u3', 'u4', 'u5']
            users.each { String user ->
                transcribe(task, user)
            }
        }
        def taskList = Task.list()
        def lastTask = taskList.last()
        // One task wasn't marked as fully transcribed (race condition)
        lastTask.isFullyTranscribed = false
        lastTask.save(flush: true, failOnError: true)

        when: "processFinishedTasks job is called"
        service.processFinishedTasks()

        then: "all tasks should be marked as fully transcribed"
        Task.findAllByProject(p).each { Task task ->
            assert task.isFullyTranscribed == true
        }
    }

    def "processFinishedTasks should not mark tasks as fully transcribed if already fully transcribed"() {
        given:
        def task = Mock(Task) {
            getId() >> 1L
            isFullyTranscribed >> true
        }
        def transcription = Mock(Transcription) {
            getDateFullyTranscribed() >> new Date()
            getTask() >> task
        }
        Transcription.createCriteria() >> Mock(DetachedCriteria) {
            list(_) >> [transcription]
        }

        when: "processFinishedTasks job is called"
        service.processFinishedTasks()

        then: "Nothing should be modified"
        0 * task.setFullyTranscribed(_)
        0 * task.save(_)
    }

    def "processFinishedTasks should not mark tasks as fully transcribed if transcriptions are incomplete"() {
        given:
        def task = Mock(Task) {
            getId() >> 1L
            isFullyTranscribed >> false
        }
        def transcription = Mock(Transcription) {
            getDateFullyTranscribed() >> new Date()
            getTask() >> task
        }
        Transcription.createCriteria() >> Mock(DetachedCriteria) {
            list(_) >> [transcription]
        }
        service.metaClass.allTranscriptionsComplete = { Task t -> false }

        when: "processFinishedTasks job is called"
        service.processFinishedTasks()

        then: "task should not be marked as fully transcribed"
        0 * task.setFullyTranscribed(_)
        0 * task.save(_)
    }

    def "processFinishedTasks should handle empty transcription list gracefully"() {
        given:
        Transcription.createCriteria() >> Mock(DetachedCriteria) {
            list(_) >> []
        }

        when: "processFinishedTasks job is called"
        service.processFinishedTasks()

        then: "no exception should be thrown"
        noExceptionThrown()
    }
}
