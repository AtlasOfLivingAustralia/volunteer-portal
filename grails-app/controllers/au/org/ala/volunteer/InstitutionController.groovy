package au.org.ala.volunteer

class InstitutionController {

    def projectService

    def index() {
        def institution = Institution.get(params.int("id"))
        if (!institution) {
            redirect(action:'list')
            return
        }

        def projects = projectService.makeSummaryListFromProjectList(Project.findAllByInstitution(institution), params)

        [institutionInstance: institution, projects: projects.projectRenderList, projectInstanceTotal: projects.totalProjectCount]
    }

    def list() {

        def institutions = []

        if (params.q) {
            institutions = Institution.findByNameIlikeOrAcronymIlike("%" + params.q + "%", "%" + params.q + "%")
        } else {
            institutions = Institution.list(params)
        }
        def totalCount = Institution.count()
        [institutions: institutions, totalInstitutions: totalCount]
    }
}
