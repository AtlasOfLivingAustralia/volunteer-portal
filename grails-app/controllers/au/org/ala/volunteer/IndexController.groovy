package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.converters.JSON

import java.util.concurrent.TimeUnit

import static java.util.concurrent.TimeUnit.MILLISECONDS

class IndexController {

    def userService
    def grailsApplication
    def projectService
    def leaderBoardService
    def multimediaService
    def institutionService

    def index = {
        def frontPage = FrontPage.instance()

        // News item
        NewsItem newsItem = null;

        if (frontPage.useGlobalNewsItem) {
            newsItem = new NewsItem(shortDescription: frontPage.newsBody, title: frontPage.newsTitle, created: frontPage.newsCreated);
        } else {
            // We need to find the latest news item from all projects, but we only include news items from projects whose news items have not been disabled
            newsItem = NewsItem.find("""from NewsItem n where (n.project is not null and (n.project.disableNewsItems is null or project.disableNewsItems != true)) or (n.institution is not null and (n.institution.disableNewsItems is null or n.institution.disableNewsItems != true)) order by n.created desc""")
        }

        def featuredProjects = projectService.getFeaturedProjectList()?.sort { it.percentTranscribed }

        def potdSummary = projectService.makeSummaryListFromProjectList([frontPage.projectOfTheDay], null).projectRenderList?.get(0)
        //def featuredProjectSummaries = projectService.makeSummaryListFromProjectList(featuredProjects, params)

        render(view: "/index", model: ['newsItem' : newsItem, 'frontPage': frontPage, featuredProjects: featuredProjects, potdSummary: potdSummary] )
    }

    def leaderBoardFragment = {
        [:]
    }

    def statsFragment = {
        // Stats
        def totalTasks = Task.count()
        def completedTasks = Task.countByFullyTranscribedByIsNotNull()
        def transcriberCount = User.countByTranscribedCountGreaterThan(0)
        ['totalTasks':totalTasks, 'completedTasks':completedTasks, 'transcriberCount':transcriberCount]
    }

    def stats(long institutionId, long projectId) {
        def maxContributors = (params.maxContributors as Integer) ?: 5
        def disableStats = params.getBoolean('disableStats', false)
        def disableHonourBoard = params.getBoolean('disableHonourBoard', false)
        Institution institution = (institutionId == -1l) ? null : Institution.get(institutionId)
        Project projectInstance = (projectId == -1l) ? null : Project.get(projectId)

        log.debug("Generating stats for inst id $institutionId, proj id: $projectId, maxContrib: $maxContributors, disableStats: $disableStats, disableHB: $disableHonourBoard")

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
            completedTasks = institutionService.countValidatedTasksForInstitution(institution)
            transcriberCount = institutionService.getTranscriberCount(institution)
        } else { // TODO Project stats, not needed for v2.3
            totalTasks = Task.count()
            completedTasks = Task.countByFullyTranscribedByIsNotNull()
            transcriberCount = User.countByTranscribedCountGreaterThan(0)
        }

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to generate volunteer-stats section")

        def daily
        def weekly
        def monthly
        def alltime

        sw.start()
        if (disableHonourBoard) {
            daily = weekly = monthly = alltime = LeaderBoardService.EMPTY_LEADERBOARD_WINNER
        } else { // TODO Project honour board, not needed for v2.3
            daily = leaderBoardService.winner(LeaderBoardCategory.daily, institution)
            weekly = leaderBoardService.winner(LeaderBoardCategory.weekly, institution)
            monthly = leaderBoardService.winner(LeaderBoardCategory.monthly, institution)
            alltime = leaderBoardService.winner(LeaderBoardCategory.alltime, institution)
        }

        // Encode the email addresses for gravatar before sending to the client to prevent
        // the client having access to the user's email address info
        [daily, weekly, monthly, alltime].each { it.email = it.email?.toLowerCase()?.encodeAsMD5() }

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to generate honour board section")

        sw.start()

        def latestContribs = Task.withCriteria {
            if (institution) {
                project {
                    eq('institution', institution)
                }
            } else if (projectInstance) {
                eq('project', projectInstance)
            }
            isNotNull('fullyTranscribedBy')
            projections {
                groupProperty('project')
                groupProperty('fullyTranscribedBy')
                max('dateFullyTranscribed', 'maxDate')
            }
            order('maxDate', 'desc')
            maxResults(maxContributors)
        }

        def contributors = latestContribs.collect {
            def proj = it[0]
            def userId = it[1]
            def details = userService.detailsForUserId(userId)
            def c = Task.createCriteria()
            def tasks = c.list(max: 5) {
                eq('project', proj)
                eq('fullyTranscribedBy', userId)
                order('dateFullyTranscribed', 'desc')
            }
            def thumbnails = tasks.collect { Task t ->
                [id: t.id, thumbnailUrl: multimediaService.getImageThumbnailUrl(t.multimedia?.first())]
            }
            [projectId: proj.id, projectName: proj.name, userId: User.findByUserId(userId)?.id ?: -1, displayName: details?.displayName, email: details?.email?.toLowerCase()?.encodeAsMD5(),
             transcribedThumbs: thumbnails, transcribedItems: tasks.totalCount, timestamp: it[2].time / 1000]
        }

        log.debug("Took ${sw.stop().elapsed(MILLISECONDS)}ms to generate contributors section")

        def result = ['totalTasks':totalTasks, 'completedTasks':completedTasks, 'transcriberCount':transcriberCount,
                      daily: daily, weekly: weekly, monthly: monthly, alltime: alltime, contributors: contributors]

        render result as JSON
    }
}
