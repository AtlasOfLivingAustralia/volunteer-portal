<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.Picklist" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}" />
        <title><g:message code="default.show.label" args="[entityName]" /></title>
        <script type="text/javascript">
            $(document).ready(function() {
                $("#searchButton").click(function(e) {
                    e.preventDefault();
                    var query = $("#q").val()
                    location.href="?q=" + query;
                });

            }); // end .ready()
        </script>
    </head>
<body class="sublevel sub-site volunteerportal">
        <div class="nav">
            <span class="menuButton"><a class="crumb" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
            <span class="menuButton"><g:link class="crumb" action="list" controller="picklist">Picklists</g:link></span>
            <span>${fieldValue(bean: picklistInstance, field: "name")}</span>
        </div>
        <div class="inner">
            <h1><g:message code="default.show.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="picklist.id.label" default="Id" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: picklistInstance, field: "id")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="picklist.name.label" default="Name" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: picklistInstance, field: "name")}</td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <!-- show the picklist -->
            <div class="list">
                <input type="text" name="q" id="q" value="${params.q}" size="40" />
                <button id="searchButton">search</button>
                <table>
                    <thead>
                        <tr>
                            <g:sortableColumn property="id" title="${message(code: 'picklistItem.id.label', default: 'Id')}" />
                            <g:sortableColumn property="key" title="${message(code: 'picklistItem.key.label', default: 'Key')}" />
                            <g:sortableColumn property="value" title="${message(code: 'picklistItem.value.label', default: 'Value')}" />
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${picklistItemInstanceList}" status="i" var="picklistItemInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                            <td><g:link controller="picklistItem" action="show" id="${picklistItemInstance.id}">${fieldValue(bean: picklistItemInstance, field: "id")}</g:link></td>
                            <td>${fieldValue(bean: picklistItemInstance, field: "key")}</td>
                            <td>${fieldValue(bean: picklistItemInstance, field: "value")}</td>
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${picklistItemInstanceTotal}" id="${picklistInstance.id}"/>
            </div>
            <div class="buttons">
                <g:form>
                    <g:hiddenField name="id" value="${picklistInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" action="edit" value="${message(code: 'default.button.edit.label', default: 'Edit')}" /></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
