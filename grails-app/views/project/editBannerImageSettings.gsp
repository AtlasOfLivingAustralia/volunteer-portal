<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
    <r:require modules="bootstrap-file-input"/>
</head>

<body>

<content tag="pageTitle">Expedition image</content>

<content tag="adminButtonBar">
</content>

<div class="alert alert-warning">
    Expedition images must be exactly <strong>254 x 158</strong> pixels in size (w x h). Images that have different dimensions will be scaled to this size when uploaded. To preserve image quality, crop and scale them to this size before uploading.
</div>

<div class="thumbnail">
    <img src="${projectInstance?.featuredImage}" class="img-responsive"/>
    <div class="caption">
        &copy; ${projectInstance.featuredImageCopyright}
    </div>
</div>

<g:form action="uploadFeaturedImage" controller="project" method="post" enctype="multipart/form-data"
        class="form-horizontal">

    <g:hiddenField name="id" value="${projectInstance.id}"/>


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
<script type='text/javascript'>
    $(document).ready(function () {
        // Initialize input type file
        $('input[type=file]').bootstrapFileInput();
    });
</script>

</body>
</html>
