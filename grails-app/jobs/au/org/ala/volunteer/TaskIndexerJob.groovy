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
            domainUpdateService.processTaskQueue()
            //fullTextIndexService.processIndexTaskQueue()
        } catch (Exception ex) {
            log.error("Exception while processing task queue!", ex)
        }
    }

}
