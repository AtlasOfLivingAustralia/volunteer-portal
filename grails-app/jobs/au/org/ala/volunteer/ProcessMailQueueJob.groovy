package au.org.ala.volunteer

class ProcessMailQueueJob {

    def emailService
    def concurrent = false

    static triggers = {
        simple repeatInterval: 5 * 60 * 1000; // 2 minutes
    }

    def execute() {
        try {
            emailService.sendQueuedMessages()
        } catch (Exception ex) {
            ex.printStackTrace()
        }
    }

}
