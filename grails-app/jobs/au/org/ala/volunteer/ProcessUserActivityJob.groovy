package au.org.ala.volunteer


class ProcessUserActivityJob {

    def userService
    def concurrent = false

    static triggers = {
        simple repeatInterval: 5000l // execute job once in 5 seconds
    }

    def execute() {
        try {
            if (grailsApplication.config.getProperty("bvp.user.activity.monitor.enabled", Boolean.class)) {
                // First of all flush the activity records to the database, in the order in which they appeared
                userService.flushActivityRecords()
                // then purge any expire ones...
                int timeout = grailsApplication.config.getProperty("bvp.user.activity.monitor.timeout", Integer.class, 3600) // default to one hour
                userService.purgeUserActivity(timeout)
            }
        } catch (Exception ex) {
            ex.printStackTrace()
        }
    }
}