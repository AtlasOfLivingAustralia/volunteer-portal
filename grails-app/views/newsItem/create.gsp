<%@ page import="au.org.ala.volunteer.NewsItem" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}"/>
        <title><g:message code="default.create.label" args="[entityName]"/></title>

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

        <cl:headerContent title="${message(code: 'default.create.label', args: [entityName])}">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'newsItem', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
                ]
            %>
        </cl:headerContent>

        <g:hasErrors bean="${newsItemInstance}">
            <div class="alert alert-danger">
                <g:renderErrors bean="${newsItemInstance}" as="list"/>
            </div>
        </g:hasErrors>
        <g:form action="save" class="form-horizontal">

            <div class="control-group">
                <label for="title" class="control-label"><g:message code="newsItem.title.label" default="Title"/></label>
                <div class="controls">
                    <g:textField name="title" value="${newsItemInstance?.title}"/>
                </div>
            </div>

            <div class="control-group">
                <label for="shortDescription" class="control-label"><g:message code="newsItem.shortDescription.label" default="Short description"/></label>
                <div class="controls">
                    <g:textField class="input-xxlarge" name="shortDescription" value="${newsItemInstance?.shortDescription}"/>
                </div>
            </div>

            <div class="control-group">
                <label for="body" class="control-label"><g:message code="newsItem.body.label" default="Body"/></label>
                <div class="controls">
                    <tinyMce:renderEditor type="advanced" name="body" cols="60" rows="10" class="input-xxlarge">
                        ${newsItemInstance?.body}
                    </tinyMce:renderEditor>

                </div>
            </div>

            <g:hiddenField name="createdBy" value="${(newsItemInstance?.createdBy) ? newsItemInstance.createdBy : currentUser }" />

            <g:hiddenField name="project" value="${newsItemInstance?.project?.id}" />

            <div class="control-group">
                <div class="controls">
                    <g:submitButton name="create" class="btn btn-primary" value="${message(code: 'default.button.create.label', default: 'Create')}"/>
                </div>
            </div>

        </g:form>
    </body>
</html>
