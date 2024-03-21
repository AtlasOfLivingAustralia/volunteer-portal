package au.org.ala.volunteer

import grails.gorm.transactions.Transactional

import static org.springframework.http.HttpStatus.*

class LabelController {

    static allowedMethods = [save: "POST", update: "PUT", delete: "POST"]

    def userService

    /**
     * Index page for Label/Tag admin
     */
    def index() {
        if (userService.isAdmin()) {
            def labelCategories = LabelCategory.list(sort: 'name', order: 'asc')
            render(view: 'index', model: [labelCategories: labelCategories, labelInstanceCount: Label.count()])
        } else {
            render(view: '/notPermitted')
        }
    }

//    def index(Integer max) {
//        if (userService.isAdmin()) {
//            params.max = Math.min(max ?: 25, 100)
//            respond Label.list(params), model: [labelInstanceCount: Label.count()]
//        } else {
//            render(view: '/notPermitted')
//        }
//    }

    def editCategory() {
        if (userService.isAdmin()) {
            def categoryId = params.long('id')
            def category = LabelCategory.get(categoryId)
            if (!category) {
                flash.message = message(code: 'default.not.found.message',
                        args: [message(code: 'default.label.category.label', default: 'Category'), params.long('id')]) as String
                redirect(action: "index")
            } else {
                render(view: 'editCategory', model: [labelCategory: category])
            }
        } else {
            render(view: '/notPermitted')
        }
    }

    def saveCategory() {
        if (userService.isAdmin()) {
            def categoryId = params.long('categoryId')
            def category = LabelCategory.get(categoryId)
            if (!category) {
                flash.message = message(code: 'default.not.found.message',
                        args: [message(code: 'default.label.category.label', default: 'Category'), params.long('id')]) as String
                redirect(action: "index")
            } else {
                def name = params.get('name')?.toString()
                if (!name) {
                    flash.message = message(code: 'default.not.updated.message',
                            args: [message(code: 'default.label.category.label', default: 'Category'), category.name]) as String
                    redirect(action: "index")
                    return
                }
                category.name = name
                category.save(flush: true, failOnError: true)
                flash.message = message(code: 'default.updated.message',
                        args: [message(code: 'default.label.category.label', default: 'Category'), category.name]) as String
                redirect(view: 'index')
            }
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def save(Label labelInstance) {
        if (userService.isAdmin()) {

            if (labelInstance == null) {
                notFound()
                return
            }

            if (labelInstance.hasErrors()) {
                respond labelInstance.errors, view: 'index-old'
                return
            }

            labelInstance.save(flush: true, failOnError: true)

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

    @Transactional
    def update(Label labelInstance) {
        if (userService.isAdmin()) {

            if (labelInstance == null) {
                notFound()
                return
            }

            if (labelInstance.hasErrors()) {
                respond labelInstance.errors, view: 'index-old'
                return
            }

            labelInstance.save(flush: true, failOnError: true)

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

    @Transactional
    def delete(Label labelInstance) {
        log.debug("Deleting label id: ${params.id}")
        if (userService.isAdmin()) {
            if (labelInstance == null) {
                notFound()
                return
            }

            labelInstance.delete(flush: true, failOnError: true)

            request.withFormat {
                form multipartForm {
                    flash.message = message(code: 'default.deleted.message', args: [message(code: 'Label.label', default: 'Label'), labelInstance.value])
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
