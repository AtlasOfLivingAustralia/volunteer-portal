package au.org.ala.volunteer

import grails.converters.JSON
import org.apache.catalina.connector.ClientAbortException

import javax.imageio.ImageIO

import static au.org.ala.volunteer.ImageUtils.contentType
import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST
import static javax.servlet.http.HttpServletResponse.SC_NOT_FOUND

class ImageController {


    final static FORMATS = ['png', 'jpg', 'gif']
    final static FORMAT_AUDIO = ['m4a', 'wav', 'mp3', 'aac']

    final static MAX_WIDTH = 1024
    final static MAX_HEIGHT = 1024

    def size(String prefix, int width, int height, String name, String format) {

        log.debug("Image request for $prefix, $name at ${width}x${height} in $format")

        def encodedPrefix = IOUtils.toFileSystemDirectorySafeName(prefix)
        def encodedName = IOUtils.toFileSystemSafeName(name)

        format = format.toLowerCase()
        if (!FORMATS.contains(format)) {
            render([error: "${format} not supported"] as JSON, status: SC_BAD_REQUEST)
            return
        }

        if (width < 0 || width >  MAX_WIDTH || height < 0 || height > MAX_HEIGHT) {
            render([error: "${width}x${height} not supported"] as JSON, status: SC_BAD_REQUEST)
            return
        }

        def imagesHome = grailsApplication.config.getProperty('images.home')
        File result = new File("$imagesHome${File.separator}$encodedPrefix", "${encodedName}_${width}_${height}.${format}")

        if (result.exists()) {
            sendImage(result, contentType(format))
            return
        }

        File original = findImage(encodedPrefix, encodedName)
        if (!original) {
            response.sendError(SC_NOT_FOUND)
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

        if (result.exists()) {
            sendImage(result, contentType(format))
            return
        }

        File original = findImage(encodedPrefix, encodedName)
        if (!original) {
            response.sendError(SC_NOT_FOUND)
            return
        }

        def originalImage = ImageIO.read(original)
        if (!originalImage) {
            log.warn("${original.path} could not be read as an image")
            render([error: "${original.path} could not be read as an image"] as JSON, status: 500)
            return
        }
        originalImage.flush()
        sendImage(result, contentType(format))
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

    static final TYPES = [
            '.jpg','.jpeg', '.png', '.gif', '.bmp', '.webp',
            '.tiff', '.tif',
            '.svg',
            '.jp2', '.j2k', '.jpf', '.jpx', '.jpm', '.mj2',
            '.jxr', '.hdp', '.wdp',
            '.apng',
            '.mng',
            '.xbm',
            '.ico'
    ]

    private File findImage(String prefix, String name) {
        def imagesHome = grailsApplication.config.getProperty('images.home')
        File home = new File(imagesHome, prefix)
        for (def ext : TYPES) {
            def f = new File(home, name + ext)
            if (f.exists()) {
                return f
            }
        }
        return null
    }

}
