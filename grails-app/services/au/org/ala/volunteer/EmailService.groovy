package au.org.ala.volunteer

import com.google.common.base.Strings
import grails.core.GrailsApplication
import grails.util.Environment
import org.joda.time.DateTime

import java.util.concurrent.ConcurrentLinkedQueue

class EmailService {

    private static Queue<QueuedEmailMessage> _queuedMessages = new ConcurrentLinkedQueue<QueuedEmailMessage>()
    private Map<String, DateTime> _recentMessages = [:]  // messageKey -> timestamp

    def mailService
    GrailsApplication grailsApplication

    /*
    def sendMail(String emailAddress, String subj, String message) {
        log.info("Sending email to ${emailAddress} - ${subj}")
        def fromAddress = grailsApplication.config.getProperty('grails.mail.default.from', "noreply@volunteer.ala.org.au")
        def subjPrefix = grailsApplication.config.getProperty('grails.mail.subjectPrefix', String, '')
        log.debug("from address: ${fromAddress}")
        log.debug("subjPrefix: ${subjPrefix}")
        def subjectToSend = (!Strings.isNullOrEmpty(subjPrefix)) ? "[${subjPrefix}] ${subj}" : subj

        mailService.sendMail {
            to emailAddress
            from fromAddress
            subject subjectToSend
            body message
        }
    }
    */

    /**
     * Sends a message immediately to the configured SMTP server (typically localhost on port 25)
     * @param emailAddress The email address to send the message
     * @param subj The subject line
     * @param message The body of the message
     * @return The mail message
     */
    def sendMail(String emailAddress, String subj, String message) {
        sendMail(new QueuedEmailMessage(emailAddress: emailAddress, subject: subj, message: message))
    }

    /**
     * Sends a message immediately to the configured SMTP server (typically localhost on port 25)
     * @param queuedEmailMessage the Email message object containing the email details.
     * @return The mail message
     */
    def sendMail(QueuedEmailMessage queuedEmailMessage) {
        if (!queuedEmailMessage) {
            log.warn("No email/recipient to send to!")
            return
        }
        log.info("Sending email to ${queuedEmailMessage}")

        def fromAddress = grailsApplication.config.getProperty('grails.mail.default.from', "DigiVol <noreply@volunteer.ala.org.au>")
        log.debug("from address: ${fromAddress}")

        def subjPrefix = grailsApplication.config.getProperty('grails.mail.subjectPrefix', String, '')
        log.debug("subjPrefix: ${subjPrefix}")
        def subjectToSend = (!Strings.isNullOrEmpty(subjPrefix)) ? "[${subjPrefix}] ${queuedEmailMessage.subject}" : queuedEmailMessage.subject

        // If replyTo parameter is not null, use that, else use default (no-reply).
        def replyToAddress = fromAddress
        def formatType = QueuedEmailMessage.FORMAT_TEXT
        if (queuedEmailMessage instanceof DetailedEmailMessage) {
            if (!Strings.isNullOrEmpty(queuedEmailMessage.replyTo)) replyToAddress = queuedEmailMessage.replyTo
            formatType = queuedEmailMessage.formatType
            log.debug("replyTo address: ${replyToAddress}")
            log.debug("formatType: ${formatType}")
        }

        if (Environment.current != Environment.PRODUCTION || !Strings.isNullOrEmpty(subjPrefix)) {
            String originalRecipient = queuedEmailMessage.emailAddress
            queuedEmailMessage.emailAddress = grailsApplication.config.getProperty('notifications.default.address', "digivol@austmus.gov.au")
            if (QueuedEmailMessage.FORMAT_TEXT.equals(formatType)) {
                queuedEmailMessage.message = "This message is addressed to: [${originalRecipient}]\n\n" + queuedEmailMessage.message
            } else if (QueuedEmailMessage.FORMAT_HTML.equals(formatType)) {
                queuedEmailMessage.message = "This message is addressed to: [<pre>${originalRecipient}</pre>]<br/><br/>" + queuedEmailMessage.message
            }

            log.debug("Test/Dev environment, sending to notification email instead: ${queuedEmailMessage.emailAddress}")
        }

        mailService.sendMail {
            to "${queuedEmailMessage.emailAddress}"
            from fromAddress
            replyTo "${replyToAddress}"
            subject subjectToSend
            switch (formatType) {
                case DetailedEmailMessage.FORMAT_HTML:
                    html queuedEmailMessage.message
                    break
                default:
                    text queuedEmailMessage.message
                    break
            }
        }
    }

    /**
     * Pushes a mail message on a queue to be sent asynchronously. The frequency of the queue being processed is
     * controlled by the {@link ProcessMailQueueJob}
     * <p />
     * The message will eventually be sent via #sendMail
     *
     * @param emailAddress The email address to send to
     * @param subject The subject line of the message
     * @param message The message body
     */
    def pushMessageOnQueue(String emailAddress, String subject, String message) {
        log.debug("Queuing email message to ${emailAddress} - ${subject}")

        def qmsg = new QueuedEmailMessage(emailAddress: emailAddress, subject: subject, message: message)
        _queuedMessages.add(qmsg)
    }

    /**
     * Pushes a mail message on a queue to be sent asynchronously. The frequency of the queue being processed is
     * controlled by the {@link ProcessMailQueueJob}
     * <p />
     * The message will eventually be sent via #sendMail
     *
     * @param emailAddress The email address to send to
     * @param subject The subject line of the message
     * @param message The message body
     * @param timeOutCheckForDuplicate Time in seconds to check for duplicate messages (same recipient, subject and body) before adding to the queue.
     */
    def pushMessageOnQueue(String emailAddress, String subject, String message, int timeOutCheckForDuplicate) {
        log.debug("Queuing email message to ${emailAddress} - ${subject}")

        String messageKey = "${emailAddress}:${subject}:${message}".toString()
        DateTime lastQueued = _recentMessages[messageKey]

        // Check if this exact message was queued recently
        if (lastQueued && lastQueued.isAfter(DateTime.now().minusSeconds(timeOutCheckForDuplicate))) {
            log.debug("Duplicate message skipped (queued ${timeOutCheckForDuplicate} seconds ago)")
            return
        }

//        def qmsg = new QueuedEmailMessage(emailAddress: emailAddress, subject: subject, message: message, timeOutCheckForDuplicate: timeOutCheckForDuplicate)
//        if (!_queuedMessages.contains(qmsg)) _queuedMessages.add(qmsg)
        def qmsg = new QueuedEmailMessage(emailAddress: emailAddress, subject: subject, message: message)
        _queuedMessages.add(qmsg)
        _recentMessages[messageKey] = new DateTime()  // Track timestamp

        // Cleanup old entries (optional, prevents memory leak)
        cleanupOldTrackedMessages()
    }

    /**
     * Cleanup old entries from the _recentMessages map to prevent memory growth. This should be called periodically, e.g. after adding a new message.
     * It removes entries that are older than a certain threshold (e.g. 10 minutes).
     */
    private void cleanupOldTrackedMessages() {
        DateTime cutoff = DateTime.now().minusSeconds(600)  // Keep 10 minutes of history
        _recentMessages.entrySet().removeAll { it.value.isBefore(cutoff) }
    }

    /**
     * Pushes a message onto a queue to be sent asynchronously. The frequency of the queue being processed is
     * controlled by the {@link ProcessMailQueueJob}
     * <p />
     * The message will eventually be sent via #sendMail
     *
     * @param queuedEmailMessage the {@link QueuedEmailMessage} object, containing the message details, to send.
     */
    def pushMessageOnQueue(QueuedEmailMessage queuedEmailMessage) {
        if (!queuedEmailMessage) {
            log.warn("No email message to queue!")
        }
        log.debug("Queuing email message to ${queuedEmailMessage.emailAddress} - ${queuedEmailMessage.subject}")
        _queuedMessages.add(queuedEmailMessage)
    }

    /**
     * Process the queue holding any unsent mail messages. This should only be called by the {@link ProcessMailQueueJob}
     */
    def sendQueuedMessages() {
        int messageCount = 0
        QueuedEmailMessage message
        while (messageCount < 100 && (message = _queuedMessages.poll()) != null) {
            if (message) {
                log.debug("Sending message to: ${message.emailAddress} - ${message.subject}")
                sendMail(message)
                messageCount++
            }
        }
    }

}
