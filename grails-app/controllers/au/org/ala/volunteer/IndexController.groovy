package au.org.ala.volunteer

import grails.converters.JSON

class IndexController {

    def projectService
    def volunteerStatsService
    def newsItemService

    def index() {
        log.debug("Index Controller, Index action")
        def frontPage = FrontPage.instance()

        def featuredProjects = projectService.getFeaturedProjectList()

        // Check if random project of the day is switched on, if it is, grab one and display, else display the current
        // if set.
        def potdSummary = null
        def projectToDisplay
        log.debug("Random project of the day?")
        if (frontPage?.randomProjectOfTheDay) {
            log.debug("Selecing random...")
            projectToDisplay = projectService.checkProjectOfTheDay(frontPage)
        } else {
            log.debug("Project: ${frontPage?.projectOfTheDay}")
            projectToDisplay = frontPage?.projectOfTheDay
        }

        if (projectToDisplay) {
            log.debug("Getting project summary for [${projectToDisplay.name}]")
            potdSummary = projectService.makeSummaryListFromProjectList([projectToDisplay], null, null, null, null, null, null, null, null, false).projectRenderList?.get(0)
        }

        // Check if there's news today:
        def newsItem = newsItemService.getCurrentNewsItem()
        log.debug("Found news item: ${newsItem}")

        render(view: "/index", model: ['frontPage': frontPage, featuredProjects: featuredProjects, potdSummary: potdSummary, newsItem: newsItem] )
    }

    def leaderBoardFragment() {
        [:]
    }

    def stats(long institutionId, long projectId, String projectType) {
        List<String> tags = params.list('tags') ?: []
        def maxContributors = (params.maxContributors as Integer) ?: 5
        def disableStats = params.getBoolean('disableStats', false)
        def disableHonourBoard = params.getBoolean('disableHonourBoard', false)
        log.debug("params: ${params}")
        def result = volunteerStatsService.generateStats(institutionId, projectType, tags, disableStats, disableHonourBoard)
        render result as JSON
    }

    def contributors(long institutionId, long projectId, String projectType) {
        List<String> tags = params.list('tags') ?: []
        def maxContributors = (params.maxContributors as Integer) ?: 5
        def disableStats = params.getBoolean('disableStats', false)
        def disableHonourBoard = params.getBoolean('disableHonourBoard', false)
        def result = volunteerStatsService.generateContributors(institutionId, projectId, projectType, tags, maxContributors)
        render result as JSON
    }

    def forumActivity(long institutionId, long projectId, String projectType) {
        List<String> tags = params.list('tags') ?: []
        def maxPosts = (params.maxPosts as Integer) ?: 5
        def disablePosts = params.getBoolean('disablePosts', false)
        def result = volunteerStatsService.generateForumPosts(institutionId, projectId, maxPosts)
        render result as JSON
    }

    def notPermitted() {
        render(view: '/notPermitted')
    }
}
