<%@ page import="au.org.ala.volunteer.NewsItem" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>

        <tinyMce:resources/>

        <r:script type="text/javascript">

            tinyMCE.init({
                mode: "textareas",
                theme: "advanced",
                editor_selector: "mceadvanced",
                theme_advanced_toolbar_location: "top",
                convert_urls: false
            });

        </r:script>

        <style type="text/css">

            .table tr td {
                border: none;
            }

        </style>

    </head>
    <body>

        <cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])}">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'newsItem', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <g:hasErrors bean="${newsItemInstance}">
                <div class="errors">
                    <g:renderErrors bean="${newsItemInstance}" as="list" />
                </div>
                </g:hasErrors>
                <g:form method="post" >
                    <g:hiddenField name="id" value="${newsItemInstance?.id}" />
                    <g:hiddenField name="version" value="${newsItemInstance?.version}" />
                    <div class="dialog">
                        <table class="table">
                            <tbody>
                                <tr class="prop">
                                    <td valign="top" class="name">
                                      <label for="title"><g:message code="newsItem.title.label" default="Title" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: newsItemInstance, field: 'title', 'errors')}">
                                        <g:textField class="input-xxlarge" name="title" value="${newsItemInstance?.title}" />
                                    </td>
                                </tr>

                                <tr class="prop">
                                    <td valign="top" class="name">
                                        <label for="shortDescription"><g:message code="newsItem.shortDescription.label" default="Short description" /></label>
                                    </td>
                                    <td valign="top" class="value ${hasErrors(bean: newsItemInstance, field: 'shortDescription', 'errors')}">
                                        <g:textArea class="input-xxlarge" cols="50" rows="4" name="shortDescription" value="${newsItemInstance?.shortDescription}" />
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
                    <div>
                        <g:actionSubmit class="save btn btn-small" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" />
                        <g:actionSubmit class="delete btn btn-small btn-danger" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" />
                    </div>
                </g:form>
            </div>
        </div>
    </body>
</html>
