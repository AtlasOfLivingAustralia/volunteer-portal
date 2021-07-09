package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml

class InstitutionMessage {

    long id
    String subject
    @SanitizedHtml
    String body
    Date dateCreated
    User createdBy
    Institution institution
    Date dateLastUpdated
    User lastUpdatedBy
    boolean approved = false
    boolean includeContact = false
    Date dateSent
    User approvedBy

    static hasMany = [recipients: MessageRecipient, auditRecipients: MessageAudit]

    static final String RECIPIENT_TYPE_USER = 'user'
    static final String RECIPIENT_TYPE_PROJECT = 'project'
    static final String RECIPIENT_TYPE_INSTITUTION = 'institution'

    static mapping = {
        table 'message'
        approved defaultValue: false
        includeContact defaultValue: false
        recipients cascade: 'all,delete-orphan'
    }

    static constraints = {
        subject blank: false, nullable: false, maxSize: 255
        body blank: true, nullable: true, maxSize: 4000
        dateCreated nullable: false
        createdBy nullable: false
        institution nullable: false
        dateLastUpdated nullable: true
        lastUpdatedBy nullable: true
        dateSent nullable: true
        approvedBy nullable: true
    }

    String toString() {
        return "Message sent ${dateSent}, subject: ${subject}, recipients: ${recipients}"
    }

    /**
     * Returns the type of recipient. Project is the only type to have multiple recipients. When there are multiple
     * recipients, if the type is not project, null is returned.
     * @return the type of recipient (user, project or institution).
     */
    def getRecipientType() {
        if (!recipients) return null
        def recipient = recipients.first()
        if (recipient.recipientUser) return RECIPIENT_TYPE_USER
        else if (recipient.recipientProject) return RECIPIENT_TYPE_PROJECT
        else return RECIPIENT_TYPE_INSTITUTION
    }

    /**
     * Returns the User object for the User recipient.
     * @return The User recipient. Returns null if the recipient isn't a User.
     */
    def getRecipientUser() {
        if (getRecipientType() != RECIPIENT_TYPE_USER) return null
        else {
            def recipientUser = recipients.first() as MessageRecipient
            return recipientUser.recipientUser
        }
    }

    /**
     * Returns a list of project recipients.
     * @return a list of Project recipients. Returns null if the recipient isn't one or more projects.
     */
    List<Project> getRecipientProjectList() {
        if (getRecipientType() != RECIPIENT_TYPE_PROJECT) return null
        else {
            def projectList = []
            recipients.each { recipient ->
                Project project = recipient.recipientProject
                if (project) projectList.add(project)
            }
            return projectList
        }
    }

    /**
     * Returns a string summary of the recipients of the message.
     * @return If recipient is a user, returns the user's name. If project, returns the project names. If institution,
     * the institution name. Returns 'No recipient' if no recipients exist.
     */
    def getRecipientSummary() {
        if (getRecipientType() == RECIPIENT_TYPE_USER) {
            return "${getRecipientUser().displayName} (Single User)"
        } else if (getRecipientType() == RECIPIENT_TYPE_PROJECT) {
            if (getRecipientProjectList().size() > 1) {
                def recipientList = getRecipientProjectList()*.name.join(',\n')
                return "${getRecipientProjectList().size()} Expeditions (${recipientList})"
            } else {
                return "${getRecipientProjectList().first().name} (Expedition)"
            }
        } else if (getRecipientType() == RECIPIENT_TYPE_INSTITUTION) {
            return "${institution.name} (Institution)"
        } else {
            return 'No recipient'
        }
    }
}
