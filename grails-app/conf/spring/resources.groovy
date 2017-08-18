import au.org.ala.volunteer.ApplicationContextHolder
import au.org.ala.volunteer.BVPServletFilter
import au.org.ala.volunteer.DigivolServletContextConfig
import au.org.ala.volunteer.SmartConfigLocaleResolver
import au.org.ala.volunteer.collectory.CollectoryClientFactoryBean
import org.springframework.boot.web.servlet.FilterRegistrationBean
import org.springframework.web.servlet.i18n.SessionLocaleResolver

// Place your Spring DSL code here
beans = {

    localeResolver(SmartConfigLocaleResolver) {
          supportedLocales = grailsApplication.config.languages.enabled.tokenize(',').collect() { new Locale(it.tokenize("_")[0], it.tokenize("_")[1]) } ?: [grailsApplication.config.languages.default ? new Locale(grailsApplication.config.languages.default): new Locale('en', 'US')]
          defaultLocale = grailsApplication.config.languages.default ? new Locale(grailsApplication.config.languages.default): new Locale('en','US')
    }

//    customPageRenderer(CustomPageRenderer, ref("groovyPagesTemplateEngine")) {
//        groovyPageLocator = ref("groovyPageLocator")
//    }

    collectoryClient(CollectoryClientFactoryBean) {
        endpoint = 'http://collections.ala.org.au/ws/'
    }

//    bvpSecurePluginFilter(BVPSecurePluginFilter) {
//        securityPrimitives = ref("securityPrimitives")
//    }

    applicationContextHolder(ApplicationContextHolder) { bean ->
        bean.factoryMethod = 'getInstance'
    }

    digivolServletContextConfig(DigivolServletContextConfig)

    bvpServletFilter(FilterRegistrationBean) {
        name = 'BVPServletFilter'
        filter = bean(BVPServletFilter)
        urlPatterns = [ '/*' ]
        asyncSupported = true
    }


}
