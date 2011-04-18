package au.org.ala.volunteer

class MultimediaController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [multimediaInstanceList: Multimedia.list(params), multimediaInstanceTotal: Multimedia.count()]
    }

    def create = {
        def multimediaInstance = new Multimedia()
        multimediaInstance.properties = params
        return [multimediaInstance: multimediaInstance]
    }

    def save = {
        def multimediaInstance = new Multimedia(params)
        if (multimediaInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), multimediaInstance.id])}"
            redirect(action: "show", id: multimediaInstance.id)
        }
        else {
            render(view: "create", model: [multimediaInstance: multimediaInstance])
        }
    }

    def show = {
        def multimediaInstance = Multimedia.get(params.id)
        if (!multimediaInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
            redirect(action: "list")
        }
        else {
            [multimediaInstance: multimediaInstance]
        }
    }

    def edit = {
        def multimediaInstance = Multimedia.get(params.id)
        if (!multimediaInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [multimediaInstance: multimediaInstance]
        }
    }

    def update = {
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

    def delete = {
        def multimediaInstance = Multimedia.get(params.id)
        if (multimediaInstance) {
            try {
                multimediaInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'multimedia.label', default: 'Multimedia'), params.id])}"
            redirect(action: "list")
        }
    }
}
