package au.org.ala.volunteer

import org.joda.time.DateTime

class QueuedEmailMessage {

    static final String FORMAT_HTML = 'html'
    static final String FORMAT_TEXT = 'text'

    String emailAddress
    String subject
    String message
    DateTime timeQueued = new DateTime()

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

        return true
    }

    int hashCode() {
        int result = emailAddress?.hashCode() ?: 0
        result = 31 * result + subject?.hashCode() ?: 0
        result = 31 * result + message?.hashCode() ?: 0
        return result
    }
}
