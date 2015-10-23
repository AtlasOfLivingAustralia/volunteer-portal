<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Create a new Expedition - Banner image</title>

    <r:script type="text/javascript">

        bvp.bindTooltips();
        bvp.suppressEnterSubmit();

        $(document).ready(function () {
            $("#btnNext").click(function (e) {
                e.preventDefault();
                bvp.submitWithWebflowEvent($(this));
            });

        });

    </r:script>

    <style type="text/css">
    </style>

</head>

<body>

<cl:headerContent title="Create a new Expedition - Expedition image" selectedNavItem="expeditions">
    <% pageScope.crumbs = [] %>
</cl:headerContent>

<g:if test="${errorMessages}">
    <div class="alert alert-danger">
        Please correct the following before proceeding:
        <ul>
            <g:each in="${errorMessages}" var="errorMessage">
                <li>
                    ${errorMessage}
                </li>
            </g:each>
        </ul>
    </div>
</g:if>


<div class="well well-small">
    <g:uploadForm>
        <div class="form-horizontal">

            <div class="control-group">
                <div class="controls">
                    The Expedition image appears on the expedition front page, and in the expeditions list.
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="featuredImage">Expedition image</label>

                <div class="controls">
                    <input type="file" name="featuredImage" id="featuredImage"/>
                    <cl:helpText>Expedition images must be exactly <strong>254 x 158</strong> pixels in size (w x h). Images that have different dimensions will be scaled to this size when uploaded. To preserve image quality, crop and scale them to this size before uploading.</cl:helpText>
                </div>
            </div>

            <g:if test="${projectImageUrl}">
                <div class="control-group">
                    <div class="controls">
                        <img src="${projectImageUrl}" class="img-polaroid"/>
                        <g:link class="btn btn-warning" event="clearImage"><i
                                class="icon-trash icon-white"></i>&nbsp;Remove image</g:link>
                    </div>
                </div>
            </g:if>

            <div class="control-group">
                <label class="control-label" for="imageCopyright">Image copyright</label>

                <div class="controls">
                    <g:textField name="imageCopyright" class="input-xlarge" value="${project.imageCopyright}"/>
                </div>
            </div>

            <div class="control-group">
                <div class="controls">
                    <g:link class="btn" event="cancel">Cancel</g:link>
                    <g:link class="btn" event="back"><i class="icon-chevron-left"></i>&nbsp;Back</g:link>
                    <button id="btnNext" event="continue" class="btn btn-primary">Next&nbsp;<i
                            class="icon-chevron-right icon-white"></i></button>
                </div>
            </div>

        </div>
    </g:uploadForm>
</div>
</body>
</html>