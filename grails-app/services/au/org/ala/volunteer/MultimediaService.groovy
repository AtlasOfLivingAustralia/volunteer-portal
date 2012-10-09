package au.org.ala.volunteer

import org.codehaus.groovy.grails.commons.ConfigurationHolder
import org.apache.commons.io.FileUtils

class MultimediaService {

    static transactional = true
    def config = ConfigurationHolder.config
    def logService

    def deleteMultimedia(Multimedia media) {
        def dir = new File(config.images.home + '/' + media.task?.projectId + '/' + media.task?.id + "/" + media.id)
        if (dir.exists()) {
            logService.log("DeleteMultimedia: Preparing to remove multimedia directory ${dir.absolutePath}")
            FileUtils.deleteDirectory(dir)
        } else {
            logService.log("DeleteMultimedia: Directory ${dir.absolutePath} does not exist!")
        }
    }

}
