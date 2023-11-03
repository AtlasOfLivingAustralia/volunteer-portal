import au.org.ala.volunteer.ApplicationContextHolder
import au.org.ala.volunteer.BVPServletFilter
import au.org.ala.volunteer.DigivolServletContextConfig
import au.org.ala.volunteer.collectory.CollectoryClientFactoryBean
import org.flywaydb.core.Flyway
import org.flywaydb.core.api.configuration.ClassicConfiguration
import org.springframework.beans.factory.config.BeanDefinition
import org.springframework.boot.web.servlet.FilterRegistrationBean

// Place your Spring DSL code here
beans = {
    collectoryClient(CollectoryClientFactoryBean) {
        endpoint = 'http://collections.ala.org.au/ws/'
    }

    applicationContextHolder(ApplicationContextHolder) { bean ->
        bean.factoryMethod = 'getInstance'
    }

    digivolServletContextConfig(DigivolServletContextConfig)

    bvpServletFilterBean(BVPServletFilter) {
        authService = ref("authService")
    }
    bvpServletFilterRegistrationBean(FilterRegistrationBean) {
        name = 'BVPServletFilter'
        filter = ref("bvpServletFilterBean")
        urlPatterns = [ '/*' ]
        asyncSupported = true
    }

    if (application.config.getProperty('spring.flyway.enabled', Boolean)) {

        flywayConfiguration(ClassicConfiguration) { bean ->
            dataSource = ref('dataSource')
            defaultSchema = application.config.getProperty('spring.flyway.default-schema')
            table = application.config.getProperty('spring.flyway.table')
            baselineOnMigrate = application.config.getProperty('spring.flyway.baselineOnMigrate', Boolean, true)
            def outOfOrderProp = application.config.getProperty('spring.flyway.outOfOrder', Boolean, false)
            outOfOrder = outOfOrderProp
            locationsAsStrings = application.config.getProperty('spring.flyway.locations', List<String>, ['classpath:db/migration'])
            if (application.config.getProperty('spring.flyway.baselineVersion', Integer))
                baselineVersionAsString = application.config.getProperty('spring.flyway.baselineVersion', Integer).toString()
        }

        flyway(Flyway, ref('flywayConfiguration')) { bean ->
            bean.initMethod = 'migrate'
        }

        BeanDefinition sessionFactoryBeanDef = getBeanDefinition('sessionFactory')

        if (sessionFactoryBeanDef) {
            addDependency(sessionFactoryBeanDef, 'flyway')
        }

        BeanDefinition hibernateDatastoreBeanDef = getBeanDefinition('hibernateDatastore')
        if (hibernateDatastoreBeanDef) {
            addDependency(hibernateDatastoreBeanDef, 'flyway')
        }

    }
    else {
        log.info "Grails Flyway plugin has been disabled"
    }
}

def addDependency(BeanDefinition beanDef, String dependencyName) {
    def dependsOnList = [ dependencyName ] as Set
    if (beanDef.dependsOn?.length > 0) {
        dependsOnList.addAll(beanDef.dependsOn)
    }
    beanDef.dependsOn = dependsOnList as String[]
}