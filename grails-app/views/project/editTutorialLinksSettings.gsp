<!doctype html>
<html>
<head>
    <meta name="layout" content="projectSettingsLayout"/>
</head>

<body>

<content tag="pageTitle">Tutorial Links</content>

<content tag="adminButtonBar">
</content>

<g:form method="post" class="form-horizontal">
    <g:hiddenField name="id" value="${projectInstance?.id}"/>
    <g:hiddenField name="version" value="${projectInstance?.version}"/>



    <div class="control-group">
        <div class="controls">
            <g:actionSubmit class="save btn btn-primary" action="updateTutorialLinksSettings" value="${message(code: 'default.button.update.label', default: 'Update')}"/>
        </div>
    </div>

</g:form>

<script type='text/javascript'>
    $(document).ready(function () {
    });
</script>
</body>
</html>
