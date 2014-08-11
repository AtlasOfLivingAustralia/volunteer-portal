<div>

    <g:uploadForm class="form-horizontal" action="uploadInstitutionImage">
        <g:hiddenField name="id" value="${institutionInstance.id}" />
        <g:hiddenField name="imageType" value="logo" />
        <input type="file" name="imagefile" />
        <g:submitButton name="btnUploadLogoImage" class="btn btn-primary" value="Upload"/>
        <button type="button" id="btnCancelLogoImageUpload">Cancel</button>
    </g:uploadForm>

</div>
<script>

    $("#btnCancelLogoImageUpload").click(function(e) {
        e.preventDefault();
        bvp.hideModal();
    });


</script>