package au.org.ala.volunteer

class InstitutionController {

    def projectService
    def institutionService
    def userService

    def index() {
        def institution = Institution.get(params.int("id"))
        if (!institution) {
            redirect(action:'list')
            return
        }

        params.max = params.mode == 'thumbs' ? 24 : 10
        params.sort = params.sort ?: 'completed'
        params.order = params.order ?: 'asc'

        def projects

        if (userService.isAdmin()) {
            projects = Project.findAllByInstitution(institution)
        } else {
            projects = Project.findAllByInstitutionAndInactiveNotEqual(institution, true)
        }

        def projectSummaries = projectService.makeSummaryListFromProjectList(projects, params)
        def transcriberCount = institutionService.getTranscriberCount(institution)
        def projectTypeCounts = institutionService.getProjectTypeCounts(institution)
        def taskCounts = institutionService.getTaskCounts(institution)

        [institutionInstance: institution, projects: projectSummaries.projectRenderList, projectInstanceTotal: projectSummaries.totalProjectCount, transcriberCount: transcriberCount, projectTypes: projectTypeCounts, taskCounts: taskCounts]
    }

    def list() {
        List<Institution> institutions

        if (params.q) {
            institutions = Institution.findAllByNameIlikeOrAcronymIlike("%" + params.q + "%", "%" + params.q + "%")
        } else {
            institutions = Institution.list(params)
        }

        def projectCounts = institutionService.getProjectCounts(institutions)

        def totalCount = Institution.count()
        [institutions: institutions, totalInstitutions: totalCount, projectCounts: projectCounts]
    }

}
