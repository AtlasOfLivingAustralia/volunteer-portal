package au.org.ala.volunteer

import groovy.util.logging.Slf4j

/**
 * Job to process finished tasks at regular intervals. Catches tasks that have not been marked as fully transcribed
 * but are finished due to a race condition.
 */
@Slf4j
class TaskFinishedJob {

    def taskService
    static concurrent = false

    static triggers = {
        simple repeatInterval: 5 * 60 * 1000;
    }

    def execute() {
        try {
            log.debug("Processing finished tasks...")
            taskService.processFinishedTasks()
        } catch (Exception ex) {
            log.error("Error processing finished tasks", ex)
        }
    }
}
