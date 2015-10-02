package au.org.ala.volunteer

import org.apache.commons.io.FileUtils

class MultimediaService {

    static transactional = true

    def logService
    def grailsApplication

    def deleteMultimedia(Multimedia media) {
        def dir = new File(grailsApplication.config.images.home + '/' + media.task?.projectId + '/' + media.task?.id + "/" + media.id)
        if (dir.exists()) {
            log.info("DeleteMultimedia: Preparing to remove multimedia directory ${dir.absolutePath}")
            FileUtils.deleteDirectory(dir)
        } else {
            log.info("DeleteMultimedia: Directory ${dir.absolutePath} does not exist!")
        }
    }

    public String getImageUrl(Multimedia media) {
        getImageUrl(media.filePath)
    }

    public String getImageUrl(String filePath) {
        return filePath ? "${grailsApplication.config.server.url}${filePath}" : ''
    }

    public String getImageThumbnailUrl(Multimedia media) {
        return media.filePathToThumbnail ? "${grailsApplication.config.server.url}${media.filePathToThumbnail}" : ''
    }


}
