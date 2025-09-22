package au.org.ala.volunteer

import asset.pipeline.grails.AssetResourceLocator
import grails.converters.JSON
import org.apache.catalina.connector.ClientAbortException
import org.apache.commons.io.FilenameUtils
import org.springframework.core.io.Resource

import javax.imageio.ImageIO

import static au.org.ala.volunteer.ImageUtils.contentType
import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST
import static javax.servlet.http.HttpServletResponse.SC_NOT_FOUND

class ImageController {

    def imageService
    AssetResourceLocator assetResourceLocator

    final static FORMATS = ['png', 'jpg', 'gif']
    final static FORMAT_AUDIO = ['m4a', 'wav', 'mp3', 'aac']

    final static MAX_WIDTH = 1024
    final static MAX_HEIGHT = 1024

    /**
     * Get an image of a specific size, creating it if necessary. If the image does not exist
     * then a placeholder image is returned. If the image cannot be found and allowBroken=true
     * is set then a 404 is returned.
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
            sendPlaceholder()
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
            sendPlaceholder()
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
     * Send a placeholder image.
     */
    private def sendPlaceholder() {
        Resource placeholderResource = assetResourceLocator.findAssetForURI('ws-placeholder-150.png')
        if (placeholderResource?.exists()) {
            log.debug("Placeholder image found.")
            response.contentType = "image/png"
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
                log.error("Exception sending image {}, {}", file, contentType, e)
                render(status: 500, text: 'an error occured')
            } else {
                // client hung up, can't do anything
                log.debug('client hung up', e)
            }
        }
    }

}
