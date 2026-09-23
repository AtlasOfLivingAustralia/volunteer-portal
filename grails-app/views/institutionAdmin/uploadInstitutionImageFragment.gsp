<div>

    <g:uploadForm action="uploadInstitutionImage">
        <g:hiddenField name="id" value="${institutionInstance.id}"/>
        <g:hiddenField name="imageType" value="${imageType ?: 'main'}"/>
        <div class="form-group">
            <div class="col-md-offset-2 col-md-6">
                <label class="form-label" for="imagefile">Image file</label>
                <input type="file" class="form-control" id="imagefile" name="imagefile"/>
            </div>
        </div>
        <div class="form-group">
            <div class="col-md-offset-2 col-md-6">
                <g:submitButton name="btnUploadInstitutionImage" class="btn btn-primary" value="Upload"/>
                <button type="button" class="btn btn-secondary" id="btnCancelInstitutionImageUpload">Cancel</button>
            </div>
        </div>
    </g:uploadForm>

</div>
<script>

    $("#btnCancelInstitutionImageUpload").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });


</script>