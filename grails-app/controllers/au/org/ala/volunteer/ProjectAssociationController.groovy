package au.org.ala.volunteer

class ProjectAssociationController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index() {
        redirect(action: "list", params: params)
    }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [projectAssociationInstanceList: ProjectAssociation.list(params), projectAssociationInstanceTotal: ProjectAssociation.count()]
    }

    def create() {
        def projectAssociationInstance = new ProjectAssociation()
        projectAssociationInstance.properties = params
        return [projectAssociationInstance: projectAssociationInstance]
    }

    def save() {
        def projectAssociationInstance = new ProjectAssociation(params)
        if (projectAssociationInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'projectAssociation.label', default: 'ProjectAssociation'), projectAssociationInstance.id])}"
            redirect(action: "show", id: projectAssociationInstance.id)
        }
        else {
            render(view: "create", model: [projectAssociationInstance: projectAssociationInstance])
        }
    }

    def show() {
        def projectAssociationInstance = ProjectAssociation.get(params.id)
        if (!projectAssociationInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'projectAssociation.label', default: 'ProjectAssociation'), params.id])}"
            redirect(action: "list")
        }
        else {
            [projectAssociationInstance: projectAssociationInstance]
        }
    }

    def edit() {
        def projectAssociationInstance = ProjectAssociation.get(params.id)
        if (!projectAssociationInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'projectAssociation.label', default: 'ProjectAssociation'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [projectAssociationInstance: projectAssociationInstance]
        }
    }

    def update() {
        def projectAssociationInstance = ProjectAssociation.get(params.id)
        if (projectAssociationInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (projectAssociationInstance.version > version) {

                    projectAssociationInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'projectAssociation.label', default: 'ProjectAssociation')] as Object[], "Another user has updated this ProjectAssociation while you were editing")
                    render(view: "edit", model: [projectAssociationInstance: projectAssociationInstance])
                    return
                }
            }
            projectAssociationInstance.properties = params
            if (!projectAssociationInstance.hasErrors() && projectAssociationInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'projectAssociation.label', default: 'ProjectAssociation'), projectAssociationInstance.id])}"
                redirect(action: "show", id: projectAssociationInstance.id)
            }
            else {
                render(view: "edit", model: [projectAssociationInstance: projectAssociationInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'projectAssociation.label', default: 'ProjectAssociation'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete() {
        def projectAssociationInstance = ProjectAssociation.get(params.id)
        if (projectAssociationInstance) {
            try {
                projectAssociationInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'projectAssociation.label', default: 'ProjectAssociation'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'projectAssociation.label', default: 'ProjectAssociation'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'projectAssociation.label', default: 'ProjectAssociation'), params.id])}"
            redirect(action: "list")
        }
    }
}
