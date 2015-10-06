<%@ page import="au.org.ala.volunteer.Picklist" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body>

<cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])} - ${picklistInstance.name}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'picklist', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
        ]
    %>
</cl:headerContent>

<div class="row">
    <div class="span12">
        <g:hasErrors bean="${picklistInstance}">
            <div class="errors">
                <g:renderErrors bean="${picklistInstance}" as="list"/>
            </div>
        </g:hasErrors>
        <g:form method="post">
            <g:hiddenField name="id" value="${picklistInstance?.id}"/>
            <g:hiddenField name="version" value="${picklistInstance?.version}"/>
            <table>
                <tbody>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="name"><g:message code="picklist.name.label" default="Name"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: picklistInstance, field: 'name', 'errors')}">
                        <g:textField name="name" value="${picklistInstance?.name}"/>
                    </td>
                </tr>

                </tbody>
            </table>

            <div style="margin-top: 20px">
                <g:actionSubmit class="save btn btn-small" action="update"
                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                <g:actionSubmit class="delete btn btn-small btn-danger" action="delete"
                                value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
            </div>

        </g:form>
    </div>
</div>
</body>
</html>
