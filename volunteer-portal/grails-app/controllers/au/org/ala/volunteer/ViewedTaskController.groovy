package au.org.ala.volunteer

class ViewedTaskController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [viewedTaskInstanceList: ViewedTask.list(params), viewedTaskInstanceTotal: ViewedTask.count()]
    }

    def create = {
        def viewedTaskInstance = new ViewedTask()
        viewedTaskInstance.properties = params
        return [viewedTaskInstance: viewedTaskInstance]
    }

    def save = {
        def viewedTaskInstance = new ViewedTask(params)
        if (viewedTaskInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'viewedTask.label', default: 'ViewedTask'), viewedTaskInstance.id])}"
            redirect(action: "show", id: viewedTaskInstance.id)
        }
        else {
            render(view: "create", model: [viewedTaskInstance: viewedTaskInstance])
        }
    }

    def show = {
        def viewedTaskInstance = ViewedTask.get(params.id)
        if (!viewedTaskInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'viewedTask.label', default: 'ViewedTask'), params.id])}"
            redirect(action: "list")
        }
        else {
            [viewedTaskInstance: viewedTaskInstance]
        }
    }

    def edit = {
        def viewedTaskInstance = ViewedTask.get(params.id)
        if (!viewedTaskInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'viewedTask.label', default: 'ViewedTask'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [viewedTaskInstance: viewedTaskInstance]
        }
    }

    def update = {
        def viewedTaskInstance = ViewedTask.get(params.id)
        if (viewedTaskInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (viewedTaskInstance.version > version) {
                    
                    viewedTaskInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'viewedTask.label', default: 'ViewedTask')] as Object[], "Another user has updated this ViewedTask while you were editing")
                    render(view: "edit", model: [viewedTaskInstance: viewedTaskInstance])
                    return
                }
            }
            viewedTaskInstance.properties = params
            if (!viewedTaskInstance.hasErrors() && viewedTaskInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'viewedTask.label', default: 'ViewedTask'), viewedTaskInstance.id])}"
                redirect(action: "show", id: viewedTaskInstance.id)
            }
            else {
                render(view: "edit", model: [viewedTaskInstance: viewedTaskInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'viewedTask.label', default: 'ViewedTask'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def viewedTaskInstance = ViewedTask.get(params.id)
        if (viewedTaskInstance) {
            try {
                viewedTaskInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'viewedTask.label', default: 'ViewedTask'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'viewedTask.label', default: 'ViewedTask'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'viewedTask.label', default: 'ViewedTask'), params.id])}"
            redirect(action: "list")
        }
    }
}
