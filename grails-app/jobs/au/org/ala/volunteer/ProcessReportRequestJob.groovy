package au.org.ala.volunteer

import groovy.util.logging.Slf4j

@Slf4j
class ProcessReportRequestJob {

    def reportRequestService

    private static int SECONDS = 1000
    private static int MINUTES = 60 * SECONDS
    private static int HOURS = 60 * MINUTES

    static concurrent = false

    def description = "Background process waiting for report generation requests."

    static triggers = {
        simple repeatInterval: 1 * MINUTES // every 60 seconds
    }

    def execute() {
        log.info("Report Process running.")
        reportRequestService.processPendingReportRequests()
        log.info("Report Process completed.")
    }
}
