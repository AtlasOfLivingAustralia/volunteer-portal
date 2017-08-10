<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body>

<content tag="pageTitle"><g:message code="project.edit_tutorial.label"/></content>

<content tag="adminButtonBar">
</content>

<g:form method="post" class="form-horizontal">
    <g:hiddenField name="id" value="${projectInstance?.id}"/>
    <g:hiddenField name="version" value="${projectInstance?.version}"/>

    <div class="form-group">
        <div class="col-md-12">
            <g:textArea name="tutorialLinks" class="mce form-control" rows="10" value="${projectInstance?.tutorialLinks}" />
        </div>

    </div>

    <div class="form-group">
        <div class="col-md-12">
            <g:actionSubmit class="save btn btn-primary" action="updateTutorialLinksSettings"
                            value="${message(code: 'default.button.update.label', default: 'Update')}"/>
        </div>
    </div>

</g:form>

</body>
</html>
