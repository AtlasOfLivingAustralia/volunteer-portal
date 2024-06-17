package au.org.ala.volunteer

import groovy.util.logging.Slf4j

@Slf4j
class DeleteOldReportsJob {

    def reportRequestService

    private static int SECONDS = 1000
    private static int MINUTES = 60 * SECONDS
    private static int HOURS = 60 * MINUTES
    static concurrent = false

    def description = "Background process to clean up old reports."

    static triggers = {
        // Testing trigger:
        // simple repeatInterval: 2 * MINUTES
        // Production trigger:
        cron name: 'deleteOldReports', cronExpression: '0 15 4 * * ?' // 4:15am
    }

    def execute() {
        log.info("Report cleanup process running.")
        reportRequestService.cleanUpReports()
        log.info("Report cleanup process completed.")
    }
}
