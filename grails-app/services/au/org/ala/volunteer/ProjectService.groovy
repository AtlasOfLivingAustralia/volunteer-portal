package au.org.ala.volunteer

import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap

class ProjectService {

    def authService
    def taskService

    public List<ProjectSummary> getFeaturedProjectList() {
        CodeTimer t = new CodeTimer("getFeaturedProjectList")
        def projectList = Project.list()
        def taskCounts = taskService.getProjectTaskCounts()
        def fullyTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts()

        List results = []
        for (Project project : projectList) {
            if (!project.inactive) {
                def percent = 0
                if (taskCounts[project.id] && fullyTranscribedCounts[project.id]) {
                    percent = ((fullyTranscribedCounts[project.id] / taskCounts[project.id]) * 100)
                    if (percent > 99 && taskCounts[project.id] != fullyTranscribedCounts[project.id]) {
                        // Avoid reported 100% unless the transcribed count actually equals the task count
                        percent = 99;
                    }
                }
                if (percent < 100) {
                    results << getProjectSummary(project, fullyTranscribedCounts, percent)
                }
            }
        }

        t.stop(true)

        return results
    }

    private ProjectSummary getProjectSummary(Project project, Map fullyTranscribedCounts, double percent) {
        def iconImage = 'icon_specimens.png'
        def iconLabel = 'Specimens'

        if (project.template.name.equalsIgnoreCase('Journal') || project.template.name.toLowerCase().startsWith("fieldnotebook")) {
            iconImage = 'icon_fieldnotes.png'
            iconLabel = 'Field notes'
        }

        def volunteer = User.findAll("from User where userId in (select distinct fullyTranscribedBy from Task where project_id = ${project.id})")

        def ps = new ProjectSummary(project: project)
        ps.iconImage = iconImage
        ps.iconLabel = iconLabel
        ps.volunteerCount = volunteer.size()
        ps.countComplete = (Integer) fullyTranscribedCounts[project.id] ?: 0
        ps.percentComplete = (percent ? Math.round(percent) : 0)

        return ps
    }

    public ProjectSummaryList getProjectSummaryList(GrailsParameterMap params) {

        def projectList

        if (authService.userInRole(CASRoles.ROLE_ADMIN)) {
            projectList = Project.list()
        } else {
            projectList = Project.findAllByInactiveOrInactive(false, null)
        }

        def taskCounts = taskService.getProjectTaskCounts()
        def fullyTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts()

        Map<Long, ProjectSummary> projects = [:]

        def incompleteCount = 0;
        for (Project project : projectList) {

            double percent = 0;
            if (taskCounts[project.id] && fullyTranscribedCounts[project.id]) {
                percent = ((fullyTranscribedCounts[project.id] / taskCounts[project.id]) * 100)
                if (percent > 99 && taskCounts[project.id] != fullyTranscribedCounts[project.id]) {
                    // Avoid reported 100% unless the transcribed count actually equals the task count
                    percent = 99;
                }
            }
            if (percent < 100 && !project.inactive) {
                incompleteCount++;
            }

            def ps = getProjectSummary(project, fullyTranscribedCounts, percent)
            projects[project.id] = ps
        }

        def summaryList = new ProjectSummaryList(numberOfIncompleteProjects: incompleteCount, totalProjectCount: projects.size())

        List<ProjectSummary> renderList = []

        renderList = projects.collect({ kvp -> kvp.value })

        if (params.q) {
            String query = params.q.toLowerCase()

            renderList = renderList.findAll { projectSummary ->
                def project = projectSummary.project

                if (project.featuredLabel?.toLowerCase()?.contains(query)) {
                    return true
                }

                if (project.featuredOwner?.toLowerCase()?.contains(query)) {
                    return true
                }

                if (project.description?.toLowerCase()?.contains(query)) {
                    return true;
                }

                if (project.shortDescription?.toLowerCase()?.contains(query)) {
                    return true;
                }

                return false;
            }
        }

        renderList = renderList.sort { projectSummary ->

            if (params.sort == 'completed') {
                return projectSummary.percentComplete
            }

            if (params.sort == 'volunteers') {
                return projectSummary.volunteerCount;
            }

            if (params.sort == 'institution') {
                return projectSummary.project.featuredOwner;
            }

            if (params.sort == 'type') {
                return projectSummary.iconLabel;
            }

            projectSummary.project.featuredLabel?.toLowerCase()
        }

        Integer startIndex = params.int('offset') ?: 0;
        if (startIndex >= renderList.size()) {
            startIndex = renderList.size() - params.int('max');
            if (startIndex < 0) {
                startIndex = 0;
            }
        }

        int endIndex = startIndex + (params.int('max') ?: 0) - 1;
        if (endIndex >= renderList.size()) {
            endIndex = renderList.size() - 1;
        }

        if (params.order == 'desc') {
            renderList = renderList.reverse()
        }

        summaryList.matchingProjectCount = renderList.size()
        summaryList.projectRenderList = (renderList ? renderList[startIndex..endIndex] : [])

        return summaryList
    }

}

class ProjectSummaryList {
    List<ProjectSummary> projectRenderList
    int totalProjectCount
    int numberOfIncompleteProjects
    int matchingProjectCount
}

class ProjectSummary {
    Project project
    String iconLabel
    String iconImage
    long volunteerCount
    long countComplete
    int percentComplete
}