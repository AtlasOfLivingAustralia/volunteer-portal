package au.org.ala.volunteer

import com.google.common.base.Strings
import grails.converters.JSON
import grails.gorm.transactions.Transactional

class InstitutionMessageController {

    def userService
    def institutionMessageService

    static allowedMethods = [save: "POST", update: "POST", approveMessage: "POST"]

    /**
     * Checks if the current logged in user has the access privilleges to access the admin page.
     * @param includeInstitutionAdmin if true, adds a check if user is an institution admin and returns true or false
     * as necessary.
     * @return true if access allowed. Redirects to home page with flash message if no access.
     */
    boolean checkAdminAccess(Boolean includeInstitutionAdmin) {
        if (userService.isAdmin() || (includeInstitutionAdmin && userService.isInstitutionAdmin())) {
            log.info("Admin access allowed.")
            return true
        } else {
            log.error("Admin access requested by ${userService.getCurrentUser()}, failed security check, redirecting.")
            flash.message = "You do not have permission to view this page"
            render(view: '/notPermitted')
            return false
        }
    }

    /**
     * Displays a list of previous messages.
     */
    def index() {
        if (checkAdminAccess(true)) {
            def institutionList = (userService.isSiteAdmin() ? Institution.listApproved([sort: 'name', order: 'asc']) :
                    userService.getAdminInstitutionList())

            params.sort = (params.sort ?: 'date_created')
            params.order = (params.order ?: 'desc')
            params.max = (params.max ?: 20)
            params.offset = (params.offset ?: 0)

            Institution institutionFilter = (params.institution ? Institution.get(params.long('institution')) :
                    institutionList.first() as Institution)
            def messageListDetails = institutionMessageService.getMessagesForInstitution(institutionFilter, params)

            render(view: 'index', model: [institutionList: institutionList,
                                          messageList: messageListDetails.messageList as List<InstitutionMessage>,
                                          messageCount: messageListDetails.messageCount as int])
        }
    }

    def approve() {
        if (checkAdminAccess(false)) {

            params.sort = (params.sort ?: 'date_created')
            params.order = (params.order ?: 'desc')
            params.max = (params.max ?: 20)
            params.offset = (params.offset ?: 0)

            def messageListDetails = institutionMessageService.getMessagesForApproval(params)

            render(view: 'approve', model: [messageList: messageListDetails.messageList as List<InstitutionMessage>,
                                                messageCount: messageListDetails.messageCount as int])
        }
    }

    /**
     * Displays create message form.
     */
    def create() {
        if (checkAdminAccess(true)) {
            def formInfo = getFormInfo()
            def institutionId = 0
            if (params.long('projectId')) {
                Project project = Project.get(params.long('projectId'))
                if (project) {
                    institutionId = project.institution.id
                    params.institution = institutionId
                }
            } else if (params.long('institution')) {
                institutionId = params.long('institution')
            }
            log.debug("institution: ${institutionId}")
            render(view: 'create', params: params, model: [recipientTypeList: formInfo.recipientTypeList,
                                                           institutionList  : formInfo.institutionSelectList,
                                                           institutionId    : institutionId])
        }
    }

    /**
     * Provides the ability to resend an existing message as a new message.
     *
     * @param institutionMessage the message to copy.
     */
    def resend(InstitutionMessage institutionMessage) {
        if (checkAdminAccess(true)) {
            def formInfo = getFormInfo()

            InstitutionMessage iMessage = new InstitutionMessage()
            if (institutionMessage) {
                iMessage.institution = institutionMessage.institution
                iMessage.subject = institutionMessage.subject
                iMessage.body = institutionMessage.body
                iMessage.includeContact = institutionMessage.includeContact
            }

            render(view: 'create', model: [institutionMessageInstance: iMessage,
                                           recipientTypeList         : formInfo.recipientTypeList,
                                           institutionList           : formInfo.institutionSelectList,
                                           institutionId             : (params.institution ? params.long('institution') : 0)])
        }
    }

    /**
     * Gathers the required information for the message form: recipient type list and institution list.
     * @return a Map defining the recipientType List and Institution list.
     */
    private def getFormInfo() {
        def recipientTypeList = [[key: InstitutionMessage.RECIPIENT_TYPE_USER, value: 'Single User'],
                                 [key: InstitutionMessage.RECIPIENT_TYPE_PROJECT, value: 'Users in an Expedition'],
                                 [key: InstitutionMessage.RECIPIENT_TYPE_INSTITUTION, value: 'Users in this Institution']]

        def institutionList
        if (!userService.isSiteAdmin()) {
            institutionList = userService.getAdminInstitutionList().findAll {
                !(it as Institution).isInactive
            }
        } else {
            institutionList = Institution.findAllByIsInactiveAndIsApproved(false, true, [sort: 'name', order: 'asc'])
        }

        def institutionSelectList = institutionList.collect {
            [id: it.id, name: it.name]
        }

        return [recipientTypeList: recipientTypeList, institutionSelectList: institutionSelectList]
    }

    /**
     * Displays the edit message form.
     * @param institutionMessage the message to edit.
     */
    def edit(InstitutionMessage institutionMessage) {
        if (checkAdminAccess(true)) {
            def formInfo = getFormInfo()

            log.debug("Message: ${institutionMessage}")
            log.debug("Recipient Types: ${formInfo.recipientTypeList}")
            log.debug("recipientType: ${institutionMessage.getRecipientType()}")

            // Get recipients/potential recipients if sent
            def recipientList = MessageAudit.findAllByMessage(institutionMessage)

            respond institutionMessage, model: [recipientTypeList: formInfo.recipientTypeList,
                                                recipientType: institutionMessage.getRecipientType(),
                                                institutionList: formInfo.institutionSelectList,
                                                recipientList: recipientList as List<MessageAudit>
            ]
        }
    }

    /**
     * Updates an existing message.
     */
    @Transactional
    def update() {
        log.debug("Institution Message Update...")
        if (checkAdminAccess(true)) {
            InstitutionMessage iMessage = InstitutionMessage.get(params.long('id'))
            if (!iMessage) {
                flash.message = "No message found"
                redirect(action: 'index')
            }

            def errors = []

            def messageBody = params.body as String
            if (Strings.isNullOrEmpty(messageBody)) {
                errors << "You didn't enter a message body. You cannot send an empty message."
            } else {
                if (checkMessageBody(messageBody)) {
                    iMessage.body = messageBody
                } else {
                    errors << "The Message Body text is too long. It needs to be less than ${getMaxBodyLength()} characters"
                }
            }

            iMessage.subject = params.subject as String
            iMessage.includeContact = (params.includeContact == "on")
            iMessage.dateLastUpdated = new Date()
            iMessage.lastUpdatedBy = userService.getCurrentUser()
            iMessage.save(flush: true, failOnError: true)

            if (!params.recipient) {
                if (params.recipientType == InstitutionMessage.RECIPIENT_TYPE_PROJECT) {
                    errors << "You must select at least one recipient expedition."
                } else if (params.recipientType == InstitutionMessage.RECIPIENT_TYPE_USER) {
                    errors << "You must select a recipient."
                }
            }

            if (!errors) {
                // Delete recipients and start again.
                institutionMessageService.deleteRecipients(iMessage.id)
                getRecipientsFromParameters(iMessage)

            } else {
                flash.message = formatErrorMessages(errors)
                log.debug("errors found, redirecting to edit.")
                def formInfo = getFormInfo()

                render(view: 'edit', model: [institutionMessageInstance: iMessage,
                                               recipientTypeList: formInfo.recipientTypeList,
                                               institutionList: formInfo.institutionSelectList,
                                               institutionId: (params.institution ? params.long('institution') : 0)])
                return
            }

            flash.message = message(code: 'institutionMessage.edited.message',
                    args: [iMessage.subject, getRecipientTypeLabel(params.recipientType as String)]) as String
            redirect(action: 'index', params: [institution: iMessage.institution.id])
        }
    }

    /**
     * Approves a message and sends emails to volunteers.
     */
    @Transactional
    def approveMessage() {
        if (checkAdminAccess(false)) {
            InstitutionMessage iMessage = InstitutionMessage.get(params.long('id'))
            if (!iMessage) {
                flash.message = "No message found"
                redirect(action: 'index')
                return
            }

            iMessage.approved = true
            iMessage.dateSent = new Date()
            iMessage.approvedBy = userService.getCurrentUser()
            iMessage.save(flush: true, failOnError: true)

            // Send the email, if the error count returned is 0, all went well.
            def errorCount = institutionMessageService.sendMessage(iMessage)
            if (errorCount == 0) {
                log.debug("Message sent successfully! (${errorCount} errors)")
                flash.message = message(code: 'institutionMessage.send.message',
                        args: [iMessage.subject, getRecipientTypeLabel(params.recipientType as String)],
                        default: "Institution message sent") as String
                log.debug("Flash message: ${flash.message}")
                redirect(action: 'index', params: [institution: iMessage.institution.id])
            } else {
                log.debug("Message sent with some errors! (${errorCount} errors)")
                flash.message = message(code: 'institutionMessage.send.fail',
                        args: [iMessage.subject, getRecipientTypeLabel(params.recipientType as String)],
                        default: "Institution message failed") as String
                redirect(action: 'index', params: [institution: iMessage.institution.id])
            }
        }
    }

    /**
     * Generates a list of IDs for the message recipients from the form parameters.
     * @param iMessage the message to save the recipients against.
     * @return a list of MessageRecipient objects for each recipient.
     */
    private def getRecipientsFromParameters(InstitutionMessage iMessage) {
        def recipients = []
        def recipientList = []

        log.debug("List type: ${params.recipient?.class}")
        if (params.recipient instanceof String[]) {
            Arrays.asList(params.recipient).each {
                log.debug("Adding project recipient: ${it}")
                recipientList.add(it)
            }
        } else {
            recipientList.add(params.recipient)
        }

        if (recipientList) {
            // Project or User
            recipientList.each { it ->
                // Create recipient
                MessageRecipient recipient = new MessageRecipient(message: iMessage)

                if (params.recipientType == InstitutionMessage.RECIPIENT_TYPE_PROJECT) {
                    Project project = Project.get((it as String).toLong().longValue())
                    if (project) recipient.recipientProject = project
                } else if (params.recipientType == InstitutionMessage.RECIPIENT_TYPE_USER) {
                    User user = User.get(it as long)
                    if (user) recipient.recipientUser = user
                }

                recipient.save(flush: true, failOnError: true)
                iMessage.addToRecipients(recipient)
                recipients.add(recipient)
            }
        } else {
            // institution
            MessageRecipient recipient = new MessageRecipient(message: iMessage)
            recipient.recipientInstitution = iMessage.institution
            recipient.save(flush: true, failOnError: true)
            recipients.add(recipient)
        }

        return recipients
    }

    /**
     * Returns the max size value for the body parameter.
     * @return the max size
     */
    private int getMaxBodyLength() {
        return InstitutionMessage.constrainedProperties['body']?.maxSize ?: Integer.MAX_VALUE
    }

    /**
     * Checks the message body parameter to ensure it's not larger than the Database column constraint.
     * @param msgBody the body text (after markdown).
     * @return true if the message body is okay to save, false if it is not (i.e. too big).
     */
    private boolean checkMessageBody(String msgBody) {
        def maxSize = getMaxBodyLength()
        return msgBody.length() <= maxSize
    }

    /**
     * Saves a new message to the Database.
     */
    @Transactional
    def save() {
        log.debug("Institution Message Save...")

        if (checkAdminAccess(true)) {
            log.debug("Params: ${params}")
            def errors = []
            InstitutionMessage iMessage = new InstitutionMessage()

            def institution = Institution.get(params.long('institution'))
            if (institution) {
                iMessage.institution = institution
            } else {
                errors << "The selected Institution does not exist."
            }

            def messageBody = params.body as String
            if (Strings.isNullOrEmpty(messageBody)) {
                errors << "You didn't enter a message body. You cannot send an empty message."
            } else {
                if (checkMessageBody(messageBody)) {
                    iMessage.body = messageBody
                } else {
                    errors << "The Message Body text is too long. It needs to be less than ${getMaxBodyLength()} characters"
                }
            }

            iMessage.subject = params.subject as String
            iMessage.dateCreated = new Date()
            iMessage.createdBy = userService.getCurrentUser()
            iMessage.includeContact = (params.includeContact == "on")

            if (!params.recipient) {
                if (params.recipientType == InstitutionMessage.RECIPIENT_TYPE_PROJECT) {
                    errors << "You must select at least one recipient expedition."
                } else if (params.recipientType == InstitutionMessage.RECIPIENT_TYPE_USER) {
                    errors << "You must select a recipient."
                }
            }

            if (!errors) {
                iMessage.save(flush: true, failOnError: true)
                getRecipientsFromParameters(iMessage)

            } else {
                flash.message = formatErrorMessages(errors)
                log.debug("errors found, redirecting to create.")
                log.debug("Errors: ${errors}")
                def formInfo = getFormInfo()

                render(view: 'create', model: [institutionMessageInstance: iMessage,
                                               recipientTypeList: formInfo.recipientTypeList,
                                               institutionList: formInfo.institutionSelectList,
                                               institutionId: (params.institution ? params.long('institution') : 0)])
                return
            }

            // Notify Site Admins that there's a new message to be approved.
            institutionMessageService.sendAdminNotification(iMessage)

            flash.message = message(code: 'institutionMessage.created.message',
                                    args: [iMessage.subject, getRecipientTypeLabel(params.recipientType as String)]) as String
            redirect(action: 'index', params: [institution: institution.id])
        }
    }

    /**
     * Delete's a message. Only a non-approved message can be deleted by a Site Admin.
     */
    @Transactional
    def delete() {
        log.debug("Institution Message Delete...")

        if (checkAdminAccess(false)) {
            def messageId = params.long('id')
            def iMessage = InstitutionMessage.get(messageId)
            params.remove('id')

            if (iMessage) {
                // Check if approved, if it is, don't allow delete.
                if (iMessage.approved) {
                    flash.message = message(code: 'institutionMessage.delete.notWhenApproved',
                            default: "You cannot delete a message that has already been sent.") as String
                    redirect(action: "index", params: [institution: iMessage.institution.id])
                } else {
                    def institutionId = iMessage.institution.id
                    iMessage.delete(flush: true)
                    flash.message = message(code: 'institutionMessage.deleted.message',
                             args: [iMessage.subject]) as String
                    redirect(action: "index", params: [institution: institutionId])
                }
            } else {
                flash.message = message(code: 'default.not.found.message',
                         args: [message(code: 'institutionMessage.default.label', default: 'Institution Message'),
                                messageId]) as String
                redirect(action: "index")
            }
        }
    }

    /**
     * Returns the recipient type label from the i18n library
     * @param recipientType the type to query.
     * @return the type's label.
     */
    private getRecipientTypeLabel(String recipientType) {
        def label = ""
        switch (recipientType) {
            case InstitutionMessage.RECIPIENT_TYPE_USER:
                label = message(code: 'user.label', default: 'User') as String
                break
            case InstitutionMessage.RECIPIENT_TYPE_PROJECT:
                label = message(code: 'project.name.label', default: 'Expedition') as String
                break
            case InstitutionMessage.RECIPIENT_TYPE_INSTITUTION:
                label = message(code: 'institution.label', default: 'Institution') as String
        }

        return label
    }

    /**
     * Formats  alist of error messages into HTML for display.
     * @param messages the list of messages.
     * @param title the title or prefix text for the list.
     * @return the HTML code for the list to display.
     */
    private String formatErrorMessages(List messages, String title = "The following errors have occurred:") {
        def sb = new StringBuilder("${title}<ul>")
        messages.each {
            sb << "<li>" + it + "</li>"
        }
        sb << "<ul>"
        return sb.toString()
    }

    /**
     * Action to record the user having opted-out of institution message capability.
     * @param id the user ID
     * @param refKey the reference verification key. Both this and userID are required to invoke the action.
     */
    @Transactional
    def optOut(User requestingUser) {
        // Check params has a user ID and refKey hash.
        User user = userService.getCurrentUser()
        log.debug("Opt out requesting user: ${requestingUser}")
        log.debug("Current user: ${user}")

        if (!params.long('id') || !params.refKey || !requestingUser || !user) {
            render(view: '/notPermitted')
            return
        }

        // Check the user ID is the same as the one for the logged in user and confirm the user key.
        def verificationRefKey = userService.getUserHash(user)
        def success = false
        if (user.id == params.long('id') && verificationRefKey == (params.refKey as String)) {
            // Matches, process opt out.
            // Check there isn't already one there for some reason.
            if (!UserOptOut.findByUser(user)) {
                UserOptOut optOut = new UserOptOut(user: user)
                optOut.dateCreated = new Date(System.currentTimeMillis())
                optOut.save(flush: true, failOnError: true)
                success = true
            }
        }

        render (view: 'optOut', model: [success: success])
    }

}
