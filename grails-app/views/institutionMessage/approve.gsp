<%@ page import="java.text.SimpleDateFormat; au.org.ala.volunteer.InstitutionMessage" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.ala.skin}">
    <g:set var="entityName" value="${message(code: 'institutionMessage.default.label', default: 'Message')}"/>
    <title><cl:pageTitle title="${g.message(code:"institutionMessage.approve.list.label", default:"Approve Institution Messages")}" /></title>
    <style type="text/css">
        table {
            font-size: 0.9em;
        }
    </style>
</head>

<body class="admin">
    <cl:headerContent title="${message(code: 'institutionMessage.approve.list.label', default: 'Approve Institution Messages')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'institutionMessage', action: 'index'),
                    label: message(code: 'institutionMessage.list.label', default: 'Institution Messages')]
            ]
        %>

        <div class="btn-group">
            <a class="btn btn-success dropdown-toggle" data-toggle="dropdown" href="#">
                <i class="fa fa-cog"></i> Tools
                <span class="caret"></span>
            </a>
            <ul class="dropdown-menu">
                <li>
                    <a href="${createLink(action: "create", params: params)}"><i class="fa fa-plus"></i>&nbsp;Create ${entityName}</a>
                </li>
                <li class="divider"></li>
                <li>
                    <a href="${createLink(action: "index")}"><i class="fa fa-envelope"></i>&nbsp
                        ${message(code: 'institutionMessage.list.label', default: 'Institution Messages')}
                    </a>
                </li>
            </ul>
        </div>
    </cl:headerContent>
    <div class="container" role="main">
        <div class="panel panel-default">
            <div class="panel-body">
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

                                <th>${message(code: 'institutionMessage.status.label', default: 'Status')}</th>

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
                                            <span class="message-recipient">${project?.name}</span>
                                        </g:else>
                                    </g:elseif>
                                    <g:else>
                                        <i class="fa fa-building" title="Recipient Type: Institution"></i> Institution
                                    </g:else>
                                    </td>
                                    <td style="text-wrap: none; text-align: center">
                                        <i class="fa fa-clock-o" title="Not Approved"></i>
                                    </td>
                                    <td style="text-wrap: none">
                                        <a class="btn btn-xs btn-default" title="Edit/Approve Message"
                                            href="${createLink(controller: 'institutionMessage', action: 'edit', id: iMessage.id)}"><i class="fa fa-edit"></i></a>
                                        <a class="btn btn-xs btn-danger delete-message" title="Delete Message"><i class="fa fa-times"></i></a>
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
    });
</asset:script>

</body>
</html>