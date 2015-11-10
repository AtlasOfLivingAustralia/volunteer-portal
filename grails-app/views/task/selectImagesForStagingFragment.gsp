<div class="form-horizontal">

    <div class="alert alert-info">
        Depending on your connection speed and the size of your images, it might be a good idea to stage images in batches of 200 or less.
    </div>

    <g:form name="stageImagesForm" controller="task" action="stageImage" method="post" enctype="multipart/form-data"
            class="form-horizontal">
        <g:hiddenField name="projectId" value="${projectInstance.id}"/>
        <div class="form-group">
            <div class="col-md-12 text-center">
                <input type="file" name="imageFile" id="imageFile" data-filename-placement="inside" multiple="multiple"/>
            </div>
        </div>

        <div class="form-group">
            <div class="col-md-12 text-center">
                <button id="btnCancelUploadImages" class="btn btn-default">Cancel</button>
                <button id="btnUploadImages" class="btn btn-primary">Stage images</button>
            </div>
        </div>

        <div class="form-group">
            <div id="uploadingMessage" class="col-md-12 text-center" style="display: none">
                <cl:spinner/> Uploading, please wait...
            </div>
        </div>

    </g:form>

    <script>

        $("#btnCancelUploadImages").click(function (e) {
            e.preventDefault();
            bvp.hideModal();
        });

        $("#btnUploadImages").click(function (e) {
            e.preventDefault();
            $("#uploadingMessage").css("display", "block");
            $("#stageImagesForm").submit();
        });

        // Initialize input type file
        $('input[type=file]').bootstrapFileInput();

    </script>

</div>