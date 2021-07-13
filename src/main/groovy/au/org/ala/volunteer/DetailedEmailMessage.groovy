package au.org.ala.volunteer

/**
 * Detailed Email message for queueing/sending. Contains replyTo and formatType field (to allow HTML emails).
 * @see {@link QueuedEmailMessage}
 */
class DetailedEmailMessage extends QueuedEmailMessage {

    String replyTo
    String formatType = FORMAT_HTML

}
