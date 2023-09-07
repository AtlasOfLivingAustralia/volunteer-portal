package au.org.ala.volunteer

import au.org.ala.volunteer.helper.FlybernateSpec
//import grails.test.mixin.TestFor
import grails.testing.services.ServiceUnitTest
import grails.web.mapping.LinkGenerator
import groovy.util.logging.Slf4j
import org.grails.spring.beans.factory.InstanceFactoryBean
import org.jooq.DSLContext
import org.jooq.SQLDialect
import org.jooq.impl.DSL
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

import static au.org.ala.volunteer.helper.TaskDataHelper.setupProject
import static au.org.ala.volunteer.helper.TaskDataHelper.setupProjectForum
import static au.org.ala.volunteer.helper.TaskDataHelper.setupTasks
import static au.org.ala.volunteer.helper.TaskDataHelper.setupUser
import static au.org.ala.volunteer.helper.TaskDataHelper.transcribe
import static au.org.ala.volunteer.helper.TaskDataHelper.validate

//@TestFor(ProjectService)
@Slf4j
class ProjectServiceSpec extends FlybernateSpec implements ServiceUnitTest<ProjectService> {

//    @Configuration
//    @Slf4j
//    static class Config {
//
//        ProjectServiceSpec projectServiceSpec
//
//        Config(ProjectServiceSpec projectServiceSpec) {
//            this.projectServiceSpec = projectServiceSpec
//        }
//
//        @Bean
//        Closure<DSLContext> jooqContextFactory() {
//            { ->
//                // need to reach deep down into the transaction status to get the connection object in the transaction
//                def conn = projectServiceSpec.transactionStatus.transaction.connectionHolder.connectionHandle.connection
//                DSL.using(conn, SQLDialect.POSTGRES_9_5)
//            }
//        }
//    }
//
//    def doWithSpring = {
//        testConfig(Config, this)
//    }

    Closure<DSLContext> jooqContextFactoryBean =
        { ->
            // need to reach deep down into the transaction status to get the connection object in the transaction
            def conn = transactionStatus.transaction.connectionHolder.connectionHandle.connection
            DSL.using(conn, SQLDialect.POSTGRES)
        }

    def setup() {
        defineBeans {
            jooqContextFactory(InstanceFactoryBean, jooqContextFactoryBean, Closure/*<DSLContext>*/)
        }
        service.grailsLinkGenerator = Stub(LinkGenerator)
        service.i18nService = Stub(I18nService)
    }

    def "ensure ALA harvest returns correct data"() {
        setup:

        def u = setupUser()
        def u2 = setupUser()

        def p = setupProject('Test Name',true)
        def p2 = setupProject('Test Name No Tasks',true)
        def p3 = setupProject('Test Name Multitranscription',true).with { it.transcriptionsPerTask = 2; it }.save(flush: true)
        def n = setupProject('Non harvest name',false)

        def ts = setupTasks(p, 3)
        def t3s = setupTasks(p3, 3)
        setupTasks(n, 2)

        transcribe(ts[0], u.userId)
        transcribe(ts[1], u.userId)

        validate(ts[0], u.userId)

        transcribe(t3s[0], u.userId)
        transcribe(t3s[0], u2.userId)

        transcribe(t3s[1], u.userId)

        setupProjectForum(p, u, 2)

        when:
        def results = service.harvestProjects()

        then:
        results.size() == 3
        results[0].name == 'Test Name'
        results[0].tasksCount == 3
        results[0].tasksTranscribedCount == 2
        results[0].tasksValidatedCount == 1
        results[0].forumMessagesCount == 2
        results[1].name == 'Test Name No Tasks'
        results[1].tasksCount == 0
        results[1].forumMessagesCount == 0
        results[2].name == 'Test Name Multitranscription'
        results[2].tasksCount == 3
        results[2].tasksTranscribedCount == 1
        results[2].tasksValidatedCount == 0
        results[2].forumMessagesCount == 0

    }
}
