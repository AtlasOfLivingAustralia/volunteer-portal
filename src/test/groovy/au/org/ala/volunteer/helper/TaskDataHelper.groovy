package au.org.ala.volunteer.helper

import au.org.ala.volunteer.Field
import au.org.ala.volunteer.ForumMessage
import au.org.ala.volunteer.ForumTopic
import au.org.ala.volunteer.Project
import au.org.ala.volunteer.ProjectForumTopic
import au.org.ala.volunteer.Task
import au.org.ala.volunteer.Template
import au.org.ala.volunteer.Transcription
import au.org.ala.volunteer.User
import au.org.ala.volunteer.ViewedTask
import groovy.util.logging.Slf4j


/**
 * Helper class for creating Projects, Tasks, Transcriptions, ViewedTasks in the database to assist setting up
 * data for testing.
 */
@Slf4j
class TaskDataHelper {

    static Project setupProject(String name = 'Test Project', boolean harvestable = false) {
        Project p = new Project(name:name, harvestableByAla: harvestable)
        p.template = new Template(name:"Test template", viewParams:[param1:'value1'], viewParams2: [param1:'value1'])
        p.template.save(failOnError:true)
        p.save(failOnError:true, flush:true)
        p
    }

    static Task addTask(Project project, int index) {
        Task task = new Task(project: project, externalIdentifier: Integer.toString(index))
        task.transcriptions = []
        task.viewedTasks = new HashSet()
        task.fields = new HashSet()
        task.save(flush: true, failOnError:true)
        task
    }

    static List<Task> setupTasks(Project project, int numberOfTasks) {
        (0..<numberOfTasks).collect { i -> addTask(project, i) }
    }

    static void transcribe(Task task, String userId, Map <Integer, Map<String, String>> fields = null) {

        view(task, userId)

        Transcription transcription = task.findUserTranscription(userId)
        if (!transcription) {
            transcription = task.addTranscription()
            task.save(failOnError:true)
        }

        log.debug("Updating transcription with id=${transcription.id}")
        transcription.fullyTranscribedBy = userId
        transcription.dateFullyTranscribed = new Date()

        if (fields) {
            fields.each { rec, fieldRec ->
                fieldRec.each {k, v ->
                    Field field = new Field(name: k, value: v, recordIdx: rec, transcribedByUserId: userId, task: task, transcription: transcription)
                    transcription.addToFields(field)
                }
            }
        }

        transcription.save(failOnError:true, flush:true)

        // The Field sync service would normally do this.
        if (task.allTranscriptionsComplete()) {
            task.isFullyTranscribed = true
        }

    }

    /**
     * Performs the same job as taskService.validate(). Domain no longer likes modifying parameters.
     * @param task the task
     * @param userId the user
     */
    static void validate(Task task, String userId) {
        if (!task.fullyValidatedBy) {
            task.fullyValidatedBy = userId
        }
        if (!task.dateFullyValidated) {
            task.dateFullyValidated = new Date()
        }
        if (!task.validatedUUID) {
            task.validatedUUID = UUID.randomUUID()
        }
        task.isValid = true
        task.save(flush: true, failOnError: true)
    }

    static void view(Task task, String userId, boolean recent = true) {

        long lastView = System.currentTimeMillis()
        if (!recent) {
            lastView  -= 1000*60*60*3 // 3 hours ago
        }
        ViewedTask viewedTask = new ViewedTask(task:task, userId:userId, numberOfViews: 1, lastView: lastView, skipped: false)
        task.viewedTasks.add(viewedTask)
        viewedTask.save(failOnError:true, flush:true)
        task.save(failOnError:true, flush:true)
    }

    static User setupUser() {
        User user = new User(firstName: 'Example', lastName: 'Test', userId: UUID.randomUUID().toString(), email: 'test@example.org', created: new Date())
        return user.save(flush: true, failOnError: true)
    }

    static ProjectForumTopic setupProjectForum(Project project, User user, int messages) {
        final pft = new ProjectForumTopic(project: project, creator: user, title: 'Test')
        pft.messages = setupForumMessages(pft, messages)
        return pft.save(flush: true, failOnError: true)
    }

    static Set<ForumMessage> setupForumMessages(ForumTopic ft, int messages) {
        (0..<messages).collect { new ForumMessage(topic: ft, user: ft.creator, date: new Date(), text: 'test', deleted: false) }.toSet()
    }
}
