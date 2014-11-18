package au.org.ala.volunteer

class TaskIndexerJob {

    def fullTextIndexService
    def grailsApplication
    def concurrent = false

    static triggers = {
        simple repeatInterval: 1000l // execute job once in 5 seconds
    }

    def execute() {
        try {
            fullTextIndexService.processIndexTaskQueue()
        } catch (Exception ex) {
            ex.printStackTrace()
        }
    }

}
