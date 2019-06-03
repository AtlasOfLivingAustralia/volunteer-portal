package au.org.ala.volunteer.au.org.ala.volunteer.helper

import au.org.ala.volunteer.Field
import au.org.ala.volunteer.Project
import au.org.ala.volunteer.Task
import au.org.ala.volunteer.Template
import au.org.ala.volunteer.Transcription
import au.org.ala.volunteer.ViewedTask


/**
 * Helper class for creating Projects, Tasks, Transcriptions, ViewedTasks in the database to assist setting up
 * data for testing.
 */
class TaskDataHelper {

    static Project setupProject() {
        Project p = new Project(name:"Test Project")
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
        task.save(failOnError:true)
        task
    }

    static void setupTasks(Project project, int numberOfTasks) {
        for (int i=0; i<numberOfTasks; i++) {
            addTask(project, i)
        }
    }

    static void transcribe(Task task, String userId, Map<String, String> fields = null) {

        view(task, userId)

        Transcription transcription = task.findUserTranscription(userId)
        if (!transcription) {
            transcription = task.addTranscription()
            task.save(failOnError:true)
        }

        println "Updating transcription with id="+transcription.id
        transcription.fullyTranscribedBy = userId
        transcription.dateFullyTranscribed = new Date()

        if (fields) {
            fields.each { k, v ->
                Field field = new Field(name:k, value:v, transcribedByUserId: userId, task:task, transcription: transcription, recordIdx: 0)
                transcription.addToFields(field)
            }
        }

        transcription.save(failOnError:true, flush:true)

        // The Field sync service would normally do this.
        if (task.allTranscriptionsComplete()) {
            task.isFullyTranscribed = true
        }

    }

    static void view(Task task, String userId, boolean recent = true) {

        long lastView = System.currentTimeMillis()
        if (!recent) {
            lastView  -= 1000*60*60*3 // 3 hours ago
        }
        ViewedTask viewedTask = new ViewedTask(task:task, userId:userId, numberOfViews: 1, lastView: lastView)
        task.viewedTasks.add(viewedTask)
        viewedTask.save(failOnError:true, flush:true)
        task.save(failOnError:true, flush:true)
    }

}
