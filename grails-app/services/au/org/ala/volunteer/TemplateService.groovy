package au.org.ala.volunteer

import com.google.common.io.Resources
import grails.core.GrailsApplication
import grails.converters.JSON
import grails.transaction.Transactional
import grails.util.Environment

import java.util.regex.Pattern

class TemplateService {

    GrailsApplication grailsApplication
    def userService

    @Transactional
    def cloneTemplate(Template template, String newName) {
        def newTemplate = new Template(name: newName, viewName: template.viewName, author: userService.currentUser.userId)

        newTemplate.viewParams = [:]
        template.viewParams.entrySet().each { entry ->
            newTemplate.viewParams[entry.key] = entry.value
        }

        newTemplate.viewParams2 = JSON.parse((template.viewParams2 as JSON).toString()) as Map

        newTemplate.save()
        // Now we need to copy over the template fields
        def fields = TemplateField.findAllByTemplate(template)
        Field.saveAll(fields.collect { f ->
            def newField = new TemplateField(f.properties)
            newField.template = newTemplate
            newField
        })
    }

    def getAvailableTemplateViews() {
        def views = []

        if (Environment.isDevelopmentEnvironmentAvailable()) {
            log.debug("Checking for dev templates")
            findDevGsps 'grails-app/views/transcribe/templateViews', views
        } else {
            log.debug("Checking for WAR deployed templates")
            findWarGsps '/WEB-INF/grails-app/views/transcribe/templateViews', views
        }
        log.debug("Got views: {}", views)

        def pattern = Pattern.compile("^transcribe/templateViews/(.*Transcribe)[.]gsp\$")

        def results = views.collectMany { String viewName ->
            def m = pattern.matcher(viewName)
            m.matches() ? [m.group(1)] : []
        }.sort()

        return results
    }

    private void findDevGsps(String current, List gsps) {
        for (file in new File(current).listFiles()) {
            if (file.path.endsWith('.gsp')) {
                gsps << file.path - 'grails-app/views/'
            } else {
                findDevGsps file.path, gsps
            }
        }
    }

    private void  findWarGsps(String current, List<String> gsps) {
        try {
            def properties = Resources.getResource('/gsp/views.properties').withReader('UTF-8') { r ->
                def p = new Properties()
                p.load(r)
                p
            }
            def keys = properties.keySet()
            log.debug("Got keys from views.properties {}", keys)
            keys.findAll { it.toString().startsWith(current) }.collect(gsps) { it - '/WEB-INF/grails-app/views/' }
        } catch (e) {
            log.error("Error loading views.properties!", e)
        }
    }

}
