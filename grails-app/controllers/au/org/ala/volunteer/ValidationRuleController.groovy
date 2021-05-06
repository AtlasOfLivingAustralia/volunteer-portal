package au.org.ala.volunteer

class ValidationRuleController {

    def userService

    def index() {
        redirect(action: 'list')
    }

    def list() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def validationRules = ValidationRule.list(params)
        [validationRules: validationRules, totalCount: ValidationRule.count]
    }

    def delete() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def rule = ValidationRule.get(params.int("id"));
        if (rule) {
            rule.delete(flush: true)
            flash.message = "Rule '${rule.name}' deleted."
        } else {
            flash.message = "No rule with id ${params.id} exists."
        }
        redirect(action: "list")
    }

    def addRule() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def rule = new ValidationRule(name: "<New rule>")
        render(view: 'edit', model: [rule: rule])
    }

    def edit() {
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def rule = ValidationRule.get(params.int("id"))
        [rule: rule]
    }

    def update() {
        log.debug("This is the update action...")
        if (!userService.isAdmin()) {
            redirect(uri: "/")
            return
        }
        def rule = ValidationRule.get(params.int("id"))
        if (rule) {
            rule.properties = params
        } else {
            rule = new ValidationRule(params)
        }

        log.debug("rule: ${rule}")

        if (!rule.save(flush: true, failOnError: true)) {
            flash.message = rule.errors
            render(view: 'edit', model: [rule: rule])
            return
        }

        log.debug("rule: ${rule}")

        redirect(action: 'list')
    }

}
