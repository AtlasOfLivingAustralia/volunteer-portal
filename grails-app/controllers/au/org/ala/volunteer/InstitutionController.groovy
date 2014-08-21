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

        def statusFilterMode = params.statusFilter as ProjectStatusFilterType ?: ProjectStatusFilterType.showAll
        def activeFilterMode = params.activeFilter as ProjectActiveFilterType ?: ProjectActiveFilterType.showAll

        def filter = composeProjectFilter(statusFilterMode, activeFilterMode)

        def projectSummaries = projectService.makeSummaryListFromProjectList(projects, params, filter)
        def transcriberCount = institutionService.getTranscriberCount(institution)
        def projectTypeCounts = institutionService.getProjectTypeCounts(institution)
        def taskCounts = institutionService.getTaskCounts(institution)

        [
            institutionInstance: institution, projects: projectSummaries.projectRenderList, filteredProjectsCount: projectSummaries.matchingProjectCount, totalProjectCount: projectSummaries.totalProjectCount,
            transcriberCount: transcriberCount, projectTypes: projectTypeCounts, taskCounts: taskCounts,
            statusFilterMode: statusFilterMode, activeFilterMode: activeFilterMode
        ]
    }

    Closure<Boolean> composeProjectFilter(ProjectStatusFilterType statusMode, ProjectActiveFilterType activeMode) {
        // Optimisation for the show all cases (no filters required)
        if ((!statusMode && !activeMode) || statusMode == ProjectStatusFilterType.showAll && activeMode == ProjectActiveFilterType.showAll) {
            return null
        }
        // Otherwise compose a function that evaluates the conjunction of a 'status' filter and an 'active' filter
        return { ProjectSummary projectSummary ->
            getStatusFilter(statusMode)(projectSummary) && getActiveFilter(activeMode)(projectSummary)
        }
    }

    Closure<Boolean> getStatusFilter(ProjectStatusFilterType statusMode) {
        switch (statusMode) {
            case ProjectStatusFilterType.showCompleteOnly:
                return { ProjectSummary projectSummary -> projectSummary.transcribedCount == projectSummary.taskCount }
            case ProjectStatusFilterType.showIncompleteOnly:
                return { ProjectSummary projectSummary -> projectSummary.transcribedCount < projectSummary.taskCount }
            default:
                // Show all
                return { ProjectSummary projectSummary -> true }
        }
    }

    Closure<Boolean> getActiveFilter(ProjectActiveFilterType activeMode) {
        switch (activeMode) {
            case ProjectActiveFilterType.showActiveOnly:
                return { ProjectSummary projectSummary -> !projectSummary.project.inactive }
            case ProjectActiveFilterType.showInactiveOnly:
                return { ProjectSummary projectSummary -> projectSummary.project.inactive  }
            default:
                // Show all
                return { ProjectSummary projectSummary -> true }
        }
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

enum ProjectStatusFilterType {

    showAll("All"), showIncompleteOnly("Incomplete"), showCompleteOnly("Completed")

    def String description

    public ProjectStatusFilterType(String desc) {
        description = desc
    }

}

enum ProjectActiveFilterType {
    showAll("All"), showActiveOnly("Active"), showInactiveOnly("Deactivated")

    def String description

    public ProjectActiveFilterType(String desc) {
        description = desc
    }

}
