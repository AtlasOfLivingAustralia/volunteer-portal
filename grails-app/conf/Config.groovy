
// locations to search for config files that get merged into the main config
// config files can either be Java properties files or ConfigSlurper scripts

// grails.config.locations = [ "classpath:${appName}-config.properties",
//                             "classpath:${appName}-config.groovy",
//                             "file:${userHome}/.grails/${appName}-config.properties",
//                             "file:${userHome}/.grails/${appName}-config.groovy"]

// if(System.properties["${appName}.config.location"]) {
//    grails.config.locations << "file:" + System.properties["${appName}.config.location"]
// }

/******************************************************************************\
 *  EXTERNAL SERVERS
\******************************************************************************/
if (!bie.baseURL) {
     bie.baseURL = "http://bie.ala.org.au/"
}
if (!biocache.baseURL) {
     biocache.baseURL = "http://biocache.ala.org.au/"
}
if (!spatial.baseURL) {
     spatial.baseURL = "http://spatial.ala.org.au/"
}
if (!ala.baseURL) {
    ala.baseURL = "http://www.ala.org.au"
}

/******************************************************************************\
 *  SECURITY
\******************************************************************************/
if (!security.cas.urlPattern) {
    security.cas.urlPattern = "/transcribe/task/.*,/transcribe/save.*,/transcribe/.*,/validate/save.*," +
            "/validate/.*,/user/.*,/project/((?!index).)*,/task/.*,/newsItem/.*, /picklist/.*, /admin/.*, /frontPage/.*,/ajax/userReport"
}
if (!security.cas.urlExclusionPattern) {
    security.cas.urlExclusionPattern = "/images.*,/css.*,/js.*"
}
if (!security.cas.authenticateOnlyIfLoggedInPattern) {
    security.cas.authenticateOnlyIfLoggedInPattern = "/,/project/index/*"
}
if (!security.cas.casServerName) {
    security.cas.casServerName = "https://auth.ala.org.au"
}
if (!security.cas.loginUrl) {
    security.cas.loginUrl = "${security.cas.casServerName}/cas/login"
}
if (!security.cas.logoutUrl) {
    security.cas.logoutUrl = "${security.cas.casServerName}/cas/logout"
}
if (!security.cas.contextPath) {
    //security.cas.contextPath = "/workforce" //"""${appName}"
}
if (!security.cas.bypass) {
    security.cas.bypass = false
}

// server.url = "http://localhost" // moved further down
images.urlPrefix = "/data/volunteer/"

auth.admin_role = "ROLE_VP_ADMIN"
auth.validator_role = "ROLE_VP_VALIDATOR"

grails.plugin.reveng.packageName = "au.org.ala.volunteer"

// Mappings for expedition labels, icons, etc
expedition = [
        [name: "Expedition Leader",
                icons: [
                        [
                            icon: "images/explorers/expedition-leader.png",
                            link: "http://www.australianmuseum.net.au/image/Gerard-Krefft/",
                            name: "Gerard Krefft",
                            bio: "Curator and Secretary of the Australian Museum 1861-1874"
                        ],[
                            icon: "images/explorers/expedition-leader-female.png",
                            link: "",
                            name: "Elsie Bramell",
                            bio:  "Fred McCarthy and Elsie Bramell both worked at the Australian Museum during the 1930s. When the couple married in 1940, public service rules prohibiting married couples from working together meant that Elsie had to resign from her position at the Museum"
                        ]
                ],
                max: 1,
                threshold: 1],
        [name: "Scientists",
                icons: [
                        [
                            icon:"images/explorers/scientist.png",
                            name: "Edward Pierson Ramsay",
                            link: "http://www.australianmuseum.net.au/image/Edward-Pierson-Ramsay/",
                            bio: "Curator of the Australian Museum 1874-1894"
                        ]
                ],
                max: 9999,
                threshold: 50],
        [name: "Collection Managers",
                icons: [
                        [
                            icon: "images/explorers/collection-manager.png",
                            name: "Helena Scott",
                            link: "http://www.australianmuseum.net.au/A-biography-of-the-Scott-sisters/",
                            bio: "Helena and Harriet (known as the Scott sisters) were two of 19th century Australia’s most prominent natural history illustrators and possibly the first professional female illustrators in the country"
                        ]
                ],
                max: 9999,
                threshold: 10],
        [name: "Technical Officers",
                icons: [
                        [
                            icon: "images/explorers/technical-officer.png",
                            name: "William Sheridan Wall",
                            link: "http://www.australianmuseum.net.au/image/William-Sheridan-Wall/",
                            bio: "Curator of the Australian Museum c. 1844-1858"
                        ]
                ],
                max: 9999,
                threshold: 1
        ]

]

volunteer.defaultProjectId = 6306
viewedTask.timeout = 2 * 60 * 60 * 1000

leaderBoard.count = 5

ala.skin = "ala2"
ala.baseURL = "http://www.ala.org.au"
bie.baseURL = "http://bie.ala.org.au"
bie.searchPath = "/search"
headerAndFooter.baseURL = "http://www2.ala.org.au/commonui"

  grails.project.groupId = "au.org.ala.volunteer" // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [ html: ['text/html','application/xhtml+xml'],
                      xml: ['text/xml', 'application/xml'],
                      text: 'text/plain',
                      js: 'text/javascript',
                      rss: 'application/rss+xml',
                      atom: 'application/atom+xml',
                      css: 'text/css',
                      csv: 'text/csv',
                      all: '*/*',
                      json: ['application/json','text/json'],
                      form: 'application/x-www-form-urlencoded',
                      multipartForm: 'multipart/form-data'
                    ]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// The default codec used to encode data with ${}
grails.views.default.codec = "none" // none, html, base64
grails.views.gsp.encoding = "UTF-8"
grails.converters.encoding = "UTF-8"
// enable Sitemesh preprocessing of GSP pages
grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// whether to install the java.util.logging bridge for sl4j. Disable for AppEngine!
grails.logging.jul.usebridge = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// set per-environment serverURL stem for creating absolute links
environments {
    production {
        grails.serverURL = "http://volunteer.ala.org.au"
        server.url = "http://volunteer.ala.org.au"
        security.cas.appServerName = server.url
        security.cas.contextPath = ""
        log4j.appender.'errors.File'="/var/log/tomcat/stacktrace.log"
        images.home = '/data/volunteer'
    }
    development {
        grails.serverURL = "http://baird.ala.org.au:8080/${appName}"
        server.url = "http://baird.ala.org.au"
        security.cas.appServerName = "http://baird.ala.org.au:8080"
        security.cas.contextPath = "/${appName}"
        images.home = '/data/volunteer'
        //log4j.appender.'errors.File'="stacktrace.log"
    }
    test {
        grails.serverURL = "http://volunteer-dev.ala.org.au"
        server.url = "http://volunteer-dev.ala.org.au"
        security.cas.appServerName = "http://volunteer-dev.ala.org.au"
        security.cas.contextPath = ""
        log4j.appender.'errors.File'="/var/log/tomcat/stacktrace.log"
        images.home = '/data/volunteer/data/volunteer'
    }
}

//hibernate.SQL="trace,stdout"
//hibernate.type="trace,stdout"

// log4j configuration
log4j = {
    // Example of changing the log pattern for the default console
    // appender:
    //
    appenders {
        console name:'stdout', layout:pattern(conversionPattern: '%-5p [%c{2}] %m%n')
    }

    error  'org.codehaus.groovy.grails.web.servlet',  //  controllers
           'org.codehaus.groovy.grails.web.pages', //  GSP
           'org.codehaus.groovy.grails.web.sitemesh', //  layouts
           'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
           'org.codehaus.groovy.grails.web.mapping', // URL mapping
           'org.codehaus.groovy.grails.commons', // core / classloading
           'org.codehaus.groovy.grails.plugins', // plugins
           'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
           'org.springframework',
           'org.hibernate',
           'net.sf.ehcache.hibernate',
           'grails.app'

    warn   'org.mortbay.log',
           'grails.app'
    info   'grails.app'
}
