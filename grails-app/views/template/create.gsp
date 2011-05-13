

<%@ page import="au.org.ala.volunteer.Template" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}" />
        <title><g:message code="default.create.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="body">
            <h1><g:message code="default.create.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${templateInstance}">
            <div class="errors">
                <g:renderErrors bean="${templateInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="author"><g:message code="template.author.label" default="Author" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateInstance, field: 'author', 'errors')}">
                                    <g:textField name="author" maxlength="200" value="${templateInstance?.author}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="name"><g:message code="template.name.label" default="Name" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateInstance, field: 'name', 'errors')}">
                                    <g:textField name="name" maxlength="200" value="${templateInstance?.name}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="viewName"><g:message code="template.viewName.label" default="View Name" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateInstance, field: 'viewName', 'errors')}">
                                    <g:textField name="viewName" value="${templateInstance?.viewName}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="fieldOrder"><g:message code="template.fieldOrder.label" default="Field Order" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateInstance, field: 'fieldOrder', 'errors')}">
                                    <g:textField name="fieldOrder" value="${templateInstance?.fieldOrder}" />
                                </td>
                            </tr>
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:submitButton name="create" class="save" value="${message(code: 'default.button.create.label', default: 'Create')}" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
