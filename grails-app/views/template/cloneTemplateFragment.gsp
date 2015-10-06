<div class="form-horizontal">

    <div class="control-group">
        This will create a copy of the '${templateInstance.name}' template, including all of its fields and settings.
    </div>

    <div class="control-group">
        <label for="templateName" class="control-label">New template name:</label>

        <div class="controls">
            <g:textField name="templateName" value="Copy of ${templateInstance?.name}"/>
        </div>
    </div>

    <div class="control-group">
        <div class="controls">
            <button type="button" class="btn" id="btnCancelCloneTemplate">Cancel</button>
            <button type="button" class="btn btn-primary" id="btnCopyTemplate">Clone template</button>
        </div>
    </div>
</div>

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