<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.NewsItem" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
            <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></span>
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
                        
                            <g:sortableColumn property="id" title="${message(code: 'newsItem.id.label', default: 'Id')}" />

                            <g:sortableColumn property="title" title="${message(code: 'newsItem.title.label', default: 'Title')}" />
                            
                            <g:sortableColumn property="body" title="${message(code: 'newsItem.body.label', default: 'Body')}" />
                        
                            <g:sortableColumn property="created" title="${message(code: 'newsItem.created.label', default: 'Created')}" />
                        
                            <g:sortableColumn property="createdBy" title="${message(code: 'newsItem.createdBy.label', default: 'Created By')}" />
                        
                            <th><g:message code="newsItem.project.label" default="Project" /></th>

                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${newsItemInstanceList}" status="i" var="newsItemInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${newsItemInstance.id}">${fieldValue(bean: newsItemInstance, field: "id")}</g:link></td>

                            <td>${fieldValue(bean: newsItemInstance, field: "title")}</td>

                            <td>${newsItemInstance?.body}</td>
                        
                            <td><g:formatDate date="${newsItemInstance.created}" format="dd-MM-yyyy" /></td>
                        
                            <td>${fieldValue(bean: newsItemInstance, field: "createdBy")}</td>
                        
                            <td>${newsItemInstance?.project?.name}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${newsItemInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
