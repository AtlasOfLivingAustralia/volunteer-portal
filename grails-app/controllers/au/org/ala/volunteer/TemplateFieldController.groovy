package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import org.springframework.dao.DataIntegrityViolationException

class TemplateFieldController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def userService

    @Transactional
    def save() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def templateField = new TemplateField(params)
        if (templateField.save(flush: true)) {
            flash.message = message(code: 'default.created.message',
                     args: [message(code: 'templateField.label', default: 'TemplateField'), templateField.id]) as String
            redirect(action: "show", id: templateField.id)
        }
        else {
            render(controller: 'template', view: "manageFields", id: templateField?.template?.id)
        }
    }

    def edit() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def templateField = TemplateField.get(params.long('id'))
        if (!templateField) {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'templateField.label', default: 'TemplateField'), params.id]) as String
            redirect(action: "list")
        } else {
            def validationRules = [""]
            def ruleList = ValidationRule.list(order:'name')*.name
            validationRules.addAll(ruleList)

            return [templateFieldInstance: templateField, validationRules: validationRules]
        }
    }

    @Transactional
    def update() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def templateField = TemplateField.get(params.long('id'))
        if (templateField) {
            if (params.version) {
                def version = params.version.toLong()
                if (templateField.version > version) {
                    templateField.errors.rejectValue("version", "default.optimistic.locking.failure",
                            [message(code: 'templateField.label', default: 'TemplateField')] as Object[],
                            "Another user has updated this TemplateField while you were editing")
                    render(view: "edit", model: [templateFieldInstance: templateField])
                    return
                }
            }
            // templateFieldInstance.properties = params
            bindData(templateField, params)
            if (!templateField.hasErrors() && templateField.save(flush: true)) {
                flash.message = message(code: 'default.updated.message',
                         args: [message(code: 'templateField.label', default: 'TemplateField'), templateField.id]) as String
                redirect(controller: 'template', action: "manageFields", id: templateField.template.id)
            } else {
                render(view: "edit", model: [templateFieldInstance: templateField])
            }
        } else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'templateField.label', default: 'TemplateField'), params.id]) as String
            redirect(controller: 'template', action: "list")
        }
    }

    def delete() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        def templateField = TemplateField.get(params.long('id'))
        if (templateField) {
            try {
                templateField.delete(flush: true)
                flash.message = message(code: 'default.deleted.message',
                         args: [message(code: 'templateField.label', default: 'TemplateField'), params.id]) as String
                redirect(controller: 'template', action: "manageFields", id: templateField.template.id)
            } catch (DataIntegrityViolationException e) {
                String message = message(code: 'default.not.deleted.message',
                          args: [message(code: 'templateField.label', default: 'TemplateField'), params.id])
                flash.message = message
                log.error(message, e)
                redirect(action: "show", id: params.id)
            }
        } else {
            flash.message = message(code: 'default.not.found.message',
                     args: [message(code: 'templateField.label', default: 'TemplateField'), params.id]) as String
            redirect(controller: 'template', action: "manageFields", id: templateField.template.id)
        }
    }
}
