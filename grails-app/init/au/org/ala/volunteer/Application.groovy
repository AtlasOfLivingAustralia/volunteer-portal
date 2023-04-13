package au.org.ala.volunteer

import grails.boot.GrailsApp
import grails.boot.config.GrailsAutoConfiguration
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import org.jooq.DSLContext
import org.jooq.SQLDialect
import org.jooq.conf.Settings
import org.jooq.impl.DSL
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.ComponentScan

import javax.sql.DataSource

@ComponentScan(basePackageClasses = EnvironmentDumper)
@CompileStatic
@Slf4j
class Application extends GrailsAutoConfiguration {
    static void main(String[] args) {
        GrailsApp.run(Application, args)
    }

    @Bean
    SQLDialect jooqDialect() {
        SQLDialect.POSTGRES
    }

    @Bean
    Settings jooqSettings() {
        new Settings().withRenderFormatted(grailsApplication.config.getProperty('dataSource.logSql', Boolean, false))
    }

    @Bean
    Closure<DSLContext> jooqContext(DataSource dataSource) {
        { -> DSL.using(dataSource, jooqDialect(), jooqSettings()) }
    }
}