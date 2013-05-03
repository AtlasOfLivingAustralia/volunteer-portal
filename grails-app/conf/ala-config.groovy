/**
 * This file is merged (at runtime) with the Grails "main" config by the ala-web-theme plugin.
 *
 * Edit this file to suit your app's dev/test/prod environments
 * OR override these values in your app's Config.groovy file and comment-out in this file
 */

/******************************************************************************\
 *  SECURITY
\******************************************************************************/

security.cas.uriFilterPattern = "/validate/save.*," +
        "/validate/.*,/user/.*,/project/((?!index).)*,/task/((?!show).)*,/newsItem/.*, /picklist/.*, /admin/.*, /frontPage/.*,/ajax/userReport,/transcribe/.*,/taskComment/((?!getCommentsAjax).)*" +
        "/locality/.*,/collectionEvent/.*,/ajax/keepSessionAlive.*,/forum/.*,/template/.*"

security.cas.uriExclusionFilterPattern = "/images.*,/css.*,/js.*"
security.cas.authenticateOnlyIfLoggedInPattern = "/,/project/index/.*,/task/show/.*,/tutorials/.*"
security.cas.casServerName = "https://auth.ala.org.au"
security.cas.loginUrl = "${security.cas.casServerName}/cas/login"
security.cas.logoutUrl = "${security.cas.casServerName}/cas/logout"
security.cas.bypass = false
security.cas.casServerUrlPrefix = 'https://auth.ala.org.au/cas'

headerAndFooter.baseURL = 'http://www2.ala.org.au/commonui'
ala.baseURL = "http://www.ala.org.au"
bie.baseURL = "http://bie.ala.org.au"
bie.searchPath = "/search"
grails.project.groupId = "au.org.ala" // change this to alter the default package name and Maven publishing destination

//environments {
//    development {
//        grails.logging.jul.usebridge = true
//        grails.host = "http://localhost"
//        grails.serverURL = "${grails.host}:8080/${appContext}"
//        security.cas.appServerName = "${grails.host}:8080"
//        security.cas.contextPath = "/${appContext}"
//        grails.resources.debug = true // cached-resources plugin - keeps original filenames but adds cache-busting params
//    }
//    test {
//        grails.logging.jul.usebridge = false
//        grails.host = "foo-test.ala.org.au"
//        grails.serverURL = "http://foo-test.ala.org.au"
//        security.cas.appServerName = grails.serverURL
//        security.cas.contextPath = ""
//        log4j.appender.'errors.File' = "/var/log/tomcat/foo-stacktrace.log"
//    }
//    production {
//        grails.logging.jul.usebridge = false
//        grails.host = "foo.ala.org.au"
//        grails.serverURL = "http://${grails.host}"
//        security.cas.appServerName = grails.serverURL
//        security.cas.contextPath = ""
//        log4j.appender.'errors.File' = "/var/log/tomcat6/foo-stacktrace.log"
//    }
//}