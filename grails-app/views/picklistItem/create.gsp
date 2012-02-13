<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.PicklistItem" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'picklistItem.label', default: 'PicklistItem')}" />
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
            <g:hasErrors bean="${picklistItemInstance}">
            <div class="errors">
                <g:renderErrors bean="${picklistItemInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="key"><g:message code="picklistItem.key.label" default="Key" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: picklistItemInstance, field: 'key', 'errors')}">
                                    <g:textField name="key" value="${picklistItemInstance?.key}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="picklist"><g:message code="picklistItem.picklist.label" default="Picklist" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: picklistItemInstance, field: 'picklist', 'errors')}">
                                    <g:select name="picklist.id" from="${au.org.ala.volunteer.Picklist.list()}" optionKey="id" value="${picklistItemInstance?.picklist?.id}"  />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="value"><g:message code="picklistItem.value.label" default="Value" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: picklistItemInstance, field: 'value', 'errors')}">
                                    <g:textField name="value" value="${picklistItemInstance?.value}" />
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
