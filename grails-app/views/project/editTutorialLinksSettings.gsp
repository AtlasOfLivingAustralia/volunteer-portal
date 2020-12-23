<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body>

<content tag="pageTitle">Tutorial Links</content>

<content tag="adminButtonBar">
</content>
<div style="margin-bottom: 3em;">
    Use this content area to give your volunteers helpful information on how to transcribe the expedition tasks. This
    might include Tutorial files you can upload. To link to a tutorial file, use the link button to create a link to the
    file, which can be found in the Tutorial admin.
</div>
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
