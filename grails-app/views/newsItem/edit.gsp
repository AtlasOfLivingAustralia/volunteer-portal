<%@ page import="au.org.ala.volunteer.NewsItem" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>

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

</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'newsItem', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
            ]
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${newsItemInstance}">
                        <div class="alert alert-danger">
                            <g:renderErrors bean="${newsItemInstance}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form method="post" class="form-horizontal">
                        <g:hiddenField name="id" value="${newsItemInstance?.id}"/>
                        <g:hiddenField name="version" value="${newsItemInstance?.version}"/>

                        <div class="form-group">
                            <label for="title" class="control-label col-md-2"><g:message code="newsItem.title.label" default="Title"/></label>

                            <div class="col-md-4">
                                <g:textField name="title" class="form-control" value="${newsItemInstance?.title}"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="shortDescription" class="control-label col-md-2"><g:message code="newsItem.shortDescription.label"
                                                                                           default="Short description"/></label>

                            <div class="col-md-4">
                                <g:textField class="form-control" name="shortDescription" value="${newsItemInstance?.shortDescription}"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="body" class="control-label col-md-2"><g:message code="newsItem.body.label" default="Body"/></label>

                            <div class="col-md-8">
                                <tinyMce:renderEditor type="advanced" name="body" rows="10" class="form-control">
                                    ${newsItemInstance?.body}
                                </tinyMce:renderEditor>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-10">
                                <g:actionSubmit class="save btn btn-small btn-primary" action="update"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                                <g:actionSubmit class="delete btn btn-small btn-danger" action="delete"
                                                value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
