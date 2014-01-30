<%@ page import="au.org.ala.volunteer.Template" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}" />
        <title><g:message code="default.show.label" args="[entityName]" /></title>
    </head>
    <body>

        <cl:headerContent title="${message(code: 'default.show.label', args: [entityName])} - ${templateInstance.name}">
           <%
               pageScope.crumbs = [
                   [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                   [link: createLink(controller: 'template', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
               ]
           %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <table class="table">
                    <tbody>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="template.id.label" default="Id" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: templateInstance, field: "id")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="template.author.label" default="Author" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: templateInstance, field: "author")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="template.name.label" default="Name" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: templateInstance, field: "name")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="template.viewName.label" default="View Name" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: templateInstance, field: "viewName")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="template.fieldOrder.label" default="Field Order" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: templateInstance, field: "fieldOrder")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="template.project.label" default="Projects" /></td>
                            
                            <td valign="top" style="text-align: left;" class="value">
                                <ul>
                                <g:each in="${templateInstance.project}" var="p">
                                    <li><g:link controller="project" action="show" id="${p.id}">${p?.encodeAsHTML()}</g:link></li>
                                </g:each>
                                </ul>
                            </td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <g:hiddenField name="id" value="${templateInstance?.id}" />
                    <g:actionSubmit class="btn edit" action="edit" value="${message(code: 'default.button.edit.label', default: 'Edit')}" />
                    <g:actionSubmit class="btn btn-danger delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" />
                </g:form>
            </div>
        </div>
    </body>
</html>
