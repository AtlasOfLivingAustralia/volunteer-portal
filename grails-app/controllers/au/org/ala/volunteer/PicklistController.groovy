package au.org.ala.volunteer

import au.com.bytecode.opencsv.CSVReader
import grails.converters.JSON
import grails.gorm.transactions.Transactional
import groovy.json.JsonOutput
import org.apache.commons.lang3.StringEscapeUtils
import org.springframework.dao.DataIntegrityViolationException

class PicklistController {

    static allowedMethods = [upload: "POST", save: "POST", update: "POST", delete: "POST"]

    def picklistService
    def imagesWebService
    def imageServiceService
    def userService

    static final UUID_REGEX = /[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/
    static final LIST_SEPARATOR_REGEX = /; | & |, /

    def index () {
        redirect(action: "list", params: params)
    }

    def uploadCsvData () {
        if (userService.isInstitutionAdmin()) {
            CSVReader csvReader = params.picklist.toCsvReader()
            picklistService.replaceItems(params.long('picklistId'), csvReader, params.institutionCode?.toString())
            updatedCsvMessage("${Picklist.get(params.long('picklistId')).name}/${params.institutionCode}")
            redirect(action: "manage", params: [picklistId: params.picklistId])
        } else {
            render(view: '/notPermitted')
        }
    }

    def uploadCsvFile() {
        if (userService.isInstitutionAdmin()) {
            def f = request.getFile('picklistFile')
            CSVReader csvReader = f.inputStream.toCsvReader(['charset': 'UTF-8'])
            picklistService.replaceItems(params.long('picklistId'), csvReader, params.institutionCode?.toString())
            updatedCsvMessage("${Picklist.get(params.long('picklistId')).name}/${params.institutionCode}")
            redirect(action: "manage", params: [picklistId: params.picklistId])
        } else {
            render(view: '/notPermitted')
        }
    }

    private void updatedCsvMessage(String msg) {
        flash.message = message(code: 'default.updated.message',
                 args: [message(code: 'picklist.label', default: 'Picklist'), msg]) as String
    }

    def manage () {
        if (userService.isInstitutionAdmin()) {
            def picklistInstitutionCodes = [""]
            picklistInstitutionCodes.addAll(picklistService.getInstitutionCodes())
            [picklistInstanceList: Picklist.list([sort: 'name', order: 'asc']), collectionCodes: picklistInstitutionCodes]
        } else {
            render(view: '/notPermitted')
        }
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
        if (userService.isInstitutionAdmin()) {
            String inst = params.institution

            def items
            if (inst) items = PicklistItem.findAllByPicklistAndInstitutionCode(picklistInstance, inst)
            else items = PicklistItem.findAllByPicklist(picklistInstance)

            respond picklistInstance, model: [picklistItems: items]
        } else {
            render(view: '/notPermitted')
        }
    }

    def wildcount(Picklist picklist) {
        if (userService.isInstitutionAdmin()) {
            def institutionCode = params.institutionCode?.toString()

            def items
            if (institutionCode) items = PicklistItem.findAllByPicklistAndInstitutionCode(picklist, institutionCode)
            else items = PicklistItem.findAllByPicklist(picklist)

            def imageIds = items.collect {
                def o = JSON.parse(it.key)
                o.dayImages + o.nightImages
            }.flatten()

            def imageMap = imageServiceService.getImageInfoForIds(imageIds)

            respond picklist, model: [picklistItems: items, institutionCode: institutionCode, imageMap: imageMap]
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def loadWildcount(Picklist picklistInstance) {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        CSVReader reader = params.csv.toCsvReader()
        String instCode = params.instCode ?: null

        def line
        def headerLine = line = reader.readNext()
        def headers = [:]
        headerLine.eachWithIndex { String entry, int i ->
            headers.put(entry.toLowerCase(), i)
        }
        int i = 0
        List<PicklistItem> pis = []
        def warnings = []
        while (line = reader.readNext()) {
            def species = getValueFromLine(line, headers, 'species')
            def reference  = getValueFromLine(line, headers, 'reference').toString()?.toLowerCase() == 'y'
            def (bnw, warnings2) = wildcountImageArrayLookup(getValueFromLine(line, headers, 'black and white'))
            def (colour, warnings3) = wildcountImageArrayLookup(getValueFromLine(line, headers, 'colour'))
            def group1 = getValueFromLine(line, headers, 'group 1')
            def group2 = getValueFromLine(line, headers, 'group 2')
            def group3 = getValueFromLine(line, headers, 'group 3')
            def similarSpecies = wildcountLineToArray(getValueFromLine(line, headers, 'similar species'))

            def tags = [group1, group2, group3].findAll { it }
            def obj = [reference: reference, tags: tags, dayImages: colour ?: [], nightImages: bnw ?: [], similarSpecies: similarSpecies]
            def pi = new PicklistItem(value: species, key: JsonOutput.toJson(obj), index: i++, institutionCode: instCode, picklist: picklistInstance)
            warnings += warnings2
            warnings += warnings3
            pis << pi
        }

        def dc
        if (instCode) dc = PicklistItem.where { picklist == picklistInstance && institutionCode == instCode }
        else dc = PicklistItem.where { picklist == picklistInstance && institutionCode == null }

        def n = dc.deleteAll()

        log.debug("Deleted $n picklist items for $picklistInstance ($instCode)")

        pis*.save()

        if (warnings) flash.message = "Couldn't find images for ${warnings.join(', ')}"

        redirect action: 'wildcount', id: picklistInstance.id, params: [institutionCode: instCode]
    }

    private def wildcountLineToArray(line) {
        line.split(LIST_SEPARATOR_REGEX).collect { (it as String)?.trim() }.findAll { 'none' != it?.toLowerCase() && 'nil' != it?.toLowerCase() && it }
    }

    private def wildcountImageArrayLookup(line) {
        def arr = wildcountLineToArray(line)
        def files = arr.findAll { !(it ==~ UUID_REGEX) }.collect { [sourceUrl: (it + '.jpg')] }

        def warnings = []

        log.debug("Fetching image info for $files")
        def infos = imagesWebService.getImageInfo(files)

        def results = arr.collect {
            if (it ==~ UUID_REGEX) {
                it
            } else {
                def result = infos[(it+'.jpg')]?.imageId
                if (!result) warnings << it
                result ?: null
            }
        }.findAll { it }

        [results, warnings]
    }

    private String getValueFromLine(line, headers, value) {
        def idx = headers.get(value.toLowerCase())
        idx == null ? null : line[idx]
    }

    def loadcsv () {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def picklist = Picklist.get(params.long('picklistId'))
        String institutionCode = params.institutionCode
        def csvdata = ''
        if (picklist) {
            StringWriter sw = new StringWriter()
            writeItemsCsv(sw, picklist, institutionCode)
            csvdata = sw.toString()
        }
        params.putAll([sort: 'name', order: 'asc'])
        def picklistInstitutionCodes = [""]
        picklistInstitutionCodes.addAll(picklistService.getInstitutionCodes())
        render(view: "manage", model: [picklistData: csvdata,
                                       picklistInstanceList: Picklist.list(params),
                                       name: picklist?.name,
                                       id: picklist?.id,
                                       institutionCode: params.institutionCode,
                                       collectionCodes: picklistInstitutionCodes])
    }

    def download () {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def picklist = Picklist.get(params.long('picklistId'))
        if (picklist) {
            response.setHeader("Content-disposition", "attachment;filename=" + picklist.name + ".csv")
            response.contentType = "text/csv"
            OutputStreamWriter writer = new OutputStreamWriter(response.outputStream)
            writeItemsCsv(writer, picklist, params.institutionCode as String)
            writer.flush()
            writer.close()
        }
    }

    def list () {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
        }
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [picklistInstanceList: Picklist.list(params), picklistInstanceTotal: Picklist.count()]
    }

    def create () {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def picklist = new Picklist()
        // picklist.properties = params
        bindData(picklist, params)
        return [picklistInstance: picklist]
    }

    @Transactional
    def save () {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def picklist = new Picklist(params)

        def existing
        if (params.fieldTypeClassifier) {
            existing = Picklist.findByNameAndFieldTypeClassifier(params.name?.toString(), params.fieldTypeClassifier?.toString())
        } else {
            existing = Picklist.findByName(params.name?.toString())
        }

        if (existing) {
            flash.message = "A picklist already exists with the name ${params.name}"
            if (params.clazz) flash.message += " and class ${params.clazz}"
            render(view: "create", model: [picklistInstance: picklist])
            return
        }

        if (picklist.save(flush: true)) {
            flash.message = message(code: 'default.created.message',
                     args: [message(code: 'picklist.label', default: 'Picklist'), picklist.id]) as String
            redirect(action: "show", id: picklist.id)
        } else {
            render(view: "create", model: [picklistInstance: picklist])
        }
    }

    def show () {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def picklist = Picklist.get(params.long('id'))
        if (!picklist) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'picklist.label', default: 'Picklist'), params.id]) as String
            redirect(action: "list")
        } else {
            params.max = Math.min(params.max ? params.int('max') : 100, 100)
            def picklistItemList
            def picklistItemTotal

            if (params.q) {
                String searchQ = "%${params.q}%"
                picklistItemList = PicklistItem.findAllByPicklistAndValueIlike(picklist, searchQ, params)
                picklistItemTotal = PicklistItem.countByPicklistAndValueIlike(picklist, searchQ)
            } else {
                picklistItemList = PicklistItem.findAllByPicklist(picklist, params)
                picklistItemTotal = PicklistItem.countByPicklist(picklist)
            }
            [picklistInstance: picklist, picklistItemInstanceList: picklistItemList, picklistItemInstanceTotal: picklistItemTotal]
        }
    }

    def edit () {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def picklist = Picklist.get(params.long('id'))
        if (!picklist) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'picklist.label', default: 'Picklist'), params.id]) as String
            redirect(action: "list")
        }
        else {
            return [picklistInstance: picklist]
        }
    }

    @Transactional
    def update () {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def picklist = Picklist.get(params.long('id'))
        if (picklist) {
            if (params.version) {
                def version = params.version.toLong()
                if (picklist.version > version) {

                    picklist.errors.rejectValue("version",
                            "default.optimistic.locking.failure",
                            [message(code: 'picklist.label', default: 'Picklist')] as Object[],
                            "Another user has updated this Picklist while you were editing")
                    render(view: "edit", model: [picklistInstance: picklist])
                    return
                }
            }

            // picklistInstance.properties = params
            bindData(picklist, params)

            if (!picklist.hasErrors() && picklist.save(flush: true)) {
                flash.message = message(code: 'default.updated.message',
                         args: [message(code: 'picklist.label', default: 'Picklist'), picklist.id]) as String
                redirect(action: "show", id: picklist.id)
            } else {
                render(view: "edit", model: [picklistInstance: picklist])
            }
        } else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'picklist.label', default: 'Picklist'), params.id]) as String
            redirect(action: "list")
        }
    }

    def delete () {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def picklist = Picklist.get(params.long('id'))
        if (picklist) {
            try {
                PicklistItem.executeUpdate("delete PicklistItem p where p.picklist = :picklist", [picklist: picklist])
                picklist.delete(flush: true)
                flash.message = message(code: 'default.deleted.message',
                         args: [message(code: 'picklist.label', default: 'Picklist'), params.id]) as String
                redirect(action: "list")
            } catch (DataIntegrityViolationException e) {
                String message = message(code: 'default.not.deleted.message',
                          args: [message(code: 'picklist.label', default: 'Picklist'), params.id]) as String
                flash.message = message
                log.error(message, e)
                redirect(action: "show", id: params.id)
            }
        } else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'picklist.label', default: 'Picklist'), params.id]) as String
            redirect(action: "list")
        }
    }

    def addCollectionCodeFragment() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
        }
    }

    def ajaxCreateNewCollectionCode() {
        if (!userService.isInstitutionAdmin()) {
            render([status: 403, message: "Forbidden"] as JSON)
        } else {
            String code = params.code?.toString()
            boolean success = false
            def message
            if (code) {
                success = picklistService.addCollectionCode(code)
                if (!success) {
                    message = "Collection code ${code} already exists."
                } else {
                    message = "Successful addition of collection code."
                }
            } else {
                message = "No code parameter supplied!"
            }
            render([success: success, message: message] as JSON)
        }
    }
}
