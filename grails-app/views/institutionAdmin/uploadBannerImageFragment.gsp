<div>

    <g:uploadForm class="form-horizontal" action="uploadInstitutionImage">
        <g:hiddenField name="id" value="${institutionInstance.id}" />
        <g:hiddenField name="imageType" value="banner" />
        <input type="file" name="imagefile" />
        <g:submitButton name="btnUploadBannerImage" class="btn btn-primary" value="Upload"/>
        <button type="button" id="btnCancelBannerImageUpload">Cancel</button>
    </g:uploadForm>

</div>
<script>

    $("#btnCancelBannerImageUpload").click(function(e) {
        e.preventDefault();
        bvp.hideModal();
    });


</script>