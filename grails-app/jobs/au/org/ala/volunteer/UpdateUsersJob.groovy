package au.org.ala.volunteer

class UpdateUsersJob {

    def userService
    def grailsApplication
    def concurrent = false

    def description = "Update all users database details from the user details service"

    static triggers = {
        cron name: 'updateUsersTrigger', cronExpression: '0 17 3 * * ?' // 3:17am
    }

    def execute() {
        log.debug("Update users job starting at ${new Date()}")
        try {
            userService.updateAllUsers()
        } catch (Exception e) {
            log.error("Update users job failed with exception", e)
        }
        log.debug("Update users job finishing at ${new Date()}")
    }

}
