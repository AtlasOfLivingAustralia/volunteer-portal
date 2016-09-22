package au.org.ala.volunteer

import groovy.sql.Sql

class NewUserDigestNotifierJob {
    def userService
    def mailService
    def grailsApplication
    def dataSource
    def concurrent = false

    def description = "Notify admin users about new users who have completed their first five transcriptions"

    static triggers = {
        cron name: 'newUsersDigestTrigger', cronExpression: '0 0 6 * * ?' // 6:00am
//        cron name: 'newUsersDigestTrigger', cronExpression: '/30 * * * * ?' // 6:00am
    }

    def execute() {
        if (grailsApplication.config.digest.enabled) {
            log.info("New User Digest Notifier job starting at ${new Date()}")
            try {
                def sql = new Sql(dataSource)

                def newTranscribers = userService.detailsForUserIds(sql.rows("""
SELECT t.fully_transcribed_by
FROM task t
GROUP BY t.fully_transcribed_by
HAVING
  sum(CASE WHEN date_fully_transcribed < (current_timestamp - interval '1 day') THEN 1 ELSE 0 END) < 5
  AND
  count(date_fully_transcribed) >= 5;
""").collect { it[0] })

                def users = User.findAllByUserIdInList(newTranscribers*.userId)

                if (users) {
                    def recipient = grailsApplication.config.digest.address ?: "Rhiannon.Stephens@austmus.gov.au"
                    log.info("Emailling $recipient with new transcribers: $users")
                    mailService.sendMail {
                        to
                        subject "DigiVol: New Transcribers"
                        body( view:"/mail/newTranscribers",
                                model: [newTranscribers: users])
                    }
                }

            } catch (Exception e) {
                log.error("Update users job failed with exception", e)
            }
        }
        log.info("New User Digest Notifier job finishing at ${new Date()}")
    }
}
