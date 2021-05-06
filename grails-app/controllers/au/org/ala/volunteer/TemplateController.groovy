package au.org.ala.volunteer

import com.google.common.hash.HashCode
import grails.converters.JSON
import grails.transaction.Transactional
import org.apache.commons.io.FilenameUtils
import org.springframework.dao.DataIntegrityViolationException
import org.springframework.web.multipart.MultipartFile

import static javax.servlet.http.HttpServletResponse.*

class TemplateController {

    static allowedMethods = [save: "POST", update: "POST", cloneTemplate: "POST"]

    def userService
    def templateFieldService
    def templateService
    def fileUploadService

    def index() {
        redirect(action: "list", params: params)
    }

    def list() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [templateInstanceList: Template.list(params), templateInstanceTotal: Template.count()]
    }

    def create() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = new Template()
        templateInstance.author = userService.currentUserId
        return [templateInstance: templateInstance, availableViews: templateService.getAvailableTemplateViews()]
    }

    def save() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        params.author = userService.currentUserId
        def templateInstance = new Template(params)
        if (templateInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'template.label', default: 'Template'), templateInstance.id])}"
            redirect(action: "edit", id: templateInstance.id)
        }
        else {
            render(view: "create", model: [templateInstance: templateInstance])
        }
    }

    def edit() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = Template.get(params.long('id'))
        if (!templateInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
            redirect(action: "list")
        }
        else {
            def availableViews = templateService.getAvailableTemplateViews()
            return [templateInstance: templateInstance, availableViews: availableViews]
        }
    }

    def update() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = Template.get(params.long('id'))
        if (templateInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (templateInstance.version > version) {
                    
                    templateInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'template.label', default: 'Template')] as Object[], "Another user has updated this Template while you were editing")
                    render(view: "edit", model: [templateInstance: templateInstance])
                    return
                }
            }

            // This is to stop an IDE warning about incompatible objects
            bindData(templateInstance, params)

            def viewParams = JSON.parse(params.viewParamsJSON as String) as Map

            def newViewParams = new HashMap<String, String>()
            if (viewParams) {
                viewParams.keySet().each {
                    newViewParams[it.toString()] = viewParams[it]?.toString()
                }
            }
            templateInstance.viewParams = newViewParams

            if (!templateInstance.hasErrors() && templateInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'template.label', default: 'Template'), templateInstance.id])}"
                redirect(action: "edit", id: templateInstance.id)
            } else {
                render(view: "edit", model: [templateInstance: templateInstance])
            }
        } else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = Template.get(params.long('id'))
        if (templateInstance) {
            try {
                // First got to delete all the template_fields...
                def fields = TemplateField.findAllByTemplate(templateInstance)
                if (fields) {
                    fields.each { it.delete(flush: true) }
                }
                // Now can delete template proper
                templateInstance.delete(flush: true)

                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
                redirect(action: "list")
            }
            catch (DataIntegrityViolationException e) {
                String message = "${message(code: 'default.not.deleted.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
                flash.message = message
                log.error(message, e)
                redirect(action: "edit", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
            redirect(action: "list")
        }
    }

    def manageFields() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = Template.get(params.int("id"))
        if (templateInstance) {
            def fields = TemplateField.findAllByTemplate(templateInstance)?.sort { it.displayOrder }

            [templateInstance: templateInstance, fields: fields]
        }
    }

    def addTemplateFieldFragment() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = Template.get(params.int("id"))
        if (templateInstance) {
            def fields = TemplateField.findAllByTemplate(templateInstance)?.sort { it.displayOrder }
            [templateInstance: templateInstance, fields: fields]
        }
    }

    @Transactional
    def moveFieldUp() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def field = TemplateField.get(params.int("fieldId"))
        if (field) {
            if (field.displayOrder > 1) {
                def predecessor = TemplateField.findByTemplateAndDisplayOrder(field.template, field.displayOrder - 1)
                if (predecessor) {
                    // swap their positions
                    predecessor.displayOrder++
                    predecessor.save()
                }
                field.displayOrder--
                field.save()
            }
        }

        redirect(action:'manageFields', id: field?.template?.id)
    }

    @Transactional
    def moveFieldDown() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def field = TemplateField.get(params.int("fieldId"))
        if (field) {
            def max = getLastDisplayOrder(field.template)
            if (field.displayOrder < max ) {
                def successor = TemplateField.findByTemplateAndDisplayOrder(field.template, field.displayOrder + 1)
                if (successor) {
                    // swap their positions
                    successor.displayOrder--
                    successor.save()
                }
                field.displayOrder++
                field.save()
            }
        }

        redirect(action:'manageFields', id: field?.template?.id)
    }

    @Transactional
    def moveFieldToPosition() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = Template.get(params.int("id"))
        def field = TemplateField.findByTemplateAndId(templateInstance, params.int("fieldId"))
        def newOrder = params.int("newOrder")
        if (templateInstance && field && newOrder) {
            def fields = TemplateField.findAllByTemplate(templateInstance)?.sort { it.displayOrder }
            if (newOrder >= 0 && newOrder <= fields.size()) {
                fields.each {
                    if (it.displayOrder >= newOrder) {
                        it.displayOrder++
                    }
                }
                field.displayOrder = newOrder
                redirect(action:'cleanUpOrdering', id:templateInstance.id)
                return
            }
        }

        redirect(action:'manageFields', id: field?.template?.id)
    }

    @Transactional
    def cleanUpOrdering() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = Template.get(params.int("id"))
        if (templateInstance) {
            def fields = TemplateField.findAllByTemplate(templateInstance)?.sort { it.displayOrder }
            int i = 1
            fields.each {
                it.displayOrder = i++
            }
            TemplateField.saveAll(fields)
        }

        redirect(action:'manageFields', id: templateInstance?.id)
    }

    @Transactional
    def addField() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        Template templateInstance = Template.get(params.int("id"))
        String fieldType = params.fieldType
        String classifier = params.fieldTypeClassifier

        if (templateInstance && fieldType) {

            def existing = TemplateField.findAllByTemplateAndFieldTypeAndFieldTypeClassifier(templateInstance, fieldType as DarwinCoreField, classifier)
            if (existing && fieldType != DarwinCoreField.spacer.toString() && fieldType != DarwinCoreField.widgetPlaceholder.toString()) {
                flash.message = "Add field failed: Field type " + fieldType + " already exists in this template!"
            } else {
                def displayOrder = getLastDisplayOrder(templateInstance) + 1
                FieldCategory category = params.category ?: FieldCategory.none
                FieldType type = params.type ?: FieldType.text
                def label = params.label ?: ""
                def field = new TemplateField(template: templateInstance, category: category, fieldType: fieldType, fieldTypeClassifier: classifier, displayOrder: displayOrder, defaultValue: '', type: type, label: label)
                field.save(failOnError: true)
            }
        }

        redirect(action:'manageFields', id: templateInstance?.id)
    }

    private int getLastDisplayOrder(Template template) {
        def c = TemplateField.createCriteria()
        def maxDisplayOrderCount = c.get({
            eq('template', template)
            projections {
                max('displayOrder')
            }
        })
        log.debug("Max order count: ${maxDisplayOrderCount}")

        return (maxDisplayOrderCount == null ? 0 : maxDisplayOrderCount as int)
    }

    @Transactional
    def deleteField() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = Template.get(params.int("id"))
        def field = TemplateField.findByTemplateAndId(templateInstance, params.int("fieldId"))
        if (field && templateInstance) {
            field.delete()
        }
        redirect(action:'manageFields', id: templateInstance?.id)
    }

    def preview() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = Template.get(params.int("id"))

        def projectInstance = new Project(template: templateInstance, featuredLabel: "PreviewProject", featuredOwner: "ALA", name: "${templateInstance.name} Preview (${templateInstance.viewName})")
        def taskInstance = new Task(project: projectInstance)
        def multiMedia = new Multimedia(id: 0)
        taskInstance.addToMultimedia(multiMedia)
        def recordValues = [:]
        def imageMetaData = [0: [width: 2048, height: 1433]]

        render(view: '/transcribe/templateViews/' + templateInstance.viewName, model: [taskInstance: taskInstance, recordValues: recordValues, isReadonly: null, template: templateInstance, nextTask: null, prevTask: null, sequenceNumber: 0, imageMetaData: imageMetaData, isPreview: true])
    }

    def exportFieldsAsCSV() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateInstance = Template.get(params.int("id"))

        if (templateInstance) {
            templateFieldService.exportFieldToCSV(templateInstance, response)
        }

    }

    def importFieldsFromCSV() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }

        MultipartFile f = request.getFile('uploadFile')

        if (!f || f.isEmpty()) {
            flash.message = "File missing or invalid. Make sure you select an upload file first!"
        } else {

            def templateInstance = Template.get(params.int("id"))
            if (templateInstance) {
                templateFieldService.importFieldsFromCSV(templateInstance, f)
            } else {
                flash.message = "Missing/invalid template id specified in request!"
            }
        }

        redirect(action:'manageFields', params:[id: params.id])
    }

    def cloneTemplate() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def template = Template.get(params.int("templateId"))
        String newName = params.newName

        if (newName) {
            def existing = Template.findByName(newName)
            if (existing) {
                flash.message = "Failed to clone template - a template with the name " + newName + " already exists!"
                redirect(action:'list')
                return
            }
        }

        if (template && newName) {
            templateService.cloneTemplate(template, newName)
        }

        redirect(action:'list')
    }

    def cloneTemplateFragment() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def template = Template.get(params.int("sourceTemplateId"))
        [templateInstance: template]
    }

    def viewParamsForm(Template template) {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def view = (params?.view ?: '') + 'Params'
        try {
            def model = [templateInstance: template]
            render template: view, model: model
        } catch (e) {
            log.trace("Could not render template $view", e)
            render status: 404
        }
    }

    /**
     * Config page for Wildlife Spotter template.
     * @param id Template ID to load config for.
     * @return
     */
    def wildlifeTemplateConfig(long id) {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def template = Template.get(id)
        def viewParams2 = template.viewParams2 ?: [ categories: [], animals: [] ]
        [id: id, templateInstance: template, viewParams2: viewParams2]
    }

    /**
     * Save action for Wildlife Spotter template config
     * @param id Template ID to save config to.
     */
    @Transactional
    def saveWildlifeTemplateConfig(long id) {
        if (!userService.isAdmin()) {
            respond status: SC_UNAUTHORIZED
            return
        }

        def template = Template.get(id)
        template.viewParams2 = request.getJSON() as Map
        template.save()

        respond status: SC_NO_CONTENT
    }

    /**
     * Upload image for Wildlife Spotter template picklists
     */
    def uploadWildlifeImage() {
        if (!userService.isAdmin()) {
            respond status: SC_UNAUTHORIZED
            return
        }

        MultipartFile upload = request.getFile('animal') ?: request.getFile('entry')

        if (upload) {
            def file = fileUploadService.uploadImage('wildlifespotter', upload) { MultipartFile f, HashCode h ->
                h.toString() + "." + fileUploadService.extension(f)
            }
            def hash = FilenameUtils.getBaseName(file.name)
            def ext = FilenameUtils.getExtension(file.name)
            render([ hash: hash, format: ext ] as JSON)
        } else {
            render([ error: "One of animal or entry must be provided" ] as JSON, status: SC_BAD_REQUEST)
        }
    }
}
