package au.org.ala.volunteer

import grails.boot.GrailsApp
import grails.boot.config.GrailsAutoConfiguration
import groovy.util.logging.Slf4j
import org.springframework.context.annotation.ComponentScan

@ComponentScan(basePackageClasses = EnvironmentDumper)
@Slf4j
class Application extends GrailsAutoConfiguration {
    static void main(String[] args) {
        GrailsApp.run(Application, args)
    }
}