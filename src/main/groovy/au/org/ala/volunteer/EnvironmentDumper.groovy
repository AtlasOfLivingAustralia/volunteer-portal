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
        log.debug("Running in ${Environment.current.name}")

        // Get configuration from GrailsApplication.
        final Config configuration = grailsApplication.config

        def props = [
                [prop: 'grails.serverURL', type: String],
                [prop: 'grails.mail.disabled', type: Boolean],
                [prop: 'grails.mail.host', type: String],
                [prop: 'grails.mail.port', type: Integer],
                [prop: 'grails.mail.overrideAddress', type: String],
                [prop: 'server.url', type: String],
                [prop: 'server.contextPath', type: String],
                [prop: 'security.cas.appServerName', type: String],
                [prop: 'images.home', type: String],
                [prop: 'images.urlPrefix', type: String],
                [prop: 'ala.image.service.url', type: String],
                [prop: 'dataSource.url', type: String],
                [prop: 'dataSource.dbCreate', type: String],
        ]

        // log the value for each config item
        props.forEach {
            try {
                final String sampleConfigValue = configuration.getProperty(it.prop, it.type)
                log.debug "Value for ${it.prop} configuration property = $sampleConfigValue"
            } catch (e) {
                log.warn("Couldn't parse ${it.prop} value: ${configuration.getProperty(it.prop)} as ${it.type}")
            }
        }

        def dataSourceProps = configuration.get('dataSource.properties')
        if (dataSourceProps instanceof Map) {
            dataSourceProps.each { k,v ->
                if (!k.toString().equalsIgnoreCase('password')) log.debug("DataSource property $k: $v")
            }
        }
    }

}