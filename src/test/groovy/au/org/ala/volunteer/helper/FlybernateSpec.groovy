package au.org.ala.volunteer.helper

import grails.config.Config
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import org.flywaydb.core.Flyway
import org.grails.config.PropertySourcesConfig
import org.grails.orm.hibernate.HibernateDatastore
import org.grails.orm.hibernate.cfg.Settings
import org.hibernate.Session
import org.hibernate.SessionFactory
import org.junit.ClassRule
import org.springframework.boot.env.PropertySourceLoader
import org.springframework.core.env.MapPropertySource
import org.springframework.core.env.MutablePropertySources
import org.springframework.core.env.PropertyResolver
import org.springframework.core.env.PropertySource
import org.springframework.core.io.DefaultResourceLoader
import org.springframework.core.io.Resource
import org.springframework.core.io.ResourceLoader
import org.springframework.core.io.support.SpringFactoriesLoader
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
@Slf4j
abstract class FlybernateSpec extends Specification {

    @Shared @AutoCleanup HibernateDatastore hibernateDatastore
    @Shared PlatformTransactionManager transactionManager
    @Shared Flyway flyway = null

    static Config getConfig() {

        List<PropertySourceLoader> propertySourceLoaders = SpringFactoriesLoader.loadFactories(PropertySourceLoader.class, FlybernateSpec.class.getClassLoader())
        ResourceLoader resourceLoader = new DefaultResourceLoader()
        MutablePropertySources propertySources = new MutablePropertySources()
        PropertySourceLoader ymlLoader = propertySourceLoaders.find { it.getFileExtensions().toList().contains("yml") }
        if (ymlLoader) {
            load(resourceLoader, ymlLoader, "application.yml").each {
                propertySources.addLast(it)
            }
        }
        PropertySourceLoader groovyLoader = propertySourceLoaders.find { it.getFileExtensions().toList().contains("groovy") }
        if (groovyLoader) {
            load(resourceLoader, groovyLoader, "application.groovy").each {
                propertySources.addLast(it)
            }
        }
        propertySources.addFirst(new MapPropertySource("defaults", getConfiguration()))
        return new PropertySourcesConfig(propertySources)
    }

    void setupSpec() {
        Config config = getConfig()

        def flywayConfig = Flyway.configure()
                .dataSource(config.getProperty('environments.test.dataSource.url'), config.getProperty('dataSource.username'), config.getProperty('dataSource.password'))
                .placeholders([
                        'baseUrl': config.getProperty('grails.serverURL', 'https://devt.ala.org.au/digivol')
                ])
                .locations('db/migration')
                .cleanDisabled(config.getProperty('flyway.cleanDisabled', Boolean, false))

        flyway = new Flyway(flywayConfig)
        flyway.clean()
        flyway.migrate()

        List<Class> domainClasses = getDomainClasses()
        String packageName = getPackageToScan(config)

        if (!domainClasses) {
            Package packageToScan = Package.getPackage(packageName) ?: getClass().getPackage()
            hibernateDatastore = new HibernateDatastore((PropertyResolver) config, packageToScan)
        } else {
            hibernateDatastore = new HibernateDatastore((PropertyResolver) config, domainClasses as Class[])
        }
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
        log.debug("FlybernateSpec: Cleanup()")
        if (isRollback()) {
            log.debug("FlybernateSpec: Rolling back...")
            transactionManager.rollback(transactionStatus)
        } else {
            log.debug("FlybernateSpec: Committing...")
            transactionManager.commit(transactionStatus)
        }
    }

    void cleanupSpec() {
        log.debug("FlybernateSpec: CleanupSpec()")
        def result = flyway.clean()
        log.debug("FlybernateSpec: Schemas Cleaned ${result.schemasCleaned}")
        log.debug("FlybernateSpec: Schemas Dropped ${result.schemasDropped}")
    }

    /**
     * @return The configuration
     */
    static Map getConfiguration() {
        Collections.singletonMap(Settings.SETTING_DB_CREATE,  (Object) "validate") // CHANGED from 'create-drop' to 'validate'
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

    /**
     * Obtains the default package to scan
     *
     * @param config The configuration
     * @return The package to scan
     */
    protected String getPackageToScan(Config config) {
        config.getProperty('grails.codegen.defaultPackage', getClass().package.name)
    }

    private static List<PropertySource> load(ResourceLoader resourceLoader, PropertySourceLoader loader, String filename) {
        if (canLoadFileExtension(loader, filename)) {
            Resource appYml = resourceLoader.getResource(filename)
            return loader.load(appYml.getDescription(), appYml) as List<PropertySource>
        } else {
            return Collections.emptyList()
        }
    }

    private static boolean canLoadFileExtension(PropertySourceLoader loader, String name) {
        return Arrays
                .stream(loader.fileExtensions)
                .map { String extension -> extension.toLowerCase() }
                .anyMatch { String extension -> name.toLowerCase().endsWith(extension) }
    }
}

