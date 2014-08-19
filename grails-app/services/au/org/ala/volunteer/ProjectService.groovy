package au.org.ala.volunteer

import grails.transaction.Transactional
import org.apache.commons.io.FileUtils
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap

import javax.imageio.ImageIO

@Transactional
class ProjectService {

    def userService
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

    private calcPercent(count, total) {
        def percent = ((count / total) * 100)
        if (percent > 99 && count != total) {
            // Avoid reported 100% unless the count actually equals the task total
            percent = 99;
        }
        return percent
    }


    public List<ProjectSummary> getFeaturedProjectList() {

        def projectList = Project.list()
        def taskCounts = taskService.getProjectTaskCounts()
        def fullyTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts()
        def fullyValidatedCounts = taskService.getProjectTaskValidatedCounts()
        def volunteerCounts = taskService.getProjectVolunteerCounts()

        List results = []
        for (Project project : projectList) {
            if (!project.inactive) {

                double percentTranscribed = 0
                double percentValidated = 0

                def taskCount = (Long) taskCounts[project.id] ?: 0
                long transcribedCount = (Long) fullyTranscribedCounts[project.id] ?: 0
                long validatedCount = (Long) fullyValidatedCounts[project.id] ?: 0
                def volunteerCount = (Integer) volunteerCounts[project.id] ?: 0

                if (taskCount) {
                    percentTranscribed = calcPercent(transcribedCount, taskCount)
                    percentValidated = calcPercent(validatedCount, taskCount)
                }

                if (percentTranscribed < 100) {
                    results << makeProjectSummary(project, taskCount, transcribedCount, percentTranscribed, validatedCount, percentValidated, volunteerCount)
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

    private ProjectSummary makeProjectSummary(Project project, long taskCount, long transcribedCount, double percentTranscribed, long fullyValidatedCount, double percentValidated, int volunteerCount) {

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
        ps.volunteerCount = volunteerCount
        ps.taskCount = taskCount
        ps.countTranscribed = transcribedCount
        ps.percentTranscribed = (percentTranscribed ? Math.round(percentTranscribed) : 0)
        ps.countValidated = fullyValidatedCount
        ps.percentValidated = (percentValidated ? Math.round(percentValidated) : 0)

        return ps
    }

    public makeSummaryListFromProjectList(List<Project> projectList, GrailsParameterMap params) {
        def taskCounts = taskService.getProjectTaskCounts()
        def fullyTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts()
        def fullyValidatedCounts = taskService.getProjectTaskValidatedCounts()
        def volunteerCounts = taskService.getProjectVolunteerCounts()

        Map<Long, ProjectSummary> projects = [:]

        def incompleteCount = 0;

        for (Project project : projectList) {

            double percentTranscribed = 0
            double percentValidated = 0

            def taskCount = (Long) taskCounts[project.id] ?: 0
            long transcribedCount = (Long) fullyTranscribedCounts[project.id] ?: 0
            long validatedCount = (Long) fullyValidatedCounts[project.id] ?: 0
            def volunteerCount = (Integer) volunteerCounts[project.id] ?: 0

            if (taskCount) {
                percentTranscribed = calcPercent(transcribedCount, taskCount)
                percentValidated = calcPercent(validatedCount, taskCount)
            }

            if (percentTranscribed < 100 && !project.inactive) {
                incompleteCount++;
            }

            def ps = makeProjectSummary(project, taskCount, transcribedCount, percentTranscribed, validatedCount, percentValidated, volunteerCount)
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

                if (project.institution && project.institution.name?.toLowerCase()?.contains(query)) {
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
                return projectSummary.percentTranscribed < 100 ? projectSummary.percentTranscribed : projectSummary.percentValidated + projectSummary.percentTranscribed
            }

            if (params.sort == 'validated') {
                return projectSummary.percentValidated
            }

            if (params.sort == 'volunteers') {
                return projectSummary.volunteerCount;
            }

            if (params.sort == 'institution') {
                return projectSummary.project.institution?.name ?: projectSummary.project.featuredOwner;
            }

            if (params.sort == 'type') {
                return projectSummary.iconLabel;
            }

            projectSummary.project.featuredLabel?.toLowerCase()
        }

        Integer startIndex = params.int('offset') ?: 0;
        if (startIndex >= renderList.size()) {
            startIndex = renderList.size() - (params.int('max') ?: 0)
            if (startIndex < 0) {
                startIndex = 0;
            }
        }

        int endIndex = startIndex + (params.int('max') ?: 0) - 1
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

    public ProjectSummaryList getProjectSummaryList(GrailsParameterMap params) {

        def projectList

        if (userService.isAdmin()) {
            projectList = Project.list()
        } else {
            projectList = Project.findAllByInactiveOrInactive(false, null)
        }

        return makeSummaryListFromProjectList(projectList, params)
    }

    def checkAndResizeExpeditionImage(Project projectInstance) {
        try {
            def filePath = "${grailsApplication.config.images.home}/project/${projectInstance.id}/expedition-image.jpg"
            def file = new File(filePath);
            if (!file.exists()) {
                return
            }

            // Now check image size...
            def image = ImageIO.read(file)
            logService.log("Checking Featured image for project ${projectInstance.id}: Dimensions ${image.width} x ${image.height}")
            if (image.width != 254 || image.height != 158) {
                logService.log "Image is not the correct size. Scaling to 254 x 158..."
                image = ImageUtils.scale(image, 254, 158)
                logService.log "Saving new dimensions ${image.width} x ${image.height}"
                ImageIO.write(image, "jpg", file)
                logService.log "Done."
            } else {
                logService.log "Image Ok. No scaling required."
            }
            return true
        } catch (Exception ex) {
            println ex
            ex.printStackTrace()
            return false
        }
    }

}
