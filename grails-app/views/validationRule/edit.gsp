<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'validationRule.label', default: 'ValidationRule')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>
    </head>
    <body>

        <cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])} - ${rule.name}">
            <%
                pageScope.crumbs = [
                        [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                        [link: createLink(controller: 'validationRule', action: 'list'), label: message(code: 'default.list.label', args: ['ValidationRule'])],
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <g:hasErrors bean="${rule}">
                    <div class="errors">
                        <g:renderErrors bean="${rule}" as="list" />
                    </div>
                </g:hasErrors>
                <g:form method="post" >
                    <g:hiddenField name="id" value="${rule?.id}" />
                    <g:hiddenField name="version" value="${rule?.version}" />

                    <table class="table">
                        <tbody>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="name"><g:message code="validationRule.name.label" default="Name" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: rule, field: 'name', 'errors')}">
                                    <g:textField name="name" value="${rule?.name}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="description"><g:message code="validationRule.description.label" default="Description" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: rule, field: 'description', 'errors')}">
                                    <g:textField name="description" value="${rule?.description}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="regularExpression"><g:message code="validationRule.regularExpression.label" default="Pattern" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: rule, field: 'regularExpression', 'errors')}">
                                    <g:textField name="regularExpression" value="${rule?.regularExpression}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="testEmptyValues"><g:message code="validationRule.testEmptyValues.label" default="Test empty/blank values" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: rule, field: 'testEmptyValues', 'errors')}">
                                    <g:checkBox name="testEmptyValues" value="${rule?.testEmptyValues}" />
                                </td>
                            </tr>


                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="message"><g:message code="validationRule.message.label" default="Message" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: rule, field: 'message', 'errors')}">
                                    <g:textField name="message" value="${rule?.message}" />
                                </td>
                            </tr>


                        </tbody>
                    </table>

                    <div>
                        <g:actionSubmit class="btn save btn-primary" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" />
                        <a href="${createLink(controller:'validationRule', action:'list')}" class="btn">Cancel</a>
                        %{--<g:actionSubmit class="btn btn-danger delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" />--}%
                    </div>
                </g:form>
            </div>
        </div>
    </body>
</html>
