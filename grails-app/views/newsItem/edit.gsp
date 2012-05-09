<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.NewsItem" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>
    </head>
    <body class="sublevel sub-site volunteerportal">
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
            <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></span>
        </div>
        <div>
            <div class="inner">
                <h1><g:message code="default.edit.label" args="[entityName]" /></h1>
                <cl:messages />
                <g:hasErrors bean="${newsItemInstance}">
                <div class="errors">
                    <g:renderErrors bean="${newsItemInstance}" as="list" />
                </div>
                </g:hasErrors>
                <g:form method="post" >
                    <g:hiddenField name="id" value="${newsItemInstance?.id}" />
                    <g:hiddenField name="version" value="${newsItemInstance?.version}" />
                    <div class="dialog">
                        <table>
                            <tbody>
                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="title"><g:message code="newsItem.title.label" default="Title" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: newsItemInstance, field: 'title', 'errors')}">
                                        <g:textField name="title" value="${newsItemInstance?.title}" />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="shortDescription"><g:message code="newsItem.shortDescription.label" default="Short description" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: newsItemInstance, field: 'shortDescription', 'errors')}">
                                        <g:textArea cols="50" rows="4" name="shortDescription" value="${newsItemInstance?.shortDescription}" />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="body"><g:message code="newsItem.body.label" default="Body" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: newsItemInstance, field: 'body', 'errors')}">
                                        %{--<g:textArea name="body" cols="40" rows="5" value="${newsItemInstance?.body}" />--}%
                                        <tinyMce:renderEditor type="advanced" name="body" cols="60" rows="10" style="width:500px;">
                                            ${newsItemInstance?.body}
                                        </tinyMce:renderEditor>
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="created"><g:message code="newsItem.created.label" default="Created" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: newsItemInstance, field: 'created', 'errors')}">
                                        <g:datePicker name="created" precision="day" value="${newsItemInstance?.created}"  />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="createdBy"><g:message code="newsItem.createdBy.label" default="Created By" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: newsItemInstance, field: 'createdBy', 'errors')}">
                                        <g:textField name="createdBy" value="${(newsItemInstance?.createdBy) ? newsItemInstance.createdBy : currentUser }" />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="project"><g:message code="newsItem.project.label" default="Project" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: newsItemInstance, field: 'project', 'errors')}">
                                        <g:select name="project.id" from="${au.org.ala.volunteer.Project.list()}" optionKey="id" optionValue="name" value="${newsItemInstance?.project?.id}" />
                                    </td>
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
        </div>
    </body>
</html>
