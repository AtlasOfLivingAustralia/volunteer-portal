<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.LabelColour" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
    <asset:stylesheet src="bootstrap-select.css" />
    <asset:javascript src="bootstrap-select.js" asset-defer="" />

    <style>
        .roles-table {
            font-size: 1rem;
        }
</style>
</head>

<body class="admin">

<cl:headerContent crumbLabel="Edit User"
                  title="Edit User" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
            [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
            [link: createLink(controller: 'user', action: 'adminList'), label: message(code: 'default.users.admin.label', default: 'Manage Users')]
        ]
    %>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${userInstance}">
                        <div class="errors">
                            <g:renderErrors bean="${userInstance}" as="list"/>
                        </div>
                    </g:hasErrors>

                    <g:form method="post" class="form-horizontal">
                        <g:hiddenField name="id" value="${userInstance?.id}"/>

                        <div class="form-group">
                            <label for="displayName" class="control-label col-md-3"><g:message code="user.displayName.label" default="Name"/></label>
                            <div class="col-md-6">
                                <g:textField name="displayName" class="form-control" disabled="disabled"
                                             value="${fieldValue(bean: userInstance, field: 'displayName')}"/>
                            </div>
                        </div>

                        <div class="form-group  ${hasErrors(bean: userInstance, field: 'transcribedCount', 'has-error')}">
                            <label for="transcribedCount" class="control-label col-md-3">
                                <g:message code="user.transcribedCount.label" default="Transcribed Count"/>
                            </label>
                            <div class="col-md-6">
                                <g:textField name="transcribedCount" class="form-control"
                                             value="${fieldValue(bean: userInstance, field: 'transcribedCount')}"/>
                            </div>
                        </div>

                        <div class="form-group  ${hasErrors(bean: userInstance, field: 'validatedCount', 'has-error')}">
                            <label for="validatedCount" class="control-label col-md-3">
                                <g:message code="user.validatedCount.label" default="Validated Count"/>
                            </label>
                            <div class="col-md-6">
                                <g:textField name="validatedCount" class="form-control"
                                             value="${fieldValue(bean: userInstance, field: 'validatedCount')}"/>
                            </div>
                        </div>

                        <div class="form-group  ${hasErrors(bean: userInstance, field: 'userId', 'has-error')}">
                            <label for="userId" class="control-label col-md-3">
                                <g:message code="user.userId.label" default="User Id"/>
                            </label>
                            <div class="col-md-6">
                                <g:textField name="transcribedCount" class="form-control" disabled="disabled"
                                             value="${fieldValue(bean: userInstance, field: 'userId')}"/>
                            </div>
                        </div>

                        <div class="form-group  ${hasErrors(bean: userInstance, field: 'email', 'has-error')}">
                            <label for="email" class="control-label col-md-3">
                                <g:message code="user.email.label" default="Email Address"/>
                            </label>
                            <div class="col-md-6">
                                <g:textField name="email" class="form-control"
                                             value="${fieldValue(bean: userInstance, field: 'email')}"/>
                            </div>
                        </div>

                        <div class="form-group" style="padding-bottom: 20px;">
                            <div class="col-md-offset-3 col-md-9">
                                <g:actionSubmit class="save btn btn-primary" action="update"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                                <g:actionSubmit class="delete btn btn-danger" action="delete"
                                                value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
                            </div>
                        </div>
                    </g:form>

                        <div class="well form-horizontal" style="padding: 10px !important;">
                            <div class="form-group">
                                <label for="roles" class="control-label col-md-3">
                                    <g:message code="user.roles.label" default="Roles"/>
                                    <a class="btn btn-link"
                                       href="${createLink(controller: 'admin', action: 'manageUserRoles', params: [userid: userInstance.id])}"
                                       title="Edit User Roles">
                                        <i class="fa fa-users" style="font-size: 1.2em;"></i>
                                    </a>
                                </label>

                                <div class="col-md-6">
                                    <div class="table-responsive roles-table">
                                        <table class="table table-bordered table-striped">
                                            <thead>
                                                <tr>
                                                    <th><g:message code="user.role.name.label" default="Role Name"/></th>
                                                    <th><g:message code="user.role.scope.label" default="Institution/Project"/></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <g:each var="roleInfo" in="${roles}">
                                                    <tr>
                                                        <td>${roleInfo.role}</td>
                                                        <td>
                                                            ${roleInfo.scope}
                                                            <g:if test="${!roleInfo.scope}">
                                                                <g:message code="user.role.site-wide.label" default="Site-wide"/>
                                                            </g:if>
                                                        </td>
                                                    </tr>
                                                </g:each>
                                                <g:if test="${roles.isEmpty()}">
                                                    <tr>
                                                        <td colspan="2"><g:message code="user.roles.none.label" default="No roles assigned"/></td>
                                                    </tr>
                                                </g:if>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>


                        <div class="well" style="padding: 10px !important;">
                            <g:form method="post" class="form-horizontal">
                                <g:hiddenField name="id" id="add-label-user-id" value="${userInstance?.id}" />
                            <div class="form-group">
                                <label for="label" class="control-label col-md-3">
                                    <g:message code="user.labels.label" default="Tags"/>
                                </label>
                                <div class="col-md-3">
                                    <g:select name="tag" from="${userLabelList}" optionKey="id" class="selectpicker form-control"
                                              noSelection="['':'- Select a Tag -']"
                                              optionValue="value" data-live-search="true"/>
                                    <div id="labels" style="padding-top: 10px;">
                                    <g:each in="${userInstance.labels}" var="l">
                                        <g:set var="labelClassName" value="${l.category.labelColour ?: 'base'}"/>
                                        <span class="label label-${labelClassName}"> ${l.value} <i class="fa fa-times-circle delete-label" data-label-id="${l.id}"></i> </span>
                                    </g:each>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <g:actionSubmit class="save btn btn-primary" action="addUserLabel"
                                                    value="${message(code: 'default.button.save.label', default: 'Add Tag')}"/>
                                </div>
                            </div>
                            </g:form>
                        </div>

                    </div>


                </div>
            </div>
        </div>
    </div>
</div>
<asset:script type="text/javascript" asset-defer="">
$(function() {
    function onDeleteLabelClick (e) {
        e.preventDefault();
        var userId = $('#add-label-user-id').val();
        var labelIdToRemove = e.target.dataset.labelId

        $.ajax({
            type: 'POST',
            dataType: 'json',
            cache: false,
            url: '${createLink(controller: "user", action: "deleteLabel")}?selectedLabelId=' + labelIdToRemove + '&userId=' + userId,
            success: function (data) {
                var t = $(e.target);
                var p = t.parent("span");
                p.remove();
            },  error: function (jqXHR, textStatus, errorThrown) {
                console.log('user/deleteLabel: Error - ' + errorThrown);
            }
        });
    }

    $('#labels').on('click', 'i.delete-label', onDeleteLabelClick);
});
</asset:script>
</body>
</html>
