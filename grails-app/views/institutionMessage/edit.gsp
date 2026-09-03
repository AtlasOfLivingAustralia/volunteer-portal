<%@ page import="au.org.ala.volunteer.MessageAudit; org.springframework.validation.FieldError" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'institutionMessage.default.label', default: 'Institution Message')}"/>
    <title><cl:pageTitle title="${g.message(code: "default.edit.label", args: [entityName], default:"Edit Institution Message")}" /></title>
    <asset:javascript src="bvp-select.js" asset-defer="" />
    <link href="https://cdn.jsdelivr.net/npm/tom-select@2.6.2/dist/css/tom-select.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/tom-select@2.6.2/dist/js/tom-select.complete.min.js"></script>
    <g:set var="disableEdit" value="${institutionMessageInstance.approved}"/>

    <style type="text/css">
        .message {
            border: 1px solid black;
            padding: 10px 10px 5px 15px;
            background-color: #f3f3f3;
        }
    </style>

</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'institutionMessage', params: [institution: institutionMessageInstance.institution.id]),
                    label: message(code: 'institutionMessage.list.label', default: 'Institution Messages')]

        ]
    %>
</cl:headerContent>
<div id="create-institution" class="container">
    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${institutionMessageInstance}">
                        <ul class="errors" role="alert">
                            <g:eachError bean="${institutionMessageInstance}" var="error">
                                <li <g:if test="${error in FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                        error="${error}"/></li>
                            </g:eachError>
                        </ul>
                    </g:hasErrors>

                    <g:form action="update" class="form-horizontal">
                        <input type="hidden" name="id" value="${institutionMessageInstance.id}" />
                        <g:if test="${institutionMessageInstance.dateSent}">
                            <g:render template="review"/>
                        </g:if>
                        <g:else>
                            <g:render template="form"/>
                        </g:else>

                        <g:if test="${!disableEdit}">
                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <g:submitButton name="update" class="save btn btn-primary"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                                <g:actionSubmit action="approveMessage" name="approve" class="save btn btn-success"
                                                value="${message(code: 'institutionMessage.approve.label', default: 'Approve and Send')}"/>
                            </div>
                        </div>
                        </g:if>
                    </g:form>
                </div>
            </div>
        </div>
    </div>

<g:if test="${institutionMessageInstance.approved}">
    <div class="card">
        <div class="card-body">
            <h4>Recipients</h4>
            <p>
                This message was sent to the following
                <g:if test="${recipientList.size() > 0}"><strong>${recipientList.size()}</strong></g:if>
                recipients:
            </p>
            <table class="table table-striped table-hover">
                <thead>
                <tr>
                    <th style="width: 50%; padding: 5px;">Recipient</th>
                    <th style="width: 30%; padding: 5px;">Date Sent</th>
                    <th style="width: 20%; padding: 5px;">Status</th>
                </tr>
                </thead>
                <tbody>
            <g:each in="${recipientList}" var="recipient" status="idx">
                    <tr>
                        <td style="padding: 5px;">${recipient.recipientUser.displayName} (${recipient.recipientUser.email})</td>
                        <td style="padding: 5px;"><g:formatDate format="yyyy-MM-dd HH:mm"
                                                                date="${institutionMessageInstance.dateSent}"/></td>

                    <g:if test="${recipient.sendStatus != MessageAudit.STATUS_SEND_OK}">
                        <td style="padding: 5px; color: red; font-weight: bold;">
                    </g:if>
                    <g:else>
                        <td style="padding: 5px;">
                    </g:else>
                            ${MessageAudit.getStatusLabel(recipient.sendStatus)}
                        </td>

                    </tr>
            </g:each>
                </tbody>
            </table>
        </div>
    </div>
</g:if>
</div>

<asset:javascript src="institution-message-recipient.js" asset-defer="" />
<asset:script type="text/javascript">
$(document).ready(function () {
<g:if test="${!institutionMessageInstance.approved}">
    InstitutionMessageRecipient.init({
        recipientSelector:      "#recipient",
        recipientContainerSelector: "#recipient-container",
        recipientTypeSelector:  ".recipient-type",
        institutionSelector:    ".institution",
        loadingSelector:        ".loading-recipient",
        initialRecipientType:   "${institutionMessageInstance.getRecipientType()}",
        selectedUserId:         ${(institutionMessageInstance?.getRecipientUser()?.id ?: 0)},
        selectedProjectIds:     "${(institutionMessageInstance?.getRecipientProjectList()) ? institutionMessageInstance.getRecipientProjectList()*.id.join(',') : ''}".split(',').map(function (v) { return v.trim(); }).filter(function (v) { return v && v !== "0"; }),
        includeOptOut: false,
        isApproved: ${institutionMessageInstance.approved ? 'true' : 'false'},
        urls: {
            users: function () {
                return "${createLink(controller: 'institutionAdmin', action: 'getUsersForInstitution', id: institutionMessageInstance?.institution?.id)}";
            },
            projects: function () {
                return "${createLink(controller: 'institutionAdmin', action: 'getActiveProjectsForInstitution', id: institutionMessageInstance?.institution?.id)}";
            }
        }
    });
</g:if>
});
</asset:script>

</body>
</html>
