import grails.util.Environment

//grails.project.class.dir = "target/classes"
//grails.project.test.class.dir = "target/test-classes"
//grails.project.test.reports.dir = "target/test-reports"
grails.servlet.version = "3.0"
grails.project.work.dir = "target"
grails.project.war.file = "target/${appName}.war"

grails.project.fork = [
        test: false,
        run: false,
        war: false,
        console: false
]
grails.reload.enabled = true

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
        mavenLocal()
        mavenRepo("http://nexus.ala.org.au/content/groups/public/") {
            updatePolicy 'always'
        }
    }

    dependencies {
        runtime 'org.postgresql:postgresql:9.4.1212.jre7'
        compile 'org.imgscalr:imgscalr-lib:4.2'
        compile 'com.squareup.retrofit2:retrofit:2.2.0'
        compile 'com.squareup.retrofit2:converter-gson:2.2.0'
        compile 'com.google.guava:guava:17.0'
        compile 'org.apache.commons:commons-compress:1.11'
        compile 'org.apache.commons:commons-pool2:2.4.2'
        compile 'org.elasticsearch:elasticsearch:1.3.5'
        compile 'net.sf.opencsv:opencsv:2.3'
        compile 'org.freemarker:freemarker:2.3.23'
        compile 'com.googlecode.owasp-java-html-sanitizer:owasp-java-html-sanitizer:20160526.1-ALA'
        test "org.grails:grails-datastore-test-support:1.0.2-grails-2.4"
    }

    plugins {
        build ":release:3.0.1"
        compile ":cache:1.1.8"
        runtime ":cache-ehcache:1.0.4"
        compile ":cache-headers:1.1.7"
        build ':tomcat:7.0.55.3'
        compile ':hibernate4:4.3.10'
        //compile ":postgresql-extensions:4.6.1"
        compile ':platform-core:1.0.0'

        runtime ":jquery:1.11.1"
        runtime ":jquery-ui:1.10.4"

        runtime ':resources:1.2.14'
        if (Environment.current == Environment.PRODUCTION) {
            runtime ":zipped-resources:1.0.1"
            runtime ":cached-resources:1.1"
            runtime ":yui-minify-resources:0.1.5"
        }

        runtime ":mail:1.0.7"
        runtime ":csv:0.3.1"
        runtime ":executor:0.3"
        compile ":markdown:1.1.1"
        runtime ":pretty-time:2.1.3.Final-1.0.1"
        runtime ":quartz:1.0.2"
        runtime ":webxml:1.4.1"

        runtime ':twitter-bootstrap:3.3.5'
        runtime ':font-awesome-resources:4.4.0'
        runtime ':ala-auth:2.0.2'

        compile ':scaffolding:2.1.2'
        runtime ':database-migration:1.4.1'

        compile ':build-info:1.2.8'
        compile ":yammer-metrics:3.0.1-2"
        compile(":images-client-plugin:0.3") {
            excludes "ala-bootstrap2"
        }
        compile ":google-visualization:1.0.2"
    }
}
