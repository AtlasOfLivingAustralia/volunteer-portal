//grails.project.class.dir = "target/classes"
//grails.project.test.class.dir = "target/test-classes"
//grails.project.test.reports.dir = "target/test-reports"
grails.project.work.dir = "target"
grails.project.war.file = "target/${appName}.war"

grails.project.fork = [
        test: false,
        run: false,
        war: false,
        console: false
]

grails.project.dependency.resolver = "maven" // or ivy

grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
        // uncomment to disable ehcache
        // excludes 'ehcache'
    }
    log "warn" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    repositories {
        grailsPlugins()
        grailsHome()
        grailsCentral()

        // uncomment the below to enable remote dependency resolution
        // from public Maven repositories
        //mavenLocal()
        mavenCentral()
        mavenRepo "http://snapshots.repository.codehaus.org"
        mavenRepo "http://repository.codehaus.org"
        mavenRepo "http://download.java.net/maven/2/"
        mavenRepo "http://repository.jboss.com/maven2/"
        mavenRepo "http://maven.ala.org.au/repository/"
        mavenRepo "http://maven.tmatesoft.com/content/repositories/releases/"
    }
    plugins {
        build ":release:3.0.1"
        compile ":cache:1.1.7"
        build ':tomcat:7.0.54'
        runtime ':hibernate:3.6.10.16'
        runtime ":jquery:1.8.3"
        runtime ":jquery-ui:1.10.4"
        runtime ':resources:1.2.8'
        runtime ":mail:1.0.6"
        runtime ":csv:0.3.1"
        runtime ":executor:0.3"
        compile ":markdown:1.1.1"
        runtime ":pretty-time:0.3"
        runtime ":quartz:1.0.1"
        runtime ":tiny-mce:3.4.9"
        runtime ":webxml:1.4.1"
        runtime ":ala-web-theme:0.8.1"
        runtime ":lesscss-resources:1.3.3"
        compile ':scaffolding:2.0.3'
        runtime ':database-migration:1.4.0'
        compile (':webflow:2.0.8.1') {
            excludes 'javassist'
        }
        compile ':scaffolding:2.0.3'
    }

    dependencies {
        runtime 'postgresql:postgresql:9.1-901.jdbc4'
        compile 'org.imgscalr:imgscalr-lib:4.2'
        compile 'com.squareup.retrofit:retrofit:1.6.1'
        compile 'com.google.guava:guava:17.0'
    }
}
