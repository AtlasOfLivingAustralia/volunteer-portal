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

