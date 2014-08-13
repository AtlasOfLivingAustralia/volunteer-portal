<div>

    <g:uploadForm class="form-horizontal" action="uploadInstitutionImage">
        <g:hiddenField name="id" value="${institutionInstance.id}" />
        <g:hiddenField name="imageType" value="${imageType ?: 'main'}" />
        <input type="file" name="imagefile" />
        <g:submitButton name="btnUploadInstitutionImage" class="btn btn-primary" value="Upload"/>
        <button type="button" id="btnCancelInstitutionImageUpload">Cancel</button>
    </g:uploadForm>

</div>
<script>

    $("#btnCancelInstitutionImageUpload").click(function(e) {
        e.preventDefault();
        bvp.hideModal();
    });


</script>