package au.org.ala.volunteer

import asset.pipeline.grails.AssetResourceLocator
import grails.converters.JSON
import org.apache.catalina.connector.ClientAbortException
import org.apache.commons.io.FilenameUtils
import org.springframework.core.io.Resource

import javax.imageio.ImageIO
import java.nio.charset.StandardCharsets

import static au.org.ala.volunteer.ImageUtils.contentType
import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST
import static javax.servlet.http.HttpServletResponse.SC_NOT_FOUND

class ImageController {

    def imageService
    def s3Service
    AssetResourceLocator assetResourceLocator

    final static FORMATS = ['png', 'jpg', 'gif']
    final static FORMAT_AUDIO = ['m4a', 'wav', 'mp3', 'aac']

    final static SAMPLE_TASK_IMAGE = "sample-task.jpg"
    final static SAMPLE_WS_IMAGE = "ws-placeholder-150.png"

    final static MAX_WIDTH = 1024
    final static MAX_HEIGHT = 1024

    /**
     * Get an image of a specific size, creating it if necessary. If the image does not exist
     * then a placeholder image is returned. If the image cannot be found and allowBroken=true
     * is set then a 404 is returned.
     * Note: This method does NOT CHECK S3.
     * @param prefix The image prefix (directory)
     * @param width The required width
     * @param height The required height
     * @param name The image name (without extension)
     * @param format The required format (png, jpg, gif)
     */
    def size(String prefix, int width, int height, String name, String format) {
        log.debug("Image request for $prefix, $name at ${width}x${height} in $format")

        def allowBroken = params.boolean('allowBroken', false)
        log.debug("allowBroken is $allowBroken")

        if (!name) {
            // Return placeholder.
            sendPlaceholder(SAMPLE_WS_IMAGE)
            return
        }

        def encodedPrefix = IOUtils.toFileSystemDirectorySafeName(prefix)
        def encodedName = IOUtils.toFileSystemSafeName(name)

        format = format.toLowerCase()
        if (!FORMATS.contains(format)) {
            // Did the extension get screwed up? Check if the file does exist:
            File fileCheck = imageService.findImageWithSupportedExtension(encodedPrefix, encodedName)
            if (fileCheck) {
                // Image is there with a different extension.
                log.debug("Found file under different file extension (or broken input): ${fileCheck.name}")
                format = FilenameUtils.getExtension(fileCheck.name)?.toLowerCase()
            } else {
                log.debug("No file found with supported extension: ${encodedName}.${format}")
                render([error: "${format} not supported"] as JSON, status: SC_BAD_REQUEST)
                return
            }
        }

        if (width < 0 || width >  MAX_WIDTH || height < 0 || height > MAX_HEIGHT) {
            render([error: "${width}x${height} not supported"] as JSON, status: SC_BAD_REQUEST)
            return
        }

        File result = imageService.getImageFile(prefix, name + "_${width}_${height}", format)
        if (result.exists()) {
            sendImage(result, contentType(format))
            return
        }

        File original = imageService.findImageWithSupportedExtension(encodedPrefix, encodedName)
        if (!original && allowBroken) {
            log.debug("Image not found, but allowBroken is true, returning 404")
            response.sendError(SC_NOT_FOUND)
            return
        } else if (!original && !allowBroken) {
            log.debug("Image not found, returning placeholder")
            sendPlaceholder(SAMPLE_WS_IMAGE)
            return
        }

        def originalImage = ImageIO.read(original)
        if (!originalImage) {
            log.warn("${original.path} could not be read as an image")
            render([error: "${original.path} could not be read as an image"] as JSON, status: 500)
            return
        }

        def scaled = ImageUtils.centreCropAndScale(originalImage, width, height)
        if (!ImageIO.write(scaled, format, result)) {
            log.warn("${original.path} could not be scaled or written with ${width}x${height} in $format")
            render([error: "${original.path} could not be read as an image"] as JSON, status: 500)
            return
        }
        scaled.flush()
        originalImage.flush()
        log.info("Scaled and saved $result")

        sendImage(result, contentType(format))
    }

    def audioFile(String prefix, String name, String format) {
        log.debug("Audio File request for $prefix and $name")

        def encodedPrefix = IOUtils.toFileSystemDirectorySafeName(prefix)
        def encodedName = IOUtils.toFileSystemSafeName(name)

        format = format.toLowerCase()
        if (!FORMAT_AUDIO.contains(format)) {
            render([error: "${format} not supported"] as JSON, status: SC_BAD_REQUEST)
            return
        }

        def imagesHome = grailsApplication.config.getProperty('images.home')
        File result = new File("$imagesHome${File.separator}$encodedPrefix", "${encodedName}.${format}")

        if (!result.exists()) {
            response.sendError(SC_NOT_FOUND)
            return
        }

        sendImage(result, contentType(format))
    }

    /**
     * Send a placeholder image to the client. The type parameter can be used to specify different placeholder
     * images for different contexts (e.g., task images vs. WS images).
     * If the specified placeholder image cannot be found, a 404 error will be returned.
     *
     * @param type The type of placeholder image to send (default is SAMPLE_WS_IMAGE)
     */
    private def sendPlaceholder(String type) {
        Resource placeholderResource = assetResourceLocator.findAssetForURI(type)
        if (placeholderResource?.exists()) {
            log.debug("Placeholder image found: ${placeholderResource.filename}, sending to client")
            response.contentType = contentType(FilenameUtils.getExtension(placeholderResource.filename))
            placeholderResource.inputStream.withStream { input ->
                response.outputStream << input
            }
            response.outputStream.flush()
        } else {
            log.debug("Placeholder image not found, returning 404")
            response.sendError(SC_NOT_FOUND)
        }
    }



    private def sendImage(File file, String contentType) {
//        lastModified(file.lastModified())
        def lm = file.lastModified()
        lastModified(lm)

        response.contentType = contentType

        cache([
                store: true,
                shared: true,
                neverExpires: true
        ])

        try {
            withCacheHeaders {
                delegate.lastModified {
                    new Date(lm)
                }
                generate {
                    file.withInputStream { stream ->
                        response.outputStream << stream
                    }
                }
            }
        } catch (ClientAbortException e) {
            // client hung up, can't do anything
            log.debug('client hung up', e)
        } catch (IOException e) {
            if (e.message != 'Broken pipe') {
                log.error("Exception sending image", e)
                render(status: 500, text: 'an error occured')
            } else {
                // client hung up, can't do anything
                log.debug('client hung up', e)
            }
        }
    }

    /**
     * Get the image for a Task's Multimedia, optionally with a size embedded in the externalIdentifier.
     * The size is determined by parsing the externalIdentifier for a suffix (e.g., "image123_thumb.jpg" -> "thumb") and checking if it matches a known size.
     * If the image is stored on S3, it will be streamed directly to the client. Otherwise, it will be read from local disk storage (and then streamed to the client).
     * If the image cannot be found or an error occurs, a placeholder image will be returned.
     *
     * @param multimediaId The ID of the Multimedia associated with the Task
     * @param externalIdentifier An image name that may contain an embedded size (e.g., "image123_thumb.jpg")
     * @param size (optional) The size of the image to retrieve (e.g., "thumb"). If not provided, it will be extracted
     * from the externalIdentifier if possible. If present, it overrides any size embedded in the externalIdentifier.
     */
    def taskImage(long multimediaId, String externalIdentifier) {
        log.debug("Request for task image with multimediaId: ${multimediaId}, externalIdentifier: ${externalIdentifier}, params: ${params}")
        try {
            Multimedia multimedia = Multimedia.get(multimediaId)
            if (!multimedia) {
                log.warn("Multimedia not found for id: ${multimediaId}")
                sendPlaceholder(SAMPLE_TASK_IMAGE)
                return
            }

            String size = params.size
            String imagePath = multimedia.filePath
            // Size will be embedded into the externalIdentifier. e.g. image123_thumb.jpg. Ensure the embedded size is valid if present.
            // Extract size from externalIdentifier (e.g., "image123_thumb.jpg" -> "thumb")
            if (externalIdentifier) {
                if (!size) {
                    def matcher = externalIdentifier =~ /(.*)_([a-zA-Z0-9_]+)\.[a-zA-Z0-9]+$/
                    if (matcher.find()) {
                        size = matcher.group(2)
                    }
                }
                if (TaskService.THUMB_SIZES.containsKey(size)) {
                    // Valid size found, modify imagePath to look for sized version
                    imagePath = imagePath.replaceFirst(/\.([a-zA-Z0-9]+)$/, '_' + size + '.$1')
                    log.debug("Looking for sized image at path: ${imagePath} for size: ${size}")
                }
            }

            // Check if image is stored in S3
            if (s3Service.isS3Enabled() && imagePath.startsWith(S3Service.S3_PREFIX)) {
                // Image is on S3 storage - stream directly to client for fastest performance
                String imageKey = imagePath.substring(S3Service.S3_PREFIX.length())
                try {
                    def s3Object = s3Service.getObject(imageKey)
                    response.setContentType(s3Object.response().contentType() ?: 'image/jpeg')

                    try {
                        s3Object.withStream { stream ->
                            response.outputStream << stream
                        }
                        response.flushBuffer()
                    } catch (ClientAbortException e) {
                        log.debug('client hung up', e)
                    } catch (IOException e) {
                        if (e.message != 'Broken pipe') {
                            log.error("Exception streaming S3 image", e)
                        } else {
                            log.debug('client hung up', e)
                        }
                    }
                } catch (Exception e) {
                    log.warn("Error retrieving image from S3: ${imageKey}", e)
                    sendPlaceholder(SAMPLE_TASK_IMAGE)
                }
            } else {
                // Image is on local disk storage
                String urlPrefix = grailsApplication.config.getProperty("images.urlPrefix", String.class)
                String imagesHome = grailsApplication.config.getProperty("images.home", String.class)

                String filePath = URLDecoder.decode(imagesHome + '/' + imagePath.substring(urlPrefix?.length()), StandardCharsets.UTF_8.name())
                File imageFile = new File(filePath)

                if (!imageFile.exists()) {
                    log.warn("Image file not found: ${filePath}")
                    sendPlaceholder(SAMPLE_TASK_IMAGE)
                    return
                }

                String fileExtension = FilenameUtils.getExtension(imagePath)?.toLowerCase()
                sendImage(imageFile, contentType(fileExtension))
            }

        } catch (Exception e) {
            log.error("Error retrieving task image for multimediaId: ${multimediaId}, externalIdentifier: ${externalIdentifier}", e)
            sendPlaceholder(SAMPLE_TASK_IMAGE)
        }
    }



}
