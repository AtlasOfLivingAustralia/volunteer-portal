<%@ page import="au.org.ala.volunteer.User" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>
    </head>
    <body>

        <cl:headerContent crumbLabel="Volunteers" title="Edit User ${userInstance.userId} - ${userDetails.displayName} (${userDetails.userName})">
            <%
                pageScope.crumbs = []
                pageScope.crumbs << [link: createLink(controller: 'user', action: 'show', id: userInstance.id), label: userDetails.displayName]
            %>
        </cl:headerContent>

        <div>
            <g:hasErrors bean="${userInstance}">
            <div class="errors">
                <g:renderErrors bean="${userInstance}" as="list" />
            </div>
            </g:hasErrors>

            <g:form method="post" >
                <g:hiddenField name="id" value="${userInstance?.id}" />
                <g:hiddenField name="version" value="${userInstance?.version}" />
                <div class="row">
                    <div class="span12">
                        <table>
                            <tbody>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="created"><g:message code="user.created.label" default="Created" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'created', 'errors')}">
                                        <g:datePicker name="created" precision="day" value="${userInstance?.created}"  />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="transcribedCount"><g:message code="user.transcribedCount.label" default="Transcribed Count" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'transcribedCount', 'errors')}">
                                        <g:textField name="transcribedCount" value="${fieldValue(bean: userInstance, field: 'transcribedCount')}" />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="validatedCount"><g:message code="user.validatedCount.label" default="Validated Count" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'validatedCount', 'errors')}">
                                        <g:textField name="validatedCount" value="${fieldValue(bean: userInstance, field: 'validatedCount')}" />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="userId"><g:message code="user.userId.label" default="User Id" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'userId', 'errors')}">
                                        <g:textField readonly="true" name="userId" maxlength="200" value="${userInstance?.userId}" />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="displayName"><g:message code="user.displayName.label" default="Display Name" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'displayName', 'errors')}">
                                        <g:textField name="displayName" value="${userInstance?.displayName}" />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="email"><g:message code="user.email.label" default="Email addresss" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'email', 'errors')}">
                                        <g:textField name="email" value="${userInstance?.email}" />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="roles"><g:message code="user.roles.label" default="Roles" /></label>
                                    </td>
                                    <td valign="top" class="value">
                                        <ul>
                                            <g:each var="role" in="${roles}">
                                                <li>${role.role.name}
                                                    (${role.project == null ? '&lt;All Projects&gt;' : role.project.featuredLabel})
                                                </li>
                                            </g:each>
                                        </ul>
                                        <a class="btn btn-small" href="${createLink(controller:'user', action:'editRoles', id:userInstance.id)}">Edit roles</a>
                                    </td>
                                </tr>

                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="row">
                    <div class="span12" style="margin-top: 10px">
                        <g:actionSubmit class="save btn btn-primary" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" />
                        <g:actionSubmit class="delete btn btn-danger" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" />
                    </div>
                </div>
            </g:form>
        </div>
    </body>
</html>
