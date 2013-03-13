// Place your Spring DSL code here
beans = {
    customPageRenderer(au.org.ala.volunteer.CustomPageRenderer, ref("groovyPagesTemplateEngine")) {
        groovyPageLocator = ref("groovyPageLocator")
    }
}
