<%@ page import="au.org.ala.volunteer.User" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body class="admin">

<cl:headerContent crumbLabel="Edit User"
                  title="Edit User ${userInstance.userId} - ${userDetails.displayName} (${userDetails.userName})" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = []
        pageScope.crumbs << [link: createLink(controller: 'user', action: 'show', id: userInstance.id), label: userDetails.displayName]
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
                        <g:hiddenField name="version" value="${userInstance?.version}"/>
                        <div class="form-group ${hasErrors(bean: userInstance, field: 'created', 'has-error')}">
                            <label class="control-label col-md-3" for="created"><g:message code="user.created.label" default="Created"/></label>
                            <div class="col-md-6 grails-date">
                                <g:datePicker name="created" precision="day" value="${userInstance?.created}"/>
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
                                <g:textField name="userId" class="form-control"
                                             value="${fieldValue(bean: userInstance, field: 'userId')}"/>
                            </div>
                        </div>

                        <div class="form-group  ${hasErrors(bean: userInstance, field: 'displayName', 'has-error')}">
                            <label for="displayName" class="control-label col-md-3">
                                <g:message code="user.displayName.label" default="Display Name"/>
                            </label>
                            <div class="col-md-6">
                                <g:textField name="displayName" class="form-control"
                                             value="${fieldValue(bean: userInstance, field: 'displayName')}"/>
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

                        <div class="form-group  ${hasErrors(bean: userInstance, field: 'roles', 'has-error')}">
                            <label for="roles" class="control-label col-md-3">
                                <g:message code="user.roles.label" default="Roles"/>
                            </label>
                            <div class="col-md-3">
                                <ul id="roles" class="form-control-static">
                                    <g:each var="role" in="${roles}">
                                        <li>${role.role.name}
                                        (${role.project == null ? '<All Projects>' : role.project.featuredLabel})
                                        </li>
                                    </g:each>
                                </ul>
                                <a class="btn btn-sm btn-default"
                                   href="${createLink(controller: 'user', action: 'editRoles', id: userInstance.id)}">Edit roles</a>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <g:actionSubmit class="save btn btn-primary" action="update"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                                <g:actionSubmit class="delete btn btn-danger" action="delete"
                                                value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
<r:script>
    $(function() {
        $('.grails-date select').each(function(){
            $(this).addClass('form-control');
        });
    });
</r:script>
</body>
</html>
