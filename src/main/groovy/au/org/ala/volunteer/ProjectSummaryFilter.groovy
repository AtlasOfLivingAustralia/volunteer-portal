package au.org.ala.volunteer

import grails.web.servlet.mvc.GrailsParameterMap

class ProjectSummaryFilter {

    public static Closure<Boolean> composeProjectFilter(ProjectStatusFilterType statusMode, ProjectActiveFilterType activeMode) {
        // Optimisation for the show all cases (no filters required)
        if ((!statusMode && !activeMode) || statusMode == ProjectStatusFilterType.showAll && activeMode == ProjectActiveFilterType.showAll) {
            return null
        }
        // Otherwise compose a function that evaluates the conjunction of a 'status' filter and an 'active' filter
        return { ProjectSummary projectSummary ->
            getStatusFilter(statusMode)(projectSummary) && getActiveFilter(activeMode)(projectSummary)
        }
    }

    public static Closure<Boolean> getStatusFilter(ProjectStatusFilterType statusMode) {
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

    public static Closure<Boolean> getActiveFilter(ProjectActiveFilterType activeMode) {
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

}

public enum ProjectStatusFilterType {

    showAll("ProjectStatusFilterType.all"), showIncompleteOnly("ProjectStatusFilterType.incomplete"), showCompleteOnly("ProjectStatusFilterType.completed")

    def String i18nLabel

    public ProjectStatusFilterType(String i18nLabel) {
        this.i18nLabel = i18nLabel
    }

    public static ProjectStatusFilterType fromString(String statusFilter) {
        if (statusFilter) {
            statusFilter as ProjectStatusFilterType
        } else {
            showAll
        }
    }

}

public enum ProjectActiveFilterType {

    showAll("projectActiveFilterType.all"), showActiveOnly("projectActiveFilterType.active"), showInactiveOnly("projectActiveFilterType.deactivated")

    def String i18nLabel

    public ProjectActiveFilterType(String i18nLabel) {
        this.i18nLabel = i18nLabel
    }

    public static ProjectActiveFilterType fromString(String activeFilter) {
        if (activeFilter) {
            activeFilter as ProjectActiveFilterType
        } else {
            showAll
        }
    }


}
