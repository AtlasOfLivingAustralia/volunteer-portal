package au.org.ala.volunteer

import javax.imageio.ImageIO
import java.awt.image.BufferedImage

class MultimediaController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index() {
        redirect(action: "list", params: params)
    }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [multimediaInstanceList: Multimedia.list(params), multimediaInstanceTotal: Multimedia.count()]
    }

    def create() {
        def multimediaInstance = new Multimedia()
        multimediaInstance.properties = params
        return [multimediaInstance: multimediaInstance]
    }

    def save() {
        def multimediaInstance = new Multimedia(params)
        if (multimediaInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), multimediaInstance.id])}"
            redirect(action: "show", id: multimediaInstance.id)
        }
        else {
            render(view: "create", model: [multimediaInstance: multimediaInstance])
        }
    }

    def show() {
        def multimediaInstance = Multimedia.get(params.id)
        if (!multimediaInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
            redirect(action: "list")
        }
        else {
            [multimediaInstance: multimediaInstance]
        }
    }

    def edit() {
        def multimediaInstance = Multimedia.get(params.id)
        if (!multimediaInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [multimediaInstance: multimediaInstance]
        }
    }

    def update() {
        def multimediaInstance = Multimedia.get(params.id)
        if (multimediaInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (multimediaInstance.version > version) {
                    
                    multimediaInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'multimedia.label', default: 'Multimedia')] as Object[], "Another user has updated this Multimedia while you were editing")
                    render(view: "edit", model: [multimediaInstance: multimediaInstance])
                    return
                }
            }
            multimediaInstance.properties = params
            if (!multimediaInstance.hasErrors() && multimediaInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), multimediaInstance.id])}"
                redirect(action: "show", id: multimediaInstance.id)
            }
            else {
                render(view: "edit", model: [multimediaInstance: multimediaInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete() {
        def multimediaInstance = Multimedia.get(params.id)
        if (multimediaInstance) {
            try {
                multimediaInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                String message = "${message(code: 'default.not.deleted.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
                flash.message = message
                log.error(message, e)
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
            redirect(action: "list")
        }
    }

    def imageDownload() {
        def mm = Multimedia.get(params.int("id"))
        if (mm) {
            def path = mm?.filePath
            String urlPrefix = grailsApplication.config.images.urlPrefix
            String imagesHome = grailsApplication.config.images.home
            path = URLDecoder.decode(imagesHome + '/' + path.substring(urlPrefix?.length()))  // have to reverse engineer the files location on disk, this info should be part of the Multimedia structure!
            BufferedImage image = null
            image = ImageIO.read(new File(path))
            def rotate = params.int("rotate") ?: 0
            if (rotate) {
                image = ImageUtils.rotateImage(image, rotate)
            }

            if (params.maxDimension) {
                def size = params.int("maxDimension")
                image = ImageUtils.scale(image, size, size)
            } else if (params.maxWidth) {
                def width = params.int("maxWidth")
                image = ImageUtils.scaleWidth(image, width)
            }

            def outputBytes = ImageUtils.imageToBytes(image)
            response.setContentType(mm.mimeType ?: "image/jpeg")
            response.setHeader("Content-disposition", "attachment;filename=${mm.task.externalIdentifier}.jpg")
            response.outputStream.write(outputBytes)
            response.flushBuffer()
        }
    }
}
