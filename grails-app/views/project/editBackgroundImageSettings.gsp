<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
    <asset:stylesheet src="bootstrap-colorpicker"/>
</head>

<body>

<content tag="pageTitle"><g:message code="project.expedition_background_image"/></content>

<content tag="adminButtonBar">
</content>

<div class="alert alert-warning">
    <g:message code="project.expedition_background_image.description"/>
</div>

<g:if test="${projectInstance?.backgroundImage}">
<div class="text-center">
    <div class="thumbnail display-inline-block">
        <img src="${projectInstance?.backgroundImage}" class="img-responsive" style="width: 600px;"/>
    </div>
</div>
</g:if>
<g:else>
    <div class="alert alert-info">
        <g:message code="project.expedition_background_image.no_image"/>
    </div>
</g:else>


<g:form action="uploadBackgroundImage" controller="project" method="post" enctype="multipart/form-data"
        class="form-horizontal">

    <g:hiddenField name="id" value="${projectInstance.id}"/>


    <div class="form-group">
        <label class="control-label col-md-3" for="backgroundImage"><g:message code="project.background_image"/></label>

        <div class="col-md-9">
            <input type="file" data-filename-placement="inside" name="backgroundImage" id="backgroundImage"/>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="backgroundImageAttribution"><g:message code="project.expedition_background_image.attribution"/></label>

        <div class="col-md-6">
            <g:textField name="backgroundImageAttribution" class="form-control"
                         value="${projectInstance.backgroundImageAttribution}"/>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="backgroundImageOverlayColour">
            <g:message code="project.backgroundImageOverlayColour.label" default="Background image overlay colour (rgba)"/>
        </label>
        <div class="col-md-6">
            <div class="input-group colpick" data-format="rgba">
                <g:textField name="backgroundImageOverlayColour" class="form-control" value="${projectInstance?.backgroundImageOverlayColour}"/>
                <span class="input-group-addon"><i></i></span>
            </div>
        </div>
        <div class="col-md-3">
            <cl:helpText>
                <g:message code="project.backgroundImageOverlayColour.help"/>
            </cl:helpText>
            <button role="button" type="button" id="setDefaultOverlay" class="btn btn-default btn-xs"><g:message code="project.backgroundImageOverlayColour.default"/></button>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-offset-3 col-md-9">
            <g:submitButton class="btn btn-success" name="Update"/>
            <a class="btn btn-danger" id="clearImageSettings" href="${createLink(action: 'clearBackgroundImageSettings', id: projectInstance.id)}"><g:message code="default.clear"/></a>
        </div>
    </div>

</g:form>
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:javascript src="bootbox" asset-defer=""/>
<asset:javascript src="bootstrap-colorpicker" asset-defer=""/>
<asset:script type='text/javascript'>
    $(function () {
        // Initialize input type file
        $('input[type=file]').bootstrapFileInput();

        $('#clearImageSettings').on('click', function(e) {
            e.preventDefault();
            var self = this;
            bootbox.confirm('${message(code: 'project.backgroundImageOverlayColour.delete.confirmation')}', function(result) {
                if (result) {
                    window.location.href = $(self).attr('href');
                }
            });
        });

        $('.colpick').colorpicker();
        bvp.bindTooltips('.fieldHelp');
        $('#setDefaultOverlay').click(function() {
            $('#backgroundImageOverlayColour').parent('.colpick').colorpicker('setValue', 'rgba(0,0,0,0.5)');
        });
    });
</asset:script>

</body>
</html>
