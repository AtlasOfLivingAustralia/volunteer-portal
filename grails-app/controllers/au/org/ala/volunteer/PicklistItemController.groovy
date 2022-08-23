package au.org.ala.volunteer

import grails.converters.JSON
import grails.gorm.transactions.Transactional

class PicklistItemController {

    def index () {
        redirect(controller: 'picklist', action: "manage")
    }

    def autocomplete() {

        def picklistId = params.picklistId
        def picklistName = params.picklist
        def task = Task.get(params.int('taskId'))
        def query = params.q
        if ((picklistId || picklistName) && query) {
            def picklist = picklistId ? Picklist.get(picklistId) : Picklist.findByName(picklistName)
            if (picklist) {
                // Check to see if there are institution specific values for this pick list.
                // If there, we constrain our search to those items, otherwise we look in the general (null institution code) list
                def items
                if (task) {
                    def instItemCount = 0
                    instItemCount = PicklistItem.countByPicklistAndInstitutionCode(picklist, task.project?.picklistInstitutionCode)

                    if (instItemCount > 0) {
                        items = PicklistItem.findAllByValueIlikeAndPicklistAndInstitutionCode("%" + query + "%", picklist, task.project?.picklistInstitutionCode)
                    } else {
                        items = PicklistItem.findAllByPicklistAndInstitutionCodeIsNullAndValueIlike(picklist, "%" + query + "%")
                    }
                } else {
                    items = PicklistItem.findAllByPicklistAndInstitutionCodeIsNullAndValueIlike(picklist, "%" + query + "%")
                }

                if (items) {
                    // Send the results back as an array
                    render(contentType: "application/json") {
                        autoCompleteList(items) { pli ->
                            name pli.value
                            key pli.key
                        }
                    }
                    return
                }
            }
        }

        render([] as JSON)
    }

    @Transactional
    def updateLocality () {
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











}
