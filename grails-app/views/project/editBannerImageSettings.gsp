<!doctype html>
<html>
    <head>
        <meta name="layout" content="projectSettingsLayout"/>
    </head>

    <body>

        <content tag="pageTitle">Banner image</content>

        <content tag="adminButtonBar">
        </content>

        <g:form action="uploadFeaturedImage" controller="project" method="post" enctype="multipart/form-data" class="form-horizontal">

            <g:hiddenField name="id" value="${projectInstance.id}" />

            <div class="control-group">
                <div class="alert">
                    Expedition banner images must be exactly <strong>254 x 158</strong> pixels in size (w x h). Images that have different dimensions will be scaled to this size when uploaded. To preserve image quality, crop and scale them to this size before uploading.
                </div>
            </div>

            <div class="control-group" style="text-align: center">
                <img src="${projectInstance?.featuredImage}" class="img-polaroid" />
                <div >
                    <em><small>${projectInstance.featuredImageCopyright}</small></em>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="featuredImage">Expedition Image</label>
                <div class="controls">
                    <input type="file" name="featuredImage" id="featuredImage"/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="featuredImageCopyright">Image copyright text</label>
                <div class="controls">
                    <g:textField name="featuredImageCopyright" class="input-xlarge" value="${projectInstance.featuredImageCopyright}" />
                </div>
            </div>

            <div class="control-group">
                <div class="controls">
                    <g:submitButton class="btn btn-primary" name="Update"/>
                </div>
            </div>

        </g:form>
        <script type='text/javascript'>
            $(document).ready(function () {
            });
        </script>

    </body>
</html>
