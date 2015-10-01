import au.org.ala.volunteer.ApplicationContextHolder
import au.org.ala.volunteer.BVPSecurePluginFilter
//import au.org.ala.volunteer.CustomPageRenderer
import au.org.ala.volunteer.collectory.CollectoryClientFactoryBean

// Place your Spring DSL code here
beans = {
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
}
