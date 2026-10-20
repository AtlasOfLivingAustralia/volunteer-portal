package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.gorm.DetachedCriteria
import grails.gorm.transactions.Transactional
import grails.plugin.cache.Cacheable
import groovy.sql.Sql
import java.util.UUID

import static java.util.concurrent.TimeUnit.MILLISECONDS
import static grails.async.Promises.waitAll
import grails.web.mapping.LinkGenerator

@Transactional
class VolunteerStatsService {

    private static final String SESSION_FILTER_TABLE = 'stats_session_filter'

    def dataSource
    def multimediaService
    def userService
    def leaderBoardService
    def institutionService
    def projectService
    LinkGenerator grailsLinkGenerator

    protected Map<String, Object> runConcurrentTasks(Map<String, Closure> operations) {
        if (!operations) {
            return [:]
        }

        def promises = operations.collect { key, work ->
            Task.async.withStatelessSession {
                def sw = Stopwatch.createStarted()
                try {
                    [key: key, value: work.call()]
                } finally {
                    log.debug("Async task [${key}] took ${sw.stop().elapsed(MILLISECONDS)}ms")
                }
            }
        }

        waitAll(promises).collectEntries { [(it.key): it.value] }
    }

    private static def emptyLeaderboardWinner() {
        [userId: 0, name: '', email: '', score: 0]
    }

    protected Map<String, Object> loadDisabledStats() {
        [totalTasks: 0,
         completedTasks: 0,
         transcriberCount: 0,
         transcriptionCount: 0,
         institutionCount: 0,
         projectCount: 0,
         templates: 0,
         speciesTranscribed: 0,
         avgTranscriptionTime: 0,
         maxTranscriptionTime: 0]
    }

    protected Map<String, Object> loadInstitutionStats(Institution institution) {
        def stats = runConcurrentTasks([
                totalTasks           : { institutionService.countTasksForInstitution(institution) },
                completedTasks       : { institutionService.countTranscribedTasksForInstitution(institution) },
                transcriberCount     : { institutionService.getTranscriberCount(institution) },
                transcriptionCount   : { institutionService.countTranscriptionsForInstitution(institution) },
                projectCount         : { institutionService.countProjectsForInstitution(institution) },
                templates            : { institutionService.countTemplatesForInstitution(institution) },
                speciesTranscribed   : { institutionService.countSpeciesTranscribedForInstitution(institution) },
                avgTranscriptionTime : { institutionService.getAverageTranscriptionTimeForInstitution(institution) },
                maxTranscriptionTime : { institutionService.getMaxTranscriptionTimeForInstitution(institution) }
        ])

        stats.institutionCount = 1
        stats
    }

    protected Map<String, Object> loadSiteStats() {
        runConcurrentTasks([
                totalTasks           : { Task.count() },
                completedTasks       : { Task.countByIsFullyTranscribed(true) },
                transcriberCount     : { User.countByTranscribedCountGreaterThan(0) },
                transcriptionCount   : { Transcription.count() },
                institutionCount     : { Institution.count() },
                projectCount         : { Project.count() },
                templates            : { Template.count() },
                avgTranscriptionTime : { Transcription.executeQuery("select avg(t.timeToTranscribe) from Transcription t where t.timeToTranscribe is not null")?.get(0) as Integer },
                maxTranscriptionTime : { Transcription.executeQuery("select max(t.timeToTranscribe) from Transcription t where t.timeToTranscribe is not null")?.get(0) as Integer },
                speciesTranscribed   : {
                    def count = Field.createCriteria().get {
                        projections {
                            countDistinct('value')
                        }
                        eq('name', 'scientificName')
                    } as Integer

                    count ?: 0
                }
        ])
    }

    protected Map<String, Object> loadLeaderBoardStats(Institution institution, String projectTempTable, boolean disableHonourBoard) {
        if (disableHonourBoard) {
            return [daily  : emptyLeaderboardWinner(),
                    weekly : emptyLeaderboardWinner(),
                    monthly: emptyLeaderboardWinner(),
                    alltime: emptyLeaderboardWinner()]
        }

        if (projectTempTable) {
            return runConcurrentTasks([
                    daily  : { leaderBoardService.winner(LeaderBoardCategory.daily, institution, projectTempTable) },
                    weekly : { leaderBoardService.winner(LeaderBoardCategory.weekly, institution, projectTempTable) },
                    monthly: { leaderBoardService.winner(LeaderBoardCategory.monthly, institution, projectTempTable) },
                    alltime: { leaderBoardService.winner(LeaderBoardCategory.alltime, institution, projectTempTable) }
            ])
        }

        runConcurrentTasks([
                daily  : { leaderBoardService.winner(LeaderBoardCategory.daily, institution, projectTempTable) },
                weekly : { leaderBoardService.winner(LeaderBoardCategory.weekly, institution, projectTempTable) },
                monthly: { leaderBoardService.winner(LeaderBoardCategory.monthly, institution, projectTempTable) },
                alltime: { leaderBoardService.winner(LeaderBoardCategory.alltime, institution, projectTempTable) }
        ])
    }

    protected def withSql(Closure work) {
        def sql = new Sql(dataSource)
        try {
            return work.call(sql)
        } finally {
            sql.close()
        }
    }

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
    //@Cacheable(value = 'MainVolunteerStats', key = { "${institutionId}-${projectTypeName ?: ''}-${tags?.toString() ?: '[]'}-${disableStats}-${disableHonourBoard}" })
    def generateStats(long institutionId, String projectTypeName, List<String> tags, boolean disableStats, boolean disableHonourBoard) {
        Institution institution = (institutionId == -1l) ? null : Institution.get(institutionId)
        String sessionId = null

        try {
            def sw = Stopwatch.createStarted()
            log.debug("Generating stats for inst id $institutionId, disableStats: $disableStats, disableHB: $disableHonourBoard, projectType: $projectTypeName, tags: $tags")

            Map stats
            Map leaderBoardStats

            if (tags || projectTypeName) {
                log.debug("Getting tag/project type stats for [tags: ${tags}, projectTypeName: ${projectTypeName}]")
                sessionId = UUID.randomUUID().toString()
                def projectStats = getProjectsForLabels(sessionId, tags, projectTypeName)

                def concurrent = runConcurrentTasks([
                        stats      : { getStatsForProjects(sessionId, projectStats.projectCount as Integer) },
                        leaderboard: { loadLeaderBoardStats(institution, sessionId, disableHonourBoard) }
                ])

                stats = concurrent.stats
                leaderBoardStats = concurrent.leaderboard
                stats.projectCount = projectStats.projectCount
            } else {
                def concurrent = runConcurrentTasks([
                        stats      : {
                            if (disableStats) {
                                log.debug("Stats are disabled")
                                return loadDisabledStats()
                            }

                            if (institution) {
                                log.debug("Getting institution stats for [${institution.name}]")
                                return loadInstitutionStats(institution)
                            }

                            log.debug("Getting full site stats")
                            return loadSiteStats()
                        },
                        leaderboard: { loadLeaderBoardStats(institution, null, disableHonourBoard) }
                ])

                stats = concurrent.stats
                leaderBoardStats = concurrent.leaderboard
            }

            def percentageComplete = (stats.totalTasks > 0) ? (stats.completedTasks / stats.totalTasks) * 100 : 0

            def avgTranscriptionTimeValue = (stats.avgTranscriptionTime ?: 0) as Integer
            def avgTranscriptionTimeAsMinutes = avgTranscriptionTimeValue.intdiv(60)
            if (avgTranscriptionTimeAsMinutes < 1) avgTranscriptionTimeAsMinutes = 0
            def avgTranscriptionTimeAsSeconds = avgTranscriptionTimeValue % 60
            def avgTranscriptionTimeString = "${avgTranscriptionTimeAsMinutes}m ${avgTranscriptionTimeAsSeconds}s"

            def avgTimeAsPercentOfMax = 0
            if (stats.maxTranscriptionTime && stats.maxTranscriptionTime > 0) {
                avgTimeAsPercentOfMax = (stats.avgTranscriptionTime ?: 0) / stats.maxTranscriptionTime * 100
                avgTimeAsPercentOfMax = Math.round(avgTimeAsPercentOfMax / 5) * 5
                if (avgTimeAsPercentOfMax == 0) avgTimeAsPercentOfMax = 1
            }

            log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to generate volunteer-stats section")
            sw.reset().start()

            def daily = leaderBoardStats.daily
            def weekly = leaderBoardStats.weekly
            def monthly = leaderBoardStats.monthly
            def alltime = leaderBoardStats.alltime

            [daily, weekly, monthly, alltime].each { it.email = it.email?.toLowerCase()?.encodeAsMD5() }

            log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to generate honour board section")

            [
                    totalTasks                : stats.totalTasks,
                    completedTasks            : stats.completedTasks,
                    percentageComplete        : percentageComplete,
                    transcriberCount          : stats.transcriberCount,
                    transcriptionCount        : stats.transcriptionCount,
                    institutionCount          : stats.institutionCount,
                    projectCount              : stats.projectCount,
                    templates                 : stats.templates,
                    speciesTranscribed        : stats.speciesTranscribed,
                    avgTranscriptionTime      : stats.avgTranscriptionTime,
                    avgTranscriptionTimeString: avgTranscriptionTimeString,
                    avgTimeAsPercentOfMax     : avgTimeAsPercentOfMax,
                    daily                     : daily,
                    weekly                    : weekly,
                    monthly                   : monthly,
                    alltime                   : alltime
            ]
        } finally {
            cleanUpTables(sessionId)
        }
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
        def messages = latestMessages.collect { ForumMessage it ->

            def topic = ForumTopic.get(it.topicId)
            def topicId = topic.id
            def topicName = topic.title
            def topicType = topic.topicType
            def topicClass = topic.class.simpleName
            def details = userDetails[it.user.userId]
            def timestamp = it.date.time / 1000
            def topicUrl = grailsLinkGenerator.link(controller: 'forum', action: 'viewForumTopic', id: topic.id)

            def forumName
            def forumUrl
            def thumbnail = null

            if (topic instanceof ProjectForumTopic) {
                def forumProject = ((ProjectForumTopic) topic).project
                forumName = forumProject.name
                thumbnail = projectService.getFeaturedImage(forumProject) + "?" + projectService.cacheBust(forumProject)
                forumUrl = grailsLinkGenerator.link(controller: 'forum', action: 'projectForum', params: [projectId: forumProject.id])
            } else if (topic instanceof TaskForumTopic) {
                def task = ((TaskForumTopic) topic).task
                forumName = task.project.name
                thumbnail = multimediaService.getImageThumbnailUrlForDisplay(task.multimedia?.first())
                forumUrl = grailsLinkGenerator.link(controller: 'forum', action: 'projectForum', params: [projectId: task.project.id])
            } else {
                forumName = "General Discussion"
                forumUrl = grailsLinkGenerator.link(controller: 'forum', action: 'index', params: [])
            }

            def userEmail = details?.email
            if (!userEmail) {
                userEmail = details?.userName ? details?.userName : null
            }

            [type        : 'forum',
             topicId     : topicId,
             topicUrl    : topicUrl,
             topicTitle  : topicName,
             topicType   : topicType.toString(),
             topicClass  : topicClass,
             forumUrl    : forumUrl,
             forumName   : forumName,
             userId      : it.userId,
             displayName : details?.displayName,
             email       : userEmail?.toLowerCase()?.encodeAsMD5(),
             thumbnailUrl: thumbnail,
             timestamp   : timestamp]
        }

        return messages
    }

    /**
     * Retrieves and collects information from {@link #getContributors(Institution, Project, String, Integer)}
     *
     * @param institutionId optional institution filter
     * @param projectId optional project filter
     * @param projectTypeName optional project type filter
     * @param tags tag filter
     * @param maxContributors maximum number of contributors to collect
     * @return a map containing the contribution information.
     */
    @Cacheable(value = 'MainVolunteerContribution', key = { "${institutionId}-${projectId}-${projectTypeName ?: ''}-${tags?.toString() ?: '[]'}-${maxContributors}" })
    def generateContributors(long institutionId, long projectId, String projectTypeName, List<String> tags, int maxContributors) {
        Institution institution = (institutionId == -1l) ? null : Institution.get(institutionId)
        Project projectInstance = (projectId == -1l) ? null : Project.get(projectId)

        String sessionId = null
        try {
            if (projectTypeName || tags) {
                sessionId = UUID.randomUUID().toString()
                def projectStats = getProjectsForLabels(sessionId, tags, projectTypeName)
                if (!projectStats.projectCount) {
                    return [contributors: []]
                }
            }

            List<LinkedHashMap<String, Serializable>> contributors = getContributors(institution, projectInstance, sessionId, maxContributors)

            [contributors: contributors]
        } finally {
            cleanUpTables(sessionId)
        }
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
    def getContributors(Institution institution, Project projectInstance, String sessionId, Integer maxContributors) {
        def sw = Stopwatch.createStarted()

        def latestTranscribers = []
        if (sessionId) {
            def query = """\
                select latest_transcribers.project_id,
                    fully_transcribed_by,
                    max_date
                from latest_transcribers
                join ${SESSION_FILTER_TABLE} on (${SESSION_FILTER_TABLE}.project_id = latest_transcribers.project_id and ${SESSION_FILTER_TABLE}.session_id = :sessionId)
                order by max_date desc
                limit ${maxContributors} """.stripIndent()

            def sql = new Sql(dataSource)
            sql.eachRow(query, [sessionId: sessionId]) { row ->
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
                [id: t.id, thumbnailUrl: multimediaService.getImageThumbnailUrlForDisplay(task.multimedia?.first())]
            }
            log.debug("Took ${sw2.stop().elapsed(MILLISECONDS)}ms to compile thumbnail info for user ${userId}")

            def userEmail = details?.email
            if (!userEmail) {
                userEmail = details?.userName ? details?.userName : null
            }

            [type: 'task',
             projectId: proj.id,
             projectName: proj.name,
             projectType: proj.projectType.name,
             userId: User.findByUserId(userId)?.id ?: -1,
             displayName: details?.displayName,
             email: userEmail?.toLowerCase()?.encodeAsMD5(),
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

    def cleanUpTables(String sessionId) {
        if (!sessionId) {
            return
        }

        Task.withNewTransaction {
            def sql = new Sql(dataSource)
            try {
                sql.execute("delete from ${SESSION_FILTER_TABLE} where session_id = :sessionId", [sessionId: sessionId])
            } finally {
                sql.close()
            }
        }
    }

    def getProjectsForLabels(String sessionId, List<String> tags, String projectType) {
        def sw = Stopwatch.createStarted()
        def labelJoin = ""
        def projectTypeJoin = ""
        def parameters = [:]
        parameters.sessionId = sessionId

        def tagParams = [:]
        if (tags?.size() > 0) {
            tagParams = tags.withIndex().collectEntries { tag, index ->
                [('tag' + index): tag]
            }
            log.debug("Tag string: ${tagParams}")

            labelJoin = """\
                left outer join project_labels on (project_labels.project_id = project.id) 
                left outer join label on (label.id = project_labels.label_id) 
                join institution on (institution.id = project.institution_id)
                """

            parameters.putAll(tagParams)

            log.debug("labelJoin: ${labelJoin}")
        }

        // Check that the tag values are project type names, and if so, join on the project_type table to filter by project type.
        // Project Type should be tags[0]
        def projectTypeNames = ProjectType.list()*.name
        if (!projectType && tags?.size() > 0 && projectTypeNames.contains(tags[0])) {
            projectType = tags[0]
            log.debug("Project type found in tags: ${projectType}")
        }

        if (projectType) {
            projectTypeJoin = """\
                join project_type on (project_type.id = project.project_type_id)
            """
            parameters.projectType = projectType
        }

        def query = """\
            insert into ${SESSION_FILTER_TABLE} (session_id, project_id)
                select distinct :sessionId, project.id
                from project
                ${labelJoin}
                ${projectTypeJoin}
        """
        if (labelJoin && projectTypeJoin) {
            query += "where label.value in (${tagParams.keySet().collect { ':' + it }.join(',')}) or project_type.name = :projectType"

            def multiParamClause = buildMultiParamSearchClause(["institution.name", "project.name", "project.short_description", "project.description", "project.featured_owner"], tags, "tag")
            query += " or " + (multiParamClause.clause as String)
            parameters.putAll(multiParamClause.params)
        } else if (labelJoin) {
            query += "where label.value in (${tagParams.keySet().collect { ':' + it }.join(',')})"
            def multiParamClause = buildMultiParamSearchClause(["institution.name", "project.name", "project.short_description", "project.description", "project.featured_owner"], tags, "tag")
            query += " or " + (multiParamClause.clause as String)
            parameters.putAll(multiParamClause.params)
        } else if (projectTypeJoin) {
            query += "where project_type.name = :projectType"
        }

        log.debug("Filling session project filter (${sessionId}): ")
        log.debug("Projects for Labels Query ---------------------------------------------------------")
        log.debug("\n" + query)
        log.debug("Params: tags: ${tags}")
        log.debug("Params: projectType: ${projectType}")

        def projectCount = 0
        Task.withNewTransaction {
            def sql = new Sql(dataSource)
            try {
                sql.execute("delete from ${SESSION_FILTER_TABLE} where session_id = :sessionId", [sessionId: sessionId])
                sql.execute(query, parameters)

                projectCount = sql.firstRow("""\
                    select count(*) as project_count
                    from ${SESSION_FILTER_TABLE}
                    where session_id = :sessionId
                """.stripIndent(), [sessionId: sessionId]).project_count as Integer
            } finally {
                sql.close()
            }
        }
        log.debug("Got projects list in ${sw.stop().elapsed(MILLISECONDS)}ms")
        [sessionId: sessionId, projectCount: projectCount]
    }

    private def buildMultiParamSearchClause(List<String> fieldReference, List<String> values, String paramPrefix) {
        if (!values || values.isEmpty()) {
            return ""
        }
        def clauseMap = [:]
        def paramMap = values.withIndex().collectEntries { value, index ->
            [(paramPrefix + index): "%" + (value as String) + "%"]
        }

        def clauseList = fieldReference.collectMany { field ->
            values.withIndex().collect { value, index ->
                "${field} ilike :${paramPrefix}${index}"
            }
        }
        clauseMap.clause = "(" + clauseList.join(" or ") + ")"
        clauseMap.params = paramMap
        return clauseMap
    }

    def getStatsForProjects(String sessionId, int projectCount) {
        def sw = Stopwatch.createStarted()
        log.debug("Got projects list in ${sw.stop().elapsed(MILLISECONDS)}ms")
        sw.reset().start()

        if (!projectCount) {
            return [totalTasks: 0,
                    completedTasks: 0,
                    transcriberCount: 0,
                    projectsInLabels: [],
                    projectTempTable: SESSION_FILTER_TABLE,
                    transcriptionCount: 0,
                    projectCount: projectCount,
                    templates: 0,
                    speciesTranscribed: 0,
                    avgTranscriptionTime: 0,
                    maxTranscriptionTime: 0,
                    institutionCount: 0]
        }

        log.info("Getting stats for ${projectCount} projects")
        def stats = runConcurrentTasks([
                taskStats          : {
                    withSql { sql ->
                        sql.firstRow("""\
                            select count(*) as task_count,
                                   count(*) filter (where t.is_fully_transcribed = true) as transcribed_count
                            from task t
                            join ${SESSION_FILTER_TABLE} pid on pid.project_id = t.project_id and pid.session_id = :sessionId
                        """.toString(), [sessionId: sessionId])
                    }
                },
                transcriptionStats : {
                    withSql { sql ->
                        sql.firstRow("""\
                            select count(*) as transcription_count,
                                   count(distinct tn.fully_transcribed_by) filter (where tn.fully_transcribed_by is not null) as transcriber_count
                            from transcription tn
                            join ${SESSION_FILTER_TABLE} pid on pid.project_id = tn.project_id and pid.session_id = :sessionId
                        """.toString(), [sessionId: sessionId])
                    }
                },
                transcriptionAggStats : {
                    withSql { sql ->
                        sql.firstRow("""\
                            select coalesce(avg(tn.time_to_transcribe) filter (where tn.time_to_transcribe is not null), 0) as avg_time,
                                   coalesce(max(tn.time_to_transcribe) filter (where tn.time_to_transcribe is not null), 0) as max_time
                            from transcription tn
                            join ${SESSION_FILTER_TABLE} pid on pid.project_id = tn.project_id and pid.session_id = :sessionId
                        """.toString(), [sessionId: sessionId])
                    }
                },
                templateCount      : {
                    withSql { sql ->
                        sql.firstRow("""\
                            select count(distinct p.template_id) as template_count
                            from project p
                            join ${SESSION_FILTER_TABLE} pid on pid.project_id = p.id and pid.session_id = :sessionId
                        """.toString(), [sessionId: sessionId]).template_count
                    }
                },
                speciesCount       : {
                    withSql { sql ->
                        sql.firstRow("""\
                            select count(distinct f.value) as species_count
                            from field f
                            join task t on t.id = f.task_id
                            join ${SESSION_FILTER_TABLE} pid on pid.project_id = t.project_id and pid.session_id = :sessionId
                            where f.name = 'scientificName'
                        """.toString(), [sessionId: sessionId]).species_count
                    }
                },
                institutionCount   : {
                    withSql { sql ->
                        sql.firstRow("""\
                            select count(distinct p.institution_id) as institution_count
                            from project p
                            join ${SESSION_FILTER_TABLE} pid on pid.project_id = p.id and pid.session_id = :sessionId
                        """.toString(), [sessionId: sessionId]).institution_count
                    }
                }
        ])

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to collect project-type stats")

        [totalTasks: stats.taskStats.task_count,
         completedTasks: stats.taskStats.transcribed_count,
         transcriberCount: stats.transcriptionStats.transcriber_count,
         projectsInLabels: [],
         projectTempTable: SESSION_FILTER_TABLE,
         transcriptionCount: stats.transcriptionStats.transcription_count,
         projectCount: projectCount,
         templates: stats.templateCount,
         speciesTranscribed: stats.speciesCount,
         avgTranscriptionTime: stats.transcriptionAggStats.avg_time,
         maxTranscriptionTime: stats.transcriptionAggStats.max_time,
         institutionCount: stats.institutionCount]
    }


}
