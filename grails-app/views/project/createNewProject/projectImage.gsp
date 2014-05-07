<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title>Create a new Expedition - Details</title>

        <r:script type="text/javascript">

            $(document).ready(function() {
            });

        </r:script>

        <style type="text/css">
        </style>

    </head>
    <body>

        <cl:headerContent title="Create a new Expedition - Details cont." selectedNavItem="expeditions">
            <% pageScope.crumbs = [] %>
        </cl:headerContent>

        <g:if test="${errorMessages}">
            <div class="alert alert-error">
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
                        <label class="control-label" for="featuredImage">Expedition Image</label>
                        <div class="controls">
                            <input type="file" name="featuredImage" id="featuredImage"/>
                            <cl:helpText>Expedition images must be exactly <strong>254 x 158</strong> pixels in size (w x h). Images that have different dimensions will be scaled to this size when uploaded. To preserve image quality, crop and scale them to this size before uploading.</cl:helpText>
                        </div>
                    </div>

                    <g:if test="${projectImageUrl}">
                        <div class="control-group">
                            <div class="controls">
                                <img src="${projectImageUrl}" class="img-polaroid" />
                                <g:link class="btn btn-warning" event="clearImage"><i class="icon-trash icon-white"></i>&nbsp;Remove image</g:link>
                            </div>
                        </div>
                    </g:if>

                    <div class="control-group">
                        <label class="control-label" for="imageCopyright">Image copyright</label>
                        <div class="controls">
                            <g:textField name="imageCopyright" class="input-xlarge" value="${project.imageCopyright}" />
                        </div>
                    </div>

                    <div class="control-group">
                        <div class="controls">
                            <g:link class="btn btn-small" event="cancel">Cancel</g:link>
                            <g:link class="btn btn-small" event="back"><i class="icon-chevron-left"></i>&nbsp;Previous</g:link>
                            <g:submitButton name="continue" class="btn btn-small btn-primary" value="Next" />
                        </div>
                    </div>

                </div>
            </g:uploadForm>
        </div>
    </body>
</html>