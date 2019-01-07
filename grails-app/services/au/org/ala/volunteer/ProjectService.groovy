package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.transaction.Transactional
import groovy.transform.Immutable
import groovyx.gpars.actor.Actors
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry
import org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream
import org.apache.commons.io.FileUtils
import grails.web.servlet.mvc.GrailsParameterMap
import org.hibernate.Session
import org.jooq.Condition
import org.jooq.SQLDialect
import org.jooq.SortOrder
import org.jooq.conf.Settings
import org.jooq.impl.DSL

import javax.annotation.PreDestroy
import javax.imageio.ImageIO
import javax.sql.DataSource

import static au.org.ala.volunteer.jooq.tables.Institution.INSTITUTION
import static au.org.ala.volunteer.jooq.tables.Project.PROJECT
import static au.org.ala.volunteer.jooq.tables.ProjectType.PROJECT_TYPE
import static au.org.ala.volunteer.jooq.tables.Task.TASK
import static au.org.ala.volunteer.jooq.tables.Transcription.TRANSCRIPTION
import static java.util.concurrent.TimeUnit.MILLISECONDS
import static org.apache.commons.compress.archivers.zip.Zip64Mode.AsNeeded
import static org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream.UnicodeExtraFieldPolicy.NOT_ENCODEABLE
import static org.jooq.impl.DSL.count as jCount
import static org.jooq.impl.DSL.countDistinct as jCountDistinct
import static org.jooq.impl.DSL.lower as jLower
import static org.jooq.impl.DSL.nvl as jNvl
import static org.jooq.impl.DSL.or as jOr
import static org.jooq.impl.DSL.sum as jSum
import static org.jooq.impl.DSL.when as jWhen

@Transactional
class ProjectService {

    static final String TASK_COUNT_COLUMN = 'taskCount'
    static final String TRANSCRIBED_COUNT_COLUMN = 'transcribedCount'
    static final String VALIDATED_COUNT_COLUMN = 'validatedCount'
    static final String VALIDATOR_COUNT_COLUMN = 'validatorCount'

    // make a static factory function because I'm not sure whether
    // these are thread safe
    private static final Condition getACTIVE_ONLY() { PROJECT.INACTIVE.eq(false) | PROJECT.INACTIVE.isNull() }

    def userService
    def taskService
    def grailsLinkGenerator
    def projectTypeService
    def forumService
    def multimediaService
    def logService
    def grailsApplication
    DataSource dataSource

    def deleteTasksActor = Actors.actor {
        loop {
            react { DeleteTasksMessage msg ->

                log.info("Deleting tasks {}", msg)

                try {
                    Task.withNewSession { Session session ->
                        Project p = Project.get(msg.projectId)
                        def count = 0
                        def lastId = Long.MIN_VALUE
                        def tasks = Task.findAllByProject(p, [sort: 'id', order: 'asc', max: 100])
                        while (tasks) {
                            if (log.isDebugEnabled()) {
                                log.debug("Deleting tasks {}", tasks*.id)
                            }
                            for (Task task : tasks) {
                                lastId = task.id
                                try {
                                    if (msg.deleteImages) multimediaService.deleteAllMultimediaForTask(task)
                                    task.delete()
                                } catch (e) {
                                    log.error("Exception while deleting task ${task.id}", e)
                                    continue
                                }
                                count++
                                if (count % 25 == 0) {
                                    def msgData = [projectId: msg.projectId, count: count, complete: false]
                                    log.debug("notifying message data {}", msgData)
                                    notify(EventSourceService.NEW_MESSAGE, new Message.EventSourceMessage(to: msg.userId, event: 'deleteTasks', data: msgData))
                                }
                            }
                            tasks = Task.findAllByProjectAndIdGreaterThan(p, lastId, [sort: 'id', order: 'asc', max: 100])
                        }
                        log.info("Completed deleting all tasks for {}", msg.projectId)
                        session.flush()
                        notify(EventSourceService.NEW_MESSAGE, new Message.EventSourceMessage(to: msg.userId, event: 'deleteTasks', data: [projectId: msg.projectId, count: count, complete: true]))
                    }
                } catch (e) {
                    log.error("Error deleting tasks", e)
                    notify(EventSourceService.NEW_MESSAGE, new Message.EventSourceMessage(to: msg.userId, event: 'deleteTasks', data: [projectId: msg.projectId, count: -1, error: e.message, complete: true]))
                }
            }
        }
    }

    @PreDestroy
    def shutdown() {
        deleteTasksActor.stop()
    }

    @Immutable
    final static class DeleteTasksMessage {
        long projectId
        String userId
        boolean deleteImages
    }

    def deleteTasksForProject(Project projectInstance, boolean deleteImages = true) {
        if (projectInstance) {
            deleteTasksActor(new DeleteTasksMessage(projectInstance.id, userService.currentUserId, deleteImages))
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
        def tasks = projectInstance.tasks.toList()
        def taskTopics = tasks ? TaskForumTopic.findAllByTaskInList(tasks) : []
        def topics = ProjectForumTopic.findAllByProject(projectInstance)
        def topicCount = 0

        // Also need to delete forum topics/posts that might be associated with this project
        log.info("Delete Project ${projectInstance.id}: Delete Task Forum Topics...")
        taskTopics?.each { topic ->
            log.info("Deleting topic ${topic.id}...")
            forumService.deleteTopic(topic)
            topicCount++
        }

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
        def dir = new File(grailsApplication.config.images.home + '/' + projectInstance.id )
        if (dir.exists()) {
            log.info("DeleteProject: Preparing to remove project directory ${dir.absolutePath}")
            FileUtils.deleteDirectory(dir)
        } else {
            log.warn("DeleteProject: Directory ${dir.absolutePath} does not exist!")
        }

    }

    public List<ProjectSummary> getFeaturedProjectList() {

        Stopwatch sw = Stopwatch.createStarted()
        def resultMaps = generateProjectSummariesQuery(dataSource, [], null, null, 'transcribed', null, null, null, ProjectStatusFilterType.showIncompleteOnly, ProjectActiveFilterType.showActiveOnly, false).fetchMaps()

        if (resultMaps.size() == 0) return []

        def projectIds = resultMaps.collect { it['id'] }
        def projects = Project.findAllByIdInList(projectIds)
        def projectsMap = projects.collectEntries { [(it.id): it] }

        def results = resultMaps.collect { result ->
            def project = projectsMap[result['id']]
            def taskCount = result[TASK_COUNT_COLUMN] ?: 0
            def transcribedCount = result[TRANSCRIBED_COUNT_COLUMN] ?: 0
            def validatedCount = result[VALIDATED_COUNT_COLUMN] ?: 0
            makeProjectSummary(project, taskCount, transcribedCount, validatedCount, 0)
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

    private ProjectSummary makeProjectSummary(Project project, Number taskCount, Number transcribedCount, Number fullyValidatedCount, Number validatorCount) {

        if (!project.projectType) {
            def projectType = guessProjectType(project)
            if (projectType) {
                project.projectType = projectType
                project.save()
            }
        }

        // Default, if all else fails
        def iconImage = grailsLinkGenerator.resource(file:'/iconLabels.png')
        def iconLabel = 'Specimens'

        if (project.projectType) {
            iconImage = projectTypeService.getIconURL(project.projectType)
            iconLabel = project.projectType.label
        }

        // def volunteer = User.findAll("from User where userId in (select distinct fullyTranscribedBy from Task where project_id = ${project.id})")

        def ps = new ProjectSummary(project: project)
        ps.iconImage = iconImage
        ps.iconLabel = iconLabel

        ps.taskCount = taskCount.toLong()
        ps.transcribedCount = transcribedCount.toLong()
        ps.validatorCount = validatorCount.toLong()
        ps.validatedCount = fullyValidatedCount.toLong()

        return ps
    }

    def makeSummaryListForInstitution(Institution institution, String tag, String q, String sort, Integer offset, Integer max, String order, ProjectStatusFilterType statusFilter, ProjectActiveFilterType activeFilter) {
        def conditions = [PROJECT.INSTITUTION_ID.eq(institution.id)]
        if (!userService.isInstitutionAdmin(institution)) {
            conditions += ACTIVE_ONLY
        }
        makeSummaryListFromConditions(conditions, tag, q, sort, offset, max, order, statusFilter, activeFilter)
    }

    private def makeSummaryListFromConditions(Collection<? extends Condition> conditions, String tag, String q, String sort, Integer offset, Integer max, String order, ProjectStatusFilterType statusFilter, ProjectActiveFilterType activeFilter) {
        def results = generateProjectSummariesQuery(dataSource, conditions, tag, q, sort, offset, max, order, statusFilter, activeFilter, true).fetchMaps()
        if (!results) {
            return makeSummaryListFromResults(results, [])
        }
        def projects = Project.findAllByIdInList(results.collect { it['id'] })
        return makeSummaryListFromResults(results, projects)
    }

    def makeSummaryListFromProjectList(List<Project> projects, String tag, String q, String sort, Integer offset, Integer max, String order, ProjectStatusFilterType statusFilter, ProjectActiveFilterType activeFilter) {
        if (!projects) {
            return makeSummaryListFromResults([], [])
        }
        def results = generateProjectSummariesQuery(dataSource, [PROJECT.ID.in(projects*.id)], tag, q, sort, offset, max, order, statusFilter, activeFilter, true).fetchMaps()
        return makeSummaryListFromResults(results, projects)
    }

    // TODO find usages of ProjectSummary.project and just project the required variables directly onto the summary
    // to skip loading the projects in hibernate
    private def makeSummaryListFromResults(List<Map<String, Object>> results, List<Project> projects) {
        def projectMap = projects.collectEntries { [(it.id): it] }
        def incompleteCount = 0
        def totalCount = 0
        def renderList = results.collect { result ->
            def project = projectMap[result['id']]
            def taskCount = result[TASK_COUNT_COLUMN] ?: 0
            def transcribedCount = result[TRANSCRIBED_COUNT_COLUMN] ?: 0
            def validatedCount = result[VALIDATED_COUNT_COLUMN] ?: 0
            def validatorCount = result[VALIDATOR_COUNT_COLUMN] ?: 0
            totalCount = result['full_count']
            if (transcribedCount < taskCount && !project.inactive) {
                incompleteCount++
            }
            makeProjectSummary(project, taskCount, transcribedCount, validatedCount, validatorCount)
        }
        new ProjectSummaryList(
                projectRenderList: renderList,
                numberOfIncompleteProjects: incompleteCount,
                matchingProjectCount: totalCount
        )
    }

    private static def generateProjectSummariesQuery(DataSource dataSource, Collection<? extends Condition> whereClauses, String tag, String q, String sort, Integer offset, Integer max, String order, ProjectStatusFilterType statusFilter, ProjectActiveFilterType activeFilter, boolean countUsers) {
        def postgres = SQLDialect.POSTGRES_9_5
        def settings = new Settings().withRenderFormatted(false)
        def context = DSL.using(dataSource, postgres, settings)

        switch (activeFilter) {
            case ProjectActiveFilterType.showActiveOnly:
                whereClauses += ACTIVE_ONLY
                break
            case ProjectActiveFilterType.showInactiveOnly:
                whereClauses += PROJECT.INACTIVE.eq(true)
                break
        }

        def taskCountClause = jCount(TASK).'as'(TASK_COUNT_COLUMN)

        def fullyTranscribedTaskCountClause = jCount(TASK.IS_FULLY_TRANSCRIBED).filterWhere(TASK.IS_FULLY_TRANSCRIBED.eq(true)).'as'(TRANSCRIBED_COUNT_COLUMN)
        def validatedCountClause = jSum(jWhen(TASK.FULLY_VALIDATED_BY.isNull(), 0).otherwise(1)).'as'(VALIDATED_COUNT_COLUMN)
        def validatorCountClause = jCountDistinct(TASK.FULLY_VALIDATED_BY).'as'(VALIDATOR_COUNT_COLUMN)

        switch (statusFilter) {
            case ProjectStatusFilterType.showCompleteOnly:
                whereClauses += taskCountClause.eq(fullyTranscribedTaskCountClause)
                break
            case ProjectStatusFilterType.showIncompleteOnly:
                whereClauses += taskCountClause.gt(fullyTranscribedTaskCountClause)
                break
        }

        def taskJoinTableColumns = [
                TASK.PROJECT_ID,
                taskCountClause,
                fullyTranscribedTaskCountClause,
                validatedCountClause
        ]

        if (countUsers) {
            taskJoinTableColumns.add(validatorCountClause)
        }

        def taskJoinTable = context.select(taskJoinTableColumns).from(TASK).groupBy(TASK.PROJECT_ID).asTable('taskStats')

        def fromClause = PROJECT.leftOuterJoin(PROJECT_TYPE).onKey()
                                .leftOuterJoin(INSTITUTION).onKey()
                                .leftOuterJoin(taskJoinTable).on(PROJECT.ID.eq(taskJoinTable.field(0, Long)))

        // apply the query paramter
        if (tag) {
            whereClauses += PROJECT_TYPE.LABEL.containsIgnoreCase(tag)
        }

        if (q) {
            def queryClauses = []
            queryClauses.add(PROJECT.FEATURED_LABEL.containsIgnoreCase(q))
            queryClauses.add(INSTITUTION.NAME.containsIgnoreCase(q))
            queryClauses.add(PROJECT.FEATURED_OWNER.containsIgnoreCase(q))
            queryClauses.add(PROJECT.DESCRIPTION.containsIgnoreCase(q))
            queryClauses.add(PROJECT.SHORT_DESCRIPTION.containsIgnoreCase(q))

            def queryWhereClause = jOr(queryClauses)

            whereClauses += queryWhereClause
        }

        def sortCondition
        switch (sort) {
            case 'completed':
                sortCondition = jWhen(taskCountClause.eq(fullyTranscribedTaskCountClause), fullyTranscribedTaskCountClause.add(validatedCountClause).div(taskCountClause.cast(Double))).otherwise(fullyTranscribedTaskCountClause.div(taskCountClause.cast(Double)))
               break
            case 'transcribed':
                sortCondition = fullyTranscribedTaskCountClause.div(taskCountClause.cast(Double))
                break
            case 'validated':
                sortCondition = validatedCountClause.div(taskCountClause.cast(Double))
                break
            case 'institution':
                sortCondition = jNvl(INSTITUTION.NAME, PROJECT.FEATURED_OWNER)
                break
            case 'type':
                sortCondition = PROJECT_TYPE.LABEL
                break
            default:
                sortCondition = jLower(PROJECT.FEATURED_LABEL)
                break
        }

        def query = context.
                select(
                    PROJECT.ID,
                    PROJECT.NAME,
                    PROJECT.DESCRIPTION,
                    PROJECT.SHORT_DESCRIPTION,
                    PROJECT.FEATURED_LABEL,
                    PROJECT.FEATURED_OWNER,
                    PROJECT_TYPE.LABEL,
                    INSTITUTION.NAME.as('institution_name'),
                    jCount().over().as('full_count')
                ).select(taskJoinTable.fields()).
                from(fromClause).
                where(whereClauses).
                orderBy(sortCondition.sort(order == 'desc' ? SortOrder.DESC : SortOrder.ASC))
        if (offset && max) return query.offset(offset).limit(max)
        else if (offset) return query.offset(offset)
        else if (max) return query.limit(max)
        else return query
    }

    ProjectSummaryList getProjectSummaryList(GrailsParameterMap params) {

        def statusFilterMode = ProjectStatusFilterType.fromString(params?.statusFilter)
        def activeFilterMode = ProjectActiveFilterType.fromString(params?.activeFilter)

        def conditions
        if (userService.isAdmin()) {
            conditions = []
        } else {
            conditions = [ACTIVE_ONLY]
        }

        //params?.q, params?.sort, params?.int('offset') ?: 0, params?.int('max') ?: 0, params?.order
        def query = params?.q
        def tag = params?.tag
        def sort = params?.sort
        def offset = params?.int('offset')
        def max = params?.int('max')
        def order = params?.order

        return makeSummaryListFromConditions(conditions, tag, query, sort, offset, max, order, statusFilterMode, activeFilterMode)
    }

    ProjectSummaryList getProjectSummaryList(ProjectStatusFilterType statusFilter, ProjectActiveFilterType activeFilter, String q, String sort, int offset, int max, String order, ProjectType projectType = null) {
        def conditions = []
        if (projectType) {
            conditions += PROJECT.PROJECT_TYPE_ID.eq(projectType.id)
        }
        if (!userService.isAdmin()) {
            conditions += ACTIVE_ONLY
        }

//        def filter = ProjectSummaryFilter.composeProjectFilter(statusFilter, activeFilter)

        return makeSummaryListFromConditions(conditions, null, q, sort, offset, max, order, statusFilter, activeFilter)
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
            [(it.id) : projectSize(it)]
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
        Task.withCriteria{
            'in'('project', projects)
            projections {
                groupProperty('project')
                count('id', 'total')
                sqlProjection('(count(is_fully_transcribed) filter (where is_fully_transcribed = true)) as fullyTranscribed', ['fullyTranscribed'], [INTEGER])
                count('fullyValidatedBy', 'validated')
            }
        }.collectEntries { row ->
            [(row[0].id): [ total: row[1], transcribed: row[2], validated: row[3] ] ]
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
            transcriptions {
                isNotNull('fullyTranscribedBy')
                projections {
                    countDistinct('fullyTranscribedBy')
                }
            }
        }
    }

    def calculateStartAndEndTranscriptionDates(Project project) {
        def result = Task.createCriteria().list {
            eq('project', project)
            transcriptions {
                projections {
                    max('dateFullyTranscribed')
                    min('dateFullyTranscribed')
                }
            }
        }
        return result ? [start: result[0][1], end: result[0][0]] : null
    }

    def countTasksForTag(ProjectType pt) {

        Task.createCriteria().count {
            project {
                eq('projectType', pt)
            }
        }
    }

    def countTranscribedTasksForTag(ProjectType pt) {
        def result = Task.createCriteria().list {
            project {
                eq('projectType', pt)
            }
            projections {
                sqlProjection('(count(is_fully_transcribed) filter (where is_fully_transcribed = true)) as fullyTranscribed', ['fullyTranscribed'], [INTEGER])
            }
        }
        return result[0]
    }

    def getTranscriberCountForTag(ProjectType pt) {
        def result = Task.createCriteria().list {
            project {
                eq('projectType', pt)
            }
            transcriptions {
                isNotNull('fullyTranscribedBy')
            }
            projections {
                transcriptions {
                    countDistinct 'fullyTranscribedBy'
                }
            }
        }

        return result[0]
    }
}
