package au.org.ala.volunteer

import org.springframework.dao.DataIntegrityViolationException

class TemplateFieldController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def userService

    def save() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateFieldInstance = new TemplateField(params)
        if (templateFieldInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'templateField.label', default: 'TemplateField'), templateFieldInstance.id])}"
            redirect(action: "show", id: templateFieldInstance.id)
        }
        else {
            render(controller: 'template', view: "manageFields", id: templateFieldInstance?.template?.id)
        }
    }

    def edit() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateFieldInstance = TemplateField.get(params.id)
        if (!templateFieldInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'templateField.label', default: 'TemplateField'), params.id])}"
            redirect(action: "list")
        }
        else {
            def validationRules = [""]
            validationRules.addAll(ValidationRule.list(order:'name')*.name)

            return [templateFieldInstance: templateFieldInstance, validationRules: validationRules]
        }
    }

    def update() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateFieldInstance = TemplateField.get(params.id)
        if (templateFieldInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (templateFieldInstance.version > version) {
                    templateFieldInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'templateField.label', default: 'TemplateField')] as Object[], "Another user has updated this TemplateField while you were editing")
                    render(view: "edit", model: [templateFieldInstance: templateFieldInstance])
                    return
                }
            }
            templateFieldInstance.properties = params
            if (!templateFieldInstance.hasErrors() && templateFieldInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'templateField.label', default: 'TemplateField'), templateFieldInstance.id])}"
                redirect(controller: 'template', action: "manageFields", id: templateFieldInstance.template.id)
            }
            else {
                render(view: "edit", model: [templateFieldInstance: templateFieldInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'templateField.label', default: 'TemplateField'), params.id])}"
            redirect(controller: 'template', action: "list")
        }
    }

    def delete() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def templateFieldInstance = TemplateField.get(params.id)
        if (templateFieldInstance) {
            try {
                templateFieldInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'templateField.label', default: 'TemplateField'), params.id])}"
                redirect(controller: 'template', action: "manageFields", id: templateFieldInstance.template.id)
            }
            catch (DataIntegrityViolationException e) {
                String message = "${message(code: 'default.not.deleted.message', args: [message(code: 'templateField.label', default: 'TemplateField'), params.id])}"
                flash.message = message
                log.error(message, e)
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'templateField.label', default: 'TemplateField'), params.id])}"
            redirect(controller: 'template', action: "manageFields", id: templateFieldInstance.template.id)
        }
    }
}
