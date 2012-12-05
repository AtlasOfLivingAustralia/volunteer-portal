package au.org.ala.volunteer

class TemplateController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [templateInstanceList: Template.list(params), templateInstanceTotal: Template.count()]
    }

    def create = {
        def templateInstance = new Template()
        templateInstance.properties = params
        return [templateInstance: templateInstance]
    }

    def save = {
        def templateInstance = new Template(params)
        if (templateInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'template.label', default: 'Template'), templateInstance.id])}"
            redirect(action: "show", id: templateInstance.id)
        }
        else {
            render(view: "create", model: [templateInstance: templateInstance])
        }
    }

    def show = {
        def templateInstance = Template.get(params.id)
        if (!templateInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
            redirect(action: "list")
        }
        else {
            [templateInstance: templateInstance]
        }
    }

    def edit = {
        def templateInstance = Template.get(params.id)
        if (!templateInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [templateInstance: templateInstance]
        }
    }

    def update = {
        def templateInstance = Template.get(params.id)
        if (templateInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (templateInstance.version > version) {
                    
                    templateInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'template.label', default: 'Template')] as Object[], "Another user has updated this Template while you were editing")
                    render(view: "edit", model: [templateInstance: templateInstance])
                    return
                }
            }
            templateInstance.properties = params
            if (!templateInstance.hasErrors() && templateInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'template.label', default: 'Template'), templateInstance.id])}"
                redirect(action: "show", id: templateInstance.id)
            }
            else {
                render(view: "edit", model: [templateInstance: templateInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def templateInstance = Template.get(params.id)
        if (templateInstance) {
            try {
                templateInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'template.label', default: 'Template'), params.id])}"
            redirect(action: "list")
        }
    }

    def manageFields() {
        def templateInstance = Template.get(params.int("id"))
        if (templateInstance) {
            def fields = TemplateField.findAllByTemplate(templateInstance)?.sort { it.displayOrder }

            [templateInstance: templateInstance, fields: fields]
        }
    }

    def moveFieldUp() {
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

    def moveFieldDown() {
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

    def cleanUpOrdering() {
        def templateInstance = Template.get(params.int("id"))
        if (templateInstance) {
            def fields = TemplateField.findAllByTemplate(templateInstance)?.sort { it.displayOrder }
            int i = 1
            fields.each {
                it.displayOrder = i++
            }
        }

        redirect(action:'manageFields', id: templateInstance?.id)
    }

    def addField() {
        def templateInstance = Template.get(params.int("id"))
        def fieldType = params.fieldType

        if (templateInstance && fieldType) {

            def existing = TemplateField.findAllByTemplateAndFieldType(templateInstance, fieldType)
            if (existing) {
                flash.message = "Add field failed: Field type " + fieldType + " already exists in this template!"
            } else {
                def displayOrder = getLastDisplayOrder(templateInstance) + 1
                def field =new TemplateField(template: templateInstance, category: FieldCategory.none, fieldType: fieldType, displayOrder: displayOrder, defaultValue: '', type: FieldType.text)
                field.save(failOnError: true)
            }
        }

        redirect(action:'manageFields', id: templateInstance?.id)
    }

    private int getLastDisplayOrder(Template template) {
        def c = TemplateField.createCriteria()
        def max = c({
            eq('template', template)
            projections {
                max('displayOrder')
            }
        })[0]
        return max
    }
    
    def deleteField() {
        def templateInstance = Template.get(params.int("id"))
        def field = TemplateField.findByTemplateAndId(templateInstance, params.int("fieldId"))
        if (field && templateInstance) {
            field.delete()
        }
        redirect(action:'manageFields', id: templateInstance?.id)
    }

}
