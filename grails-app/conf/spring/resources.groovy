import au.org.ala.volunteer.ApplicationContextHolder
import au.org.ala.volunteer.BVPServletFilter
import au.org.ala.volunteer.DigivolServletContextConfig
import au.org.ala.volunteer.collectory.CollectoryClientFactoryBean
import org.flywaydb.core.Flyway
import org.flywaydb.core.api.MigrationVersion
import org.springframework.beans.factory.config.BeanDefinition
import org.springframework.boot.web.servlet.FilterRegistrationBean

// Place your Spring DSL code here
beans = {
//    customPageRenderer(CustomPageRenderer, ref("groovyPagesTemplateEngine")) {
//        groovyPageLocator = ref("groovyPageLocator")
//    }

    collectoryClient(CollectoryClientFactoryBean) {
        endpoint = 'http://collections.ala.org.au/ws/'
    }

//    bvpSecurePluginFilter(BVPSecurePluginFilter) {
//        securityPrimitives = ref("securityPrimitives")
//    }

    applicationContextHolder(ApplicationContextHolder) { bean ->
        bean.factoryMethod = 'getInstance'
    }

    digivolServletContextConfig(DigivolServletContextConfig)

    bvpServletFilter(FilterRegistrationBean) {
        name = 'BVPServletFilter'
        filter = bean(BVPServletFilter)
        urlPatterns = [ '/*' ]
        asyncSupported = true
    }

    if (application.config.flyway.enabled) {

        flyway(Flyway) { bean ->
            bean.initMethod = 'migrate'
            dataSource = ref('dataSource')
            baselineOnMigrate = application.config.flyway.baselineOnMigrate
            locations = application.config.flyway.locations ?: 'classpath:db/migration'
            if (application.config.flyway.baselineVersion) baselineVersionAsString = application.config.flyway.baselineVersion.toString()
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