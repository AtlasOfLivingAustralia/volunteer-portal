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

//        def projects
//
//        if (userService.isInstitutionAdmin(institution)) {
//            projects = Project.findAllByInstitution(institution)
//        } else {
//            projects = Project.findAllByInstitutionAndInactiveNotEqual(institution, true)
//        }

        def statusFilterMode = ProjectStatusFilterType.fromString(params.statusFilter)
        def activeFilterMode = ProjectActiveFilterType.fromString(params.activeFilter)

//        def filter = ProjectSummaryFilter.composeProjectFilter(statusFilterMode, activeFilterMode)

        def projectSummaries = projectService.makeSummaryListForInstitution(institution, params.tag, params.q, params.sort, params.int('offset', 0), params.int('max'), params.order, statusFilterMode, activeFilterMode)
        def transcriberCount = institutionService.getTranscriberCount(institution)

        def taskCounts = institutionService.getTaskCounts(institution)
        def completedProjects = institutionService.getProjectCompletedCount(institution)
        def underwayProjects = institutionService.getProjectUnderwayCount(institution)

        def newsItems = NewsItem.findAllByInstitution(institution, [sort:'created', order: 'desc'])
        def newsItem = newsItems?.size() > 0 ? newsItems.get(0) : null

        [
            institutionInstance: institution, projects: projectSummaries.projectRenderList, filteredProjectsCount: projectSummaries.matchingProjectCount,
            transcriberCount: transcriberCount, completedProjects: completedProjects, underwayProjects: underwayProjects, taskCounts: taskCounts,
            statusFilterMode: statusFilterMode, activeFilterMode: activeFilterMode, newsItem: newsItem, newsItems: newsItems
        ]
    }

    def list() {
        List<Institution> institutions
        def totalCount

        if (!params.sort) {
            params.sort = 'name'
        }
        if (!params.order) {
            params.order = 'asc'
        }

        if (!params.offset) {
            params.offset = 0
        }

        if (!params.max) {
            params.max = 10
        }

        if (params.q) {
            def query = "%${params.q}%"
            institutions = Institution.findAllByNameIlikeOrAcronymIlike(query, query, params)
            totalCount = Institution.countByNameIlikeOrAcronymIlike(query, query)
        } else {
            institutions = Institution.list(params)
            totalCount = Institution.count()
        }

        def projectCounts = institutionService.getProjectCounts(institutions)
        def projectVolunteers = institutionService.getTranscriberCounts(institutions)
        def taskCounts = institutionService.countTasksForInstitutions(institutions)

        [   institutions: institutions,
            totalInstitutions: totalCount,
            projectCounts: projectCounts,
            projectVolunteers: projectVolunteers,
            taskCounts: taskCounts
        ]
    }

}
