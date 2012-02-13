<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.PicklistItem" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'picklistItem.label', default: 'PicklistItem')}" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="crumb" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
        </div>
        <div class="body">
            <h1><g:message code="default.list.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                            <g:sortableColumn property="id" title="${message(code: 'picklistItem.id.label', default: 'Id')}" />
                        
                            <g:sortableColumn property="key" title="${message(code: 'picklistItem.key.label', default: 'Key')}" />
                        
                            <th><g:message code="picklistItem.picklist.label" default="Picklist" /></th>
                        
                            <g:sortableColumn property="value" title="${message(code: 'picklistItem.value.label', default: 'Value')}" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${picklistItemInstanceList}" status="i" var="picklistItemInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${picklistItemInstance.id}">${fieldValue(bean: picklistItemInstance, field: "id")}</g:link></td>
                        
                            <td>${fieldValue(bean: picklistItemInstance, field: "key")}</td>
                        
                            <td>${fieldValue(bean: picklistItemInstance, field: "picklist")}</td>
                        
                            <td>${fieldValue(bean: picklistItemInstance, field: "value")}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${picklistItemInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
