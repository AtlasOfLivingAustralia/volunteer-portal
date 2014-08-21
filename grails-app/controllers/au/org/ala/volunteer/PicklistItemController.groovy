package au.org.ala.volunteer

import grails.converters.JSON

class PicklistItemController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]
    
    def autocomplete() {

        def picklistName = params.picklist
        def task = Task.get(params.int('taskId'))
        def query = params.q
        if (picklistName && query && task) {
            def picklist = Picklist.findByName(picklistName)
            if (picklist) {
                // Check to see if there are institution specific values for this pick list.
                // If there, we constrain our search to those items, otherwise we look in the general (null institution code) list
                def instItemCount = PicklistItem.countByPicklistAndInstitutionCode(picklist, task.project?.picklistInstitutionCode)
                def items
                if (instItemCount > 0) {
                    items = PicklistItem.findAllByValueIlikeAndPicklistAndInstitutionCode("%" + query + "%", picklist, task.project?.picklistInstitutionCode)
                } else {
                    items = PicklistItem.findAllByPicklistAndInstitutionCodeIsNullAndValueIlike(picklist, "%" + query + "%")
                }

                if (items) {
                    // Send the results back as an array
                    render(contentType: "application/json") {
                        autoCompleteList = array {
                            for (pli in items) {
                                picklistItem(name: pli.value, key: pli.key)
                            }
                        }
                    }
                    return
                }
            }
        }

        render([] as JSON)
    }

    def updateLocality = {
        def picklist = Picklist.findByName("verbatimLocality")
        def name = params.name
        def picklistItems = PicklistItem.findAllByValueIlikeAndPicklist("%"+name+"%", picklist)

        if (!picklistItems) {
            def picklistItemInstance = new PicklistItem()
            picklistItemInstance.picklist = picklist
            picklistItemInstance.value = name + "|" + params.lat + "|" + params.lng + "|" + params.cuim
            if (picklistItemInstance.save(flush: true)) {
                render (status: 201, text: "locality added as new picklistItem")
            }
            else {
                render (status: 500, text: "Failed to save new picklistItem: " + picklistItemInstance.errors)
            }
        } else {
            // picklistitem with same locality exists
            render (status: 200, text: "Item already present in picklist: " + name)
        }
    }

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 100, 100)
        [picklistItemInstanceList: PicklistItem.list(params), picklistItemInstanceTotal: PicklistItem.count()]
    }

    def create = {
        def picklistItemInstance = new PicklistItem()
        picklistItemInstance.properties = params
        return [picklistItemInstance: picklistItemInstance]
    }

    def save = {
        def picklistItemInstance = new PicklistItem(params)
        if (picklistItemInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'picklistItem.label', default: 'PicklistItem'), picklistItemInstance.id])}"
            redirect(action: "show", id: picklistItemInstance.id)
        }
        else {
            render(view: "create", model: [picklistItemInstance: picklistItemInstance])
        }
    }

    def show = {
        def picklistItemInstance = PicklistItem.get(params.id)
        if (!picklistItemInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'picklistItem.label', default: 'PicklistItem'), params.id])}"
            redirect(action: "list")
        }
        else {
            [picklistItemInstance: picklistItemInstance]
        }
    }

    def edit = {
        def picklistItemInstance = PicklistItem.get(params.id)
        if (!picklistItemInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'picklistItem.label', default: 'PicklistItem'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [picklistItemInstance: picklistItemInstance]
        }
    }

    def update = {
        def picklistItemInstance = PicklistItem.get(params.id)
        if (picklistItemInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (picklistItemInstance.version > version) {
                    
                    picklistItemInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'picklistItem.label', default: 'PicklistItem')] as Object[], "Another user has updated this PicklistItem while you were editing")
                    render(view: "edit", model: [picklistItemInstance: picklistItemInstance])
                    return
                }
            }
            picklistItemInstance.properties = params
            if (!picklistItemInstance.hasErrors() && picklistItemInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'picklistItem.label', default: 'PicklistItem'), picklistItemInstance.id])}"
                redirect(action: "show", id: picklistItemInstance.id)
            }
            else {
                render(view: "edit", model: [picklistItemInstance: picklistItemInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'picklistItem.label', default: 'PicklistItem'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def picklistItemInstance = PicklistItem.get(params.id)
        if (picklistItemInstance) {
            try {
                picklistItemInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'picklistItem.label', default: 'PicklistItem'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'picklistItem.label', default: 'PicklistItem'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'picklistItem.label', default: 'PicklistItem'), params.id])}"
            redirect(action: "list")
        }
    }
}
