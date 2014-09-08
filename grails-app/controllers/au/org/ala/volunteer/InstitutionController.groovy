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

        if (userService.isInstitutionAdmin(institution)) {
            projects = Project.findAllByInstitution(institution)
        } else {
            projects = Project.findAllByInstitutionAndInactiveNotEqual(institution, true)
        }

        def statusFilterMode = ProjectStatusFilterType.fromString(params.statusFilter)
        def activeFilterMode = ProjectActiveFilterType.fromString(params.activeFilter)

        def filter = ProjectSummaryFilter.composeProjectFilter(statusFilterMode, activeFilterMode)

        def projectSummaries = projectService.makeSummaryListFromProjectList(projects, params, filter)
        def transcriberCount = institutionService.getTranscriberCount(institution)
        def projectTypeCounts = institutionService.getProjectTypeCounts(institution, userService.isInstitutionAdmin(institution))
        def taskCounts = institutionService.getTaskCounts(institution)

        def newsItem = NewsItem.findByInstitution(institution)

        [
            institutionInstance: institution, projects: projectSummaries.projectRenderList, filteredProjectsCount: projectSummaries.matchingProjectCount, totalProjectCount: projectSummaries.totalProjectCount,
            transcriberCount: transcriberCount, projectTypes: projectTypeCounts, taskCounts: taskCounts,
            statusFilterMode: statusFilterMode, activeFilterMode: activeFilterMode, newsItem: newsItem
        ]
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
