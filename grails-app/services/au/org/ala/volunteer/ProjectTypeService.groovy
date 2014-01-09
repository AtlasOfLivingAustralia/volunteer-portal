package au.org.ala.volunteer

import org.apache.commons.io.FileUtils
import org.springframework.web.multipart.MultipartFile

class ProjectTypeService {

    def grailsApplication

    def saveImageForProjectType(ProjectType projectType, File imageFile) {

        if (!projectType || !projectType.name) {
            return
        }

        def file = new File(getLocalFileNameForIcon(projectType));
        file.getParentFile().mkdirs();
        FileUtils.copyFile(imageFile, file);
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
        return "${grailsApplication.config.images.home}/projectType/${projectType.name}.png"
    }

    def getIconURL(ProjectType projectType) {
        return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}projectType/${projectType.name}.png"
    }

}
