package au.org.ala.volunteer

import com.google.common.io.Files
import grails.boot.GrailsApp
import grails.boot.config.GrailsAutoConfiguration
import grails.io.IOUtils
import groovy.util.logging.Slf4j
import org.grails.core.io.DefaultResourceLocator
import org.springframework.beans.factory.config.PropertiesFactoryBean
import org.springframework.beans.factory.config.YamlPropertiesFactoryBean
import org.springframework.context.EnvironmentAware
import org.springframework.context.annotation.ComponentScan
import org.springframework.core.env.ConfigurableEnvironment
import org.springframework.core.env.Environment
import org.springframework.core.env.MapPropertySource
import org.springframework.core.env.PropertiesPropertySource

@ComponentScan(basePackageClasses = EnvironmentDumper)
@Slf4j
class Application extends GrailsAutoConfiguration {
    static void main(String[] args) {
        GrailsApp.run(Application, args)
    }
}