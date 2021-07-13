package au.org.ala.volunteer

class QueuedEmailMessage {

    static final String FORMAT_HTML = 'html'
    static final String FORMAT_TEXT = 'text'

    String emailAddress
    String subject
    String message

    String toString() {
        return "Queued Email to: ${emailAddress}, with subject: ${subject}"
    }
}
