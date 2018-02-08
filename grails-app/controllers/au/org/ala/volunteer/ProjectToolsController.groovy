package au.org.ala.volunteer

class ProjectToolsController {

    def projectToolsService

    def matchRecordedByIdFromPicklist() {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            def fieldsModified = projectToolsService.updateKeyFieldFromPicklistField(projectInstance, "recordedBy", "recordedByID")
            flash.message = "${fieldsModified} fields updated."
        }
        redirect(controller: 'task', action: 'projectAdmin', id: projectInstance?.id)
    }

    def reindexProjectTasks() {
        def projectInstance = Project.get(params.id)
        if (projectInstance) {
            def c = Task.createCriteria()
            def taskList = c.list {
                eq("project", projectInstance)
                projections {
                    property("id")
                }
            }
            taskList.each { long taskId ->
                DomainUpdateService.scheduleTaskIndex(taskId)
            }
            flash.message = message(code: 'projectTools.task_schedules_for_indexing', args: [taskList.size()])
        }

        redirect(controller: 'task', action: 'projectAdmin', id: projectInstance?.id)
    }
}
