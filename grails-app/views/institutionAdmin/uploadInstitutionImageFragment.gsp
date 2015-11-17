<div>

    <g:uploadForm class="form-horizontal" action="uploadInstitutionImage">
        <g:hiddenField name="id" value="${institutionInstance.id}"/>
        <g:hiddenField name="imageType" value="${imageType ?: 'main'}"/>
        <div class="form-group">
            <div class="col-md-offset-2 col-md-6">
                <input type="file" data-filename-placement="inside" name="imagefile"/>
            </div>
        </div>
        <div class="form-group">
            <div class="col-md-offset-2 col-md-6">
                <g:submitButton name="btnUploadInstitutionImage" class="btn btn-primary" value="Upload"/>
                <button type="button" class="btn btn-default" id="btnCancelInstitutionImageUpload">Cancel</button>
            </div>
        </div>
    </g:uploadForm>

</div>
<script>

    $("#btnCancelInstitutionImageUpload").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

    // Initialize input type file
    $('input[type=file]').bootstrapFileInput();

</script>