package au.org.ala.volunteer.helper

import au.org.ala.volunteer.Field
import au.org.ala.volunteer.ForumMessage
import au.org.ala.volunteer.ForumTopic
import au.org.ala.volunteer.Project
import au.org.ala.volunteer.ProjectForumTopic
import au.org.ala.volunteer.ProjectType
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

    static Project setupProject(String projectName = 'Test Project', boolean harvestable = false) {
        ProjectType pt = new ProjectType().tap {
            name = PROJECT_TYPE_CAMERATRAP
            label = "Test Cameratrap"
        }
        Project p = new Project().tap {
            name = projectName
            harvestableByAla = harvestable
            projectType = pt
        }
        p.template = new Template().tap {
            name = "Test template"
            supportMultipleTranscriptions = true
            viewParams = [param1:'value1']
            viewParams2 = [param1:'value1']
        }
        pt.save(failOnError:true)
        p.template.save(failOnError:true)
        p.save(failOnError:true, flush:true)
        p
    }

    static Task addTask(Project projectInstance, int index) {
        Task task = new Task().tap {
            project = projectInstance
            externalIdentifier = Integer.toString(index)
        }
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
        log.debug("transcribing task: ${task}")
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

    static void view(Task taskInstance, String userIdValue, boolean recent = true) {

        long lastViewValue = System.currentTimeMillis()
        if (!recent) {
            lastViewValue  -= 1000*60*60*3 // 3 hours ago
        }
        ViewedTask viewedTask = new ViewedTask().tap {
            task = taskInstance
            userId = userIdValue
            numberOfViews = 1
            lastView = lastViewValue
            skipped = false
        }
        taskInstance.viewedTasks.add(viewedTask)
        viewedTask.save(failOnError:true, flush:true)
        taskInstance.save(failOnError:true, flush:true)
    }

    static User setupUser() {
//        User user = new User(firstName: 'Example', lastName: 'Test', userId: UUID.randomUUID().toString(), email: 'test@example.org', created: new Date())
        User user = new User().tap {
            firstName = 'Example'
            lastName = 'Test'
            userId = UUID.randomUUID().toString()
            email = 'test@example.org'
            created = new Date()
        }
        return user.save(flush: true, failOnError: true)
    }

    static ProjectForumTopic setupProjectForum(Project projectInstance, User userInstance, int messages) {
        final pft = new ProjectForumTopic().tap {
            project =  projectInstance
            creator = userInstance
            title = 'Test'
        }
        pft.messages = setupForumMessages(pft, messages)
        return pft.save(flush: true, failOnError: true)
    }

    static Set<ForumMessage> setupForumMessages(ForumTopic ft, int messages) {
        (0..<messages).collect { new ForumMessage().tap {
            topic = ft
            user = ft.creator
            date = new Date()
            text = 'test'
            deleted = false
        } }.toSet()
    }
}
