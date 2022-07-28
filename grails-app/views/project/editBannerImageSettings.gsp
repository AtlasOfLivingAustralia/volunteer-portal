<%@ page import="au.org.ala.volunteer.Project" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body>

<content tag="pageTitle">Expedition image</content>

<content tag="adminButtonBar">
</content>

<div class="alert alert-warning">
    For best results and to preserve quality, it is recommend that the expedition image aspect ratio sits anywhere between <strong>3:2</strong> and <strong>4:3</strong> with a minimum of <strong>600px width</strong>.
</div>

<div class="text-center">
    <div class="thumbnail display-inline-block">
        <cl:featuredImage project="${projectInstance}" class="img-responsive" style="width: 600px;"/>
        <div class="caption">
            <g:message code="image.attribution.prefix" /> ${projectInstance.featuredImageCopyright}
        </div>
    </div>
</div>

<g:form action="uploadFeaturedImage" controller="project" method="post" enctype="multipart/form-data"
        class="form-horizontal">

    <g:hiddenField name="id" value="${projectInstance.id}"/>
    <g:hiddenField name="formType" value="${Project.EDIT_SECTION_IMAGE}" />


    <div class="form-group">
        <label class="control-label col-md-3" for="featuredImage">Expedition Image</label>

        <div class="col-md-9">
            <input type="file" data-filename-placement="inside" name="featuredImage" id="featuredImage"/>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="featuredImageCopyright">Image copyright text</label>

        <div class="col-md-6">
            <g:textField name="featuredImageCopyright" class="form-control"
                         value="${projectInstance.featuredImageCopyright}"/>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-offset-3 col-md-9">
            <g:submitButton class="btn btn-primary" name="Update"/>
        </div>
    </div>

</g:form>
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:script type='text/javascript'>
    $(function () {

        // Initialize input type file
        $('input[type=file]').bootstrapFileInput();
    });
</asset:script>

</body>
</html>
