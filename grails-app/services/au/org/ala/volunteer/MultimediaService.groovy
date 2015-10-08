package au.org.ala.volunteer

import org.apache.commons.io.FileUtils
import org.apache.commons.lang.StringUtils

class MultimediaService {

    static transactional = true

    def logService
    def grailsApplication
    def grailsLinkGenerator

    def deleteMultimedia(Multimedia media) {
        def dir = new File(grailsApplication.config.images.home + '/' + media.task?.projectId + '/' + media.task?.id + "/" + media.id)
        if (dir.exists()) {
            log.info("DeleteMultimedia: Preparing to remove multimedia directory ${dir.absolutePath}")
            FileUtils.deleteDirectory(dir)
        } else {
            log.info("DeleteMultimedia: Directory ${dir.absolutePath} does not exist!")
        }
    }

    public String filePathFor(Multimedia media) {
        grailsApplication.config.images.home + File.pathSeparator + media.task?.projectId + File.pathSeparator + media.task?.id + File.pathSeparator + media.id
    }

    public String getImageUrl(Multimedia media) {
        return media.filePath ? "${grailsApplication.config.server.url}${media.filePath}" : ''
    }

    public String getImageThumbnailUrl(Multimedia media) {
        if (new File(filePathFor(media), filenameFromFilePath(media.filePathToThumbnail)).exists()) {
            media.filePathToThumbnail ? "${grailsApplication.config.server.url}${media.filePathToThumbnail}" : ''
        } else {
            grailsLinkGenerator.resource(dir:'/images', file:'sample-task-thumbnail.jpg')
        }
    }

    private String filenameFromFilePath(String filePath) {
        StringUtils.substringAfterLast(filePath, '/')
    }
}
