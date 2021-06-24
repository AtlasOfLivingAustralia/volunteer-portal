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

        params.max = params.mode == 'thumbs' ? 24 : 10
        params.sort = params.sort ?: 'completed'
        params.order = params.order ?: 'asc'

        def statusFilterMode = ProjectStatusFilterType.fromString(params.statusFilter as String)
        def activeFilterMode = ProjectActiveFilterType.fromString(params.activeFilter as String)

//        def filter = ProjectSummaryFilter.composeProjectFilter(statusFilterMode, activeFilterMode)

        def projectSummaries = projectService.makeSummaryListForInstitution(institution, params.tag as String,
                params.q as String, params.sort as String, params.int('offset', 0), params.int('max'),
                params.order as String, statusFilterMode, activeFilterMode)
        def transcriberCount = institutionService.getTranscriberCount(institution)

        def taskCounts = institutionService.getTaskCounts(institution)
        def completedProjects = institutionService.getProjectCompletedCount(institution)
        def underwayProjects = institutionService.getProjectUnderwayCount(institution)

        [
                institutionInstance  : institution,
                projects             : projectSummaries.projectRenderList,
                filteredProjectsCount: projectSummaries.matchingProjectCount,
                transcriberCount     : transcriberCount,
                completedProjects    : completedProjects,
                underwayProjects     : underwayProjects,
                taskCounts           : taskCounts,
                statusFilterMode     : statusFilterMode,
                activeFilterMode     : activeFilterMode
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

            def closure = {
                and {
                    eq('isInactive', false)
                    eq('isApproved', true)
                    or {
                        ilike('name', query)
                        ilike('acronym', query)
                    }
                }
            }

            institutions = Institution.createCriteria().list(params) {
                closure.delegate = delegate
                closure()
            } as List

            totalCount = Institution.createCriteria().get {
                closure.delegate = delegate
                closure()
                projections {
                    count('id')
                }
            }

        } else {
            institutions = Institution.findAllByIsInactiveAndIsApproved(false, true, params)
            totalCount = Institution.countByIsInactiveAndIsApproved(false, true)
        }

        def projectCounts = institutionService.getProjectCounts(institutions)
        def projectVolunteers = institutionService.getTranscriberCounts(institutions)
        def taskCounts = institutionService.countTasksForInstitutions(institutions)

        [
            institutions: institutions,
            totalInstitutions: totalCount,
            projectCounts: projectCounts,
            projectVolunteers: projectVolunteers,
            taskCounts: taskCounts
        ]
    }
}
