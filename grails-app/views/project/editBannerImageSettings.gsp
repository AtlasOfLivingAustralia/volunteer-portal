<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body>

<content tag="pageTitle"><g:message code="project.expedition_image"/></content>

<content tag="adminButtonBar">
</content>

<div class="alert alert-warning">
    <g:message code="project.expedition_image.description"/>
</div>

<div class="text-center">
    <div class="thumbnail display-inline-block">
        <img src="${projectInstance?.featuredImage}" class="img-responsive" style="width: 600px;"/>
        <div class="caption">
            <g:message code="image.attribution.prefix" /> ${projectInstance.featuredImageCopyright}
        </div>
    </div>
</div>

<g:form action="uploadFeaturedImage" controller="project" method="post" enctype="multipart/form-data"
        class="form-horizontal">

    <g:hiddenField name="id" value="${projectInstance.id}"/>


    <div class="form-group">
        <label class="control-label col-md-3" for="featuredImage"><g:message code="project.expedition_image"/></label>

        <div class="col-md-9">
            <input type="file" data-filename-placement="inside" name="featuredImage" id="featuredImage"/>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="featuredImageCopyright"><g:message code="project.expedition_image.copyright.label"/></label>

        <div class="col-md-6">
            <g:textField name="featuredImageCopyright" class="form-control"
                         value="${projectInstance.featuredImageCopyright}"/>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-offset-3 col-md-9">
            <g:submitButton class="btn btn-primary" name="${message(code: 'default.button.update.label')}"/>
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
