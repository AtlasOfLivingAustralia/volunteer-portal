package au.org.ala.volunteer

class ProjectToolsController {

    def projectToolsService
    def projectService

    def matchRecordedByIdFromPicklist() {
        def project = Project.get(params.long('id'))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            def fieldsModified = projectToolsService.updateKeyFieldFromPicklistField(project, "recordedBy", "recordedByID")
            flash.message = "${fieldsModified} fields updated."
        }
        redirect(controller: 'task', action: 'projectAdmin', id: project?.id)
    }

    def reindexProjectTasks() {
        def project = Project.get(params.long('id'))
        if (!projectService.isAdminForProject(project)) {
            render(view: '/notPermitted')
            return
        }

        if (project) {
            def c = Task.createCriteria()
            def taskList = c.list {
                eq("project", project)
                projections {
                    property("id")
                }
            } as List<Long>
            taskList.each { long taskId ->
                DomainUpdateService.scheduleTaskIndex(taskId)
            }
            flash.message = "${taskList.size()} tasks scheduled for indexing."
        }

        redirect(controller: 'task', action: 'projectAdmin', id: project?.id)
    }
}
