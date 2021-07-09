<%@ page import="java.text.SimpleDateFormat; au.org.ala.volunteer.InstitutionMessage" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.ala.skin}">
    <g:set var="entityName" value="${message(code: 'institutionMessage.default.label', default: 'Message')}"/>
    <title><cl:pageTitle title="${g.message(code:"institutionMessage.list.label", default:"Institution Messages")}" /></title>
    <style type="text/css">
        table {
            font-size: 0.9em;
        }
    </style>
</head>

<body class="admin">
    <cl:headerContent title="${message(code: 'institutionMessage.list.label', default: 'Institution Messages')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
            ]
        %>

            <a class="btn btn-success" href="${createLink(action: "create", params: params)}"><i
                    class="icon-plus icon-white"></i>&nbsp;Create ${entityName}</a>
    </cl:headerContent>
    <div class="container" role="main">
        <div class="panel panel-default">
            <div class="panel-body">
                <p>
                    Welcome to the DigiVol Institution messaging system. This system allows institutions to contact individual
                    volunteers directly, via email, through DigiVol. Institutions can contact individuals, a group of individuals
                    based on contribution to an expedition or multiple expeditions, or all people who have contributed to an institutions
                    activities.
                </p>
                <p>
                    This tool is intended to allow institutions to contact volunteers with expedition/project updates,
                    results or outcomes. You could also use this system to contact individual volunteers with feedback
                    or information relating to validation.<br>
                    <strong>All</strong> messages will be <u>approved by the DigiVol Admin prior to being sent</u>, this is to
                    ensure that volunteers are sent communications at appropriate times and don’t become overwhelmed with
                    message fatigue. <br>
                    If you have any questions, or think your communication is better sent via the regular DigiVol monthly
                    newsletter, then please contact <a href="mailto:digivol@australian.museum">digivol@australian.museum</a>.
                </p>
                <p>
                    Please note, volunteers can opt-out of receiving messages from this tool and will be noted as such when composing new messages.
                </p>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-6">
                        <g:select class="form-control institutitonFilter" name="institution" from="${institutionList}"
                                  optionKey="id"
                                  value="${params?.institution}" noSelection="['':'- Filter by Institution -']" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                        <small>${messageCount ?: 0} Messages found.</small>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 table-responsive">
                        <table class="table table-striped table-hover">
                            <thead>
                            <tr>
                                <g:sortableColumn property="date_created"
                                                  title="${message(code: 'institutionMessage.dateCreated.label', default: 'Date Created')}"
                                                  params="${params}"/>

                                <g:sortableColumn property="subject"
                                                  title="${message(code: 'institutionMessage.subject.label', default: 'Subject')}"
                                                  params="${params}"/>

                                <g:sortableColumn property="sender"
                                                  title="${message(code: 'institutionMessage.sender.label', default: 'Sender')}"
                                                  params="${params}"/>

                                <th>Recipient</th>

                                <g:sortableColumn property="status"
                                                  title="${message(code: 'institutionMessage.status.label', default: 'Status')}"
                                                  params="${params}"/>

                                <th>Action</th>
                            </tr>
                            </thead>
                            <tbody>
                            <g:each in="${messageList}" status="i" var="iMessage">
                                <tr class="${(i % 2) == 0 ? 'even' : 'odd'}"
                                    messageId="${iMessage.id}"
                                    recipientType="${iMessage.getRecipientType()}">
                                    <td style="text-wrap: none; vertical-align: middle;">
                                        <g:formatDate format="yyyy-MM-dd HH:mm"
                                                      date="${iMessage.dateCreated}"/>
                                    </td>
                                    <td class="message-subject"
                                        style="vertical-align: middle; text-wrap: none; width: 30%">
                                        ${iMessage.subject}
                                    </td>
                                    <td style="vertical-align: middle; text-wrap: none">${iMessage.createdBy.displayName.capitalize()}</td>
                                    <td style="vertical-align: middle;">
                                    <g:if test="${iMessage.getRecipientType() == InstitutionMessage.RECIPIENT_TYPE_USER}">
                                        <i class="fa fa-user"  title="Recipient Type: User"></i> <span class="message-recipient">${iMessage.getRecipientUser()?.displayName}</span>
                                    </g:if>
                                    <g:elseif test="${iMessage.getRecipientType() == InstitutionMessage.RECIPIENT_TYPE_PROJECT}">
                                        <i class="fa fa-folder" title="Recipient Type: Expedition"></i>
                                        <g:if test="${iMessage.getRecipientProjectList().size() > 1}">
                                            <g:set var="projectListOut" value="${iMessage.getRecipientProjectList()*.name.join(',\n')}" />
                                            <span class="message-recipient" title="${projectListOut}">
                                                ${iMessage.getRecipientProjectList().size()} Expeditions
                                            </span>
                                        </g:if>
                                        <g:else>
                                            <g:set var="project" value="${iMessage.getRecipientProjectList()?.first()}"/>
%{--                                                <g:each in="${iMessage.getRecipientProjectList()}" status="idx" var="project">--}%
                                            <span class="message-recipient">${project?.name}</span>
%{--                                                </g:each>--}%
                                        </g:else>
                                    </g:elseif>
                                    <g:else>
                                        <i class="fa fa-building" title="Recipient Type: Institution"></i> Institution
                                    </g:else>
                                    </td>
                                    <td style="text-wrap: none; text-align: center">
                                    <g:if test="${iMessage.approved}">
                                        <i class="fa fa-check"
                                           title="Approved/Sent: ${new SimpleDateFormat("yyyy-MM-dd HH:mm:ss z").format(iMessage.dateSent)} (by ${iMessage.approvedBy.displayName})"></i>
                                    </g:if>
                                    <g:else>
                                        <i class="fa fa-clock-o" title="Not Approved"></i>
                                    </g:else>
                                    </td>
                                    <td style="text-wrap: none">
                                        <a class="btn btn-xs btn-default" title="Resend Message"
                                           href="${createLink(controller: 'institutionMessage', action: 'resend', id: iMessage.id)}"><i class="fa fa-share"></i></a>
                                    <g:if test="${!iMessage.approved}">
                                        <a class="btn btn-xs btn-default" title="Edit<cl:ifSiteAdmin>/Approve</cl:ifSiteAdmin> Message"
                                            href="${createLink(controller: 'institutionMessage', action: 'edit', id: iMessage.id)}"><i class="fa fa-edit"></i></a>
                                    </g:if>
                                    <g:else>
                                        <a class="btn btn-xs btn-default" title="View Message Details"
                                           href="${createLink(controller: 'institutionMessage', action: 'edit', id: iMessage.id)}"><i class="fa fa-list-alt"></i></a>
                                    </g:else>
                                <cl:ifSiteAdmin>
                                    <g:if test="${!iMessage.approved}">
                                        <a class="btn btn-xs btn-danger delete-message" title="Delete Message"><i class="fa fa-times"></i></a>
                                    </g:if>
                                </cl:ifSiteAdmin>
                                    </td>
                                </tr>
                            </g:each>
                            </tbody>
                        </table>

                        <div class="pagination">
                            <g:paginate total="${messageCount ?: 0}" action="index" params="${params}"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

<asset:script type="text/javascript">
    jQuery(function($) {

        $('.institutitonFilter').change(function() {
            let filter = $(this).val();
            var url = "${createLink(controller: 'institutionMessage', action: 'index')}" +
                "?institution=" + filter;
            window.location = url;
        });
<cl:ifSiteAdmin>
        $(".delete-message").click(function(e) {
            e.preventDefault();
            const messageId = $(this).parents("[messageId]").attr("messageId");
            const recipientType = $(this).parents("[recipientType]").attr("recipientType");
            const recipientElem = $(this).closest('tr').find('.message-recipient');
            let recipient = "";
            const subject = $(this).closest('tr').find('.message-subject').html().trim();
            if (recipientType === '${InstitutionMessage.RECIPIENT_TYPE_INSTITUTION}') {
                recipient = "this institution";
            } else {
                if (recipientElem.attr('title') !== undefined && recipientElem.attr('title') !== false) {
                    // Mulitple projects
                    recipient = recipientElem.attr('title');
                } else {
                    recipient = recipientElem.html();
                }
            }

            if (messageId) {
                let confirmMsg = 'Are you sure you wish to delete the message "' + subject + '"';
                if (recipient !== undefined) {
                   confirmMsg += " to " + recipient;
                }
                confirmMsg += "?";

                bootbox.confirm(confirmMsg, function(result) {
                    if (result) window.location = "${createLink(controller: 'institutionMessage', action: 'delete')}/" + messageId;
                });
            } else {
                console.log("Missing info: mId: [" + messageId + "], recipientType: [" + recipientType +
                    "], recipient: [" + recipient + "]");
            }
        });
</cl:ifSiteAdmin>
    });
</asset:script>

</body>
</html>