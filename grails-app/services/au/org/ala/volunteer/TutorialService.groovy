package au.org.ala.volunteer

import org.springframework.web.multipart.MultipartFile

class TutorialService {

    def grailsApplication

    private String getTutorialDirectory() {
        return grailsApplication.config.images.home + "/tutorials"
    }

    private String createFilePath(String name) {
        return tutorialDirectory + "/" + name
    }

    def listTutorials() {
        def dir = new File(tutorialDirectory)
        if (!dir.exists()) {
            dir.mkdirs();
        }

        def files = dir.listFiles()
        def tutorials = []
        files.each {
            def url = grailsApplication.config.server.url + grailsApplication.config.images.urlPrefix + "/tutorials/" + it.name
            tutorials << [file: it, name: it.name, url: url]
        }

        return tutorials
    }

    def uploadTutorialFile(MultipartFile file) {
        def filePath = createFilePath(file.originalFilename)
        def newFile = new File(filePath);
        file.transferTo(newFile);
    }

    def deleteTutorial(String name) {
        def filePath = createFilePath(name)
        def file = new File(filePath)
        if (file.exists()) {
            file.delete()
            return true
        }

        return false
    }

}
