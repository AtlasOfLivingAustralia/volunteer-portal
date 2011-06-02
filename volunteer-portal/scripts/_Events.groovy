import org.codehaus.groovy.grails.commons.ConfigurationHolder

eventWebXmlStart = {
    if (!ConfigurationHolder.config.security.cas.bypass) {
        def tmpWebXml = "${projectWorkDir}/web.xml.tmp"
        ant.replace(file: tmpWebXml, token: "@security.cas.casServerName@", value: ConfigurationHolder.config.security.cas.casServerName)
        println "Injecting CAS Security Configuration: casServerName = ${ConfigurationHolder.config.security.cas.casServerName}"
        ant.replace(file: tmpWebXml, token: "@security.cas.appServerName@", value: ConfigurationHolder.config.security.cas.appServerName)
        println "Injecting CAS Security Configuration: appServerName = ${ConfigurationHolder.config.security.cas.appServerName}"
        ant.replace(file: tmpWebXml, token: "@security.cas.contextPath@", value: ConfigurationHolder.config.security.cas.contextPath)
        println "Injecting CAS Security Configuration: contextPath = ${ConfigurationHolder.config.security.cas.contextPath}"
        ant.replace(file: tmpWebXml, token: "@security.cas.urlPattern@", value: ConfigurationHolder.config.security.cas.urlPattern)
        println "Injecting CAS Security Configuration: url pattern = ${ConfigurationHolder.config.security.cas.urlPattern}"
        ant.replace(file: tmpWebXml, token: "@security.cas.urlExclusionPattern@", value: ConfigurationHolder.config.security.cas.urlExclusionPattern)
        println "Injecting CAS Security Configuration: url exclusion pattern = ${ConfigurationHolder.config.security.cas.urlExclusionPattern}"
        ant.replace(file: tmpWebXml, token: "@security.cas.authenticateOnlyIfLoggedInPattern@", value: ConfigurationHolder.config.security.cas.authenticateOnlyIfLoggedInPattern)
        println "Injecting CAS Security Configuration: authenticate only if logged in pattern = ${ConfigurationHolder.config.security.cas.authenticateOnlyIfLoggedInPattern}"
        ant.replace(file: tmpWebXml, token: "@security.cas.loginUrl@", value: ConfigurationHolder.config.security.cas.loginUrl)
        println "Injecting CAS Security Configuration: loginUrl = ${ConfigurationHolder.config.security.cas.loginUrl}"
    }
}
