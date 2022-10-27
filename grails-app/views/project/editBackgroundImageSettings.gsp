<%@ page import="au.org.ala.volunteer.Project" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
    <asset:stylesheet src="bootstrap-colorpicker"/>
</head>

<body>

<content tag="pageTitle">Expedition background image</content>

<content tag="adminButtonBar">
</content>

<div class="alert alert-warning">
    For best results and to preserve quality, it is recommend that the background image has a <strong>resolution</strong> of at least <strong>2 megapixels</strong> (eg: 1920 x 1080). The system won't accept images bigger than 512KB though.<br/>
    <strong>The darker the image the better!</strong>
</div>

<cl:hasProjectBackgroundImage project="${projectInstance}">
<div class="text-center">
    <div class="thumbnail display-inline-block">
        <cl:backgroundImage project="${projectInstance}" class="img-responsive" style="width: 600px;" />
    </div>
</div>
</cl:hasProjectBackgroundImage>
<cl:hasNoProjectBackgroundImage project="${projectInstance}">
    <div class="alert alert-info">
        No background image uploaded yet.
    </div>
</cl:hasNoProjectBackgroundImage>


<g:form action="uploadBackgroundImage" controller="project" method="post" enctype="multipart/form-data"
        class="form-horizontal">

    <g:hiddenField name="id" value="${projectInstance.id}"/>
    <g:hiddenField name="formType" value="${Project.EDIT_SECTION_BG_IMAGE}" />

    <div class="form-group">
        <label class="control-label col-md-3" for="backgroundImage">Background Image</label>

        <div class="col-md-9">
            <input type="file" data-filename-placement="inside" name="backgroundImage" id="backgroundImage"/>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="backgroundImageAttribution">Image attribution text</label>

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
            <cl:helpText>This will be applied over the background image.  Use this if the background image makes the text that overlays it unreadable.  A good starting point is black at half opacity (i.e. `rgba(0,0,0,0.5)`).</cl:helpText>
            <button role="button" type="button" id="setDefaultOverlay" class="btn btn-default btn-xs">Set to default</button>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-offset-3 col-md-9">
            <g:submitButton class="btn btn-success" name="Update"/>
            <a class="btn btn-danger" id="clearImageSettings" href="${createLink(action: 'clearBackgroundImageSettings', id: projectInstance.id)}">Clear</a>
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
            bootbox.confirm('The background image and attribution text will be deleted. Are you sure?', function(result) {
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
