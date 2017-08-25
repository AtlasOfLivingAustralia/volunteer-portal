<g:form action="cloneTemplate" params="[templateId: templateInstance.id]">
    <div class="form-group">
        <p class="">This will create a copy of the '${templateInstance.name}' template, including all of its fields and settings.</p>
    </div>

    <div class="form-group">
        <label for="newName" class="control-label">New template name:</label>
        <g:textField name="newName" class="form-control" value="Copy of ${templateInstance?.name}"/>
    </div>

    <div class="modal-footer">
        <button type="button" class="btn btn-default" id="btnCancelCloneTemplate">Cancel</button>
        <g:submitButton class="btn btn-success" id="btnCopyTemplate" name="clone">Clone template</g:submitButton>
    </div>
</g:form>

<script>

    $("#templateName").select().focus();

    $("#btnCancelCloneTemplate").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

</script>