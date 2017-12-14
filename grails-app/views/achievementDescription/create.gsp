<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.ala.skin}">
    <g:set var="entityName"
           value="${message(code: 'achievementDescription.label', default: 'Badge Description')}"/>
    <title><g:message code="default.create.label" args="[entityName]"/></title>
    <asset:stylesheet src="codemirror/codemirror-monokai.css" />
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'create.achievementDescription.label', default: 'Create Badge')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'achievementDescription', action: 'index'), label: message(code: 'default.achievementDescription.label', default: 'Manage Badges')]
        ]

    %>
</cl:headerContent>

<div class="container" role="main">
    <div class="panel panel-default">
        <div class="panel-body">
            <g:hasErrors bean="${achievementDescriptionInstance}">
                <ul class="errors" role="alert">
                    <g:eachError bean="${achievementDescriptionInstance}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </g:hasErrors>
            <g:form url="[resource: achievementDescriptionInstance, action: 'save']" class="form-horizontal">
                <g:render template="form"/>
                <div class="form-group">
                    <div class="col-md-offset-3 col-md-9">
                        <g:submitButton name="create" class="save btn btn-primary"
                                        value="${message(code: 'default.button.create.label', default: 'Create')}"/>
                    </div>
                </div>
            </g:form>
        </div>
    </div>
</div>
<asset:javascript src="bootstrap-file-input.js" asset-defer=""/>
<asset:script type="text/javascript">
    $(function() {
        // Initialize input type file
        $('input[type=file]').bootstrapFileInput();
    });
</asset:script>
</body>
</html>
