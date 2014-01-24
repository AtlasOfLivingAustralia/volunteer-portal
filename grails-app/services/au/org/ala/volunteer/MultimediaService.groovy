package au.org.ala.volunteer

import org.apache.commons.io.FileUtils

class MultimediaService {

    static transactional = true

    def logService
    def grailsApplication

    def deleteMultimedia(Multimedia media) {
        def dir = new File(grailsApplication.config.images.home + '/' + media.task?.projectId + '/' + media.task?.id + "/" + media.id)
        if (dir.exists()) {
            logService.log("DeleteMultimedia: Preparing to remove multimedia directory ${dir.absolutePath}")
            FileUtils.deleteDirectory(dir)
        } else {
            logService.log("DeleteMultimedia: Directory ${dir.absolutePath} does not exist!")
        }
    }

    public String getImageUrl(Multimedia media) {
        return "${grailsApplication.config.server.url}${media.filePath}"
    }

}
