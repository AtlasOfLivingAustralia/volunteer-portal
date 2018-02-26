package au.org.ala.volunteer

import grails.util.Environment
import grails.util.Holders
import groovy.sql.Sql

class NewUserDigestNotifierJob {
    def userService
    def mailService
    def dataSource
    def concurrent = false

    def description = "Notify admin users about new users who have completed their first five transcriptions"

    static triggers = {
        if (Environment.current == Environment.DEVELOPMENT && Holders.config.getProperty('digest.debug', Boolean,false)) {
            log.info("Enabling 30s trigger")
            cron name: 'newUsersDigestTrigger', cronExpression: '/30 * * * * ?' // every 30s
        } else {
            log.info("Enabling 6am trigger")
            cron name: 'newUsersDigestTrigger', cronExpression: '0 0 6 * * ?' // 6:00am
        }
    }

    def execute() {
        if (grailsApplication.config.getProperty('digest.enabled', Boolean, false)) {
            def recipient = grailsApplication.config.getProperty('digest.address')
            def threshold = grailsApplication.config.getProperty('digest.threshold', Integer, 5)
            if (!recipient) {
                throw new IllegalStateException("New user transcriptions digest email is enabled but no email address (digest.address) was specified")
            }
            log.info("New User Digest Notifier job starting at ${new Date()}")
            try {
                def sql = new Sql(dataSource)

                def userIds = sql.rows("""
SELECT t.fully_transcribed_by
FROM task t
GROUP BY t.fully_transcribed_by
HAVING
  sum(CASE WHEN date_fully_transcribed < (current_timestamp - interval '1 day') THEN 1 ELSE 0 END) < ?
  AND
  count(date_fully_transcribed) >= ?;
""", [threshold, threshold]).collect { it[0] }
                //def newTranscribers = userService.detailsForUserIds(userIds)

                if (userIds) {
                    log.info("Found {} user ids for new user digest", userIds.size())
                    def users = User.findAllByUserIdInList(userIds)

                    if (users) {

                        log.info("Emailling $recipient with new transcribers: $users")
                        mailService.sendMail {
                            to recipient
                            subject "DigiVol: New Transcribers"
                            body( view:"/mail/newTranscribers",
                                    model: [newTranscribers: users])
                        }
                    }
                } else {
                    log.debug("No new users found for digest")
                }
             } catch (Exception e) {
                log.error("Update users job failed with exception", e)
            }
        }
        log.info("New User Digest Notifier job finishing at ${new Date()}")
    }
}
