<%@ page import="au.org.ala.volunteer.Template" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>

        <r:script>

            $(document).ready(function() {

                $("#btnPreview").click(function(e) {
                    e.preventDefault();
                    window.open("${createLink(controller:'template', action:'preview', id:templateInstance.id)}", "TemplatePreview");
                });

                $("#btnEditFields").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller: 'template',action:'manageFields', id:templateInstance.id)}";
                });

            });


        </r:script>

    </head>
    <body>

        <cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])} - ${templateInstance.name}">
           <%
               pageScope.crumbs = [
                   [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                   [link: createLink(controller: 'template', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
               ]
           %>
            <div>
                <a href="${createLink(action:'create')}" class="btn">Create new template</a>
            </div>
       </cl:headerContent>

        <div class="row">
            <div class="span12">
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
                                        <g:if test="${availableViews}">
                                            <g:select from="${availableViews}" name="viewName" value="${templateInstance?.viewName}" />
                                        </g:if>
                                        <g:else>
                                            <g:textField name="viewName" value="${templateInstance?.viewName}" />
                                        </g:else>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="project"><g:message code="template.viewparams.label" default="Template View Parameters:" /></label>
                                    </td>
                                    <td valign="top" class="value">
                                        <g:textArea name="viewParamsJSON" rows="4" cols="40" value="${templateInstance.viewParams as grails.converters.JSON}">
                                        </g:textArea>
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
                                    <td>
                                        <button class="btn" id="btnEditFields">Edit Fields</button>
                                        <button class="btn" id="btnPreview">Preview Template</button>
                                    </td>
                                </tr>

                            </tbody>
                        </table>
                    </div>
                    <div class="buttons">
                        <g:actionSubmit class="btn save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" />
                        <g:actionSubmit class="btn btn-danger delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" />
                    </div>
                </g:form>
            </div>
        </div>
    </body>
</html>
