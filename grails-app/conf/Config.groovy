import au.org.ala.volunteer.CASRoles
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

// server.url = "http://localhost" // moved further down
images.urlPrefix = "/data/volunteer/"

grails.plugin.reveng.packageName = "au.org.ala.volunteer"

// Mappings for expedition labels, icons, etc
expedition = [
        [name: "Expedition Leader",
                icons: [
                        [
                            icon: "images/explorers/Gerard Krefft.png",
                            link: "http://www.australianmuseum.net.au/image/Gerard-Krefft/",
                            name: "Gerard Krefft (1830-1881)",
                            bio: "In June 1860 Kreft was appointed Assistant Curator of the Australian Museum, then acting Curator and Secretary after Simon Rood Pittard's death.Krefft built up the Museum's collections and won international repute as a scientist, corresponding with Charles Darwin, Sir Richard Owen and Albert Gunther of the British Museum. He was an early supporter of Darwin's theory of evolution. Krefft's discovery of the Queensland lungfish and its description in 1870, and his exploration of Wellington Caves in 1866, and writings of its fossils, are two of his significant achievements. During Krefft's time, Barnet's College Street extension to the building was erected (1861-1867)."
                        ],[
                            icon: "images/explorers/Helena Forde.png",
                            name: "Helena Forde (nee Scott) (1832-1910)",
                            link: "http://www.australianmuseum.net.au/A-biography-of-the-Scott-sisters/",
                            bio: "Helena and Harriet (known as the Scott sisters) were two of 19th century Australia’s most prominent natural history illustrators and possibly the first professional female illustrators in the country"
                        ],[
                            icon: "images/explorers/Elsie Brammel.png",
                            link: "",
                            name: "Elsie Bramell",
                            bio:  "Fred McCarthy and Elsie Bramell both worked at the Australian Museum during the 1930s. When the couple married in 1940, public service rules prohibiting married couples from working together meant that Elsie had to resign from her position at the Museum"
                        ],[
                            icon: "images/explorers/Robert Etheridge.png",
                            link: "http://www.australianmuseum.net.au/Curators-and-Directors-of-the-Australian-Museum/",
                            name: "Robert Etheridge Jnr (1846-1920)",
                            bio:  "Robert Etheridge Jnr trained as a palaeontologist and was appointed curator of the Australian Mueseum in 1895. During his time, the museum building was enlarged with the erection of the south wing, public lectures resumed and cadetships were introduced."
                        ],[
                            icon: "images/explorers/George Bennet.png",
                            link: "http://www.australianmuseum.net.au/Curators-and-Directors-of-the-Australian-Museum/",
                            name: "Dr George Bennett (1804-1893)",
                            bio:  "George Bennett, a distinguished naturalist and medical practitioner, travelled extensively, visiting Sydney in 1829 and 1832, before settling there in 1835. Bennett lobbied for the position of Curator at the fledgling Museum, and was appointed in 1835. His major achievement was the publication in 1837 of the first published 'Catalogue of Specimens of Natural History and Miscellaneous Curiosities deposited in the Australian Museum', which then comprised 36 mammal species, 317 Australian birds and 25 exotic birds, 15 reptiles, 6 fishes, 211 insects, 25 shells, 57 foreign fossils and 25 'native ornaments, weapons, utensils'."
                        ]
                ],
                max: 1,
                threshold: 1],
        [name: "Scientists",
                icons: [
                        [
                            icon:"images/explorers/Edward Pierson Ramsay.png",
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
                            icon: "images/explorers/Susan Emily Naegueli.png",
                            link: "http://www.australianmuseum.net.au/Harry-Burrell-Glass-Plate-Negative-Collection/",
                            name: "Susan Emily Naegueli",
                            bio:  "Susan Emily Naegueli, also known as Mrs Harry Burrell. Harry Burrell invented the ‘platypussary’ and referred to himself as the ‘platypoditudinarian’.  Susan worked with Harry on his research and was also a naturalist in her own right, lecturing to school and other groups on monotremes."
                        ]
                ],
                max: 9999,
                threshold: 10],
        [name: "Technical Officers",
                icons: [
                        [
                            icon: "images/explorers/William Sheridan Wall.png",
                            name: "William Sheridan Wall",
                            link: "http://www.australianmuseum.net.au/image/William-Sheridan-Wall/",
                            bio: "Curator of the Australian Museum c. 1844-1858"
                        ]
                ],
                max: 9999,
                threshold: 1
        ]

]

achievements = [
        [ name: 'tenth_transcription', label:"10th transcription", description:'Submit ten transcription tasks for validation', icon: 'images/achievements/bronze_lens.png' ],
        [ name: 'hundredth_transcription', label:"100th transcription", description:'Submit one hundred transcription tasks for validation', icon: 'images/achievements/silver_telescope.png' ],
        [ name: 'fivehundredth_transcription', label:"500th transcription", description:'Submit five hundred transcription tasks for validation', icon: 'images/achievements/gold_microscope.png' ],
        [ name: 'three_projects', label:"Three expeditions", description:'Transcribe tasks across three different expeditions', icon: 'images/achievements/bronze_net.png' ],
        [ name: 'five_projects', label:"Five expeditions", description:'Transcribe tasks across five different expeditions', icon: 'images/achievements/silver_binoculars.png' ],
        [ name: 'seven_projects', label:"Seven expeditions", description:'Transcribe tasks across seven different expeditions', icon: 'images/achievements/gold_telescope.png' ],

]

volunteer.defaultProjectId = 6306
viewedTask.timeout = 2 * 60 * 60 * 1000

leaderBoard.count = 5

ala.skin = "ala-bootstrap"
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

grails {
    mail {
        host = "localhost"
        port = 25
        username = ""
        password = ""
        props = [
            "mail.smtp.auth":"false",
        ]
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
    warn  'grails.plugin.mail'

    trace   'au.org.ala.cas.client'
}
