package au.org.ala.volunteer

class ProjectTypeService {

    def grailsApplication

    def saveImageForProjectType(ProjectType projectType, InputStream imageStream) {

        if (!projectType || !projectType.name) {
            return
        }

        def filePath = "${grailsApplication.config.images.home}/projectType/${projectType.name}.png"
    }
}
