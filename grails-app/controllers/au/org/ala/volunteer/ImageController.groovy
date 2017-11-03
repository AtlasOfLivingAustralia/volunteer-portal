package au.org.ala.volunteer

import grails.converters.JSON

import javax.imageio.ImageIO

import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST
import static javax.servlet.http.HttpServletResponse.SC_NOT_FOUND

class ImageController {


    final static FORMATS = ['png', 'jpg', 'gif']

    final static MAX_WIDTH = 1024
    final static MAX_HEIGHT = 1024

    def size(String prefix, int width, int height, String name, String format) {

        log.debug("Image request for $prefix, $name at ${width}x${height} in $format")

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
        File result = new File("$imagesHome${File.separator}$prefix", "${name}_${width}_${height}.${format}")

        if (result.exists()) {
            sendImage(result, contentType(format))
            return
        }

        File original = findImage(prefix, name)
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
    }

    static final TYPES = [
            '.jpg','jpeg',
            '.jp2', '.j2k', '.jpf', '.jpx', '.jpm', '.mj2',
            '.jxr', '.hdp', '.wdp',
            '.png','.apng',
            '.gif',
            '.bmp',
            '.webp',
            '.tiff', '.tif',
            '.mng',
            '.svg',
            '.xbm',
            '.ico'
    ]

    private File findImage(String prefix, String name) {
        def imagesHome = grailsApplication.config.getProperty('images.home')
        File home = new File(imagesHome, prefix)
        def ext = TYPES.find { ext ->
            new File(home, name + ext).exists()
        }
        ext ? new File(home, name + ext) : null
    }

    // TODO move to utils
    private String contentType(String format) {
        switch(format) {
            case 'jpg': return 'image/jpeg'
            case 'png': return 'image/png'
            case 'gif': return 'image/gif'
        }
        return 'application/octet-stream'
    }
}
