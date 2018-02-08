package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.transaction.Transactional
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry
import org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream
import org.apache.commons.io.FileUtils
import grails.web.servlet.mvc.GrailsParameterMap

import javax.imageio.ImageIO

import static java.util.concurrent.TimeUnit.MILLISECONDS
import static org.apache.commons.compress.archivers.zip.Zip64Mode.AsNeeded
import static org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream.UnicodeExtraFieldPolicy.NOT_ENCODEABLE

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
                                log.error("Failed to delete multimedia: ", ex)
                            }
                        }
                    }
                    t.delete()
                } catch (Exception ex) {
                    log.error("Failed to delete task ${t.id}: ", ex)
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
        log.info("Delete Project ${projectInstance.id}: Delete staging profile...")
        if (profile) {
            StagingFieldDefinition.executeUpdate("delete from StagingFieldDefinition f where f.id in (select ff.id from StagingFieldDefinition ff where ff.profile = :profile)", [profile: profile])
            profile.delete(flush: true, failOnError: true)
        }

        // Load all related forum topics
        // Need to load them all first before querying for the UserForumWatchLists otherwise they can't be removed from
        // the UserForumWatchLists topics set as of Hibernate plugin v3.6.10.16.
        def taskList = projectInstance.tasks.toList();
        def topicCount = 0
        if(taskList.size()>0) {
            def taskTopics = TaskForumTopic.findAllByTaskInList(taskList)
            // Also need to delete forum topics/posts that might be associated with this project
            log.info("Delete Project ${projectInstance.id}: Delete Task Forum Topics...")
            taskTopics?.each { topic ->
                log.info("Deleting topic ${topic.id}...")
                forumService.deleteTopic(topic)
                topicCount++
            }
        }


        def topics = ProjectForumTopic.findAllByProject(projectInstance)

        log.info("Delete Project ${projectInstance.id}: Delete Project Forum Topics...")
        topics?.each { topic ->
            forumService.deleteTopic(topic)
            topicCount++
        }
        log.info("Delete Project ${projectInstance.id}: ${topicCount} forum topics deleted")

        log.info("Project ${projectInstance.id}: Delete Project Forum Watchlist...")
        forumService.deleteProjectForumWatchlist(projectInstance)
        //def projectForumWatchListCount = ProjectForumWatchList.executeUpdate("delete from ProjectForumWatchList where project = :project", [project: projectInstance])
        log.info("Delete Project ${projectInstance.id}: project forum watch list deleted")

        // Delete Multimedia
        log.info("Delete Project ${projectInstance.id}: Delete multimedia...")
        def mmCount = Multimedia.executeUpdate("delete from Multimedia m where m.id in (select mm.id from Multimedia mm where mm.task.project = :project)", [project: projectInstance])
        log.info("Delete Project ${projectInstance.id}: ${mmCount} multimedia items deleted")
        // Delete Fields
        log.info("Project ${projectInstance.id}: Delete Fields...")
        def fieldCount = Field.executeUpdate("delete from Field f where f.id in (select ff.id from Field ff where ff.task.project = :project)", [project: projectInstance])
        log.info("Delete Project ${projectInstance.id}: ${fieldCount} fields deleted")

        // Viewed Tasks
        log.info("Project ${projectInstance.id}: Delete Viewed Tasks...")
        def viewedTaskCount = ViewedTask.executeUpdate("delete from ViewedTask vt where vt.id in (select vt2.id from ViewedTask vt2 where vt2.task.project = :project)", [project: projectInstance])
        log.info("Delete Project ${projectInstance.id}: ${viewedTaskCount} viewed tasks deleted")

        // Viewed Tasks
        log.info("Project ${projectInstance.id}: Delete Task comments...")
        def commentCount = TaskComment.executeUpdate("delete from TaskComment tc where tc.id in (select tc2.id from TaskComment tc2 where tc2.task.project = :project)", [project: projectInstance])
        log.info("Delete Project ${projectInstance.id}: ${commentCount} task comments deleted")

        // Delete Tasks
        // Tasks are deleted automatically because they're owned by the project

        // now we can delete the project itself
        log.info("Project ${projectInstance.id}: Delete Project...")
        projectInstance.delete(flush: true, failOnError: true)

        // if we get here we can delete the project directory on the disk
        log.info("Project ${projectInstance.id}: Removing folder from disk...")
        def dir = new File(grailsApplication.config.images.home + '/' + projectInstance.id)
        if (dir.exists()) {
            log.info("DeleteProject: Preparing to remove project directory ${dir.absolutePath}")
            FileUtils.deleteDirectory(dir)
        } else {
            log.warn("DeleteProject: Directory ${dir.absolutePath} does not exist!")
        }

    }

    public List<ProjectSummary> getFeaturedProjectList() {

        Stopwatch sw = Stopwatch.createStarted()

        log.debug("featured project list")
        def projectList = Project.findAllByInactive(false)
        //def projectIds = projectList*.id
        log.debug("project list: ${sw.elapsed(MILLISECONDS)}ms")
        sw.reset().start()
        def taskCounts = taskService.getProjectTaskCounts()
        log.debug("task counts: ${sw.elapsed(MILLISECONDS)}ms")
        sw.reset().start()
        def fullyTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts()
        log.debug("fully transcribed counts: ${sw.elapsed(MILLISECONDS)}ms")
        sw.reset().start()
        def fullyValidatedCounts = taskService.getProjectTaskValidatedCounts()
        log.debug("fully validated counts: ${sw.elapsed(MILLISECONDS)}ms")
        sw.reset().start()
//        def volunteerCounts = taskService.getProjectTranscriberCounts(projectIds)
//        log.debug("volunteer counts: ${sw.elapsed(MILLISECONDS)}ms")
//        sw.reset().start()
//        def validatorCounts = taskService.getProjectValidatorCounts(projectIds)
//        log.debug("validator counts: ${sw.elapsed(MILLISECONDS)}ms")
//        sw.reset().start()

        List results = []
        for (Project project : projectList) {
            //if (!project.inactive) {

            def taskCount = (Long) taskCounts[project.id] ?: 0
            long transcribedCount = (Long) fullyTranscribedCounts[project.id] ?: 0
            long validatedCount = (Long) fullyValidatedCounts[project.id] ?: 0
//                def volunteerCount = (Integer) volunteerCounts[project.id] ?: 0
//                def validatorCount = (Integer) validatorCounts[project.id] ?: 0
            if (transcribedCount < taskCount) {
                results << makeProjectSummary(project, taskCount, transcribedCount, validatedCount, 0, 0)
//volunteerCount, validatorCount)
            }
            //}
        }
        log.debug("make summary projects: ${sw.elapsed(MILLISECONDS)}ms")
        sw.reset().start()

        return results
    }

    private static ProjectType guessProjectType(Project project) {

        def viewName = project.template.viewName.toLowerCase()

        if (viewName.contains("journal") || viewName.contains("fieldnotebook") || viewName.contains("observationDiary")) {
            return ProjectType.findByName("fieldnotes")
        } else if (viewName.contains('camera trap') || viewName.contains('wild count') || viewName.contains('wildcount')) {
            return ProjectType.findByName("cameratraps")
        }

        return ProjectType.findByName("specimens")
    }

    private ProjectSummary makeProjectSummary(Project project, long taskCount, long transcribedCount, long fullyValidatedCount, int transcriberCount, int validatorCount) {

        if (!project.projectType) {
            def projectType = guessProjectType(project)
            if (projectType) {
                project.projectType = projectType
                project.save()
            }
        }

        // Default, if all else fails
        def iconImage = grailsLinkGenerator.resource(file: '/iconLabels.png')
        def iconLabel = 'Specimens'

        if (project.projectType) {
            iconImage = projectTypeService.getIconURL(project.projectType)
            iconLabel = project.projectType.label
        }

        // def volunteer = User.findAll("from User where userId in (select distinct fullyTranscribedBy from Task where project_id = ${project.id})")

        def ps = new ProjectSummary(project: project)
        ps.iconImage = iconImage
        ps.iconLabel = iconLabel
        ps.transcriberCount = transcriberCount

        ps.taskCount = taskCount
        ps.transcribedCount = transcribedCount
        ps.validatorCount = validatorCount
        ps.validatedCount = fullyValidatedCount

        return ps
    }

    public makeSummaryListFromProjectList(List<Project> projectList, GrailsParameterMap params, Closure<Boolean> filter = null) {
        //def projectIds = projectList*.id
        def taskCounts = taskService.getProjectTaskCounts()
        def fullyTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts()
        def fullyValidatedCounts = taskService.getProjectTaskValidatedCounts()
        def transcriberCounts = taskService.getProjectTranscriberCounts()
        def validatorCounts = taskService.getProjectValidatorCounts()


        Map<Long, ProjectSummary> projects = [:]

        def incompleteCount = 0;

        for (Project project : projectList) {

            def taskCount = (Long) taskCounts[project.id] ?: 0
            long transcribedCount = (Long) fullyTranscribedCounts[project.id] ?: 0
            long validatedCount = (Long) fullyValidatedCounts[project.id] ?: 0
            def transcriberCount = (Integer) transcriberCounts[project.id] ?: 0
            def validatorCount = (Integer) validatorCounts[project.id] ?: 0

            if (transcribedCount < taskCount && !project.inactive) {
                incompleteCount++;
            }

            def ps = makeProjectSummary(project, taskCount, transcribedCount, validatedCount, transcriberCount, validatorCount)
            projects[project.id] = ps
        }

        def summaryList = new ProjectSummaryList(numberOfIncompleteProjects: incompleteCount, totalProjectCount: projects.size())

        List<ProjectSummary> renderList = []

        renderList = projects.collect({ kvp -> kvp.value })

        // first remove any filtered projects - This supports view filters such as 'active' or 'incomplete' only views
        if (filter) {
            renderList = renderList.findAll filter
        }

        // Then apply the query paramter
        if (params?.q) {
            String query = params.q.toLowerCase()
            String tagPrefix = "tag:"

            renderList = renderList.findAll { projectSummary ->
                def project = projectSummary.project

                // special syntax for label (project type). NdR Oct 2015.
                if (query.startsWith(tagPrefix) && projectSummary.iconLabel?.toLowerCase()?.contains(query.replaceFirst(tagPrefix, ""))) {
                    return true
                }

                if (project.i18nName?.toString()?.toLowerCase()?.contains(query)) {
                    return true
                }

                if (project.institution && project.institution.i18nName?.toString()?.toLowerCase()?.contains(query)) {
                    return true
                }

                if (project.featuredOwner?.toLowerCase()?.contains(query)) {
                    return true
                }

                if (project.i18nDescription?.toString()?.toLowerCase()?.contains(query)) {
                    return true;
                }

                if (project.i18nShortDescription?.toString()?.toLowerCase()?.contains(query)) {
                    return true;
                }

                return false;
            }
        }

        renderList = renderList.sort { projectSummary ->

            if (params?.sort == 'completed') {
                return projectSummary.percentTranscribed < 100 ? projectSummary.percentTranscribed : projectSummary.percentValidated + projectSummary.percentTranscribed
            }

            if (params?.sort == 'validated') {
                return projectSummary.percentValidated
            }

            if (params?.sort == 'volunteers') {
                return projectSummary.transcriberCount;
            }

            if (params?.sort == 'institution') {
                return projectSummary.project.institution?.i18nName ?: projectSummary.project.featuredOwner;
            }

            if (params?.sort == 'type') {
                return projectSummary.iconLabel;
            }

            projectSummary.project.i18nName?.toString()?.toLowerCase()
        }

        Integer startIndex = params?.int('offset') ?: 0;
        if (startIndex >= renderList.size()) {
            startIndex = renderList.size() - (params?.int('max') ?: 0)
            if (startIndex < 0) {
                startIndex = 0;
            }
        }

        int endIndex = startIndex + (params?.int('max') ?: 0) - 1
        if (endIndex >= renderList.size()) {
            endIndex = renderList.size() - 1;
        }

        if (params?.order == 'desc') {
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

        def statusFilterMode = ProjectStatusFilterType.fromString(params?.statusFilter)
        def activeFilterMode = ProjectActiveFilterType.fromString(params?.activeFilter)

        def filter = ProjectSummaryFilter.composeProjectFilter(statusFilterMode, activeFilterMode)

        return makeSummaryListFromProjectList(projectList, params, filter)
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
            log.info("Checking Featured image for project ${projectInstance.id}: Dimensions ${image.width} x ${image.height}")
            if (image.width > 600) {
                log.info "Image is not the correct size. Scaling width to 600px..."
                image = ImageUtils.scaleWidth(image, 600)
                log.info "Saving new dimensions ${image.width} x ${image.height}"
                ImageIO.write(image, "jpg", file)
                log.info "Done."
            } else {
                log.info "Image Ok. No scaling required."
            }
            return true
        } catch (Exception ex) {
            log.error("Could not check and resize expedition image for $projectInstance", ex)
            return false
        }
    }

    def projectSize(List<Project> projects) {
        projects.collectEntries {
            [(it.id): projectSize(it)]
        }
    }

    def projectSize(Project project) {
        final projectPath = new File(grailsApplication.config.images.home, project.id.toString())
        try {
            [size: projectPath.directorySize(), error: null]
        } catch (e) {
            [error: e, size: -1]
        }
    }

    def imageStoreStats() {
        final f = new File(grailsApplication.config.images.home)
        [total: f.totalSpace, free: f.freeSpace, usable: f.usableSpace]
    }

    def calculateCompletion(List<Project> projects) {
        Task.withCriteria {
            'in'('project', projects)

            projections {
                groupProperty('project')
                count('id', 'total')
                count('fullyTranscribedBy', 'transcribed')
                count('fullyValidatedBy', 'validated')
            }
        }.collectEntries { row ->
            [(row[0].id): [total: row[1], transcribed: row[2], validated: row[3]]]
        }
    }

    def writeArchive(Project project, OutputStream outputStream) {
        final projectPath = new File(grailsApplication.config.images.home, project.id.toString())
        def zos = new ZipArchiveOutputStream(outputStream)
        zos.encoding = 'UTF-8'
        zos.fallbackToUTF8 = true
        zos.createUnicodeExtraFields = NOT_ENCODEABLE
        zos.useLanguageEncodingFlag = true
        zos.useZip64 = AsNeeded
        zos.withStream {
            addToZip(zos, projectPath, '')
            zos.finish()
        }
    }

    def archiveProject(Project project) {
        final projectPath = new File(grailsApplication.config.images.home, project.id.toString())
        def result = projectPath.deleteDir()
        if (!result) {
            log.warn("Couldn't delete images for $project")
            throw new IOException("Couldn't delete images for $project")
        }
    }

    static def addToZip(ZipArchiveOutputStream zos, File path, String entryPath) {
        String entryName = entryPath + path.getName();

        if (path.isFile()) {
            ZipArchiveEntry zipEntry = new ZipArchiveEntry(path, entryName);
            zos.putArchiveEntry(zipEntry);
            path.withInputStream { fis ->
                zos << fis
            }
            zos.closeArchiveEntry()
        } else if (path.isDirectory()) {
            File[] children = path.listFiles()

            if (children != null) {
                for (File child : children) {
                    addToZip(zos, child.absoluteFile, "$entryName/")
                }
            }
        }
    }

    def calculateNumberOfTranscribers(Project project) {
        Task.createCriteria().get {
            eq('project', project)
            isNotNull('fullyTranscribedBy')
            projections {
                countDistinct('fullyTranscribedBy')
            }
        }
    }

    def calculateStartAndEndTranscriptionDates(Project project) {
        def result = Task.createCriteria().list {
            eq('project', project)
            projections {
                max('dateFullyTranscribed')
                min('dateFullyTranscribed')
            }
        }
        return result ? [start: result[0][1], end: result[0][0]] : null
    }
}
