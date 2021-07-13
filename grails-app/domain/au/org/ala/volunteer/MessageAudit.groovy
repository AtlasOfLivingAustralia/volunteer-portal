package au.org.ala.volunteer

class MessageAudit {

    InstitutionMessage message
    User recipientUser
    Date dateSent
    int sendStatus

    static final int STATUS_NOT_SENT = 0
    static final int STATUS_OPT_OUT = 1
    static final int STATUS_NO_ADDRESS = 2
    static final int STATUS_SEND_ERROR = 3
    static final int STATUS_MESSAGE_RENDER_ERROR = 4
    static final int STATUS_SEND_OK = 99

    static mapping = {
        table 'message_recipient_audit'
        version false
        sendStatus defaultValue: 0
    }

    static constraints = {
        message nullable: false
        recipientUser nullable: false
        dateSent nullable: false
    }

    /**
     * Returns a label for each status type.
     * @param status the status
     * @return the label
     */
    static def getStatusLabel(int status) {
        switch(status) {
            case STATUS_NOT_SENT:
                return "Not sent"
            case STATUS_OPT_OUT:
                return "Opted Out"
            case STATUS_NO_ADDRESS:
                return "No email address on file"
            case STATUS_SEND_ERROR:
                return "Send error"
            case STATUS_MESSAGE_RENDER_ERROR:
                return "Error rendering message"
            case STATUS_SEND_OK:
                return "Sent OK"
        }
    }
}
