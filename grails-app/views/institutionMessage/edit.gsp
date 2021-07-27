<%@ page import="au.org.ala.volunteer.MessageAudit; org.springframework.validation.FieldError" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'institutionMessage.default.label', default: 'Institution Message')}"/>
    <title><cl:pageTitle title="${g.message(code: "default.edit.label", args: [entityName], default:"Edit Institution Message")}" /></title>
    <asset:stylesheet src="bootstrap-select.css" asset-defer="" />
    <asset:javascript src="bootstrap-select.js" asset-defer="" />
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
    <div class="panel panel-default">
        <div class="panel-body">
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
    <div class="panel panel-default">
        <div class="panel-body">
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

<asset:script type="text/javascript">
    $(document).ready(function() {
    <g:if test="${!institutionMessageInstance.approved}">
        function initRecipient() {
            const recipientType = "${institutionMessageInstance.getRecipientType()}";
            $('#recipient').prop('disabled', false);
            console.log("Init recipient");
            getRecipientData(recipientType);
            $('#recipient').selectpicker();
        }

        initRecipient();

        $('.recipient-type').change(function() {
            console.log("recipient type change");
            $('#recipient').prop('disabled', false);
            getRecipientData(this.value);
        });

        function getRecipientData(recipientType) {
            $('.loading-recipient').removeClass('hidden');
            if (recipientType === 'user') {
                getUserList();
            } else if (recipientType === 'project') {
                getProjectList();
            } else {
                updateRecipient(recipientType, null);
            }
        }

        function updateRecipient(type, data) {
            console.log("Update recipient field");
            let selectList = "";

            if (type === 'user') {
                // build user select
                const selectedValue = ${(institutionMessageInstance?.getRecipientUser()?.id ?: 0)};
                $.each(data, function(idx, u) {
                    let selectedAttr = "";
                    if (u.id === selectedValue) selectedAttr = " selected='selected'";

                    selectList += "<option value='" + u.id + "'" + selectedAttr + ">" + u.lastName + ", " + u.firstName + "</option>";
                });

                $('#recipient').selectpicker('destroy');
                $('#recipient').empty()
                    .removeAttr("multiple")
                    .removeAttr("data-selected-text-format")
                    .removeAttr("data-count-selected-text")
                    .append(selectList);

            <g:if test="${institutionMessageInstance.approved}">
                $('#recipient').attr("disabled", true);
            </g:if>

                $('#recipient').selectpicker();

            } else if (type === 'project') {
                // build project select
                const selectedValues = "${(institutionMessageInstance?.getRecipientProjectList()) ? institutionMessageInstance.getRecipientProjectList()*.id.join(",") : ""}";
                console.log("Selected Value: " + selectedValues);
                $.each(data, function(idx, p) {
                    selectList += "<option value='" + p.id + "'>" + p.name + "</option>";
                });

                $('#recipient').selectpicker('destroy');
                $('#recipient').empty()
                    .attr("multiple", "true")
                    .append(selectList);

                // Set selected attributes
                $.each(selectedValues.split(","), function(idx, e) {
                     $("#recipient option[value='" + e + "']").prop("selected", true);
                });

            <g:if test="${institutionMessageInstance.approved}">
                $('#recipient').attr("disabled", true);
            </g:if>

                $('#recipient').selectpicker({
                    selectedTextFormat: 'count > 1',
                    countSelectedText: "{0} expeditions selected"
                });

            } else {
                $('#recipient').selectpicker('destroy');
                $('#recipient').empty()
                    .removeAttr("multiple")
                    .removeAttr("data-selected-text-format")
                    .removeAttr("data-count-selected-text")
                    .append("<option>- Institution; no recipient required -</option>");
                $('#recipient').attr("disabled", true);
                $('#recipient').selectpicker();
            }

            $('#recipient').selectpicker('refresh');
            $('.loading-recipient').addClass('hidden');
        }

        function getUserList() {
            console.log("Get user List");
            const url = "${createLink(controller: 'institutionAdmin', action: 'getUsersForInstitution', id: institutionMessageInstance?.institution?.id)}";
            $.get({
                url: url,
                dataType: 'json'
            }).done(function(data) {
                //console.log(data)
                updateRecipient('user', data);
            });
        }

        function getProjectList() {
            console.log("Get project List");
            const url = "${createLink(controller: 'institutionAdmin', action: 'getActiveProjectsForInstitution', id: institutionMessageInstance?.institution?.id)}";
            $.get({
                url: url,
                dataType: 'json'
            }).done(function(data) {
                //console.log(data)
                updateRecipient('project', data);
            });
        }
    </g:if>
    });

</asset:script>

</body>
</html>
