package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.events.EventPublisher
import grails.gorm.transactions.Transactional
import grails.web.mapping.LinkGenerator
import grails.web.servlet.mvc.GrailsParameterMap
import groovy.sql.Sql
import groovy.time.TimeCategory
import groovy.transform.Immutable
import groovyx.gpars.actor.Actors
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry
import org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream
import org.apache.commons.io.FileUtils
import org.hibernate.Session
import org.jooq.Condition
import org.jooq.DSLContext
import org.jooq.SortOrder
import org.jooq.impl.DSL
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.i18n.LocaleContextHolder

import javax.annotation.PreDestroy
import javax.imageio.ImageIO
import javax.sql.DataSource
import java.util.concurrent.ThreadLocalRandom

import static au.org.ala.volunteer.jooq.tables.ForumMessage.FORUM_MESSAGE
import static au.org.ala.volunteer.jooq.tables.ForumTopic.FORUM_TOPIC
import static au.org.ala.volunteer.jooq.tables.Institution.INSTITUTION
import static au.org.ala.volunteer.jooq.tables.Label.LABEL
import static au.org.ala.volunteer.jooq.tables.Project.PROJECT
import static au.org.ala.volunteer.jooq.tables.ProjectLabels.PROJECT_LABELS
import static au.org.ala.volunteer.jooq.tables.ProjectType.PROJECT_TYPE
import static au.org.ala.volunteer.jooq.tables.Task.TASK
import static au.org.ala.volunteer.jooq.tables.Transcription.TRANSCRIPTION
import static java.util.concurrent.TimeUnit.MILLISECONDS
import static org.apache.commons.compress.archivers.zip.Zip64Mode.AsNeeded
import static org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream.UnicodeExtraFieldPolicy.NOT_ENCODEABLE
import static org.jooq.impl.DSL.*
import static org.jooq.impl.DSL.count as jCount
import static org.jooq.impl.DSL.countDistinct as jCountDistinct
import static org.jooq.impl.DSL.lower as jLower
import static org.jooq.impl.DSL.nvl as jNvl
import static org.jooq.impl.DSL.or as jOr
import static org.jooq.impl.DSL.sum as jSum
import static org.jooq.impl.DSL.when as jWhen

@Transactional
class ProjectService implements EventPublisher {

    static final String TASK_COUNT_COLUMN = 'taskCount'
    static final String TRANSCRIBED_COUNT_COLUMN = 'transcribedCount'
    static final String VALIDATED_COUNT_COLUMN = 'validatedCount'
    static final String TRANSCRIBER_COUNT_COLUMN = 'transcriberCount'
    static final String VALIDATOR_COUNT_COLUMN = 'validatorCount'
    static final String NOTIFICATION_TYPE_ACTIVATION = 'activated'
    static final String NOTIFICATION_TYPE_COMPLETION = 'completed'

    // make a static factory function because I'm not sure whether
    // these are thread safe
    private static final Condition getACTIVE_ONLY() { PROJECT.INACTIVE.eq(false) | PROJECT.INACTIVE.isNull() }

    def userService
    DataSource dataSource
    LinkGenerator grailsLinkGenerator
    def projectTypeService
    def forumService
    def multimediaService
    def i18nService
    def grailsApplication
    def emailService
    def messageSource
    @Autowired
    Closure<DSLContext> jooqContextFactory

    def deleteTasksActor = Actors.actor {
        loop {
            react { DeleteTasksMessage msg ->

                log.info("Deleting tasks ${msg}")

                try {
                    Task.withNewSession { Session session ->
                        Project p = Project.get(msg.projectId)
                        def count = 0
                        def lastId = Long.MIN_VALUE
                        def tasks = Task.findAllByProject(p, [sort: 'id', order: 'asc', max: 100])
                        while (tasks) {
                            log.debug("Iterating, Deleting ${tasks.size()} tasks")
                            if (log.isDebugEnabled()) {
                                log.debug("Deleting tasks ${tasks*.id}")
                            }
                            for (Task task : tasks) {
                                lastId = task.id
                                try {
                                    if (msg.deleteImages) multimediaService.deleteAllMultimediaForTask(task)
                                    task.delete()
                                } catch (e) {
                                    log.error("Exception while deleting task ${task.id}: ${e.getMessage()}", e)
                                    throw e
                                }
                                count++
                                if (count % 25 == 0) {
                                    def msgData = [projectId: msg.projectId, count: count, complete: false]
                                    log.debug("notifying progress message data ${msgData}")
                                    notify(EventSourceService.NEW_MESSAGE, new Message.EventSourceMessage(to: msg.userId, event: 'deleteTasks', data: msgData))
                                }
                            }
                            tasks = Task.findAllByProjectAndIdGreaterThan(p, lastId, [sort: 'id', order: 'asc', max: 100])
                        }

                        // Reset disk usage to zero, as all tasks have been deleted.
                        p.sizeInBytes = 0

                        log.info("Completed deleting all tasks for ${msg.projectId}")

                        session.flush()
                        notify(EventSourceService.NEW_MESSAGE, new Message.EventSourceMessage(to: msg.userId, event: 'deleteTasks', data: [projectId: msg.projectId, count: count, complete: true]))
                    }
                } catch (e) {
                    log.error("Error encountered deleting tasks and/or images: ${e.getMessage()}", e)
                    notify(EventSourceService.NEW_MESSAGE, new Message.EventSourceMessage(to: msg.userId, event: 'deleteTasks', data: [projectId: msg.projectId, count: -1, error: e.message, complete: true]))
                }
            }
        }
    }

    @PreDestroy
    def shutdown() {
        deleteTasksActor.stop()
    }

    /**
     * Returns boolean if the user is an admin for the project or not.
     * @param project the project in question
     * @return true if user is admin, false if not.
     */
    def isAdminForProject(Project project) {
        if (!project) return false
        def currentUser = userService.currentUserId
        return currentUser != null && (userService.isSiteAdmin() || userService.isInstitutionAdmin(project?.institution))
    }

    @Transactional(readOnly = true)
    def harvestProjects() {
        def context = jooqContextFactory()

        def forumMessageCountQuery = DSL.
                select(count().filterWhere(condition(not(FORUM_MESSAGE.DELETED)) | FORUM_MESSAGE.DELETED.isNull()))
                .from(FORUM_TOPIC).join(FORUM_MESSAGE).on(FORUM_TOPIC.ID.eq(FORUM_MESSAGE.TOPIC_ID))
                .where(FORUM_TOPIC.CLASS.eq(ProjectForumTopic.class.name) & FORUM_TOPIC.PROJECT_ID.eq(PROJECT.ID))


        def records = context
                .select(PROJECT.ID, PROJECT.NAME, PROJECT.DESCRIPTION,
                        count(TASK.ID),
                        count().filterWhere(TASK.IS_FULLY_TRANSCRIBED),
                        count().filterWhere(TASK.IS_VALID),
                        forumMessageCountQuery.asField("forumMessageCount")
                )
                .from(PROJECT)
                .leftJoin(TASK).on(TASK.PROJECT_ID.eq(PROJECT.ID))
                .where(PROJECT.HARVESTABLE_BY_ALA)
                .groupBy(PROJECT.ID, PROJECT.NAME, PROJECT.DESCRIPTION)
                .fetch()

        def result = records.collect { record ->
            def id = record.value1()
            def name = record.value2()
            def description = record.value3()
            def taskCount = record.value4()
            def fullyTranscribedCount = record.value5()
            def fullyValidatedCount = record.value6()
            def forumMessageCount = record.value7()

            final link = grailsLinkGenerator.link(absolute: true, controller: 'project', action: 'index', id: id)
            final dataUrl = grailsLinkGenerator.link(absolute: true, controller:'ajax', action:'expeditionBiocacheData', id: id)

            def citation = i18nService.message("harvest.citation", '{0} digitised at {1} ({2})', [name, i18nService.message('default.application.name'), grailsLinkGenerator.link(uri: '/', absolute: true)])
            def licenseType = i18nService.message('harvest.license.type', 'Creative Commons Attribution Australia', [])
            def licenseVersion = i18nService.message('harvest.license.version', '3.0', [])

            [
                id: id,
                name: name,
                description: description,
                tasksCount: taskCount,
                tasksTranscribedCount: fullyTranscribedCount,
                tasksValidatedCount: fullyValidatedCount,
                expeditionHomePage: link,
                dataUrl: dataUrl,
                citation: citation,
                licenseType: licenseType,
                licenseVersion: licenseVersion,
                forumMessagesCount: forumMessageCount
            ]
        }

        result
    }

    def saveProject (Project projectInstance, boolean flush = true, boolean failOnError = null) {
        projectInstance.save(flush: flush, failOnError: failOnError)
    }

    def createProject(Project project) {
        def user = userService.getCurrentUser()

        try {
            // Set inactive and created by
            project.featuredLabel = project.name
            project.featuredOwner = project.institution.name
            project.inactive = true
            project.createdBy = user
            project.save(failOnError: true, flush: true)

            // sign the creator up for project forum topic notifications
            forumService.watchProject(user, project, true)
        } catch (Exception ex) {
            log.error("Unable to save Project: ${ex.getMessage()}", ex)
            return false
        }

        true
    }

    /**
     * Sends an email notification to the configured email with the included message. Project notifications are sent
     * to the configured address (notifications.project.address).
     * @param projectInstance the instance of the project affected
     * @param message the message being sent.
     */
    def emailNotification(Project projectInstance, String message, String type = NOTIFICATION_TYPE_ACTIVATION) {
        // Send email to grailsApplication.config.notifications.project.address
        log.debug("Sending project notification")
        def appName = messageSource.getMessage("default.application.name", null, "DigiVol", LocaleContextHolder.locale)
        def projectLabel = messageSource.getMessage("project.name.label", null, "Project", LocaleContextHolder.locale)
        emailService.sendMail(grailsApplication.config.notifications.project.address, "${appName} ${projectLabel} ${type}: ${projectInstance.name}", message)
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
            return
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

    public List<ProjectSummary>  getFeaturedProjectList() {

        Stopwatch sw = Stopwatch.createStarted()
        def resultMaps = generateProjectSummariesQuery(jooqContextFactory(), [], null, null, 'transcribed', null, null, null, ProjectStatusFilterType.showIncompleteOnly, ProjectActiveFilterType.showActiveOnly, false).fetchMaps()

        if (resultMaps.size() == 0) return []

        def projectIds = resultMaps.collect { it['id'] }
        def projects = Project.findAllByIdInList(projectIds)
        def projectsMap = projects.collectEntries { [(it.id): it] }

        def results = resultMaps.collect { result ->
            def project = projectsMap[result['id']]
            def taskCount = result[TASK_COUNT_COLUMN] ?: 0
            def transcribedCount = result[TRANSCRIBED_COUNT_COLUMN] ?: 0
            def validatedCount = result[VALIDATED_COUNT_COLUMN] ?: 0
            makeProjectSummary(project, taskCount, transcribedCount, validatedCount,0, 0)
        }

        log.debug("make summary projects: ${sw.elapsed(MILLISECONDS)}ms")
        sw.reset().start()

        return results
    }

    private static ProjectType guessProjectType(Project project) {
        def viewName = project.template.viewName.toLowerCase()

        if (viewName.contains("journal") || viewName.contains("fieldnotebook") || viewName.contains("observationDiary")) {
            return ProjectType.findByName(ProjectType.PROJECT_TYPE_FIELDNOTES)
        } else if (viewName.contains('camera trap') || viewName.contains('wild count') || viewName.contains('wildcount')) {
            return ProjectType.findByName(ProjectType.PROJECT_TYPE_CAMERATRAP)
        }

        return ProjectType.findByName(ProjectType.PROJECT_TYPE_SPECIMEN)
    }

    private ProjectSummary makeProjectSummary(Project project, Number taskCount, Number transcribedCount, Number fullyValidatedCount, Number transcriberCount, Number validatorCount) {

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
        ps.transcriberCount = transcriberCount.toLong()
        ps.validatedCount = fullyValidatedCount.toLong()

        return ps
    }

    def makeSummaryListForInstitution(Institution institution, String tag, String q, String sort, Integer offset, Integer max, String order, ProjectStatusFilterType statusFilter, ProjectActiveFilterType activeFilter) {
        def conditions = [PROJECT.INSTITUTION_ID.eq(institution.id)]
        if (!userService.isSiteAdmin() && !userService.isInstitutionAdmin(institution)) {
            conditions += ACTIVE_ONLY
        }
        makeSummaryListFromConditions(conditions, tag, q, sort, offset, max, order, statusFilter, activeFilter, false)
    }

    private def makeSummaryListFromConditions(Collection<? extends Condition> conditions, def tag, String q, String sort, Integer offset, Integer max, String order, ProjectStatusFilterType statusFilter, ProjectActiveFilterType activeFilter, boolean countUser) {
        def results = generateProjectSummariesQuery(jooqContextFactory(), conditions, tag, q, sort, offset, max, order, statusFilter, activeFilter, countUser).fetchMaps()
        if (!results) {
            return makeSummaryListFromResults(results, [])
        }
        def projects = Project.findAllByIdInList(results.collect { it['id'] })
        return makeSummaryListFromResults(results, projects)
    }

    def makeSummaryListFromProjectList(List<Project> projects, String tag, String q, String sort, Integer offset, Integer max, String order, ProjectStatusFilterType statusFilter, ProjectActiveFilterType activeFilter, boolean countUser) {
        if (!projects) {
            return makeSummaryListFromResults([], [])
        }
        def results = generateProjectSummariesQuery(jooqContextFactory(), [PROJECT.ID.in(projects*.id)], tag, q, sort, offset, max, order, statusFilter, activeFilter, countUser).fetchMaps()
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
            def transcriberCount = result[TRANSCRIBER_COUNT_COLUMN] ?: 0
            def validatorCount = result[VALIDATOR_COUNT_COLUMN] ?: 0
            totalCount = result['full_count']
            if (transcribedCount < taskCount && !project.inactive) {
                incompleteCount++
            }
            makeProjectSummary(project, taskCount, transcribedCount, validatedCount, transcriberCount, validatorCount)
        }
        new ProjectSummaryList(
                projectRenderList: renderList,
                numberOfIncompleteProjects: incompleteCount,
                matchingProjectCount: totalCount
        )
    }

    private def generateProjectSummariesQuery(DSLContext context, Collection<? extends Condition> whereClauses, def tag, String q, String sort, Integer offset, Integer max, String order, ProjectStatusFilterType statusFilter, ProjectActiveFilterType activeFilter, boolean countUsers) {

        switch (activeFilter) {
            case ProjectActiveFilterType.showActiveOnly:
                whereClauses += ACTIVE_ONLY
                break
            case ProjectActiveFilterType.showInactiveOnly:
                whereClauses += PROJECT.INACTIVE.eq(true)
                break
            case ProjectActiveFilterType.showArchivedOnly:
                // Note CD: removed static declaration off method to do this. I couldn't find any reason
                // for it to remain static...
                // This option is only given to Admins and IA's. IA's should only see their institutions archived projects.
                if (!userService.isAdmin()) {
                    log.debug("Project summary, Not an admin but has institution admin...")
                    def institutionAdminList = userService.getAdminInstitutionList()
                    def institutionAdminClause = [PROJECT.ARCHIVED.eq(true), PROJECT.INSTITUTION_ID.in(institutionAdminList*.id)]
                    whereClauses += institutionAdminClause
                } else {
                    whereClauses += PROJECT.ARCHIVED.eq(true)
                }
                break
        }

        def taskCountClause = jCount(TASK).'as'(TASK_COUNT_COLUMN)

        def fullyTranscribedTaskCountClause = jCount(TASK.IS_FULLY_TRANSCRIBED).filterWhere(TASK.IS_FULLY_TRANSCRIBED.eq(true)).'as'(TRANSCRIBED_COUNT_COLUMN)
        def validatedCountClause = jSum(jWhen(TASK.FULLY_VALIDATED_BY.isNull(), 0).otherwise(1)).'as'(VALIDATED_COUNT_COLUMN)
        def validatorCountClause = jCountDistinct(TASK.FULLY_VALIDATED_BY).'as'(VALIDATOR_COUNT_COLUMN)
        def transcriberCountClause = jCountDistinct(TRANSCRIPTION.FULLY_TRANSCRIBED_BY).'as'(TRANSCRIBER_COUNT_COLUMN)

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
        def taskJoinTable
        if (countUsers) {
            taskJoinTableColumns.add(transcriberCountClause)
            taskJoinTableColumns.add(validatorCountClause)
            taskJoinTable = context.select(taskJoinTableColumns).from(TASK.leftOuterJoin(TRANSCRIPTION).on(TASK.ID.eq(TRANSCRIPTION.TASK_ID))).groupBy(TASK.PROJECT_ID).asTable('taskStats')
        } else {
            taskJoinTable = context.select(taskJoinTableColumns).from(TASK).groupBy(TASK.PROJECT_ID).asTable('taskStats')
        }

       // def taskJoinTable = context.select(taskJoinTableColumns).from(TASK).groupBy(TASK.PROJECT_ID).asTable('taskStats')

        def fromClause = PROJECT.leftOuterJoin(PROJECT_TYPE).onKey()
                                .leftOuterJoin(INSTITUTION).onKey()
                                .leftOuterJoin(taskJoinTable).on(PROJECT.ID.eq(taskJoinTable.field(0, Long)))

        // apply the query paramter
        if (tag) {
            // #392 Add Project Type to the tag search (i.e. clicking on Project Type searches by 'tag')
            def tagSearch = []
            def labelJoinTable = context.select([PROJECT_LABELS.PROJECT_ID]).from(PROJECT_LABELS.leftJoin(LABEL).on(PROJECT_LABELS.LABEL_ID.eq(LABEL.ID))).where(LABEL.VALUE.in(tag))
            def typeJoinTable = context.select([PROJECT.ID]).from(PROJECT.leftJoin(PROJECT_TYPE).on(PROJECT.PROJECT_TYPE_ID.eq(PROJECT_TYPE.ID))).where(PROJECT_TYPE.LABEL.in(tag))

            tagSearch.add(PROJECT.ID.in(labelJoinTable))
            tagSearch.add(PROJECT.ID.in(typeJoinTable))

            whereClauses += jOr(tagSearch)
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
            case 'volunteers':
                if (!countUsers) throw new IllegalStateException("Can't sort by volunteer count when counting users is disabled")
                sortCondition = transcriberCountClause
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
                orderBy(coalesce(PROJECT.INACTIVE, false).sort(SortOrder.ASC),
                        sortCondition.sort(order == 'desc' ? SortOrder.DESC : SortOrder.ASC))
        if (offset && max) return query.offset(offset).limit(max)
        else if (offset) return query.offset(offset)
        else if (max) return query.limit(max)
        else return query
    }

    ProjectSummaryList getProjectSummaryList(GrailsParameterMap params, boolean countUser) {

        def statusFilterMode = ProjectStatusFilterType.fromString(params?.statusFilter)
        def activeFilterMode = ProjectActiveFilterType.fromString(params?.activeFilter)

        def conditions
        if (userService.isAdmin()) {
            conditions = []
        } else {
            //conditions = [ACTIVE_ONLY]
            if (userService.isInstitutionAdmin()) {
                log.debug("Project summary, Not an admin but has institution admin...")
                def institutionAdminList = userService.getAdminInstitutionList()
                def institutionAdminClause = [ACTIVE_ONLY, PROJECT.INSTITUTION_ID.in(institutionAdminList*.id)]
                conditions = [jOr(institutionAdminClause)]
            } else {
                conditions = [ACTIVE_ONLY]
            }
        }

        //params?.q, params?.sort, params?.int('offset') ?: 0, params?.int('max') ?: 0, params?.order
        def query = params?.q
        def tag = params?.tag
        def sort = params?.sort
        def offset = params?.int('offset')
        def max = params?.int('max')
        def order = params?.order

        return makeSummaryListFromConditions(conditions, tag, query, sort, offset, max, order, statusFilterMode, activeFilterMode, countUser)
    }

    // used by customLandingPage or wildLifeSpotter
    ProjectSummaryList getProjectSummaryList(ProjectStatusFilterType statusFilter, ProjectActiveFilterType activeFilter, String q, String sort, int offset, int max, String order, ProjectType projectType = null, def tag = null, boolean countUser = false) {
        def conditions = []
        if (projectType) {
            conditions += PROJECT.PROJECT_TYPE_ID.eq(projectType.id)
        }
        if (!userService.isAdmin()) {
            if (userService.isInstitutionAdmin()) {
                log.debug("Project summary, Not an admin but has institution admin...")
                def institutionAdminList = userService.getAdminInstitutionList()
                def institutionAdminClause = [ACTIVE_ONLY, PROJECT.INSTITUTION_ID.in(institutionAdminList*.id)]
                conditions += jOr(institutionAdminClause)
            } else {
                conditions += ACTIVE_ONLY
            }
        }

//        def filter = ProjectSummaryFilter.composeProjectFilter(statusFilter, activeFilter)

        return makeSummaryListFromConditions(conditions, tag, q, sort, offset, max, order, statusFilter, activeFilter, countUser)
    }

    def checkAndResizeExpeditionImage(Project projectInstance) {
        try {
            def filePath = "${grailsApplication.config.images.home}/project/${projectInstance.id}/expedition-image.jpg"
            def file = new File(filePath)
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
            long sizeInBytes = projectPath.directorySize()
            project.sizeInBytes = sizeInBytes
            project.save(flush: true, failOnError: true)
            [size: sizeInBytes, error: null]
        } catch (e) {
            log.warn("ProjectService was unable to calculate project path directory size (possibly already archived?): ${e.message}")
            [error: e, size: -1]
        }
    }

    def imageStoreStats() {
        final f = new File(grailsApplication.config.images.home)
        [total: f.totalSpace, free: f.freeSpace, usable: f.usableSpace]
    }

    def calculateCompletion(List<Project> projects) {
        if (projects?.size() > 0) {
            Task.withCriteria {
                'in'('project', projects)
                projections {
                    groupProperty('project')
                    count('id', 'total')
                    sqlProjection('(count(is_fully_transcribed) filter (where is_fully_transcribed = true)) as fullyTranscribed', ['fullyTranscribed'], [INTEGER])
                    count('fullyValidatedBy', 'validated')
                }
            }.collectEntries { row ->
                [(row[0].id): [total: row[1], transcribed: row[2], validated: row[3]]]
            }
        } else {
            [:]
        }
    }

    /**
     * Checks if the current project is complete. Returns true if all tasks have been transcribed. Returns false if
     * not or the project parameter is null.
     * @param project The project to check
     * @return true if project has been completed, false if not.
     */
    def isProjectComplete(Project project) {
        if (!project) {
            return true
        } else {
            def projectMap = calculateCompletion([project])
            final projectCounts = projectMap[project.id]
            if (projectCounts) {
                def transcribed = (projectCounts.transcribed / projectCounts.total) * 100.0
                return (transcribed == 100)
            }
        }

        return false
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

    /**
     * Archives project by deleting all images stored under the project ID, sets the archive flag to true
     * and the inactive flag to true.
     * @param project the project to archive.
     * @throws IOException if no images or directory found for the project.
     */
    def archiveProject(Project project) {
        final projectPath = new File(grailsApplication.config.images.home, project.id.toString())
        def result = projectPath.deleteDir()
        if (!result) {
            log.warn("Couldn't delete images for $project")
            throw new IOException("Couldn't delete images for $project")
        } else {
            log.info("Archived project (from service): ${project.name} [${project.id}]")
            project.archived = true
            project.inactive = true
            project.save(flush: true, failOnError: true)
        }
    }

    def cloneProject(Project sourceProject, String newName) {
        def newProject = new Project(name: newName, featuredLabel: newName, inactive: true,
                createdBy: userService.getCurrentUser())

        def cloneableFields = Project.getCloneableFields()
        cloneableFields.each { field ->
            newProject."${field}" = sourceProject."${field}"
            log.debug("Source value: " + sourceProject."${field}")
            log.debug("New value: " + newProject."${field}")
        }

        def sourceLabels = sourceProject.labels
        sourceLabels.each { Label label ->
            newProject.addToLabels(label)
        }

        newProject.save(failOnError: true, flush: true)

        return newProject
    }

    static def addToZip(ZipArchiveOutputStream zos, File path, String entryPath) {
        String entryName = entryPath + path.getName()

        if (path.isFile()) {
            ZipArchiveEntry zipEntry = new ZipArchiveEntry(path, entryName)
            zos.putArchiveEntry(zipEntry)
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

    def countTasksForTag(def projectsInLabels = null) {

        if (projectsInLabels?.size() > 0) {
            Task.createCriteria().count {
                project {
                    'in' 'id', projectsInLabels
                }
            }
        } else {
            return 0
        }
    }

    def countTranscribedTasksForTag(def projectsInLabels = null) {

        if (projectsInLabels?.size() > 0) {
            def result = Task.createCriteria().list {
                if (projectsInLabels) {
                    project {
                        'in' 'id', projectsInLabels
                    }
                }
                projections {
                    sqlProjection('(count(is_fully_transcribed) filter (where is_fully_transcribed = true)) as fullyTranscribed', ['fullyTranscribed'], [INTEGER])
                }
            }
            return result[0]
        } else {
            return 0
        }
    }

    /**
     * @deprecated countDistinct projection for createCriteria() clashes with Jooq. Moved this method to
     * VolunteerStatsService.
     * @param projectsInLabels
     * @return
     */
    def getTranscriberCountForTag(def projectsInLabels = null) {

        if (projectsInLabels?.size() > 0) {
            def result = Task.createCriteria().list {
                if (projectsInLabels) {
                    project {
                        'in' 'id', projectsInLabels
                    }
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
        } else {
            return 0
        }
    }

    /**
     * Randomly select a project from active, non-archived projects. Only selects from projects that have not been
     * perviously selected in the last 5 days (to prevent frequent reselection) and is less than 90% completed.
     *
     * @return the randomly selected project. If no active, unarchived projects exist, return null.
     */
    def selectRandomProject() {
        def startDate = null
        def endDate = new Date()
        use(TimeCategory) {
            startDate = endDate - 5.days
        }
        if (!startDate) startDate = new Date()
        log.debug("Random project selection time frame: ${startDate}")

        def query = """\
            select p.id,
                   sum(case when ta.is_fully_transcribed = true then 1 else 0 end) as transcribed, 
                   sum(case when ta.fully_validated_by is not null then 1 else 0 end) as validated,
                   count(ta.id) as total_tasks,
                   (100.0*(cast(sum(case when ta.is_fully_transcribed = true then 1 else 0 end) as decimal(7,2)) / count(ta.id))) as completion
              from project p
              join task ta on (ta.project_id = p.id)
            where p.archived = false
              and p.inactive = false
              and (p.potd_last_selected <= :startDate or p.potd_last_selected is null)
            group by p.id, name
            having sum(case when ta.fully_validated_by is not null then 1 else 0 end) < count(ta.id) """.stripIndent()

        def sql = new Sql(dataSource)
        def projectList = []
        def backupList = []
        def results = sql.rows(query, [startDate: startDate.toTimestamp()])

        if (results.size() > 0) {
            results.each { row ->
                Project project = Project.get(row.id as long)
                if (project && row.completion < 100.0) projectList.add(project)
                else if (project) backupList.add(project)
            }
        }

        log.debug("Project Lists to choose from: projectList: ${projectList.size()}")
        log.debug("Project Lists to choose from: backupList: ${backupList.size()}")

        // Backup checking. If there are no projects that are open and yet to be transcribed, use the
        // backup list (projects needing validation). If that list is empty, just grab the list of projects.
        if (projectList.size() == 0 && backupList.size() > 0) {
            log.debug("Project list is empty, going to backupList")
            projectList = backupList
        } else if (projectList.size() == 0 && backupList.size() == 0) {
            log.debug("No projects to choose from, getting any project")
            projectList = Project.createCriteria().list {
                and {
                    eq('archived', false)
                    eq('inactive', false)
                    or {
                        lt('potdLastSelected', startDate)
                        isNull('potdLastSelected')
                    }
                }
            } as List
            log.debug("Projects list: ${projectList.size()}")
        }

        Project projectToDisplay = null
        if (projectList.size() > 1) {
            // Randomly select a project from the list.
            int randomIndex = ThreadLocalRandom.current().nextInt(0, ((projectList.size() - 1) > 0 ? projectList.size() - 1 : 1))
            projectToDisplay = projectList.get(randomIndex) as Project
        } else if (projectList.size() == 1) {
            projectToDisplay = projectList.first() as Project
        }

        if (projectToDisplay) {
            log.debug("Project selected: ${projectToDisplay}")
            projectToDisplay.potdLastSelected = new Date()
            projectToDisplay.save(failOnError: true, flush: true)
        }

        sql.close()

        return projectToDisplay.id
    }

    /**
     * Determines if the difference between the current datetime is a time that allows for a new random project to be
     * selected.
     * @param randomProjectDateUpdated the last datetime the random project was updated.
     * @return
     */
    def isTimeToUpdateRandomProject(Date randomProjectDateUpdated) {
        def currentDate = new Date().getAt(Calendar.DAY_OF_YEAR)
        if (!randomProjectDateUpdated) return true
        def lastDate = randomProjectDateUpdated.getAt(Calendar.DAY_OF_YEAR)
        // If we've gone over to the next year, return true.
        if (currentDate < lastDate) return true
        return currentDate - lastDate >= 1
    }

    /**
     * Intended to be called from index page, checks if time to update the project of the day. If so, gets a new
     * project and updates the frontpage parameter.
     * @param frontPage The front page details.
     */
    def checkProjectOfTheDay(FrontPage frontPage) {
        log.debug("Checking if it's time to change the PotD")
        if (isTimeToUpdateRandomProject(frontPage.randomProjectDateUpdated) ||
                isProjectComplete(frontPage.projectOfTheDay)) {
            log.debug("Yes, updating PotD...")
            def projectId = selectRandomProject()
            def project = Project.get(projectId)
            if (project) {
                log.debug("New PotD: ${project}")
                frontPage.projectOfTheDay = project
                frontPage.randomProjectDateUpdated = new Date()
                frontPage.save(failOnError: true, flush: true)
            }
            return frontPage.projectOfTheDay
        } else {
            log.debug("Using existing PotD: ${frontPage.projectOfTheDay}")
            return frontPage.projectOfTheDay
        }
    }

    /**
     * Saves the uploaded background image or deletes the existing one if argument is null.  Consumes the inputstream
     * but doesn't close it
     * @param multipartFile
     */
    void setBackgroundImage(Project project, InputStream inputStream, String contentType) {
        if (!project) {
            throw new IllegalArgumentException("Set background image - project must be provided")
        }

        if (inputStream && contentType) {
            // Save image
            String fileExtension = contentType == 'image/png' ? 'png' : 'jpg'
            def filePath = "${grailsApplication.config.images.home}/project/${project.id}/expedition-background-image.${fileExtension}"
            def file = new File(filePath)
            file.getParentFile().mkdirs()
            file.withOutputStream {
                it << inputStream
            }
        } else {
            // Remove image if exists
            String localPathJpg = "${grailsApplication.config.images.home}/project/${project.id}/expedition-background-image.jpg"
            String localPathPng = "${grailsApplication.config.images.home}/project/${project.id}/expedition-background-image.png"
            File fileJpg = new File(localPathJpg)
            File filePng = new File(localPathPng)
            if (fileJpg.exists()) {
                fileJpg.delete()
            } else if (filePng.exists()) {
                filePng.delete()
            }
        }
    }

    /**
     * Retrieves background image url
     * @return background image url or null if non existent
     */
    String getBackgroundImage(Project project) {
        if (!project) return null

        String localPath = "${grailsApplication.config.images.home}/project/${project.id}/expedition-background-image"
        String localPathJpg = "${localPath}.jpg"
        String localPathPng = "${localPath}.png"
        File fileJpg = new File(localPathJpg)
        File filePng = new File(localPathPng)

        if (fileJpg.exists()) {
            return "${grailsApplication.config.server.url}${grailsApplication.config.images.urlPrefix}project/${project.id}/expedition-background-image.jpg"
        } else if (filePng.exists()) {
            return "${grailsApplication.config.server.url}${grailsApplication.config.images.urlPrefix}project/${project.id}/expedition-background-image.png"
        } else {
            return null
        }
    }

    /**
     * Gets the projects featured image url.
     * @param project the project to search
     * @return the String url of the image file or a default base image if none exists. Returns null if project is not provided.
     */
    String getFeaturedImage(Project project) {
        if (!project) return null
        // Check to see if there is a feature image for this expedition by looking in its project directory.
        // If one exists, use it, otherwise use a default image...
        def localPath = "${grailsApplication.config.images.home}/project/${project.id}/expedition-image.jpg"
        def file = new File(localPath)
        if (!file.exists()) {
            return grailsLinkGenerator.resource(file: '/banners/default-expedition-large.jpg')
        } else {
            def urlPrefix = grailsApplication.config.images.urlPrefix
            def infix = urlPrefix.endsWith('/') ? '' : '/'
            return "${grailsApplication.config.server.url}/${urlPrefix}${infix}project/${project.id}/expedition-image.jpg"
        }
    }
}
