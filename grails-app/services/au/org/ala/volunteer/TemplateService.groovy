package au.org.ala.volunteer

import grails.transaction.Transactional
import grails.web.context.ServletContextHolder as SCH

import java.util.regex.Pattern

class TemplateService {

    def grailsApplication
    def userService

    @Transactional
    def cloneTemplate(Template template, String newName) {
        def newTemplate = new Template(name: newName, viewName: template.viewName, author: userService.currentUser.userId)

        newTemplate.viewParams = [:]
        template.viewParams.entrySet().each { entry ->
            newTemplate.viewParams[entry.key] = entry.value
        }

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
        if (grailsApplication.isWarDeployed()) {
            findWarGsps '/WEB-INF/grails-app/views/transcribe/templateViews', views
        } else {
            findDevGsps 'grails-app/views/transcribe/templateViews', views
        }

        def pattern = Pattern.compile("^transcribe/templateViews/(.*Transcribe)[.]gsp\$")

        def results = []
        views.each { String viewName ->
            def m = pattern.matcher(viewName)
            if (m.matches()) {
                results << m.group(1)
            }
        }

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

    private void findWarGsps(current, gsps) {
        def servletContext = SCH.servletContext
        for (path in servletContext.getResourcePaths(current)) {
            if (path.endsWith('.gsp')) {
                gsps << path - '/WEB-INF/grails-app/views/'
            } else {
                findWarGsps path, gsps
            }
        }
    }

}
