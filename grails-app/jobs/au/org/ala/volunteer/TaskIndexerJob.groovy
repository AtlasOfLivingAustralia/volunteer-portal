package au.org.ala.volunteer

class TaskIndexerJob {

    def domainUpdateService
    //def fullTextIndexService
    def grailsApplication
    def concurrent = false

    static triggers = {
        simple repeatInterval: 1000l // execute job once in 5 seconds
    }

    def execute() {
        try {
            log.debug("Running Task Indexer Job")
            domainUpdateService.processTaskQueue()
            //fullTextIndexService.processIndexTaskQueue()
            log.debug("Task Indexer Job complete")
        } catch (Exception ex) {
            log.error("Exception while processing task queue!", ex)
        }
    }

}
