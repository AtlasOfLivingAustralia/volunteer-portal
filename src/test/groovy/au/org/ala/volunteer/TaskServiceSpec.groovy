package au.org.ala.volunteer

import grails.test.hibernate.HibernateSpec
import grails.test.mixin.TestFor
import org.grails.orm.hibernate.cfg.Settings

import static au.org.ala.volunteer.helper.TaskDataHelper.*

@TestFor(TaskService)
class TaskServiceSpec extends HibernateSpec {

    /**
     * This is to build up some data in the test database for the purposes of running SQL queries.
     * It needs to be deleted at some point.
     */
    Map getConfiguration() {
        Collections.singletonMap(Settings.SETTING_DB_CREATE, "update")
    }
    boolean isRollback() { return false }

    String userId = '1234'
    Project p
    def setup() {
       p = setupProject()
    }

    def teardown() {
        //p.delete(flush:true)
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

            println "Found task: "+task?.id
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

        then: "the first task will be 2 as the algorithm returns jump results and picks the last one"
        int expectedTaskExternalId = 2
        task.externalIdentifier == Integer.toString(expectedTaskExternalId)

        while (task != null && expectedTaskExternalId < numberOfTasks-jump) {
            expectedTaskExternalId = expectedTaskExternalId + jump

            task = service.getNextTask(userId, p, task.id)

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
}
