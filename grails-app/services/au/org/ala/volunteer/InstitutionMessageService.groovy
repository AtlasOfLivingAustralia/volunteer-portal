package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import grails.web.servlet.mvc.GrailsParameterMap
import groovy.sql.Sql
import org.hibernate.Session
import org.springframework.context.i18n.LocaleContextHolder

import javax.sql.DataSource

@Transactional
class InstitutionMessageService {

    def dataSource
    def userService
    def institutionService
    def emailService
    def groovyPageRenderer
    def grailsApplication
    def messageSource

    def getMessagesForApproval(GrailsParameterMap params) {
        String query = """\
            select m.id
            from message m
            left join vp_user u2 on (created_by_id = u2.id)
            where m.approved = false """.stripIndent()

        def sortClause = "order by "
        switch (params.sort) {
            case 'sender':
                sortClause += """\
                    concat(u2.first_name, ' ', u2.last_name) ${params?.order} """.stripIndent()
                break
            case 'subject':
                sortClause += "m.subject ${params?.order} "
                break
            case 'date_created':
            default:
                sortClause += "m.date_created ${params?.order}"
                break
        }

        def messageList = []
        def sql = new Sql(dataSource as DataSource)
        def selectQuery = "${query} ${sortClause}"
        int offset = params.int('offset') + 1
        int max = params.int('max')

        sql.eachRow(selectQuery.toString(), offset, max) { row ->
            InstitutionMessage institutionMessage = InstitutionMessage.get(row.id as long)
            if (institutionMessage) {
                messageList.add(institutionMessage)
            }
        }

        def totalMessages = sql.firstRow("select count(*) as message_count from (" + query + ") messages")

        log.debug("total messages: ${totalMessages?.message_count}")
        sql.close()

        [messageList: messageList, messageCount: (totalMessages?.message_count) ?: 0]
    }

    /**
     * Returns a list of institution messages for a given institution.
     * @param institution the institution to query
     * @param params the query parameters (sort, order etc)
     * @return Map containing messageList(List) and messageCount(int)
     */
    def getMessagesForInstitution(Institution institution, def params) {
        String query = """\
            select m.id
            from message m
            left join vp_user u2 on (created_by_id = u2.id)
            where m.institution_id = :institutionId """.stripIndent()

        def sortClause = "order by "
        switch (params.sort) {
//            case 'recipient':
//                sortClause += """\
//                    (case when (recipient_user_id is not null)
//                            then concat(u1.first_name, ' ', u1.last_name)
//                        when (recipient_project_id is not null)
//                            then project.name
//                        else institution.name end) ${params?.order} """.stripIndent()
//                break
            case 'sender':
                sortClause += """\
                    concat(u2.first_name, ' ', u2.last_name) ${params?.order} """.stripIndent()
                break
            case 'subject':
                sortClause += "m.subject ${params?.order} "
                break
            case 'status':
                sortClause += "m.approved ${params?.order}, m.id ${params?.order}"
                break
            case 'date_created':
            default:
                sortClause += "m.date_created ${params?.order}"
                break
        }

        def queryParameters = [institutionId: institution.id]
        def messageList = []
        def sql = new Sql(dataSource)
        sql.eachRow("${query} ${sortClause}", queryParameters, (params.offset as int) + 1, params.max as int) { row ->
            InstitutionMessage institutionMessage = InstitutionMessage.get(row.id as long)
            if (institutionMessage) {
                messageList.add(institutionMessage)
            }
        }

        def totalMessages = sql.firstRow("select count(*) as message_count from (${query}) messages", queryParameters)

        log.debug("total messages: ${totalMessages?.message_count}")
        sql.close()

        [messageList: messageList, messageCount: (totalMessages?.message_count) ?: 0]
    }

    /**
     * Delete's all recipients for a message. This is utilised by the update method of the controller. It's simpler to
     * delete all the existing recipients and re-create them.
     * @param messageId the ID of the message.
     */
    def deleteRecipients(long messageId) {
        try {
            MessageRecipient.withNewSession { Session session ->
                InstitutionMessage iMessage = InstitutionMessage.get(messageId)
                def recipients = MessageRecipient.findAllByMessage(iMessage)

                recipients.each {
                    it.delete()
                }

                session.flush()
            }
        } catch (Exception e) {
            log.error("Error encountered deleting recipients", e)
        }
    }

    /**
     * Generates the list of User objects to send the message to.
     * @param iMessage the message being sent
     * @return a List of User objects representing the recipients of the message.
     */
    def getRecipientsForMessagePreSend(InstitutionMessage iMessage) {
        def recipientList = new ArrayList<User>()
        if (iMessage.getRecipientType() == InstitutionMessage.RECIPIENT_TYPE_USER) {
            User user = iMessage.getRecipientUser()
            recipientList.add(user)
        } else if (iMessage.getRecipientType() == InstitutionMessage.RECIPIENT_TYPE_PROJECT) {
            def projectList = iMessage.getRecipientProjectList()
            projectList.each {
                def users = getActiveUsersForProject(it) as List<User>
                users.each { user ->
                    recipientList.add(user)
                }

                // Get users from user roles (may not have transcribed/validated).
                //def userRoles = UserRole.findAllByProjectOrInstitution(it, it.institution)
                //userRoles?.each {userRole ->
                //    recipientList.add(userRole.user)
                //}
            }

            // Remove duplicates
            recipientList.unique { a, b ->
                a.id <=> b.id
            }
        } else if (iMessage.getRecipientType() == InstitutionMessage.RECIPIENT_TYPE_INSTITUTION) {
            def userList = institutionService.getActiveUsersForInstitution(iMessage.institution)
            userList.each {
                User user = User.get(it.id as long)
                if (user) recipientList.add(user)
            }
        }

        recipientList
    }

    /**
     * Returns a list of active users for a given project, including validators. The list is sorted by name
     * (lastName+firstName).
     * @param project the project to query.
     * @return the list of User objects
     */
    def getActiveUsersForProject(Project project) {
        if (!project) return null

        String query = """\
            select distinct tr.fully_transcribed_by as user_id
            from transcription tr
            join task ta on (ta.id = tr.task_id)
            join project p on (p.id = tr.project_id)
            where tr.fully_transcribed_by is not null
              and p.id = :projectId
            union
            select distinct tr.fully_validated_by as user_id
            from transcription tr
            join task ta on (ta.id = tr.task_id)
            join project p on (p.id = tr.project_id)
            where tr.fully_validated_by is not null
              and p.id = :projectId """.stripIndent()

        def sql = new Sql(dataSource)
        def results = []

        sql.eachRow(query, [projectId: project.id]) { row ->
            User user = User.findByUserId(row.user_id as String)
            if (user) {
                results.add(user)
            }
        }

        // Sort on name
        results.sort { a, b ->
            "${a.lastName}${a.firstName}" <=> "${b.lastName}${b.firstName}"
        }

        sql.close()
        results
    }

    /**
     * Sends a notification email to the Site Admin email address notifying of a new message waiting to be approved.
     * @param iMessage the message waiting to send.
     */
    def sendAdminNotification(InstitutionMessage iMessage) {
        if (!iMessage) return

        def messageBody = groovyPageRenderer.render(view: '/institutionMessage/newMessageNotification',
                model: [institution: iMessage.institution.name,
                        createdBy: iMessage.createdBy.displayName,
                        recipients: iMessage.getRecipientSummary()])
        def recipient = grailsApplication.config.getProperty('notifications.default.address', String, '') as String
        def appName = messageSource.getMessage("default.application.name", null, "DigiVol",
                LocaleContextHolder.locale) as String
        def iMessageLabel = messageSource.getMessage("institutionMessage.default.label", null,
                "Institution Message", LocaleContextHolder.locale) as String

        def subject = "${appName} ${iMessageLabel} created"
        emailService.sendMail(recipient, subject, messageBody)
    }

    /**
     * Sends the institution message. The recipients are retrieved according to the selected recipient type and then
     * queues a new email for each recipient and a MessageAudit record is created for each one.
     * Opted out users are ignored
     * @param iMessage the message to send
     * @return the number of errors found with recipients. For example, if a user is opted out, an error generating the
     * message occurs, the user has no email address or some other error occurred while queueing the message.
     */
    def sendMessage(InstitutionMessage iMessage) {
        if (!iMessage) return false

        // Get the message recipients
        def errorCount = 0
        def recipientList = getRecipientsForMessagePreSend(iMessage)
        def serverUrl = grailsApplication.config.getProperty('grails.serverURL', String, '')
        if (!serverUrl) {
            throw new Exception("Error sending institution message. Could not find serverUrl configuration setting. " +
                    "This is required for email messages. Contact DigiVol Admins.")
        }

        // For each user, render the template, add email to queue.
        recipientList.each { recipient ->
            MessageAudit audit = new MessageAudit(recipientUser: recipient,
                    message: iMessage,
                    dateSent: new Date())

            // If there's no email for the user, don't go any further.
            if (!recipient.email) {
                audit.sendStatus = MessageAudit.STATUS_NO_ADDRESS
                audit.save(failOnError: true, flush: true)
                errorCount++
                return
            }

            // If the user has opted out of these messages, go no further.
            def optOutStatus = UserOptOut.findByUser(recipient)
            if (optOutStatus) {
                audit.sendStatus = MessageAudit.STATUS_OPT_OUT
                audit.save(failOnError: true, flush: true)
                errorCount++
                return
            }

            def userVerificationHash = userService.getUserHash(recipient)

            // Render the message, if errors, set the status and move on.
            String message
            try {
                message = groovyPageRenderer.render(view: '/institutionMessage/messageTemplate',
                    model: [subject                  : iMessage.subject,
                            inboxPreview             : "A message from ${iMessage.institution.name}",
                            serverUrl                : serverUrl,
                            institutionName          : iMessage.institution.name,
                            messageBody              : iMessage.body,
                            institutionId            : iMessage.institution.id,
                            senderName               : iMessage.createdBy.displayName,
                            institutionIncludeContact: iMessage.includeContact,
                            institutionContactName   : iMessage.institution.contactName,
                            recipientEmail           : recipient.email,
                            recipient_id             : recipient.id,
                            refKey                   : userVerificationHash // optout ref key
                    ])
            } catch (Exception e) {
                log.error("Failed creating mail message render for institution message for user ${recipient}: ${e.getMessage()}", e)
                audit.sendStatus = MessageAudit.STATUS_MESSAGE_RENDER_ERROR
                audit.save(failOnError: true, flush: true)
                errorCount++
                return
            }

            // Send to the queue, if errors, set the status and move on.
            if (message) {
                try {
                    def replyTo = (iMessage.includeContact) ? iMessage.institution.contactEmail : null
                    DetailedEmailMessage queuedMessage = new DetailedEmailMessage(emailAddress: recipient.email,
                                            subject: iMessage.subject,
                                            message: message,
                                            replyTo: replyTo,
                                            formatType: DetailedEmailMessage.FORMAT_HTML)
                    emailService.pushMessageOnQueue(queuedMessage)
                    audit.sendStatus = MessageAudit.STATUS_SEND_OK
                    audit.save(failOnError: true, flush: true)
                } catch (Exception e) {
                    log.error("Failed creating mail message render for institution message for user ${recipient}: ${e.getMessage()}", e)
                    audit.sendStatus = MessageAudit.STATUS_SEND_ERROR
                    audit.save(failOnError: true, flush: true)
                    errorCount++
                }
            }
        }

        return errorCount
    }


}
