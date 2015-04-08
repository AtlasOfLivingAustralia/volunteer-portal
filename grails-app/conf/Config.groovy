/******************************************************************************\
 *  CONFIG MANAGEMENT
\******************************************************************************/
def appName = 'volunteer-portal'
def ENV_NAME = "${appName.toUpperCase()}_CONFIG"
default_config = "/data/${appName}/config/${appName}-config.properties"
if(!grails.config.locations || !(grails.config.locations instanceof List)) {
    grails.config.locations = []
}
if(System.getenv(ENV_NAME) && new File(System.getenv(ENV_NAME)).exists()) {
    println "[${appName}] Including configuration file specified in environment: " + System.getenv(ENV_NAME);
    grails.config.locations.add "file:" + System.getenv(ENV_NAME)
} else if(System.getProperty(ENV_NAME) && new File(System.getProperty(ENV_NAME)).exists()) {
    println "[${appName}] Including configuration file specified on command line: " + System.getProperty(ENV_NAME);
    grails.config.locations.add "file:" + System.getProperty(ENV_NAME)
} else if(new File(default_config).exists()) {
    println "[${appName}] Including default configuration file: " + default_config;
    grails.config.locations.add "file:" + default_config
} else {
    println "[${appName}] No external configuration file defined."
}

println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"

headerAndFooter.baseURL = 'http://www2.ala.org.au/commonui'
ala.baseURL = "http://www.ala.org.au"
bie.baseURL = "http://bie.ala.org.au"
bie.searchPath = "/search"
grails.project.groupId = "au.org.ala" // change this to alter the default package name and Maven publishing destination
security.cas.adminRole = "ROLE_VP_ADMIN"
security.cas.validatorRole = "ROLE_VP_VALIDATOR"

bvp.user.activity.monitor.enabled = true // can turn off activity monitoring
bvp.user.activity.monitor.timeout = 3600 // seconds

bvp.users.migrateIds = false
bvp.labels.ensureDefault = true

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

elasticsearch.location="/data/volunteer/elasticsearch"

grails.databinding.convertEmptyStringsToNull = false

// Mappings for expedition labels, icons, etc
expedition = [
        [name: "Expedition Leader",
                icons: [
                        [
                            icon: "images/explorers/GerardKrefft.png",
                            link: "http://www.australianmuseum.net.au/image/Gerard-Krefft/",
                            name: "Gerard Krefft (1830-1881)",
                            bio: "In June 1860 Kreft was appointed Assistant Curator of the Australian Museum, then acting Curator and Secretary after Simon Rood Pittard's death.Krefft built up the Museum's collections and won international repute as a scientist, corresponding with Charles Darwin, Sir Richard Owen and Albert Gunther of the British Museum. He was an early supporter of Darwin's theory of evolution. Krefft's discovery of the Queensland lungfish and its description in 1870, and his exploration of Wellington Caves in 1866, and writings of its fossils, are two of his significant achievements. During Krefft's time, Barnet's College Street extension to the building was erected (1861-1867)."
                        ],[
                            icon: "images/explorers/HelenaForde.png",
                            name: "Helena Forde (nee Scott) (1832-1910)",
                            link: "http://www.australianmuseum.net.au/A-biography-of-the-Scott-sisters/",
                            bio: "Helena and Harriet (known as the Scott sisters) were two of 19th century Australia’s most prominent natural history illustrators and possibly the first professional female illustrators in the country"
                        ],[
                            icon: "images/explorers/ElsieBrammel.png",
                            link: "",
                            name: "Elsie Bramell",
                            bio:  "Fred McCarthy and Elsie Bramell both worked at the Australian Museum during the 1930s. When the couple married in 1940, public service rules prohibiting married couples from working together meant that Elsie had to resign from her position at the Museum"
                        ],[
                            icon: "images/explorers/RobertEtheridge.png",
                            link: "http://www.australianmuseum.net.au/Curators-and-Directors-of-the-Australian-Museum/",
                            name: "Robert Etheridge Jnr (1846-1920)",
                            bio:  "Robert Etheridge Jnr trained as a palaeontologist and was appointed curator of the Australian Mueseum in 1895. During his time, the museum building was enlarged with the erection of the south wing, public lectures resumed and cadetships were introduced."
                        ],[
                            icon: "images/explorers/GeorgeBennet.png",
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
                            icon:"images/explorers/EdwardPiersonRamsay.png",
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
                            icon: "images/explorers/SusanEmilyNaegueli.png",
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
                            icon: "images/explorers/WilliamSheridanWall.png",
                            name: "William Sheridan Wall",
                            link: "http://www.australianmuseum.net.au/image/William-Sheridan-Wall/",
                            bio: "Curator of the Australian Museum c. 1844-1858"
                        ]
                ],
                max: 9999,
                threshold: 1
        ]

]

// TODO Remove this after ala-auth plugin is updated
userDetails.url = "https://auth.ala.org.au/userdetails/userDetails/"
userDetailsById.bulkPath = 'getUserDetailsFromIdList'

volunteer.defaultProjectId = 6306
viewedTask.timeout = 2 * 60 * 60 * 1000

leaderBoard.count = 5

ala.skin = "ala-bootstrap"
ala.baseURL = "http://www.ala.org.au"
bie.baseURL = "http://bie.ala.org.au"
bie.searchPath = "/search"
headerAndFooter.baseURL = "http://www2.ala.org.au/commonui"

grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = true
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

bvp.tmpdir="/data/${appName}/config/"

// set per-environment serverURL stem for creating absolute links
environments {
    development {
        grails.serverURL = "http://devt.ala.org.au:8080/${appName}"
        server.url = "http://devt.ala.org.au"
        security.cas.appServerName = "http://devt.ala.org.au:8080"
        security.cas.contextPath = "/${appName}"
        images.home = '/data/volunteer-portal'
    }
    test {
        grails.serverURL = "http://volunteer-dev.ala.org.au"
        server.url = "http://volunteer-dev.ala.org.au"
        security.cas.appServerName = "http://volunteer-dev.ala.org.au"
        security.cas.contextPath = ""
        images.home = '/data/volunteer/data/volunteer'
    }
    production {
        grails.serverURL = "http://volunteer.ala.org.au"
        server.url = "http://volunteer.ala.org.au"
        security.cas.appServerName = server.url
        security.cas.contextPath = ""
        images.home = '/data/volunteer'
    }
    uat {
        grails.serverURL = "http://volunteer-uat.ala.org.au/${appName}"
        server.url = "http://volunteer-uat.ala.org.au"
        security.cas.appServerName = server.url
        security.cas.contextPath = "/${appName}"
        images.home = '/data/volunteer'
    }

}

metrics {
    // servletUrlPattern = '/admin/metrics/*'
    servletEnabled = true
}

environments {
    development {
        grails.mail.disabled = true
        grails.mail.host = "fake.ala.org.au"
        grails.mail.overrideAddress = "your.email@here.com"
    }
    production {
        grails.mail.host = "localhost"
        grails.mail.port = 25
        grails.mail.username = ""
        grails.mail.password = ""
        grails.mail.props = [
                "mail.smtp.auth": "false",
        ]
    }
}
grails.mail.default.from="support@ala.org.au"

grails {
    cache {
        enabled = true
        ehcache {
            //ehcacheXmlLocation = 'classpath:ehcache.xml' // conf/ehcache.xml
            //reloadable = false
        }
        config = {
            cache {
                name 'userDetailsCache'
                eternal false
                timeToLiveSeconds 1800
                timeToIdleSeconds 300
                maxElementsInMemory 200000 // TODO Derive from a property?
                memoryStoreEvictionPolicy 'LRU'
                overflowToDisk true
                diskPersistent false
                diskExpiryThreadIntervalSeconds 120
            }
            diskStore {
                temp true
            }
        }
    }
}

//hibernate.SQL="trace,stdout"
//hibernate.type="trace,stdout"

// log4j configuration
def loggingDir = (System.getProperty('catalina.base') ? System.getProperty('catalina.base') + '/logs' : './logs')
log4j = {
    // Example of changing the log pattern for the default console
    // appender:
    //
    appenders {
        environments {
            production {
                rollingFile name: "tomcatLog", maxFileSize: '10MB', file: "${loggingDir}/${appName}.log", layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")//, threshold: Level.INFO
                rollingFile name: "access", maxFileSize: '10MB', file: "${loggingDir}/${appName}-session-access.log", layout: pattern(conversionPattern: "%d %m%n")//, threshold: Level.INFO
            }
            development {
                console name: "tomcatLog", layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")//, threshold: Level.DEBUG
                console name: "access", layout: pattern(conversionPattern: "%d %m%n")//, threshold: Level.DEBUG
            }
            test {
                rollingFile name: "tomcatLog", maxFileSize: '1MB', file: "/tmp/${appName}", layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")//, threshold: Level.DEBUG
                rollingFile name: "access", maxFileSize: '10MB', file: "/tmp/${appName}-session-access.log", layout: pattern(conversionPattern: "%d %m%n")//, threshold: Level.DEBUG
            }
        }
    }

    root {
        error 'tomcatLog'
    }

    info    additivity: false,
            access: ["au.org.ala.volunteer.BVPServletFilter",
                   "au.org.ala.volunteer.BVPSessionListener"]

    
    error   'org.codehaus.groovy.grails.web.servlet',  //  controllers
            'org.codehaus.groovy.grails.web.pages', //  GSP
            'org.codehaus.groovy.grails.web.sitemesh', //  layouts
            'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
            'org.codehaus.groovy.grails.web.mapping', // URL mapping
            'org.codehaus.groovy.grails.commons', // core / classloading
            'org.codehaus.groovy.grails.plugins', // plugins
            'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
            'org.springframework',
            'org.hibernate',
            'net.sf.ehcache.hibernate'
            
    warn    'org.mortbay.log',
            'grails.plugin.mail',
            'au.org.ala.cas.client',
            'au.org.ala.cas.util'
            
    info    'grails.app',
            'au.org.ala'

}

// Uncomment and edit the following lines to start using Grails encoding & escaping improvements

/* remove this line 
// GSP settings
grails {
    views {
        gsp {
            encoding = 'UTF-8'
            htmlcodec = 'xml' // use xml escaping instead of HTML4 escaping
            codecs {
                expression = 'html' // escapes values inside null
                scriptlet = 'none' // escapes output from scriptlets in GSPs
                taglib = 'none' // escapes output from taglibs
                staticparts = 'none' // escapes output from static template parts
            }
        }
        // escapes all not-encoded output at final stage of outputting
        filteringCodecForContentType {
            //'text/html' = 'html'
        }
    }
}
remove this line */
