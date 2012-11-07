package au.org.ala.volunteer



class ForumWatchNotifierJob {

    def logService
    def forumService

    static triggers = {
      simple repeatInterval: 30000l // execute job once in 30 seconds
    }

    def execute() {
        forumService.processPendingNotifications()
    }
}
