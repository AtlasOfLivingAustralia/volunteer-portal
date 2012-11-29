package au.org.ala.volunteer

import org.springframework.web.multipart.MultipartFile

class StagingService {

    def grailsApplication

    String getStagingDirectory(Project project) {
        return "${grailsApplication.config.images.home}/${project.id}/staging"
    }

    String createStagedPath(Project project, String filename) {
        return getStagingDirectory(project) + "/" + filename
    }

    def stageImage(Project project, MultipartFile file) {
        def filePath = createStagedPath(project, file.originalFilename)
        println "copying image to " + filePath
        def newFile = new File(filePath);
        file.transferTo(newFile);
    }

    def listStagedFiles(Project project) {
        def dir = new File(getStagingDirectory(project))
        if (!dir.exists()) {
            dir.mkdirs();
        }

        def files = dir.listFiles()
        def images = []
        files.each {
            def url = grailsApplication.config.server.url + grailsApplication.config.images.urlPrefix + "/${project.id}/staging/" + it.name
            images << [file: it, name: it.name, url: url]
        }

        return images
    }

    def unstageImage(Project project, String imageName) {
        def file = new File(createStagedPath(project, imageName))
        if (file.exists()) {
            file.delete()
            return true
        }
        return false
    }

}
