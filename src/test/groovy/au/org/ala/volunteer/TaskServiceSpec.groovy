package au.org.ala.volunteer

import grails.test.hibernate.HibernateSpec
import grails.test.mixin.TestFor
import org.grails.orm.hibernate.cfg.Settings


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
       setupProject()
    }

    def teardown() {
        //p.delete(flush:true)
    }

    private void setupProject() {
        p = new Project(name:"Test Project")
        p.template = new Template(name:"Test template", viewParams:[param1:'value1'], viewParams2: [param1:'value1'])
        p.template.save(failOnError:true)
        p.save(failOnError:true)
    }

    private void addTask(Project project, int transcriptionCount) {
        Task task = new Task(project: project)
        task.transcriptions = []
        task.viewedTasks = new HashSet()
        task.save(failOnError:true)

    }

    private void setupTasks(Project project, int numberOfTasks, int transcriptionCount) {
        for (int i=0; i<numberOfTasks; i++) {
            addTask(project, transcriptionCount)
        }
    }

    private void transcribe(Task task, String userId) {

        view(task, userId)

        Transcription transcription = task.transcriptions.find{it.fullyTranscribedBy == userId}
        if (!transcription) {
            transcription = new Transcription(task:task, project:task.project)
            task.transcriptions.add(transcription)
            task.save(failOnError:true)
        }

        println "Updating transcription with id="+transcription.id
        transcription.fullyTranscribedBy = userId
        transcription.dateFullyTranscribed = new Date()
        transcription.save(failOnError:true, flush:true)



    }

    private void view(Task task, String userId, boolean recent = true) {

        ViewedTask viewedTask = new ViewedTask(task:task, userId:userId, numberOfViews: 1)
        task.viewedTasks.add(viewedTask)
        viewedTask.save(failOnError:true, flush:true)
        task.save(failOnError:true, flush:true)
    }

    def "when are are multiple transcriptions per task, the same user shouldn't be assigned a task they've already transcribed"() {
        setup:

        int transcriptionsPerTask = 5
        p.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        int numberOfTasks = 10
        setupTasks(p, numberOfTasks, transcriptionsPerTask)

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

    }

    def "when there are multiple transcriptions per task, we should still be able to assign them to our user if all of the transcriptions are not completed for the Task"() {
        setup:

        int transcriptionsPerTask = 5
        p.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        int numberOfTasks = 10
        setupTasks(p, numberOfTasks, transcriptionsPerTask)
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
        p.template.viewParams = [transcriptionsPerTask:transcriptionsPerTask as String]
        int numberOfTasks = 10
        setupTasks(p, numberOfTasks, transcriptionsPerTask)
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
}
