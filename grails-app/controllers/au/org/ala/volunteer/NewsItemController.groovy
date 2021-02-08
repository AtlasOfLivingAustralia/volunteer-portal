package au.org.ala.volunteer

class NewsItemController {

    static allowedMethods = [save: "POST", update: "POST"]

    def userService

    def index() {
        redirect(action: "list", params: params)
    }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        params.sort = params.sort ?: 'created'
        params.order = params.order ?: 'desc'
        def newsItems = null
        Project project = null
        Institution institution = null
        if (params.id) {
            // id could actually mean either a project or an institution - look for a project first
            project = Project.get(params.int('id'))
            if (project) {
                // find by project
                newsItems = NewsItem.findAllByProject(project, params)
            } else {
                institution = Institution.get(params.int("id"))
                if (institution) {
                    // find by institution
                    newsItems = NewsItem.findAllByInstitution(institution, params)
                }
            }
        }

        if (!newsItems) {
            newsItems = NewsItem.list(params).asList()
        }

        [newsItemInstanceList: newsItems, newsItemInstanceTotal: newsItems?.size(), projectInstance: project, institutionInstance: institution]
    }

    def create() {
        def currentUserId = userService.currentUserId
        Project p = Project.get(params.long('project.id'))
        def isAdmin = (userService.isAdmin() || userService.isInstitutionAdmin(p?.institution))
        if (currentUserId != null && isAdmin) {
            def newsItemInstance = new NewsItem()
            newsItemInstance.properties = params
            return [newsItemInstance: newsItemInstance, currentUser: currentUserId]
        } else {
            flash.message = "You do not have permission to view this page"
            redirect(controller: "project", action: "editNewsItemsSettings", id: params.id)
        }
    }

    def save() {
        def projectId = params.int("project")
        def institutionId = params.int("institution")
        params.project = null
        params.institution = null
        def newsItemInstance = new NewsItem(params)
        newsItemInstance.created = new Date()
        if (projectId) {
            def project = Project.get(projectId)
            newsItemInstance.project = project
        } else if (institutionId) {
            def institution = Institution.get(institutionId)
            newsItemInstance.institution = institution
        }

        if (newsItemInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), newsItemInstance.id])}"
            if (newsItemInstance.project) {
                redirect(controller: 'project', action: "editNewsItemsSettings", id: newsItemInstance.project.id)
            } else if (newsItemInstance.institution) {
                redirect(controller: 'institutionAdmin', action: 'editNewsItems', id: newsItemInstance.institution.id)
            } else {
                redirect(action: "show", id: newsItemInstance.id)
            }
        } else {
            render(view: "create", model: [newsItemInstance: newsItemInstance])
        }
    }

    def show() {
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
        def currentUserId = userService.currentUserId
        def newsItemInstance = NewsItem.get(params.id)
        def isAdmin = (userService.isAdmin() || userService.isInstitutionAdmin(newsItemInstance?.project?.institution))
        if (currentUserId != null && isAdmin) {
            //def newsItemInstance = NewsItem.get(params.id)
            if (!newsItemInstance) {
                flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), params.id])}"
                redirect(action: "list")
            } else {
                return [newsItemInstance: newsItemInstance, currentUser: currentUserId]
            }
        } else {
            flash.message = "You do not have permission to view this page"
            redirect(controller: "project", action: "index", id: params.id)
        }
    }

    def update() {
        def currentUserId = userService.currentUserId
        def newsItemInstance = NewsItem.get(params.id)
        def isAdmin = (userService.isAdmin() || userService.isInstitutionAdmin(newsItemInstance?.project?.institution))
        if (currentUserId != null && isAdmin) {
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
                    if (newsItemInstance.project) {
                        redirect(controller:'project', action:'editNewsItemsSettings', id: newsItemInstance.project.id)
                    } else if (newsItemInstance.institution) {
                        redirect(controller:'institutionAdmin', action:'editNewsItems', id: newsItemInstance.institution.id)
                    } else {
                        redirect(action: "show", id: newsItemInstance.id)
                    }
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
            flash.message = "You do not have permission to view this page"
            redirect(controller: "project", action: "index", id: params.id)
        }
    }

    def delete() {
        def newsItemInstance = NewsItem.get(params.id)
        if (newsItemInstance) {
            def fromProjectId = newsItemInstance.project?.id
            def fromInstitutionId = newsItemInstance.institution?.id
            try {
                newsItemInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), params.id])}"
                if (fromProjectId) {
                    redirect(controller:'project', action:'editNewsItemsSettings', id: fromProjectId)
                } else if (fromInstitutionId) {
                    redirect(controller:'institutionAdmin', action:'editNewsItems', id: fromInstitutionId)
                } else {
                    redirect(action: "list")
                }
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                String message = "${message(code: 'default.not.deleted.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), params.id])}"
                flash.message = message
                log.error(message, e)
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'newsItem.label', default: 'NewsItem'), params.id])}"
            redirect(action: "list")
        }
    }
}
