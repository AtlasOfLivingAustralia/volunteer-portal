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
class Application extends GrailsAutoConfiguration implements EnvironmentAware {
    static void main(String[] args) {
        GrailsApp.run(Application, args)
    }

    @Override
    void setEnvironment(Environment environment) {
        load(this, environment)
    }

    static load(GrailsAutoConfiguration application, Environment environment) {
        if (application && environment) {
            DefaultResourceLocator resourceLocator = new DefaultResourceLocator()
            if (environment.containsProperty('grails.config.locations')) {
                for (String configLocation : environment.getProperty('grails.config.locations', List.class)) {
                    def configurationResource = resourceLocator.findResourceForURI(configLocation)
                    if (configurationResource) {
                        String fileName = configurationResource.getFile().getName()
                        String ext = Files.getFileExtension(fileName)
                        log.info("Attempting to load external config: $fileName")
                        MapPropertySource source
                        switch (ext.toLowerCase()) {
                            case 'groovy':
                                log.info("Loading external config: $fileName as groovy")
                                def config = new ConfigSlurper(grails.util.Environment.current.name).parse(IOUtils.toString(configurationResource.getInputStream(), 'UTF-8'))
                                source = new MapPropertySource(configLocation, config)
                                break
                            case 'properties':
                            case 'config':
                                log.info("Loading external config: $fileName as properties")
                                PropertiesFactoryBean pfb = new PropertiesFactoryBean()
                                pfb.setFileEncoding('UTF-8')
                                pfb.setLocation(configurationResource)
                                pfb.afterPropertiesSet()
                                Properties properties = pfb.getObject()
                                source = new PropertiesPropertySource(configLocation, properties)
                                break
                            case 'yml':
                                log.info("Loading external config: $fileName as yaml")
                                YamlPropertiesFactoryBean ypfb = new YamlPropertiesFactoryBean()
                                ypfb.setResources(configurationResource)
                                ypfb.afterPropertiesSet()
                                Properties properties = ypfb.getObject()
                                source = new PropertiesPropertySource(configLocation, properties)
                                break
                            default:
                                log.warn("NOT Loading external config: $fileName")
                                continue
                        }
                        if (source) {
                            (environment as ConfigurableEnvironment).propertySources.addFirst(source)
                        }
                    }
                }
            }
        }
    }
}