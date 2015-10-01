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

grails.project.target.level = 1.7
grails.project.source.level = 1.7

grails.project.dependency.resolver = "maven" // or ivy

grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
        // uncomment to disable ehcache
        // excludes 'ehcache'
    }
    log "warn" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    checksums true // Whether to verify checksums on resolve
    legacyResolve false // whether to do a secondary resolve on plugin installation, not advised and here for backwards compatibility

    repositories {
        inherits true // Whether to inherit repository definitions from plugins

        grailsPlugins()
        grailsHome()
        mavenLocal()
        mavenRepo("http://nexus.ala.org.au/content/groups/public/") {
            updatePolicy 'always'
        }
        grailsCentral()
        mavenCentral()
        // uncomment these (or add new ones) to enable remote dependency resolution from public Maven repositories
        //mavenRepo "http://repository.codehaus.org"
        //mavenRepo "http://download.java.net/maven/2/"
        //mavenRepo "http://repository.jboss.com/maven2/"
    }

    plugins {
        build ":release:3.0.1"
        compile ":cache:1.1.8"
        runtime ":cache-ehcache:1.0.4"
        build ':tomcat:7.0.55.3'
//        runtime (':hibernate:3.6.10.18') { //runtime ":hibernate4:4.3.10"
//            excludes 'net.sf.ehcache:ehcache-core'
//        }
        runtime ':hibernate4:4.3.10'

        runtime ":jquery:1.11.1"
        runtime ":jquery-ui:1.10.4"

        // asset-pipeline 2.0+ requires Java 7, use version 1.9.x with Java 6
        compile ":asset-pipeline:2.5.1"

        //runtime ':resources:1.2.14'
        //runtime ":lesscss-resources:1.3.3"
        //compile ":cache-headers:1.1.7"
        //runtime ":cached-resources:1.0"

        runtime ":mail:1.0.7"
        runtime ":csv:0.3.1"
        runtime ":executor:0.3"
        compile ":markdown:1.1.1"
        runtime ":pretty-time:2.1.3.Final-1.0.1"
        runtime ":quartz:1.0.2"
        runtime ":tiny-mce:3.4.9"
        runtime ":webxml:1.4.1"

        //runtime ':ala-bootstrap3:1.3'
        runtime ':twitter-bootstrap:3.3.5'
        runtime ':font-awesome-resources:4.3.0.1'
        runtime ':ala-auth:1.3.1'

        compile ':scaffolding:2.1.2'
        runtime ':database-migration:1.4.1'
        compile (':webflow:2.1.0') {
            excludes 'javassist'
        }
        compile ':build-info:1.2.8'
        compile ":yammer-metrics:3.0.1-2"
        //compile ":grails-melody:1.55.0"
        compile(":images-client-plugin:0.3") {
            excludes "ala-bootstrap2"
        }
    }

    dependencies {
        runtime 'org.postgresql:postgresql:9.3-1103-jdbc41'
        compile 'org.imgscalr:imgscalr-lib:4.2'
        compile 'com.squareup.retrofit:retrofit:1.6.1'
        compile 'com.google.guava:guava:17.0'
        compile 'org.apache.commons:commons-pool2:2.4.2'
        compile 'org.elasticsearch:elasticsearch:1.3.5'
        compile 'net.sf.opencsv:opencsv:2.3'
        compile 'org.freemarker:freemarker:2.3.23'
        test "org.grails:grails-datastore-test-support:1.0.2-grails-2.4"
    }
}
