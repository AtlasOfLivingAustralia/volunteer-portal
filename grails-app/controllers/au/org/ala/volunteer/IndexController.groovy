package au.org.ala.volunteer

class IndexController {

    def userService
    def grailsApplication
    def projectService

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
}
