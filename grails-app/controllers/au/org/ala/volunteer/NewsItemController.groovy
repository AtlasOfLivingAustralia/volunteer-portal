package au.org.ala.volunteer

class NewsItemController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def authService
    def ROLE_ADMIN = grailsApplication.config.auth.admin_role

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        def newsItems = null
        def project = null
        if (params.id) {
            project = Project.get(params.id)
            if (project) {
                // find by project

                newsItems = NewsItem.findAllByProject(project, [:], params)
            }
        }

        if (!newsItems) {
            newsItems = NewsItem.list(params).asList()
        }

        [newsItemInstanceList: newsItems, newsItemInstanceTotal: newsItems?.size(), projectInstance: project]
    }

    def create = {
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(ROLE_ADMIN)) {
            def newsItemInstance = new NewsItem()
            //def currentUser = authService.username()
            newsItemInstance.properties = params
            return [newsItemInstance: newsItemInstance, currentUser: currentUser]
        } else {
            flash.message = "You do not have permission to view this page (${ROLE_ADMIN} required)"
            redirect(controller: "project", action: "index", id: params.id)
        }
    }

    def save = {
        def projectId = params.int("project")
        params.project = null
        def newsItemInstance = new NewsItem(params)
        if (projectId) {
            def project = Project.get(projectId)
            newsItemInstance.project = project
        }

        if (newsItemInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), newsItemInstance.id])}"
            redirect(action: "show", id: newsItemInstance.id)
        }
        else {
            render(view: "create", model: [newsItemInstance: newsItemInstance])
        }
    }

    def show = {
        def newsItemInstance = NewsItem.get(params.id)
        if (!newsItemInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), params.id])}"
            redirect(action: "list")
        }
        else {
            [newsItemInstance: newsItemInstance]
        }
    }

    def edit = {
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(ROLE_ADMIN)) {
            def newsItemInstance = NewsItem.get(params.id)
            //def currentUser = authService.username()
            if (!newsItemInstance) {
                flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), params.id])}"
                redirect(action: "list")
            }
            else {
                return [newsItemInstance: newsItemInstance, currentUser: currentUser]
            }
        } else {
            flash.message = "You do not have permission to view this page (${ROLE_ADMIN} required)"
            redirect(controller: "project", action: "index", id: params.id)
        }
    }

    def update = {
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(ROLE_ADMIN)) {
            def newsItemInstance = NewsItem.get(params.id)
            if (newsItemInstance) {
                if (params.version) {
                    def version = params.version.toLong()
                    if (newsItemInstance.version > version) {

                        newsItemInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'newsItem.label', default: 'NewsItem')] as Object[], "Another user has updated this NewsItem while you were editing")
                        render(view: "edit", model: [newsItemInstance: newsItemInstance])
                        return
                    }
                }
                newsItemInstance.properties = params
                if (!newsItemInstance.hasErrors() && newsItemInstance.save(flush: true)) {
                    flash.message = "${message(code: 'default.updated.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), newsItemInstance.id])}"
                    redirect(action: "show", id: newsItemInstance.id)
                }
                else {
                    render(view: "edit", model: [newsItemInstance: newsItemInstance])
                }
            }
            else {
                flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), params.id])}"
                redirect(action: "list")
            }
        } else {
            flash.message = "You do not have permission to view this page (${ROLE_ADMIN} required)"
            redirect(controller: "project", action: "index", id: params.id)
        }
    }

    def delete = {
        def newsItemInstance = NewsItem.get(params.id)
        if (newsItemInstance) {
            try {
                newsItemInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), params.id])}"
            redirect(action: "list")
        }
    }
}
