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
}
