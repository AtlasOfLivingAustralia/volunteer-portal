package au.org.ala.volunteer

class MessageRecipient {

    long id
    InstitutionMessage message
    User recipientUser
    Project recipientProject
    Institution recipientInstitution

    static constraints = {
        message nullable: false
        recipientUser nullable: true
        recipientProject nullable: true
        recipientInstitution nullable: true
    }

    static mapping = {
        version false
    }

    String toString() {
        return "Recipient (message ID: ${message.id}) " +
                "${(recipientUser ? "User: ${recipientUser}" : (recipientProject ? "Project: ${recipientProject}" : "Institution ${recipientInstitution}"))}"
    }
}
