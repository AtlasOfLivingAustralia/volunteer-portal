package au.org.ala.volunteer

class PicklistController {

    static allowedMethods = [upload: "POST", save: "POST", update: "POST", delete: "POST"]

    def picklistService

    def index = {
        redirect(action: "list", params: params)
    }

    def load = {}

    def upload = {
      picklistService.load(params.name, params.picklist)
      redirect(action: "list")
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [picklistInstanceList: Picklist.list(params), picklistInstanceTotal: Picklist.count()]
    }

    def create = {
        def picklistInstance = new Picklist()
        picklistInstance.properties = params
        return [picklistInstance: picklistInstance]
    }

    def save = {
        def picklistInstance = new Picklist(params)
        if (picklistInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'picklist.label', default: 'Picklist'), picklistInstance.id])}"
            redirect(action: "show", id: picklistInstance.id)
        }
        else {
            render(view: "create", model: [picklistInstance: picklistInstance])
        }
    }

    def show = {
        def picklistInstance = Picklist.get(params.id)
        if (!picklistInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'picklist.label', default: 'Picklist'), params.id])}"
            redirect(action: "list")
        }
        else {
          params.max = Math.min(params.max ? params.int('max') : 100, 100)


          def picklistItemInstanceList = PicklistItem.findAllByPicklist(picklistInstance, params)
          def picklistItemInstanceTotal = PicklistItem.countByPicklist(picklistInstance)


          [picklistInstance: picklistInstance, picklistItemInstanceList: picklistItemInstanceList, picklistItemInstanceTotal: picklistItemInstanceTotal]
        }
    }

    def edit = {
        def picklistInstance = Picklist.get(params.id)
        if (!picklistInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'picklist.label', default: 'Picklist'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [picklistInstance: picklistInstance]
        }
    }

    def update = {
        def picklistInstance = Picklist.get(params.id)
        if (picklistInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (picklistInstance.version > version) {
                    
                    picklistInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'picklist.label', default: 'Picklist')] as Object[], "Another user has updated this Picklist while you were editing")
                    render(view: "edit", model: [picklistInstance: picklistInstance])
                    return
                }
            }
            picklistInstance.properties = params
            if (!picklistInstance.hasErrors() && picklistInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'picklist.label', default: 'Picklist'), picklistInstance.id])}"
                redirect(action: "show", id: picklistInstance.id)
            }
            else {
                render(view: "edit", model: [picklistInstance: picklistInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'picklist.label', default: 'Picklist'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def picklistInstance = Picklist.get(params.id)
        if (picklistInstance) {
            try {
                PicklistItem.executeUpdate("delete PicklistItem p where p.picklist = :picklist", [picklist: picklistInstance])
                picklistInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'picklist.label', default: 'Picklist'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'picklist.label', default: 'Picklist'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'picklist.label', default: 'Picklist'), params.id])}"
            redirect(action: "list")
        }
    }
}
