package au.org.ala.volunteer

import org.codehaus.groovy.grails.web.context.ServletContextHolder as SCH

import java.util.regex.Pattern

class TemplateService {

    def grailsApplication

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
