<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'templateField.label', default: 'TemplateField')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>

<body>
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
    <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label"
                                                                           args="[entityName]"/></g:link></span>
    <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label"
                                                                               args="[entityName]"/></g:link></span>
</div>

<div class="inner">
    <h1><g:message code="default.show.label" args="[entityName]"/></h1>
    <cl:messages/>
    <div class="dialog">
        <table>
            <tbody>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.id.label" default="Id"/></td>

                <td valign="top" class="value">${fieldValue(bean: templateFieldInstance, field: "id")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.fieldType.label"
                                                         default="Field Type"/></td>

                <td valign="top" class="value">${templateFieldInstance?.fieldType?.encodeAsHTML()}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.label.label" default="Label"/></td>

                <td valign="top" class="value">${fieldValue(bean: templateFieldInstance, field: "label")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.defaultValue.label"
                                                         default="Default Value"/></td>

                <td valign="top" class="value">${fieldValue(bean: templateFieldInstance, field: "defaultValue")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.mandatory.label" default="Mandatory"/></td>

                <td valign="top" class="value"><g:formatBoolean boolean="${templateFieldInstance?.mandatory}"/></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.multiValue.label"
                                                         default="Multi Value"/></td>

                <td valign="top" class="value"><g:formatBoolean boolean="${templateFieldInstance?.multiValue}"/></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.helpText.label" default="Help Text"/></td>

                <td valign="top" class="value">${fieldValue(bean: templateFieldInstance, field: "helpText")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.validationRule.label"
                                                         default="Validation Rule"/></td>

                <td valign="top" class="value">${fieldValue(bean: templateFieldInstance, field: "validationRule")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.template.label" default="Template"/></td>

                <td valign="top" class="value"><g:link controller="template" action="show"
                                                       id="${templateFieldInstance?.template?.id}">${templateFieldInstance?.template?.encodeAsHTML()}</g:link></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.displayOrder.label"
                                                         default="Display Order"/></td>

                <td valign="top" class="value">${fieldValue(bean: templateFieldInstance, field: "displayOrder")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.category.label" default="Category"/></td>

                <td valign="top" class="value">${templateFieldInstance?.category?.encodeAsHTML()}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="templateField.type.label" default="Type"/></td>

                <td valign="top" class="value">${templateFieldInstance?.type?.encodeAsHTML()}</td>

            </tr>

            </tbody>
        </table>
    </div>

    <div class="buttons">
        <g:form>
            <g:hiddenField name="id" value="${templateFieldInstance?.id}"/>
            <span class="button"><g:actionSubmit class="edit" action="edit"
                                                 value="${message(code: 'default.button.edit.label', default: 'Edit')}"/></span>
            <span class="button"><g:actionSubmit class="delete" action="delete"
                                                 value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                 onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/></span>
        </g:form>
    </div>
</div>
</body>
</html>
