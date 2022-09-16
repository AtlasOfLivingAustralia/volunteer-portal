package au.org.ala.volunteer.helper

import grails.config.Config
import grails.persistence.Entity
import grails.test.hibernate.HibernateSpec
import groovy.transform.CompileStatic
import org.flywaydb.core.Flyway
import org.grails.config.PropertySourcesConfig
import org.grails.orm.hibernate.HibernateDatastore
import org.grails.orm.hibernate.cfg.Settings
import org.hibernate.Session
import org.hibernate.SessionFactory
import org.springframework.beans.factory.config.BeanDefinition
import org.springframework.boot.env.PropertySourcesLoader
import org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider
import org.springframework.core.env.MapPropertySource
import org.springframework.core.env.MutablePropertySources
import org.springframework.core.env.PropertyResolver
import org.springframework.core.io.DefaultResourceLoader
import org.springframework.core.io.ResourceLoader
import org.springframework.core.type.filter.AnnotationTypeFilter
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.TransactionStatus
import org.springframework.transaction.interceptor.DefaultTransactionAttribute
import spock.lang.AutoCleanup
import spock.lang.Shared
import spock.lang.Specification

/**
 * This is the HibernateSpec with Flyway migrate / clean integrated instead of using Hibernate create-drop
 */
@CompileStatic
abstract class FlybernateSpec extends Specification {

    @Shared @AutoCleanup HibernateDatastore hibernateDatastore
    @Shared PlatformTransactionManager transactionManager
    @Shared Flyway flyway = new Flyway()

    void setupSpec() {
        PropertySourcesLoader loader = new PropertySourcesLoader()
        ResourceLoader resourceLoader = new DefaultResourceLoader()
        MutablePropertySources propertySources = loader.propertySources
        loader.load resourceLoader.getResource("application.yml")
        loader.load resourceLoader.getResource("application.groovy")
        propertySources.addFirst(new MapPropertySource("defaults", getConfiguration()))
        Config config = new PropertySourcesConfig(propertySources)

        flyway.setDataSource(config.getProperty('environments.test.dataSource.url'),
                config.getProperty('environments.test.dataSource.username'),
                config.getProperty('environments.test.dataSource.password'))

        flyway.setLocations('db/migration')
        flyway.clean()
        flyway.migrate()

        List<Class> domainClasses = getDomainClasses()

        if (!domainClasses) {
            String packageName = config.getProperty('grails.codegen.defaultPackage', getClass().package.name)
            ClassPathScanningCandidateComponentProvider componentProvider = new ClassPathScanningCandidateComponentProvider(false)
            componentProvider.addIncludeFilter(new AnnotationTypeFilter(Entity))

            for (BeanDefinition candidate in componentProvider.findCandidateComponents(packageName)) {
                Class persistentEntity = Class.forName(candidate.beanClassName)
                domainClasses << persistentEntity
            }
        }
        hibernateDatastore = new HibernateDatastore(
                (PropertyResolver)config,
                domainClasses as Class[])
        transactionManager = hibernateDatastore.getTransactionManager()
    }

    /**
     * The transaction status
     */
    TransactionStatus transactionStatus

    void setup() {
        transactionStatus = transactionManager.getTransaction(new DefaultTransactionAttribute())
    }

    void cleanup() {
        if(isRollback()) {
            transactionManager.rollback(transactionStatus)
        }
        else {
            transactionManager.commit(transactionStatus)
        }
        flyway.clean()
    }

    /**
     * @return The configuration
     */
    Map getConfiguration() {
        Collections.singletonMap(Settings.SETTING_DB_CREATE, "validate")
    }

    /**
     * @return the current session factory
     */
    SessionFactory getSessionFactory() {
        hibernateDatastore.getSessionFactory()
    }

    /**
     * @return the current Hibernate session
     */
    Session getHibernateSession() {
        getSessionFactory().getCurrentSession()
    }

    /**
     * Whether to rollback on each test (defaults to true)
     */
    boolean isRollback() {
        return true
    }
    /**
     * @return The domain classes
     */
    List<Class> getDomainClasses() { [] }
}
