package au.org.ala.volunteer

import grails.transaction.Transactional
import org.apache.commons.io.FileUtils
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap

@Transactional
class ProjectService {

    def authService
    def taskService
    def grailsLinkGenerator
    def projectTypeService
    def forumService
    def multimediaService
    def logService
    def grailsApplication

    def deleteTasksForProject(Project projectInstance, boolean deleteImages = true) {
        if (projectInstance) {
            def tasks = Task.findAllByProject(projectInstance)
            for (Task t : tasks) {
                try {
                    if (deleteImages) {
                        t.multimedia.each { image ->
                            try {
                                multimediaService.deleteMultimedia(image)
                            } catch (IOException ex) {
                                logService.log("Failed to delete multimedia: " + ex.message)
                            }
                        }
                    }
                    t.delete()
                } catch (Exception ex) {
                    logService.log("Failed to delete task ${t.id}: " + ex.message)
                }
            }
        }

    }

    def deleteProject(Project projectInstance) {


        if (!projectInstance) {
            return;
        }

        // First need to delete the staging profile, if it exists, and to do that you need to delete all its items first
        def profile = ProjectStagingProfile.findByProject(projectInstance)
        logService.log("Delete Project ${projectInstance.id}: Delete staging profile...")
        if (profile) {
            StagingFieldDefinition.executeUpdate("delete from StagingFieldDefinition f where f.id in (select ff.id from StagingFieldDefinition ff where ff.profile = :profile)", [profile: profile])
            profile.delete(flush: true, failOnError: true)
        }

        // Also need to delete forum topics/posts that might be associated with this project
        logService.log("Delete Project ${projectInstance.id}: Delete Project Forum Topics...")
        def topics = ProjectForumTopic.findByProject(projectInstance)
        def topicCount = 0
        topics?.each { topic ->
            forumService.deleteTopic(topic)
            topicCount++
        }

        logService.log("Delete Project ${projectInstance.id}: Delete Task Forum Topics...")
        topics = TaskForumTopic.executeQuery("from TaskForumTopic where id in (select TT.id from TaskForumTopic TT where TT.task.project = :project)", [project: projectInstance])
        topics?.each { topic ->
            logService.log("Deleting topic ${topic.id}...")
            forumService.deleteTopic(topic)
            topicCount++
        }
        logService.log("Delete Project ${projectInstance.id}: ${topicCount} forum topics deleted")

        // Delete Multimedia
        logService.log("Delete Project ${projectInstance.id}: Delete multimedia...")
        def mmCount = Multimedia.executeUpdate("delete from Multimedia m where m.id in (select mm.id from Multimedia mm where mm.task.project = :project)", [project: projectInstance])
        logService.log("Delete Project ${projectInstance.id}: ${mmCount} multimedia items deleted")
        // Delete Fields
        logService.log("Project ${projectInstance.id}: Delete Fields...")
        def fieldCount = Field.executeUpdate("delete from Field f where f.id in (select ff.id from Field ff where ff.task.project = :project)", [project: projectInstance])
        logService.log("Delete Project ${projectInstance.id}: ${fieldCount} fields deleted")

        // Viewed Tasks
        logService.log("Project ${projectInstance.id}: Delete Viewed Tasks...")
        def viewedTaskCount = ViewedTask.executeUpdate("delete from ViewedTask vt where vt.id in (select vt2.id from ViewedTask vt2 where vt2.task.project = :project)", [project: projectInstance])
        logService.log("Delete Project ${projectInstance.id}: ${viewedTaskCount} viewed tasks deleted")

        // Viewed Tasks
        logService.log("Project ${projectInstance.id}: Delete Task comments...")
        def commentCount = TaskComment.executeUpdate("delete from TaskComment tc where tc.id in (select tc2.id from TaskComment tc2 where tc2.task.project = :project)", [project: projectInstance])
        logService.log("Delete Project ${projectInstance.id}: ${commentCount} task comments deleted")

        // Delete Tasks
        logService.log("Project ${projectInstance.id}: Delete Tasks...")
        def taskCount = Task.executeUpdate("delete from Task t where t.id in (select tt.id from Task tt where project = :project)", [project: projectInstance])
        logService.log("Delete Project ${projectInstance.id}: ${taskCount} tasks deleted")

        // now we can delete the project itself
        logService.log("Project ${projectInstance.id}: Delete Project...")
        projectInstance.delete(flush: true, failOnError: true)

        // if we get here we can delete the project directory on the disk
        logService.log("Project ${projectInstance.id}: Removing folder from disk...")
        def dir = new File(grailsApplication.config.images.home + '/' + projectInstance.id )
        if (dir.exists()) {
            logService.log("DeleteProject: Preparing to remove project directory ${dir.absolutePath}")
            FileUtils.deleteDirectory(dir)
        } else {
            logService.log("DeleteProject: Directory ${dir.absolutePath} does not exist!")
        }

    }

    public List<ProjectSummary> getFeaturedProjectList() {

        def projectList = Project.list()
        def taskCounts = taskService.getProjectTaskCounts()
        def fullyTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts()
        def volunteerCounts = taskService.getProjectVolunteerCounts()

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
                    results << getProjectSummary(project, fullyTranscribedCounts, percent, volunteerCounts)
                }
            }
        }

        return results
    }

    private static ProjectType guessProjectType(Project project) {

        def viewName = project.template.viewName.toLowerCase()

        if (viewName.contains("journal") || viewName.contains("fieldnotebook") || viewName.contains("observationDiary")) {
            return ProjectType.findByName("fieldnotes")
        }

        return ProjectType.findByName("specimens")
    }

    private ProjectSummary getProjectSummary(Project project, Map fullyTranscribedCounts, double percent, Map volunteerCounts) {

        if (!project.projectType) {
            def projectType = guessProjectType(project)
            if (projectType) {
                project.projectType = projectType
                project.save()
            }
        }

        // Default, if all else fails
        def iconImage = grailsLinkGenerator.resource(dir:'/images', file:'icon_specimens.png')
        def iconLabel = 'Specimens'

        if (project.projectType) {
            iconImage = projectTypeService.getIconURL(project.projectType)
            iconLabel = project.projectType.label
        }

        // def volunteer = User.findAll("from User where userId in (select distinct fullyTranscribedBy from Task where project_id = ${project.id})")

        def ps = new ProjectSummary(project: project)
        ps.iconImage = iconImage
        ps.iconLabel = iconLabel
        ps.volunteerCount = (Integer) volunteerCounts[project.id] ?: 0
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
        def volunteerCounts = taskService.getProjectVolunteerCounts()

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

            def ps = getProjectSummary(project, fullyTranscribedCounts, percent, volunteerCounts)
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