package au.org.ala.volunteer

import groovy.time.TimeCategory



class ForumWatchNotifierJob {

    private static int SECONDS = 1000
    private static int MINUTES = 60 * SECONDS
    private static int HOURS = 60 * MINUTES

    def logService
    def forumService



    static triggers = {
      //simple repeatInterval: 30 * SECONDS
      simple repeatInterval: 2 * HOURS
    }

    def execute() {
        forumService.processPendingNotifications()
    }
}
