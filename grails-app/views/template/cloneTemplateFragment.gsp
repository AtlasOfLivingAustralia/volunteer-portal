<form>
    <div class="form-group">
        <p class=""><g:message code="template.cloneTemplateFragment.description" args="${[templateInstance.name]}"/></p>
    </div>

    <div class="form-group">
        <label for="templateName" class="control-label"><g:message code="template.cloneTemplateFragment.new_template_name" /></label>
        <g:textField name="templateName" class="form-control" value="${message(code: 'template.cloneTemplateFragment.copy_of', args: [templateInstance?.name])}"/>
    </div>

    <div class="modal-footer">
        <button type="button" class="btn btn-default" id="btnCancelCloneTemplate"><g:message code="default.cancel"/></button>
        <button type="button" class="btn btn-success" id="btnCopyTemplate"><g:message code="template.cloneTemplateFragment.clone_template" /></button>
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