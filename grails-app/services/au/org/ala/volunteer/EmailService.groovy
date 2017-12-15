package au.org.ala.volunteer

import grails.core.GrailsApplication

import java.util.concurrent.ConcurrentLinkedQueue

class EmailService {

    static transactional = false

    private static Queue<QueuedEmailMessage> _queuedMessages = new ConcurrentLinkedQueue<QueuedEmailMessage>()

    def mailService
    def logService
    GrailsApplication grailsApplication

    /**
     * Sends a message immediately to the configured SMTP server (typically localhost on port 25)
     * @param emailAddress The email address to send the message
     * @param subj The subject line
     * @param message The body of the message
     * @return The mail message
     */
    def sendMail(String emailAddress, String subj, String message) {
        log.info("Sending email to ${emailAddress} - ${subj}")
        def fromAddress = grailsApplication.config.getProperty('mail.fromAddress', "noreply@volunteer.ala.org.au")
        mailService.sendMail {
            to emailAddress
            from fromAddress
            subject subj
            body message
        }
    }

    /**
     * Pushes a mail message on a queue to be sent asynchronously. The frequency of the queue being processed is controlled by the {@link ProcessMailQueueJob}
     * <p />
     * The message will eventually be sent via #sendMail
     *
     * @param emailAddress The email address to send to
     * @param subject The subject line of the message
     * @param message The message body
     */
    def pushMessageOnQueue(String emailAddress, String subject, String message) {
        log.info("Queuing email message to ${emailAddress} - ${subject}")
        def qmsg = new QueuedEmailMessage(emailAddress: emailAddress, subject: subject, message: message)
        _queuedMessages.add(qmsg)
    }

    /**
     * Process the queue holding any unsent mail messages. This should only be called by the {@link ProcessMailQueueJob}
     */
    def sendQueuedMessages() {
        int messageCount = 0
        QueuedEmailMessage message
        while (messageCount < 100 && (message = _queuedMessages.poll()) != null) {
            if (message) {
                sendMail(message.emailAddress, message.subject, message.message)
                messageCount++
            }
        }
    }

}
