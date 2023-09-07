package au.org.ala.volunteer

import org.apache.commons.io.FileUtils
import org.springframework.web.multipart.MultipartFile

class ProjectTypeService {

    def grailsApplication

    def saveImageForProjectType(ProjectType projectType, InputStream image) {

        if (!projectType || !projectType.name) {
            return
        }

        def file = new File(getLocalFileNameForIcon(projectType));
        if (!file.parentFile?.exists()) {
            if (!file.getParentFile().mkdirs()) {
                throw new RuntimeException("Failed to create directory for project type icon: ${file.parentFile.absolutePath} - check permissions?")
            }
        }

        FileUtils.copyInputStreamToFile(image, file)
    }

    def saveImageForProjectType(ProjectType projectType, MultipartFile imageFile) {

        if (!projectType || !projectType.name) {
            return
        }

        def file = new File(getLocalFileNameForIcon(projectType));
        file.getParentFile().mkdirs();
        imageFile.transferTo(file);
    }

    def getLocalFileNameForIcon(ProjectType projectType) {
        return "${grailsApplication.config.getProperty('images.home', String)}/projectType/${projectType.name}.png"
    }

    def getIconURL(ProjectType projectType) {
        return "${grailsApplication.config.getProperty('server.url', String)}/${grailsApplication.config.getProperty('images.urlPrefix', String)}projectType/${projectType.name}.png"
    }

}
