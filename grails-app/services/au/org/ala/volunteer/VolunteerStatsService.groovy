package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.gorm.DetachedCriteria
import grails.transaction.Transactional
import grails.plugin.cache.Cacheable
import javax.annotation.PostConstruct
import static java.util.concurrent.TimeUnit.MILLISECONDS

@Transactional
class VolunteerStatsService {

    def multimediaService
    def userService
    def leaderBoardService
    def institutionService
    def projectService

    private g

    @PostConstruct
    def initialise() {
        g = applicationContext.getBean('org.grails.plugins.web.taglib.ApplicationTagLib')
    }

    @Cacheable(value = 'MainVolunteerContribution', key = "(#institutionId?.toString()?:'-1') + (#projectId?.toString()?:'-1') + (#tagName?:'') + (#disableStats.toString()) + (#disableHonourBoard.toString())")
    //@Cacheable(value = 'MainVolunteerContribution')
    def generateStats(long institutionId, long projectId, String tagName, int maxContributors, boolean disableStats, boolean disableHonourBoard) {
        Institution institution = (institutionId == -1l) ? null : Institution.get(institutionId)
        Project projectInstance = (projectId == -1l) ? null : Project.get(projectId)
        ProjectType pt = tagName ? ProjectType.findByName(tagName) : null

        log.debug("Generating stats for inst id $institutionId, proj id: $projectId, maxContrib: $maxContributors, disableStats: $disableStats, disableHB: $disableHonourBoard, tagName: $tagName")

        def sw = Stopwatch.createStarted()

        def totalTasks
        def completedTasks
        def transcriberCount
        if (disableStats) {
            totalTasks = 0
            completedTasks = 0
            transcriberCount = 0
        } else if (institution) {
            totalTasks = institutionService.countTasksForInstitution(institution)
            completedTasks = institutionService.countTranscribedTasksForInstitution(institution)
            transcriberCount = institutionService.getTranscriberCount(institution)
        } else if (tagName) {
            totalTasks = projectService.countTasksForTag(pt)
            completedTasks = projectService.countTranscribedTasksForTag(pt)
            transcriberCount = projectService.getTranscriberCountForTag(pt)
        } else { // TODO Project stats, not needed for v2.3
            totalTasks = Task.count()
            completedTasks = Task.countByIsFullyTranscribed(true) //Transcription.countByFullyTranscribedByIsNotNull()
            transcriberCount = User.countByTranscribedCountGreaterThan(0)
        }

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to generate volunteer-stats section")

        sw.start()

        def daily
        def weekly
        def monthly
        def alltime

        if (disableHonourBoard) {
            daily = weekly = monthly = alltime = LeaderBoardService.EMPTY_LEADERBOARD_WINNER
        } else { // TODO Project honour board, not needed for v2.3
            daily = leaderBoardService.winner(LeaderBoardCategory.daily, institution, pt)
            weekly = leaderBoardService.winner(LeaderBoardCategory.weekly, institution, pt)
            monthly = leaderBoardService.winner(LeaderBoardCategory.monthly, institution, pt)
            alltime = leaderBoardService.winner(LeaderBoardCategory.alltime, institution, pt)
        }

        // Encode the email addresses for gravatar before sending to the client to prevent
        // the client having access to the user's email address info
        [daily, weekly, monthly, alltime].each { it.email = it.email?.toLowerCase()?.encodeAsMD5() }

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to generate honour board section")

        sw.start()

        List<LinkedHashMap<String, Serializable>> contributors = generateContributors(institution, projectInstance, pt, maxContributors)
        //generateContributors(institution, projectInstance, pt, maxContributors)

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to generate contributors section")

        ['totalTasks':totalTasks, 'completedTasks':completedTasks, 'transcriberCount':transcriberCount,
         daily: daily, weekly: weekly, monthly: monthly, alltime: alltime, contributors: contributors]


    }


  //  @Cacheable(value = 'MainVolunteerContribution', key = "#institution?.key?:'' + #projectInstance?.key?:'' + #pt?.key?:''")
    def generateContributors(Institution institution, Project projectInstance, ProjectType pt, maxContributors) {

        def latestTranscribers = LatestTranscribers.withCriteria {
            if (institution) {
                project {
                    eq('institution', institution)
                    ne('inactive', true)
                }
            } else if (pt) {
                project {
                    eq('projectType', pt)
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

        def latestMessages

        if (institution) {
            latestMessages = ForumMessage.findAll('FROM ForumMessage fm WHERE fm.topic.project.institution = :institution ORDER BY date desc', [institution: institution], [max: maxContributors])
            latestMessages += ForumMessage.findAll('FROM ForumMessage fm WHERE fm.topic.task.project.institution = :institution ORDER BY date desc', [institution: institution], [max: maxContributors])
        } else if (pt) {
            latestMessages = ForumMessage.findAll('FROM ForumMessage fm WHERE fm.topic.project.projectType = :pt ORDER BY date desc', [pt: pt], [max: maxContributors])
            latestMessages += ForumMessage.findAll('FROM ForumMessage fm WHERE fm.topic.task.project.projectType = :pt ORDER BY date desc', [pt: pt], [max: maxContributors])
        } else if (projectInstance) {
            latestMessages = ForumMessage.withCriteria {
                or {
                    'in'('topic', new DetachedCriteria(ProjectForumTopic).build {
                        eq('project', projectInstance)
                        projections {
                            property('id')
                        }
                    })
                    'in'('topic', new DetachedCriteria(TaskForumTopic).build {
                        task {
                            eq('project', projectInstance)
                        }
                        projections {
                            property('id')
                        }
                    })
                }
                order('date', 'desc')
                maxResults(maxContributors)
            }
        } else {
            latestMessages = ForumMessage.withCriteria {
                order('date', 'desc')
                maxResults(maxContributors)
            }
        }

        def messages = latestMessages.collect {
            def topic = it.topic
            def topicId = topic.id
            def details = userService.detailsForUserId(it.user.userId)
            def timestamp = it.date.time / 1000
            def topicUrl = g.createLink(controller: 'forum', action: 'viewForumTopic', id: topic.id)

            def forumName
            def forumUrl
            def thumbnail = null

            if (topic instanceof ProjectForumTopic) {
                def project = ((ProjectForumTopic) topic).project
                forumName = project.name
                thumbnail = project.featuredImage
                forumUrl = g.createLink(controller: 'forum', action: 'projectForum', params: [projectId: project.id])
            } else if (topic instanceof TaskForumTopic) {
                def task = ((TaskForumTopic) topic).task
                forumName = task.project.name
                thumbnail = multimediaService.getImageThumbnailUrl(task.multimedia?.first())
                forumUrl = g.createLink(controller: 'forum', action: 'projectForum', params: [projectId: task.project.id, selectedTab: 1])
            } else {
                forumName = "General Discussion"
                forumUrl = g.createLink(controller: 'forum', action: 'index', params: [selectedTab: 1])
            }

            [type        : 'forum', topicId: topicId, topicUrl: topicUrl, forumName: forumName, forumUrl: forumUrl, userId: it.userId,
             displayName : details?.displayName, email: details?.email?.toLowerCase()?.encodeAsMD5(),
             thumbnailUrl: thumbnail, timestamp: timestamp]
        }

        def transcribers = latestTranscribers.collect {
            def proj = it.project
            def userId = it.fullyTranscribedBy
            def details = userService.detailsForUserId(userId)
            
            def tasks = LatestTranscribersTask.withCriteria() {
                eq('project', proj)
                eq('fullyTranscribedBy', userId)
                order('dateFullyTranscribed', 'desc')
            }

            def thumbnailLists = (tasks && (tasks.size() > 0)) ? tasks.subList(0, (tasks.size() < 5)? tasks.size(): 5): []

            def thumbnails = thumbnailLists.collect { LatestTranscribersTask t ->
                def task = Task.findById (t.taskId)
                [id: t.id, thumbnailUrl: multimediaService.getImageThumbnailUrl(task.multimedia?.first())]
            }
            [type             : 'task', projectId: proj.id, projectName: proj.name, userId: User.findByUserId(userId)?.id ?: -1, displayName: details?.displayName, email: details?.email?.toLowerCase()?.encodeAsMD5(),
             transcribedThumbs: thumbnails, transcribedItems: tasks.size(), timestamp: it.maxDate.time / 1000]

        }

        def contributors = (messages + transcribers).sort { -it.timestamp }.take(maxContributors)
        return contributors
    }

}
