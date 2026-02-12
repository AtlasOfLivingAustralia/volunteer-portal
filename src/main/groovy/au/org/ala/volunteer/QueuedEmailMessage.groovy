package au.org.ala.volunteer

import org.joda.time.DateTime

class QueuedEmailMessage {

    static final String FORMAT_HTML = 'html'
    static final String FORMAT_TEXT = 'text'

    String emailAddress
    String subject
    String message
    DateTime timeQueued = new DateTime()
    int timeOutCheckForDuplicate = 120 // seconds

    String toString() {
        return "Queued Email to: ${emailAddress}, with subject: ${subject}"
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        QueuedEmailMessage that = (QueuedEmailMessage) o

        if (emailAddress != that.emailAddress) return false
        if (message != that.message) return false
        if (subject != that.subject) return false

        // If I've been queued in the last x seconds then consider myself equal to another message with the same content
        if (timeQueued?.isBefore(DateTime.now().minusSeconds(timeOutCheckForDuplicate))) {
            return false
        }

        return true
    }
}
