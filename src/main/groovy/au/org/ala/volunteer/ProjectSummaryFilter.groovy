package au.org.ala.volunteer

enum ProjectStatusFilterType {

    showAll("All"), showIncompleteOnly("Incomplete"), showCompleteOnly("Completed")

    String description

    ProjectStatusFilterType(String desc) {
        description = desc
    }

    static ProjectStatusFilterType fromString(String statusFilter) {
        if (statusFilter) {
            statusFilter as ProjectStatusFilterType
        } else {
            getDefault()
        }
    }

    static ProjectStatusFilterType getDefault() {
        showAll
    }

}

enum ProjectActiveFilterType {

    showAll("All"), showActiveOnly("Active"), showInactiveOnly("Deactivated"), showArchivedOnly("Archived")

    String description

    ProjectActiveFilterType(String desc) {
        description = desc
    }

    static ProjectActiveFilterType fromString(String activeFilter) {
        if (activeFilter) {
            activeFilter as ProjectActiveFilterType
        } else {
            getDefault()
        }
    }

    static ProjectActiveFilterType getDefault() {
        showAll
    }
}
