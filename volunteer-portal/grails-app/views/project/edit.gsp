

<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
            <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="body">
            <h1><g:message code="default.edit.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${projectInstance}">
            <div class="errors">
                <g:renderErrors bean="${projectInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <g:hiddenField name="id" value="${projectInstance?.id}" />
                <g:hiddenField name="version" value="${projectInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="name"><g:message code="project.name.label" default="Name" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'name', 'errors')}">
                                    <g:textField name="name" maxlength="200" value="${projectInstance?.name}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="description"><g:message code="project.description.label" default="Description" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'description', 'errors')}">
                                    %{--<g:textArea name="description" cols="40" rows="5" value="${projectInstance?.description}" />--}%
                                    <tinyMce:renderEditor type="advanced" name="description" cols="60" rows="10" style="width:500px;">
                                        ${projectInstance?.description}
                                    </tinyMce:renderEditor>
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="description"><g:message code="project.tutorialLinks.label" default="Tutorial Links" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'tutorialLinks', 'errors')}">
                                    %{--<g:textArea name="tutorialLinks" cols="40" rows="5" value="${projectInstance?.tutorialLinks}" />--}%
                                    <tinyMce:renderEditor type="advanced" name="tutorialLinks" cols="60" rows="10" style="width:500px;">
                                        ${projectInstance?.tutorialLinks}
                                    </tinyMce:renderEditor>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="template"><g:message code="project.template.label" default="Template" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'template', 'errors')}">
                                    <g:select name="template.id" from="${au.org.ala.volunteer.Template.list()}" optionKey="id" value="${projectInstance?.template?.id}" noSelection="['null': '']" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="created"><g:message code="project.created.label" default="Created" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'created', 'errors')}">
                                    <g:datePicker name="created" precision="day" value="${projectInstance?.created}" default="none" noSelection="['': '']" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="bannerImage"><g:message code="project.bannerImage.label" default="Banner Image" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'bannerImage', 'errors')}">
                                    <g:textField name="bannerImage" value="${projectInstance?.bannerImage}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="newsItems"><g:message code="project.newsItems.label" default="News Items" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'newsItems', 'errors')}">
                                    
<ul>
<g:each in="${projectInstance?.newsItems?}" var="n">
    <li><g:link controller="newsItem" action="show" id="${n.id}">${n?.encodeAsHTML()}</g:link></li>
</g:each>
</ul>
<g:link controller="newsItem" action="create" params="['project.id': projectInstance?.id]">${message(code: 'default.add.label', args: [message(code: 'newsItem.label', default: 'NewsItem')])}</g:link>

                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="projectAssociations"><g:message code="project.projectAssociations.label" default="Project Associations" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'projectAssociations', 'errors')}">
                                    
<ul>
<g:each in="${projectInstance?.projectAssociations?}" var="p">
    <li><g:link controller="projectAssociation" action="show" id="${p.id}">${p?.encodeAsHTML()}</g:link></li>
</g:each>
</ul>
<g:link controller="projectAssociation" action="create" params="['project.id': projectInstance?.id]">${message(code: 'default.add.label', args: [message(code: 'projectAssociation.label', default: 'ProjectAssociation')])}</g:link>

                                </td>
                            </tr>
                        
                            %{--<tr class="prop">--}%
                                %{--<td valign="top" class="name">--}%
                                  %{--<label for="tasks"><g:message code="project.tasks.label" default="Tasks" /></label>--}%
                                %{--</td>--}%
                                %{--<td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'tasks', 'errors')}">--}%
                                    %{----}%
%{--<ul>--}%
%{--<g:each in="${projectInstance?.tasks?}" var="t">--}%
    %{--<li><g:link controller="task" action="show" id="${t.id}">${t?.encodeAsHTML()}</g:link></li>--}%
%{--</g:each>--}%
%{--</ul>--}%
%{--<g:link controller="task" action="create" params="['project.id': projectInstance?.id]">${message(code: 'default.add.label', args: [message(code: 'task.label', default: 'Task')])}</g:link>--}%

                                %{--</td>--}%
                            %{--</tr>--}%
                        
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
