package au.org.ala.volunteer

import static org.springframework.http.HttpStatus.*

class LabelController {

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE"]

    def userService

    def index(Integer max) {
        if (userService.isAdmin()) {
            params.max = Math.min(max ?: 25, 100)
            respond Label.list(params), model: [labelInstanceCount: Label.count()]
        } else {
            render(view: '/notPermitted')
        }
    }

    def save(Label labelInstance) {
        if (userService.isAdmin()) {

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
        } else {
            render status: 403
        }
    }

    def update(Label labelInstance) {
        if (userService.isAdmin()) {

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
        } else {
            render status: 403
        }
    }

    def delete(Label labelInstance) {
        if (userService.isAdmin()) {
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
        } else {
            render status: 403
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
