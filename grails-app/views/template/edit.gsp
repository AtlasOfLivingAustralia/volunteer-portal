<%@ page import="au.org.ala.volunteer.Template" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
            <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="inner">
            <h1><g:message code="default.edit.label" args="[entityName]" /></h1>
            <cl:messages />
            <g:hasErrors bean="${templateInstance}">
            <div class="errors">
                <g:renderErrors bean="${templateInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <g:hiddenField name="id" value="${templateInstance?.id}" />
                <g:hiddenField name="version" value="${templateInstance?.version}" />
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
                                  <label for="project"><g:message code="template.project.label" default="Projects that use this template:" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateInstance, field: 'project', 'errors')}">
                                    
                                    <ul>
                                    <g:each in="${templateInstance?.project?}" var="p">
                                        <li><g:link controller="project" action="show" id="${p.id}">${p?.encodeAsHTML()}</g:link></li>
                                    </g:each>
                                    </ul>
                                </td>
                            </tr>

                            <tr>
                                <td></td>
                                <td><a class="button" href="${createLink(controller: 'template',action:'manageFields', id:templateInstance.id)}">Edit Fields</a></td>
                            </tr>
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" /></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
