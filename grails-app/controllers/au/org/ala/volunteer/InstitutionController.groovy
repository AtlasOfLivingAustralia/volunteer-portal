package au.org.ala.volunteer

class InstitutionController {

    def projectService
    def institutionService

    def index() {
        def institution = Institution.get(params.int("id"))
        if (!institution) {
            redirect(action:'list')
            return
        }

        params.sort = params.sort ?: 'completed'
        params.order = params.order ?: 'asc'

        def projects = projectService.makeSummaryListFromProjectList(Project.findAllByInstitution(institution), params)

        [institutionInstance: institution, projects: projects.projectRenderList, projectInstanceTotal: projects.totalProjectCount]
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
