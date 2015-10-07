<form>

    <div class="form-group">
        <p class="">This will create a copy of the '${templateInstance.name}' template, including all of its fields and settings.</p>
    </div>

    <div class="form-group">
        <label for="templateName" class="control-label">New template name:</label>

        <div class="controls">
            <g:textField name="templateName" class="form-control" value="Copy of ${templateInstance?.name}"/>
        </div>
    </div>

    <div class="modal-footer">
        <button type="button" class="btn btn-default" id="btnCancelCloneTemplate">Cancel</button>
        <button type="button" class="btn btn-primary" id="btnCopyTemplate">Clone template</button>
    </div>
</form>

<script>

    $("#templateName").select().focus();

    $("#btnCancelCloneTemplate").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

    $("#btnCopyTemplate").click(function (e) {
        e.preventDefault();
        var newName = $("#templateName").val();
        if (newName) {
            window.location = "${createLink(action:"cloneTemplate", params:[templateId: templateInstance.id])}&newName=" + newName;
        }
    });

</script>