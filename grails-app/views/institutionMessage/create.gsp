<%@ page import="org.springframework.validation.FieldError; au.org.ala.volunteer.InstitutionMessage" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'institutionMessage.default.label', default: 'Institution Message')}"/>
    <title><cl:pageTitle title="${g.message(code: "default.new.label", args: [entityName], default:"Create Institution Message")}" /></title>
    <asset:javascript src="bvp-select.js" asset-defer="" />
    <link href="https://cdn.jsdelivr.net/npm/tom-select@2.6.2/dist/css/tom-select.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/tom-select@2.6.2/dist/js/tom-select.complete.min.js"></script>
    <g:set var="disableEdit" value="${false}"/>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.new.label', args: [entityName])}" selectedNavItem="bvpadmin">
    <%
        def institution = (params.institution ?: 0) as int
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: (institution > 0 ? createLink(controller: 'institutionMessage', params: [institution: institution]) :
                        createLink(controller: 'institutionMessage')),
                    label: message(code: 'institutionMessage.list.label', default: 'Institution Messages')]

        ]
    %>
</cl:headerContent>
<div id="create-institution" class="container">
    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-md-12">
                    <g:form action="save" class="form-horizontal">
                        <g:render template="form"/>
                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <small id="includeContactHelp" class="form-text text-muted" style="margin-bottom: 2em;">Note: Creating this message does not send immediately to volunteers. Messages must be approved by DigiVol Administrators before messages are sent.</small><br />
                                <br />
                                <g:submitButton name="create" class="save btn btn-primary"
                                                value="${message(code: 'default.button.create.label', default: 'Create')}"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>

<asset:javascript src="institution-message-recipient.js" asset-defer="" />
<asset:script type="text/javascript">
$(document).ready(function () {
    const params = new URLSearchParams(window.location.search);
    const institutionId = $('.institution').val();

    const initialRecipientType = (function () {
    <g:if test="${params.projectId}">
        $('.institution').val(${institutionId});
        $('.recipient-type').val("${InstitutionMessage.RECIPIENT_TYPE_PROJECT}");
        return "${InstitutionMessage.RECIPIENT_TYPE_PROJECT}";
    </g:if>
    <g:else>
        if (params.get('institution')) {
            $('.institution').val(params.get('institution'));
        }
        return "${institutionMessageInstance?.getRecipientType() ?: InstitutionMessage.RECIPIENT_TYPE_USER}";
    </g:else>
    })();

    const selectedProjectIds = (function () {
        const fromQuery = params.get('projectId');
        if (fromQuery) return fromQuery.split(',').map(function (v) { return v.trim(); }).filter(function (v) { return v && v !== "0"; });
        const fromServer = "${(institutionMessageInstance?.getRecipientProjectList()) ? institutionMessageInstance.getRecipientProjectList()*.id.join(',') : ''}";
        return fromServer ? fromServer.split(',').map(function (v) { return v.trim(); }).filter(function (v) { return v && v !== "0"; }) : [];
    })();

    InstitutionMessageRecipient.init({
        recipientSelector:      "#recipient",
        recipientContainerSelector: "#recipient-container",
        recipientTypeSelector:  ".recipient-type",
        institutionSelector:    ".institution",
        loadingSelector:        ".loading-recipient",
        initialRecipientType:   initialRecipientType,
        selectedUserId:         ${(institutionMessageInstance?.getRecipientUser()?.id ?: 0)},
        selectedProjectIds:     selectedProjectIds,
        includeOptOut:          true,
        isApproved:             false,
        urls: {
            users: function () {
                return "${createLink(controller: 'institutionAdmin', action: 'getUsersForInstitution')}/" + $('.institution').val();
            },
            projects: function () {
                return "${createLink(controller: 'institutionAdmin', action: 'getActiveProjectsForInstitution')}/" + $('.institution').val();
            }
        }
    });
});
</asset:script>

</body>
</html>
