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
        <tinyMce:renderEditor type="advanced" name="tutorialLinks" cols="60" rows="10" class="span12">
            ${projectInstance?.tutorialLinks}
        </tinyMce:renderEditor>
    </div>

    <div class="control-group">
        <g:actionSubmit class="save btn btn-primary" action="updateTutorialLinksSettings"
                        value="${message(code: 'default.button.update.label', default: 'Update')}"/>
    </div>

</g:form>

<script type="text/javascript">
    $(document).ready(function () {
        tinyMCE.init({
            mode: "textareas",
            theme: "advanced",
            editor_selector: "mceadvanced",
            theme_advanced_toolbar_location: "top",
            convert_urls: false
        });
    });
</script>
</body>
</html>
