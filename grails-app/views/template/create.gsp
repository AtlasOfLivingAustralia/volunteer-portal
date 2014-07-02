<%@ page import="au.org.ala.volunteer.Template" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}" />
        <title><g:message code="default.create.label" args="[entityName]" /></title>
    </head>
    <body>

        <cl:headerContent title="${message(code: 'default.create.label', args: [entityName])}">
           <%
               pageScope.crumbs = [
                   [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                   [link: createLink(controller: 'template', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
               ]
           %>
       </cl:headerContent>

        <div class="row">
            <div class="span12">
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
                                        <g:if test="${availableViews}">
                                            <g:select from="${availableViews}" name="viewName" value="${templateInstance?.viewName}" />
                                        </g:if>
                                        <g:else>
                                            <g:textField name="viewName" value="${templateInstance?.viewName}" />
                                        </g:else>
                                    </td>
                                </tr>

                            </tbody>
                        </table>
                    </div>

                    <g:submitButton name="create" class="btn save" value="${message(code: 'default.button.create.label', default: 'Create')}" />

                </g:form>
            </div>
        </div>
    </body>
</html>
