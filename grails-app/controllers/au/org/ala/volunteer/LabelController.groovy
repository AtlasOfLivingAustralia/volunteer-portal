package au.org.ala.volunteer

import grails.converters.JSON
import grails.gorm.transactions.Transactional

import static org.springframework.http.HttpStatus.*
import static javax.servlet.http.HttpServletResponse.SC_FORBIDDEN
import static javax.servlet.http.HttpServletResponse.SC_NOT_FOUND

class LabelController {

//    static allowedMethods = [saveNewLabel: "POST", updateCategory: "POST", saveCategory: "POST", createCategory: "POST",
//                             saveLabel: "POST", deleteCategory: "POST"]

    def userService
    def labelAdminService

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

    def editCategory() {
        if (userService.isAdmin()) {
            def categoryId = params.long('id')
            def category = LabelCategory.get(categoryId)
            if (!category) {
                log.info("No category found,  redirecting back to index.")
                flash.message = message(code: 'default.not.found.message',
                        args: [message(code: 'default.label.category.label', default: 'Category'), params.long('id')]) as String
                redirect(action: "index")
            } else {
                log.info("Edit category: ${category.name}")
                final def loadedDefaultLabels = grailsApplication.config.getProperty("bvp.labels.ensureDefault", Boolean, false)
                render(view: 'editCategory', model: [labelCategory: category, categoryList: LabelCategory.list(), loadedDefaultLabels: loadedDefaultLabels])
            }
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def updateCategory() {
        if (userService.isAdmin()) {
            def categoryId = params.long('categoryId')
            def category = LabelCategory.get(categoryId)
            if (!category) {
                flash.message = message(code: 'default.not.found.message',
                        args: [message(code: 'default.label.category.label', default: 'Category'), params.long('id')]) as String
                redirect(action: "index")
            } else {
                if (!category.isDefault) {
                    def name = params.get('name')?.toString()
                    if (!name) {
                        flash.message = message(code: 'default.not.updated.message',
                                args: [message(code: 'default.label.category.label', default: 'Category'), category.name]) as String
                        redirect(action: "index")
                        return
                    }
                    category.name = name
                }

                category.labelColour = params.get('labelColour')
                category.updatedDate = new Date()
                category.save(flush: true, failOnError: true)

                flash.message = message(code: 'default.updated.message',
                        args: [message(code: 'default.label.category.label', default: 'Category'), category.name]) as String
                redirect(view: 'index')
            }
        } else {
            render(view: '/notPermitted')
        }
    }

    def createCategory() {
        if (userService.isAdmin()) {
            render(view: 'createCategory')
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def saveCategory() {
        if (userService.isAdmin()) {
            LabelCategory newCategory = new LabelCategory()
            def categoryName = params.get("name") as String
            if (!categoryName) {
                newCategory.errors.rejectValue("name", "label.category.name.notnull",
                        "A category name must be provided.")
            }
            newCategory.name = categoryName
            newCategory.isDefault = false
            newCategory.updatedDate = new Date()
            newCategory.createdBy = userService.currentUser.id

            def catCheck = LabelCategory.findByName(categoryName)
            if (catCheck) {
                // Name already exists, cannot create it.
                newCategory.errors.rejectValue("name", "label.name.unique",
                        "Category name must be unique.")
            }

            if (newCategory.errors.hasErrors()) {
                log.info("LabelCategory Errors: ${newCategory.errors}")
                render(view: 'createCategory', model: [labelCategory: newCategory])
                return
            } else {
                newCategory.save(flush: true, failOnError: true)
                flash.message = message(code: 'default.created.message',
                        args: [message(code: 'default.label.category.label', default: 'Category'), newCategory.name]) as String
                redirect(view: 'index')
            }
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def saveNewLabel() {
        log.info("Saving new label")
        if (userService.isAdmin()) {
            LabelCategory labelCategory = LabelCategory.get(params.long('categoryId'))
            if (!labelCategory) {
                flash.message = message(code: 'default.not.found.message',
                        args: [message(code: 'default.label.category.label', default: 'Category'), params.long('categoryId')]) as String
                render(view: 'index')
                return
            }

            String value = params.get('value') as String
            if (!value) {
                flash.message = message(code: 'label.name.notnull') as String
                redirect(view: 'editCategory', params: [id: labelCategory.id])
                return
            }

            Label label = new Label()
            label.category = labelCategory
            label.value = value
            label.isDefault = false
            label.updatedDate = new Date()
            label.createdBy = userService.currentUser.id
            label.save(flush: true, failOnError: true)

            flash.message = message(code: 'default.created.message',
                    args: [message(code: 'default.label.label', default: 'Tag'), label.value]) as String
            redirect(action: 'editCategory', params: [id: labelCategory.id])
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def saveLabel() {
        log.info("Saving label")
        if (userService.isAdmin()) {
            log.info("id: ${params.long('id')}, value: ${params.get('labelName')}")
            def label = Label.get(params.long('id'))
            log.info("Label: ${label}")
            if (label == null) {
                notFound()
                return
            }

            label.value = params.get('labelName')
            label.updatedDate = new Date()
            label.save(flush: true, failOnError: true)
            log.info("label saved: ${label}")
            render([message: "Successfully updated label '${label.value}'"] as JSON)
        } else {
            response.status = SC_FORBIDDEN
            render([message: "Access forbidden."] as JSON)
        }
    }

    @Transactional
    def deleteLabel() {
        log.debug("Deleting label id: ${params.id}")
        if (userService.isAdmin()) {
            Label labelInstance = Label.get(params.long('id'))
            if (!labelInstance) {
                notFound()
                return
            }

            if (labelAdminService.isLabelInUse(labelInstance)) {
                flash.message = message(code: 'label.delete.notallowed', args: [labelInstance.value]) as String
                redirect(action: 'editCategory', params: [id: labelInstance.category.id])
                return
            }

            labelInstance.delete(flush: true, failOnError: true)

            flash.message = message(code: 'default.deleted.message',
                    args: [message(code: 'default.label.label', default: 'Tag'), labelInstance.value]) as String
            redirect(action: 'editCategory', params: [id: labelInstance.category.id])

        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def deleteCategory() {
        log.info("Deleting category.")
        if (userService.isAdmin()) {
            LabelCategory labelCategory = LabelCategory.get(params.long('id'))
            if (!labelCategory) {
                flash.message = message(code: 'default.not.found.message',
                        args: [message(code: 'default.label.category.label', default: 'Category'), params.long('id')]) as String
                redirect(action: "index")
                return
            }
            def name = labelCategory.name
            // Delete category
            if (labelCategory.isDefault) {
                // Shouldn't allow deletion due to system default category
                flash.message = message(code: 'label.category.delete.notallowed', args: [labelCategory.name]) as String
                redirect(action: "index")
                return
            }

            try {
                labelCategory.delete(flush: true, failOnError: true)
            } catch (Exception ex) {
                flash.message = message(code: 'label.category.delete.notallowed', args: [labelCategory.name]) as String
                redirect(action: "index")
                return
            }

            flash.message = message(code: 'default.deleted.message',
                    args: [message(code: 'default.label.category.label', default: 'Category'), name]) as String
            redirect(action: 'index')
        } else {
            render(view: '/notPermitted')
        }
    }

    @Transactional
    def changeCategory() {
        log.debug("Changing label category.")
        if (userService.isAdmin()) {
            Label label = Label.get(params.long('labelId'))
            LabelCategory labelCategory = LabelCategory.get(params.long('newCategory'))
            if (!label || !labelCategory) {
                flash.message = "Unable to modify ${message(code: 'default.label.label', default: 'Tag')}, missing parameters: label or category."
                redirect(action: "index")
                return
            }

            // Check if new category already has tag of this value
            def labelCheck = labelCategory.labels.find {
                it.value == label.value
            }

            if (labelCheck) {
                // One already exists. Return an error.
                flash.message = "Unable to modify ${message(code: 'default.label.label', default: 'Tag')}, new category already has a label with the same name."
                redirect(action: "editCategory", params: [id: label.category.id])
                return
            }

            label.category = labelCategory
            label.updatedDate = new Date()
            label.save(flush: true, failOnError: true)

            flash.message = message(code: 'default.updated.message',
                    args: [message(code: 'default.label.label', default: 'Tag'), label.value]) as String
            redirect(action: 'editCategory', params: [id: labelCategory.id])
        } else {
            render(view: '/notPermitted')
        }
    }

    def labelUsage() {
        if (userService.isAdmin()) {
            def labelId = params.long('id')

            def label = Label.get(labelId)
            if (!label) {
                // return emtpy map
                response.status = SC_NOT_FOUND
                render([:] as JSON)
                return
            }

            def result = labelAdminService.getLabelUsage(label)
            if (result.size() > 0) {
                render(result as JSON)
            } else {
                response.status = SC_NOT_FOUND
                render([:] as JSON)
            }
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
