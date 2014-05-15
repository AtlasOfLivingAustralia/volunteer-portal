<!doctype html>
<html>
    <head>
        <meta name="layout" content="projectSettingsLayout"/>
    </head>

    <body>

        <content tag="pageTitle">General Settings</content>

        <content tag="adminButtonBar">
        </content>

        <g:form method="post" class="form-horizontal">
            <g:hiddenField name="id" value="${projectInstance?.id}"/>
            <g:hiddenField name="version" value="${projectInstance?.version}"/>

            <div class="control-group">
                <label class="control-label" for="name">Expedition sponsor</label>
                <div class="controls">
                    <g:textField class="input-xlarge" name="featuredOwner" value="${projectInstance.featuredOwner}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="name">Expedition name</label>
                <div class="controls">
                    <g:textField class="input-xlarge" name="name" value="${projectInstance.name}" />
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="shortDescription">Short description</label>
                <div class="controls">
                    <g:textField class="input-xxlarge" name="shortDescription"  value="${projectInstance.shortDescription}" />
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="description">Long description</label>
                <div class="controls">
                    <tinyMce:renderEditor type="advanced" name="description" cols="60" rows="10" class="span12">
                        ${projectInstance.description}
                    </tinyMce:renderEditor>
                    %{--<g:textArea rows="8" class="input-xxlarge" name="description"  value="${projectInstance.description}" />--}%
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="template">Template</label>
                <div class="controls">
                    <g:select name="template" from="${templates}" value="${projectInstance.template?.id}" optionKey="id" />
                    <a class="btn" href="${createLink(controller:'template', action:'edit', id:projectInstance?.template?.id)}">Edit template</a>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="projectType">Expedition type</label>
                <div class="controls">
                    <g:select name="projectType" from="${projectTypes}" value="${projectInstance.projectType?.id}" optionValue="label" optionKey="id" />
                </div>
            </div>

            <div class="control-group">
                <div class="controls">
                    <g:actionSubmit class="save btn btn-primary" action="updateGeneralSettings" value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                </div>
            </div>

        </g:form>

        <script type="text/javascript">
            $(document).ready(function() {
                tinyMCE.init({
                    mode: "textareas",
                    theme: "advanced",
                    editor_selector: "mceadvanced",
                    theme_advanced_toolbar_location : "top",
                    convert_urls : false
                });
            });
        </script>
    </body>
</html>
