package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.gorm.DetachedCriteria
import grails.gorm.transactions.Transactional
import grails.plugin.cache.Cacheable
import groovy.sql.Sql

import javax.annotation.PostConstruct
import javax.sql.DataSource

import static java.util.concurrent.TimeUnit.MILLISECONDS
import grails.web.mapping.LinkGenerator

@Transactional
class VolunteerStatsService {

    DataSource dataSource
    def multimediaService
    def userService
    def leaderBoardService
    def institutionService
    def projectService
    LinkGenerator grailsLinkGenerator

    /**
     * Generates a map of stats info, including total transcribers and leaderboard (daily/weekly/monthly)
     *
     * @param institutionId optional institution
     * @param projectId optional project
     * @param projectTypeName optional project type
     * @param tags optional tags to filter on
     * @param maxContributors the maximum number of transcribers to
     * @param disableStats flag whether stats has been disabled
     * @param disableHonourBoard flag whether honour board has been disabled
     * @return transcriber stats on the given parameters
     */
    @Cacheable(value = 'MainVolunteerStats', key = { "${institutionId?.toString() ?: '-1'}-${projectTypeName ?: ''}-${tags?.toString() ?: '[]'}-${disableStats?.toString()}-${disableHonourBoard?.toString()}" })
    def generateStats(long institutionId, String projectTypeName, List<String> tags, boolean disableStats, boolean disableHonourBoard) {
        Institution institution = (institutionId == -1l) ? null : Institution.get(institutionId)

        String projectTempTable = null

        def sw = Stopwatch.createStarted()
        log.debug("Generating stats for inst id $institutionId, disableStats: $disableStats, disableHB: $disableHonourBoard, projectType: $projectTypeName")

        def totalTasks
        def completedTasks
        def transcriberCount

        if (disableStats) {
            log.debug("Stats are disabled")
            totalTasks = 0
            completedTasks = 0
            transcriberCount = 0
        } else if (institution) {
            log.debug("Getting institution stats for [${institution.name}]")
            totalTasks = institutionService.countTasksForInstitution(institution)
            completedTasks = institutionService.countTranscribedTasksForInstitution(institution)
            transcriberCount = institutionService.getTranscriberCount(institution)
        } else if (tags || projectTypeName) {
            log.debug("Getting tag/project type stats for [tags: ${tags}, projectTypeName: ${projectTypeName}]")
            def stats = getStatsForProjects(tags, projectTypeName)
            totalTasks = stats.tasks
            completedTasks = stats.transcriptions
            transcriberCount = stats.transcribers
            projectTempTable = stats.projectTempTable

        } else { // TODO Project stats, not needed for v2.3
            log.debug("Getting full site stats")
            totalTasks = Task.count()
            completedTasks = Task.countByIsFullyTranscribed(true) //Transcription.countByFullyTranscribedByIsNotNull()
            transcriberCount = User.countByTranscribedCountGreaterThan(0)
        }

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to generate volunteer-stats section")

        sw.reset().start()

        def daily
        def weekly
        def monthly
        def alltime

        if (disableHonourBoard) {
            daily = weekly = monthly = alltime = LeaderBoardService.EMPTY_LEADERBOARD_WINNER
        } else { // TODO Project honour board, not needed for v2.3
            daily = leaderBoardService.winner(LeaderBoardCategory.daily, institution, /*projectsInLabels*/ projectTempTable)
            weekly = leaderBoardService.winner(LeaderBoardCategory.weekly, institution, projectTempTable)
            monthly = leaderBoardService.winner(LeaderBoardCategory.monthly, institution, projectTempTable)
            alltime = leaderBoardService.winner(LeaderBoardCategory.alltime, institution, projectTempTable)
        }

        // Encode the email addresses for gravatar before sending to the client to prevent
        // the client having access to the user's email address info
        [daily, weekly, monthly, alltime].each { it.email = it.email?.toLowerCase()?.encodeAsMD5() }

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to generate honour board section")

        cleanUpTables(projectTempTable)

        ['totalTasks': totalTasks, 'completedTasks': completedTasks, 'transcriberCount': transcriberCount,
         daily: daily, weekly: weekly, monthly: monthly, alltime: alltime]
    }

    /**
     * Collects forum post information for a given project or institution
     *
     * @param institutionId the optional institution
     * @param projectId the optional project
     * @param maxPosts the maximum number of posts to collect
     * @return a list of contributors and their forum posts
     */
    def generateForumPosts(long institutionId, long projectId, int maxPosts) {
        def messages = getForumActivity(institutionId, projectId, maxPosts)
        def contributors = messages.sort { -it.timestamp }.take(maxPosts)
        return [contributors: contributors]
    }

    /**
     * Retrieves and collates forum activity for a given institution, project or all forums.
     *
     * @param institutionId optional institution
     * @param projectId optional project
     * @param maxPosts maximum number of posts to collect
     * @return a map containing forum posts
     */
    def getForumActivity(Long institutionId, Long projectId, Integer maxPosts) {
        Institution institution = (institutionId == -1l) ? null : Institution.get(institutionId)
        Project project = (projectId == -1l) ? null : Project.get(projectId)

        def latestMessages

        if (institution) {
            latestMessages = ForumMessage.findAll('FROM ForumMessage fm WHERE fm.topic.project.institution = :institution ORDER BY date desc', [institution: institution], [max: maxPosts])
            latestMessages += ForumMessage.findAll('FROM ForumMessage fm WHERE fm.topic.task.project.institution = :institution ORDER BY date desc', [institution: institution], [max: maxPosts])
        } else if (project) {
            latestMessages = ForumMessage.withCriteria {
                or {
                    'in'('topic', new DetachedCriteria(ProjectForumTopic).build {
                        eq('project', project)
                        projections {
                            property('id')
                        }
                    })
                    'in'('topic', new DetachedCriteria(TaskForumTopic).build {
                        task {
                            eq('project', project)
                        }
                        projections {
                            property('id')
                        }
                    })
                }
                order('date', 'desc')
                maxResults(maxPosts)
            }
        } else {
            latestMessages = ForumMessage.withCriteria {
                order('date', 'desc')
                maxResults(maxPosts)
            }
        }

        def userDetails = userService.detailsForUserIds(latestMessages*.user*.userId).collectEntries { [(it.userId): it] }
        def messages = latestMessages.collect {
            def topic = it.topic
            def topicId = topic.id
            def details = userDetails[it.user.userId]
            def timestamp = it.date.time / 1000
            def topicUrl = grailsLinkGenerator.link(controller: 'forum', action: 'viewForumTopic', id: topic.id)

            def forumName
            def forumUrl
            def thumbnail = null

            if (topic instanceof ProjectForumTopic) {
                def forumProject = ((ProjectForumTopic) topic).project
                forumName = forumProject.name
                thumbnail = projectService.getFeaturedImage(forumProject)
                forumUrl = grailsLinkGenerator.link(controller: 'forum', action: 'projectForum', params: [projectId: forumProject.id])
            } else if (topic instanceof TaskForumTopic) {
                def task = ((TaskForumTopic) topic).task
                forumName = task.project.name
                thumbnail = multimediaService.getImageThumbnailUrl(task.multimedia?.first())
                forumUrl = grailsLinkGenerator.link(controller: 'forum', action: 'projectForum', params: [projectId: task.project.id, selectedTab: 1])
            } else {
                forumName = "General Discussion"
                forumUrl = grailsLinkGenerator.link(controller: 'forum', action: 'index', params: [selectedTab: 1])
            }

            [type        : 'forum',
             topicId     : topicId,
             topicUrl    : topicUrl,
             forumName   : forumName,
             forumUrl    : forumUrl,
             userId      : it.userId,
             displayName : details?.displayName,
             email       : details?.email?.toLowerCase()?.encodeAsMD5(),
             thumbnailUrl: thumbnail,
             timestamp   : timestamp]
        }

        return messages
    }

    /**
     * Retrieves and collects information from {@link #getContributors(Institution, Project, List<Long>, Integer, String)}
     *
     * @param institutionId optional institution filter
     * @param projectId optional project filter
     * @param projectTypeName optional project type filter
     * @param tags tag filter
     * @param maxContributors maximum number of contributors to collect
     * @return a map containing the contribution information.
     */
    @Cacheable(value = 'MainVolunteerContribution', key = { "${institutionId?.toString() ?: '-1'}-${projectId?.toString() ?: '-1'}-${projectTypeName ?: ''}-${tags?.toString() ?: '[]'}-${maxContributors?.toString()}" })
    def generateContributors(long institutionId, long projectId, String projectTypeName, List<String> tags, int maxContributors) {
        Institution institution = (institutionId == -1l) ? null : Institution.get(institutionId)
        Project projectInstance = (projectId == -1l) ? null : Project.get(projectId)

        String tempTableName = ""
        def projectList = []

        if (projectTypeName || tags) {
            tempTableName = 'stats_projects_for_contributors'
            projectList = getProjectsForLabels(tempTableName, tags, projectTypeName)
        }

        List<LinkedHashMap<String, Serializable>> contributors = getContributors(institution, projectInstance, projectList, maxContributors, tempTableName)
        cleanUpTables(tempTableName)

        [contributors: contributors]
    }

    /**
     * Collects a list of contributions from transcribers, including transcriptions AND forum posts. Can be filtered
     * on institution, project, project type or tag.
     *
     * @param institution optional institution filter
     * @param projectInstance optional project filter
     * @param projectIds optional project ID list
     * @param maxContributors maximum number of contributors to collect
     * @param projectTempTable collation table containing data
     * @return a map of contributors containing information on their activity
     */
    def getContributors(Institution institution, Project projectInstance, List<Long> projectIds, Integer maxContributors, String projectTempTable) {
        def sw = Stopwatch.createStarted()

        def latestTranscribers = []
        if (projectTempTable) {
            def projectJoin = ""
            if (projectIds) {
                projectJoin = " join ${projectTempTable} on (${projectTempTable}.project_id = latest_transcribers.project_id) "
            }
            def query = """\
                select latest_transcribers.project_id,
                    fully_transcribed_by,
                    max_date
                from latest_transcribers
                ${projectJoin}
                order by max_date desc
                limit ${maxContributors} """.stripIndent()

            def sql = new Sql(dataSource)
            sql.eachRow(query) { row ->
                latestTranscribers.add(LatestTranscribers.findByFullyTranscribedByAndMaxDate(row.fully_transcribed_by as String, (row.max_date as Date).toTimestamp()))
            }
            sql.close()
        } else {
            latestTranscribers = LatestTranscribers.withCriteria {
                if (institution) {
                    project {
                        eq('institution', institution)
                        ne('inactive', true)
                    }
                } else if (projectInstance) {
                    eq('project', projectInstance)
                } else {
                    project {
                        ne('inactive', true)
                    }
                }
                order('maxDate', 'desc')
                maxResults(maxContributors)
            }
        }

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to collect latest transcribers")
        sw.reset().start()

        def messages = getForumActivity(institution?.id, projectInstance?.id, maxContributors)
        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to compile message details")
        sw.reset().start()

        def userDetails = userService.detailsForUserIds(latestTranscribers*.fullyTranscribedBy).collectEntries { [(it.userId): it] }
        def transcribers = latestTranscribers.collect {

            def proj = it.project
            def userId = it.fullyTranscribedBy
            def details = userDetails[userId]


            def tasks = LatestTranscribersTask.withCriteria() {
                eq('project', proj)
                eq('fullyTranscribedBy', userId)
                order('dateFullyTranscribed', 'desc')
            }

            def sw2 = Stopwatch.createStarted()
            def thumbnailLists = (tasks && (tasks.size() > 0)) ? tasks.subList(0, (tasks.size() < 5)? tasks.size(): 5): []
            log.debug("Took ${sw2.stop().elapsed(MILLISECONDS)}ms to get transcriber thumbnailLists for user ${userId}")

            sw2.reset().start()
            def thumbnails = thumbnailLists.collect { LatestTranscribersTask t ->
                def task = Task.findById (t.taskId)
                [id: t.id, thumbnailUrl: multimediaService.getImageThumbnailUrl(task.multimedia?.first())]
            }
            log.debug("Took ${sw2.stop().elapsed(MILLISECONDS)}ms to compile thumbnail info for user ${userId}")

            [type: 'task',
             projectId: proj.id,
             projectName: proj.name,
             projectType: proj.projectType.name,
             userId: User.findByUserId(userId)?.id ?: -1,
             displayName: details?.displayName,
             email: details?.email?.toLowerCase()?.encodeAsMD5(),
             transcribedThumbs: thumbnails,
             transcribedItems: tasks.size(),
             timestamp: it.maxDate.time / 1000]
        }

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to collect transcriber details and thumbnails")
        sw.reset().start()

        def contributors = (messages + transcribers).sort { -it.timestamp }.take(maxContributors)
        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to sort final list")

        return contributors
    }

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

    def createTempTableForProjectStats(String tempTableName) {
        log.debug("Executing temp table creation")
        String query = """\
            create temp table ${tempTableName} (
                project_id bigint primary key
            )
        """.stripIndent()
        def sql = new Sql(dataSource)
        sql.execute(query)
        sql.close()
    }

    def cleanUpTables(String tempTableName) {
        if (!tempTableName) {
            return
        }

        def query = "drop table if exists " + tempTableName
        def sql = new Sql(dataSource)
        sql.execute(query)
        sql.close()
    }

    def getProjectsForLabels(String tempTableName, List<String> tags, String projectType) {

        if (!tempTableName) {
            tempTableName = "stats_temp_table"
        }
        createTempTableForProjectStats(tempTableName)

        def labelJoin = ""
        def projectTypeJoin = ""
        def parameters = [:]

        if (tags?.size() > 0) {
            def tagParams = tags.withIndex().collectEntries { tag, index ->
                [('tag' + index): tag]
            }
            log.debug("Tag string: ${tagParams}")

            labelJoin = """\
                join project_labels on (project_labels.project_id = project.id) 
                join label on (label.id = project_labels.label_id and label.value in (${tagParams.keySet().collect { ':' + it }.join(',')})) """

            parameters.putAll(tagParams)

            log.debug("labelJoin: ${labelJoin}")
        }

        if (projectType) {
            projectTypeJoin = """\
                join project_type on (project_type.id = project.project_type_id and project_type.name = :projectType)
            """
            parameters.projectType = projectType
        }

        def query = """\
            insert into {tempTableName}
                select distinct project.id
                from project
                ${labelJoin}
                ${projectTypeJoin}
        """
        // This is SAFE - the variable is not modifiable/input from parameters.
        query = query.replace("{tempTableName}", tempTableName)

        log.debug("Filling temp project table (${tempTableName}): ")
        log.debug(query)
        log.debug("Params: tags: ${tags}")
        log.debug("Params: projectType: ${projectType}")

        def sql = new Sql(dataSource)
        if (parameters.size() > 0) {
            sql.executeInsert(query, parameters)
        } else {
            sql.executeInsert(query)
        }

        query = """\
            select project_id 
            from """ + tempTableName

        def projectList = []
        sql.eachRow(query) { row ->
            projectList.add(row.project_id)
        }

        sql.close()

        projectList
    }

    private def getTempJoin(String tempTableName, String joinTable) {
        return "join ${tempTableName} on (${tempTableName}.project_id = ${joinTable}.project_id)"
    }

    def getStatsForProjects(List<String> tags, String projectType) {
        // Tasks
        // Transcribed Tasks
        // Transcribers
        def sw = Stopwatch.createStarted()
        String tempTableName = 'stats_projects_for_labels'
        def projectList = getProjectsForLabels(tempTableName, tags, projectType)
        def tempJoin = getTempJoin(tempTableName, "task")
        log.debug("Got projects list in ${sw.stop().elapsed(MILLISECONDS)}ms")
        sw.reset().start()

        String query = """\
            select count(*) as task_count
            from task
            ${tempJoin} """

        def sql = new Sql(dataSource)

        def result = sql.firstRow(query)
        def taskCount = result.task_count

        log.debug("Got task count in ${sw.stop().elapsed(MILLISECONDS)}ms")
        sw.reset().start()

        query = """\
            select count(is_fully_transcribed) filter (where is_fully_transcribed = true) as transcribed_count
            from task
            ${tempJoin} """

        result = sql.firstRow(query)
        def transcribedTaskCount = result.transcribed_count

        log.debug("Got transcribed task count in ${sw.stop().elapsed(MILLISECONDS)}ms")
        sw.reset().start()

        tempJoin = getTempJoin(tempTableName, "transcription")
        query = """\
            select distinct fully_transcribed_by
            from transcription
            ${tempJoin} 
            where fully_transcribed_by is not null """

        result = sql.rows(query)
        def transcriberCount = result.size()

        log.debug("Got transcriber count in ${sw.stop().elapsed(MILLISECONDS)}ms")

        sql.close()

        [tasks: taskCount, transcriptions: transcribedTaskCount, transcribers: transcriberCount, projectsInLabels: projectList, projectTempTable: tempTableName]
    }

}
