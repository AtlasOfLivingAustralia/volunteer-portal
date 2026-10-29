package au.org.ala.volunteer

import au.org.ala.volunteer.helper.FlybernateSpec
import grails.testing.services.ServiceUnitTest

import static au.org.ala.volunteer.helper.TaskDataHelper.addTask
import static au.org.ala.volunteer.helper.TaskDataHelper.createTranscription
import static au.org.ala.volunteer.helper.TaskDataHelper.setupProject

class FieldServiceSpec extends FlybernateSpec implements ServiceUnitTest<FieldService> {

    def setup() {
        service.dataSource = hibernateDatastore.dataSource
    }

    def "findAllTasksByFieldValues sets numberOfTranscriptions using fully transcribed rows only"() {
        given:
        Project project = setupProject()
        Task taskWithCompleteAndIncomplete = addTask(project, 1)
        Task taskWithIncompleteOnly = addTask(project, 2)

        new Field(
                task: taskWithCompleteAndIncomplete,
                name: 'scientificName',
                value: 'match value 1',
                recordIdx: 0,
                transcribedByUserId: 'user-1',
                superceded: false
        ).save(flush: true, failOnError: true)

        new Field(
                task: taskWithIncompleteOnly,
                name: 'scientificName',
                value: 'match value 2',
                recordIdx: 0,
                transcribedByUserId: 'user-2',
                superceded: false
        ).save(flush: true, failOnError: true)

        Transcription complete = createTranscription(taskWithCompleteAndIncomplete, 'user-1')
        complete.fullyTranscribedBy = 'user-1'
        complete.dateFullyTranscribed = new Date()
        complete.save(flush: true, failOnError: true)

        createTranscription(taskWithCompleteAndIncomplete, 'user-2').save(flush: true, failOnError: true)
        createTranscription(taskWithIncompleteOnly, 'user-3').save(flush: true, failOnError: true)

        Map params = [sort: 'id', order: 'asc', max: 10, offset: 0]

        when:
        Map result = service.findAllTasksByFieldValues(project, 'match value', params)

        then:
        result.taskCount == 2
        result.taskList*.id.containsAll([taskWithCompleteAndIncomplete.id, taskWithIncompleteOnly.id])
        result.taskList.find { it.id == taskWithCompleteAndIncomplete.id }.numberOfTranscriptions == 1
        result.taskList.find { it.id == taskWithIncompleteOnly.id }.numberOfTranscriptions == 0
    }
}

