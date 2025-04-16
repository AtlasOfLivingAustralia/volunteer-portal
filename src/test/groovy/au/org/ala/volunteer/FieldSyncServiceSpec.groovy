package au.org.ala.volunteer

import au.org.ala.volunteer.helper.FlybernateSpec
import grails.testing.gorm.DataTest
import grails.testing.services.ServiceUnitTest
import groovy.util.logging.Slf4j
import org.grails.spring.beans.factory.InstanceFactoryBean
import org.jooq.DSLContext
import org.jooq.SQLDialect
import org.jooq.impl.DSL

import java.sql.Connection

import static au.org.ala.volunteer.helper.TaskDataHelper.*

@Slf4j
class FieldSyncServiceSpec extends FlybernateSpec implements ServiceUnitTest<FieldSyncService> {

    TaskService taskService

    def user
    def userList = []
    def transcriptionFields = [scientificName: "Macropodidae", vernacularName: "Kangaroo", individualCount: 1]
    def project

    Closure<DSLContext> jooqContextFactoryBean = { ->
        // need to reach deep down into the transaction status to get the connection object in the transaction
        def conn = transactionStatus.transaction.connectionHolder.connectionHandle.connection
        DSL.using(conn, SQLDialect.POSTGRES)
    }

    def setup() {
        defineBeans {
            jooqContextFactory(InstanceFactoryBean, jooqContextFactoryBean, Closure/*<DSLContext>*/)
        }

        user = setupUser()
        (1..2).each { i ->
            def userA = setupUser("user${i}")
            def fields = transcriptionFields
            fields.individualCount = (i % 2) + 1
            userList << [user: userA, fields: fields]
        }

        taskService = Mock(TaskService)
        service.taskService = taskService
    }

    def "syncFields should set fullyTranscribedBy and increment transcription count when markAsFullyTranscribed is true"() {
        setup:
        project = setupProject()
        def task = addTask(project, 0)
        log.info("Task: ${task}")
        def transcription = createTranscription(task, user.userId as String)
        log.info("User transcribed count: ${user.transcribedCount}, transcription: ${transcription}")

        when:
        service.syncFields(task, [:], user.userId, true, false, null, [], null, transcription)
        log.info("User transcribed count: ${user.transcribedCount}")

        then:
        transcription.fullyTranscribedBy == user.userId
        transcription.dateFullyTranscribed != null
        user.transcribedCount == 1
        taskService.allTranscriptionsComplete(task) >> false
        task.isFullyTranscribed == false
    }

    def "syncFields should throw IllegalArgumentException when markAsFullyTranscribed is true and transcription is null"() {
        given:
        def task = Mock(Task)

        when:
        service.syncFields(task, transcriptionFields, "user1", true, false, null, [], null, null)

        then:
        thrown(IllegalArgumentException)
    }

    def "syncFields should synchronize access to task when multiple threads execute concurrently"() {
        given:
        project = setupProject()
        setTranscriptionsPerTask(project, 2)
        def task = addTask(project, 0)
        log.info("Task: ${task}")
        userList.each { row ->
            def user = row.user as User
            def transcription = createTranscription(task, user.userId)
            row.transcription = transcription
        }

        when:
        def threads = []
        (1..2).each { i ->
            threads << Thread.start {
                log.info("Starting thread ${i}")
                def user = userList[i-1].user as User
                //def transcription = createTranscription(task, user.userId)
                def transcription = userList[i-1].transcription as Transcription
                log.info("Transcription: ${transcription}")
                service.syncFields(task, userList[i-1].fields as Map, user.userId, true, false, null, [], null, transcription)
                log.info("User transcribed count: ${user.transcribedCount}, transcription: ${transcription}")
            }
        }
        threads*.join()

        then:
        task.viewedTasks.size() == 2
        task.transcriptions.size() == 2
    }
}
