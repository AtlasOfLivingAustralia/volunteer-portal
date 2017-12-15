package au.org.ala.volunteer

import grails.config.Config
import grails.core.GrailsApplication
import grails.util.Environment
import groovy.util.logging.Slf4j
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component

@Component
@Slf4j
class EnvironmentDumper implements CommandLineRunner {

    @Autowired
    GrailsApplication grailsApplication

    @Override
    void run(final String... args) throws Exception {
        println "Running in ${Environment.current.name}"

        // Get configuration from GrailsApplication.
        final Config configuration = grailsApplication.config

        def props = [
                'grails.serverURL',
                'grails.mail.disabled',
                'grails.mail.host',
                'grails.mail.port',
                'grails.mail.overrideAddress',
                'server.url',
                'server.contextPath',
                'security.cas.appServerName',
                'images.home',
                'images.urlPrefix',
                'ala.image.service.url',
                'dataSource.url',
                'dataSource.dbCreate',
                'dataSource.properties'
                ]

        // log the value for each config item
        props.forEach {
            final String sampleConfigValue = configuration.getProperty(it)
            log.info "Value for $it configuration property = $sampleConfigValue"
        }
    }

}