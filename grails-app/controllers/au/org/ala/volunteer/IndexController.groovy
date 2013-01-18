package au.org.ala.volunteer

class IndexController {

    def userService
    def grailsApplication

    def index = {
        def frontPage = FrontPage.instance()

        // News item
        NewsItem newsItem = null;

        if (frontPage.useGlobalNewsItem) {
            newsItem = new NewsItem(shortDescription: frontPage.newsBody, title: frontPage.newsTitle, created: frontPage.newsCreated);
        } else {
            // We need to find the latest news item from all projectRenderList, but we only include news items from projectRenderList whose news items have not been disabled
            newsItem = NewsItem.find("""from NewsItem n where n.project.disableNewsItems is null or project.disableNewsItems != true order by n.created desc""")
        }

        render(view: "/index", model: ['newsItem' : newsItem, 'frontPage': FrontPage.instance()] )
    }

    def leaderBoardFragment = {

        def t = new CodeTimer("Calculate user scores")
        def r = userService.getAllUserScores()

        r.removeAll {
            it.username == null
        }

        def results = r.sort({it.score}).reverse()
        int maxSize = grailsApplication.config.leaderBoard.count

        if (results.size() > maxSize) {
            results = results.subList(0, maxSize)
        }

        t.stop(true)

        [results: results]
    }

    def statsFragment = {
        // Stats
        def totalTasks = Task.count()
        def completedTasks = Task.findAll("from Task where length(fullyTranscribedBy) > 0").size()
        def transcriberCount = User.findAll("from User where transcribedCount > 0").size()
        ['totalTasks':totalTasks, 'completedTasks':completedTasks, 'transcriberCount':transcriberCount]
    }
}
