package au.org.ala.volunteer

import grails.converters.JSON
import org.apache.commons.lang3.StringEscapeUtils
import org.grails.plugins.csv.CSVWriter

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
    
    def uploadCsvData = {
        picklistService.replaceItems(Long.parseLong(params.picklistId), params.picklist.toCsvReader(), params.institutionCode)
        redirect(action: "manage")
    }

    def uploadCsvFile() {
        def f = request.getFile('picklistFile')
        picklistService.replaceItems(Long.parseLong(params.picklistId), f.inputStream.toCsvReader(['charset':'UTF-8']), params.institutionCode)
        redirect(action: "manage")
    }

    def manage = {
        def picklistInstitutionCodes = [""]
        picklistInstitutionCodes.addAll(picklistService.getInstitutionCodes())
        [picklistInstanceList: Picklist.list(), collectionCodes: picklistInstitutionCodes]
    }

    private static writeItemsCsv(Writer writer, Picklist picklist, String institutionCode) {
        if (picklist) {

            def delim = ','
            def items = PicklistItem.findAllByPicklistAndInstitutionCode(picklist, institutionCode ?: null)
            items?.each { item ->
                writer.write(item.value ? StringEscapeUtils.escapeCsv(item.value) : '')
                writer.write(delim)
                writer.write(item.key ? StringEscapeUtils.escapeCsv(item.key) : '')
                writer.write("\n")
            }
        }
    }

    def images(Picklist picklistInstance) {
        def inst = params.institution

        def items
        if (inst) items = PicklistItem.findAllByPicklistAndInstitutionCode(picklistInstance, inst)
        else items = PicklistItem.findAllByPicklist(picklistInstance)

        respond picklistInstance, model: [picklistItems: items]
    }

    def loadcsv = {
        def picklist = Picklist.get(params.picklistId)
        def institutionCode = params.institutionCode
        def csvdata = ''
        if (picklist) {
            StringWriter sw = new StringWriter();
            writeItemsCsv(sw, picklist, institutionCode)
            csvdata = sw.toString();
        }
        def picklistInstitutionCodes = [""]
        picklistInstitutionCodes.addAll(picklistService.getInstitutionCodes())
        render(view: "manage", model: [picklistData:csvdata, picklistInstanceList: Picklist.list(params), name: picklist?.name, id: picklist?.id, institutionCode: params.institutionCode, collectionCodes: picklistInstitutionCodes])
    }
    
    def download = {
        def picklist = Picklist.get(params.picklistId)
        if (picklist) {
            response.setHeader("Content-disposition", "attachment;filename=" + picklist.name + ".csv")
            response.contentType = "text/csv"
            OutputStreamWriter writer = new OutputStreamWriter(response.outputStream);
            writeItemsCsv(writer, picklist, params.institutionCode)
            writer.flush();
            writer.close();
        }
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

        def existing
        if (params.fieldTypeClassifier) {
            existing = Picklist.findByNameAndFieldTypeClassifier(params.name, params.fieldTypeClassifier)
        } else {
            existing = Picklist.findByName(params.name)
        }

        if (existing) {
            flash.message = "A picklist already exists with the name ${params.name}"
            if (params.clazz) flash.message += " and class ${params.clazz}"
            render(view: "create", model: [picklistInstance: picklistInstance])
            return
        }

        if (picklistInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'picklist.label', default: 'Picklist'), picklistInstance.id])}"
            redirect(action: "show", id: picklistInstance.id)
        } else {
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
            def picklistItemInstanceList
            def picklistItemInstanceTotal

            if (params.q) {
                picklistItemInstanceList = PicklistItem.findAllByPicklistAndValueIlike(picklistInstance, "%" + params.q + "%", params)
                picklistItemInstanceTotal = PicklistItem.countByPicklistAndValueIlike(picklistInstance, "%" + params.q + "%")
            } else {
                picklistItemInstanceList = PicklistItem.findAllByPicklist(picklistInstance, params)
                picklistItemInstanceTotal = PicklistItem.countByPicklist(picklistInstance)
            }
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

    def addCollectionCodeFragment() {
    }

    def ajaxCreateNewCollectionCode() {
        def code = params.code
        boolean success = false
        def message = ""
        if (code) {
            success = picklistService.addCollectionCode(code)
            if (!success) {
                message = "Collection code ${code} already exists."
            }
        } else {
            message = "No code parameter supplied!"
        }
        render([success: success, message: message] as JSON)
    }
}
