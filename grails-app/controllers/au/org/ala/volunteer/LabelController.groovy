package au.org.ala.volunteer

import static org.springframework.http.HttpStatus.*

class LabelController {

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE"]

    def userService

    private boolean checkAdmin() {
        if (userService.isAdmin()) {
            return true;
        }

        flash.message = "You do not have permission to view this page"
        redirect(uri:"/")
    }

    def index(Integer max) {
        if (!checkAdmin()) {
            render status: FORBIDDEN
            return
        }
        params.max = Math.min(max ?: 25, 100)
        respond Label.list(params), model: [labelInstanceCount: Label.count()]
    }

    def save(Label labelInstance) {
        if (!checkAdmin()) {
            redirect(controller: 'frontPage')
            return
        }

        if (labelInstance == null) {
            notFound()
            return
        }

        if (labelInstance.hasErrors()) {
            respond labelInstance.errors, view: 'index'
            return
        }

        labelInstance.save flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'label.label', default: 'Label'), labelInstance.value])
                redirect action: 'index'
            }
            '*' { respond labelInstance, [status: CREATED] }
        }
    }

    def update(Label labelInstance) {
        if (!checkAdmin()) {
            redirect(controller: 'frontPage')
            return
        }

        if (labelInstance == null) {
            notFound()
            return
        }

        if (labelInstance.hasErrors()) {
            respond labelInstance.errors, view: 'index'
            return
        }

        labelInstance.save flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'Label.label', default: 'Label'), labelInstance.value])
                redirect action: 'index'
            }
            '*' { respond labelInstance, [status: OK] }
        }
    }

    def delete(Label labelInstance) {

        if (labelInstance == null) {
            notFound()
            return
        }

        labelInstance.delete flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'Label.label', default: 'Label'), labelInstance.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NO_CONTENT }
        }
    }

    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'label.label', default: 'Label'), params.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NOT_FOUND }
        }
    }

}
