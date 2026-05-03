package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import org.apache.commons.io.FileUtils
import org.apache.commons.lang.StringUtils

import javax.imageio.ImageIO
import java.awt.image.BufferedImage

@Transactional
class MultimediaService {

    def grailsApplication
    def grailsLinkGenerator
    def s3Service

    /**
     * Closure to handle deletion of multimedia from S3. This is used in both deleteMultimedia and deleteAllMultimediaForTask
     * to ensure consistent logging and error handling when deleting from S3.
     */
    private Closure deleteS3Callback = { String prefix ->
        log.info("DeleteMultimedia: Preparing to remove multimedia from S3 with prefix ${prefix}")
        try {
            s3Service.deleteForPrefix(prefix)
            log.info("DeleteMultimedia: Successfully deleted multimedia from S3 for prefix ${prefix}")
        } catch (Exception e) {
            log.error("DeleteMultimedia: Error deleting multimedia from S3 for prefix ${prefix}: ${e.message}", e)
        }
    }

    def deleteAllMultimediaForTask(Task task) {
        // Delete from S3
        if (s3Service.isS3Enabled()) {
            def prefix = "${task.projectId}/${task.id}/"
            deleteS3Callback(prefix)
        }

        // Delete from disk
        def dir = new File(grailsApplication.config.getProperty('images.home', String) as String, "${task.projectId}${File.separatorChar}${task.id}")
        if (dir.exists()) {
            log.info("DeleteMultimedia: Preparing to remove multimedia directory ${dir.absolutePath}")
            FileUtils.deleteDirectory(dir)
        } else {
            log.info("DeleteMultimedia: Task directory ${dir.absolutePath} does not exist!")
        }
    }

    def deleteMultimedia(Multimedia media) {
        // Delete from S3
        if (s3Service.isS3Enabled()) {
            def prefix = "${media.task?.projectId}/${media.task?.id}/${media.id}"
            deleteS3Callback(prefix)
        }

        def dir = new File((grailsApplication.config.getProperty('images.home', String) as String) +
                '/' + media.task?.projectId + '/' + media.task?.id + "/" + media.id)
        if (dir.exists()) {
            log.info("DeleteMultimedia: Preparing to remove multimedia directory ${dir.absolutePath}")
            FileUtils.deleteDirectory(dir)
        } else {
            log.info("DeleteMultimedia: Directory ${dir.absolutePath} does not exist!")
        }
    }

    String filePathFor(Multimedia media) {
        if (s3Service.isS3Enabled() && media.filePath?.startsWith(S3Service.S3_PREFIX)) {
            return StringUtils.substringBeforeLast(media.filePath, '/')
        } else {
            grailsApplication.config.getProperty('images.home', String) + File.separator + media.task?.projectId +
                    File.separator + media.task?.id + File.separator + media.id
        }
    }

    /**
     * Get the URL for the given multimedia object. If the multimedia object is null, or if the file path is null or empty,
     * return an empty string.
     *
     * @param media The multimedia object for which to get the URL.
     * @param size Optional size parameter to get a specific thumbnail size. If provided, it will modify the file path accordingly.
     * @return The URL of the multimedia file, or an empty string if the multimedia object is null or if the file path is null or empty.
     */
    String getImageUrl(Multimedia media, String size = null) {
        def filePath = media.filePath ?: ''
        if (size && TaskService.THUMB_SIZES.containsKey(size)) {
            filePath = filePath.replaceFirst(/\.([a-zA-Z]*)$/, '_' + size + '.$1')
        }

        if (s3Service.isS3Enabled() && filePath?.startsWith(S3Service.S3_PREFIX)) {
            String url = grailsLinkGenerator.link(
                mapping: 'taskImage',
                params: [
                    multimediaId: media.id.toString(),
                    externalIdentifier: media.task.externalIdentifier,
                    size: size
                ],
                absolute: true
            )
            return url
        } else {
            filePath ? getImageUrl(filePath) : ''
        }
    }

    String getSampleAudioUrl(String prefix, String name, String format) {
        def encodedPrefix = IOUtils.toFileSystemDirectorySafeName(prefix)
        def encodedName = IOUtils.toFileSystemSafeName(name)

        def imagesHome = grailsApplication.config.getProperty('images.home')
        def filePath = imagesHome + File.separator + encodedPrefix + File.separator + encodedName + format
        return filePath
    }

    /**
     * Get the URL for the given file path. If the file path is null or empty, return an empty string.
     *
     * @param filePath The file path for which to get the URL.
     * @return The URL of the file, or an empty string if the file path is null or empty.
     */
    String getImageUrl(String filePath) {
        return filePath ? "${grailsApplication.config.getProperty('server.url', String)}${filePath}" : ''
    }

    /**
     * Get the URL for the thumbnail of the given media. If the media is null, or if the thumbnail does not exist,
     * return a default thumbnail image URL.
     *
     * @param media The multimedia object for which to get the thumbnail URL.
     * @param absolute Whether to return an absolute URL (including server URL) or a relative URL. Default is false
     * (relative).
     * @return The URL of the thumbnail image.
     */
    String getImageThumbnailUrl(Multimedia media, boolean absolute = false) {
        if (media == null) {
            log.error("getImageThumbnailUrl called for null media object")
            return grailsLinkGenerator.resource(file:'/sample-task-thumbnail.jpg')
        }

        if (s3Service.isS3Enabled() && media.filePathToThumbnail?.startsWith(S3Service.S3_PREFIX)) {
            // If S3 is enabled and the thumbnail path starts with the S3 prefix, return the S3 URL.
            def imageKey = media.filePathToThumbnail.substring(S3Service.S3_PREFIX.length())
            def urlImagePath = grailsLinkGenerator.link(
                mapping: 'taskImage',
                params: [
                    multimediaId: media.id.toString(),
                    externalIdentifier: media.task.externalIdentifier,
                    size: 'thumb'
                ],
                absolute: absolute
            )
            // Check the image at the end of this URL exists:
            BufferedImage image = ImageIO.read(s3Service.getObject(imageKey))
            // Check image has content (i.e. it exists and is not an empty file):
            if (image != null && image.getWidth() > 0 && image.getHeight() > 0) {
                return urlImagePath
            } else {
                log.warn("Thumbnail requested for $media but S3 object at ${urlImagePath} does not exist or is not a valid image")
                return grailsLinkGenerator.resource(file:'/sample-task-thumbnail.jpg', absolute: absolute)
            }
        } else {
            String filePath = filePathFor(media) ?: ''
            String filename = filenameFromFilePath(media.filePathToThumbnail) ?: ''
            File file = new File(filePath, filename)
            // log.debug("getImageThumbnailUrl media: $media, filePath: $filePath, filename: $filename, file: $file, exists: ${file.exists()}")
            if (file.exists()) {
                return media.filePathToThumbnail ? "${grailsApplication.config.getProperty('server.url', String)}${media.filePathToThumbnail}" : ''
            } else {
                // Log the warning from the Taglib, if the image isn't available.
                // log.warn("Thumbnail requested for $media but $file doesn't exist")
                return grailsLinkGenerator.resource(file:'/sample-task-thumbnail.jpg', absolute: absolute)
            }
        }
    }

    /**
     * Get the URL for the thumbnail of the given media, specifically for display purposes. This method checks if S3 is
     * enabled and if the thumbnail path starts with the S3 prefix.
     * If so, it generates a URL using the grailsLinkGenerator. If not, it falls back to the getImageThumbnailUrl method.
     *
     * @param media The multimedia object for which to get the thumbnail URL.
     * @param absolute Whether to return an absolute URL (including server URL) or a relative URL. Default is false (relative).
     * @return The URL of the thumbnail image for display purposes.
     * @see ImageController#taskImage(long, String).
     */
    String getImageThumbnailUrlForDisplay(Multimedia media, boolean absolute = false) {
        log.debug("getImageThumbnailUrlForDisplay called for media: ${media.id}, S3 enabled: ${s3Service.isS3Enabled()}")
        log.debug("Media filePathToThumbnail: ${media?.filePathToThumbnail}")
        if (s3Service.isS3Enabled() && media?.filePathToThumbnail?.startsWith(S3Service.S3_PREFIX)) {
            def url = grailsLinkGenerator.link(
                mapping: 'taskImage',
                params: [
                    multimediaId: media.id.toString(),
                    externalIdentifier: media.task.externalIdentifier,
                    size: 'thumb'
                ],
                absolute: absolute
            )
            log.debug("S3 Link: Multimedia ID: ${media.id}, externalIdentifier: ${media.task.externalIdentifier}")
            log.debug("Generated thumbnail URL: ${url}")
            return url
        } else {
            return getImageThumbnailUrl(media, absolute)
        }
    }

    private String filenameFromFilePath(String filePath) {
        StringUtils.substringAfterLast(filePath, '/')
    }

    Map<Long, Multimedia> findImagesForTasks(Collection<Long> taskIds) {
        List<Multimedia> mm = []
        if (taskIds) {
            mm = Multimedia.withCriteria {
                task {
                    'in'('id', taskIds)
                }
            }
        }
        return mm.groupBy {
            it.taskId
        }.collectEntries { taskId, mms ->
            [(taskId): mms?.find { it.mimeType.startsWith('image') }]
        }
    }
}
