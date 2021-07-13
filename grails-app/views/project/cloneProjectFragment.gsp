<g:form action="cloneProject" params="[projectId: project.id]">
    <div class="form-group">
        <p class="">This will create a copy of the expedition <b>'${project.name}'</b>.</p>
        <p>Enter a new name for the expedition and click the 'Clone expedition' button.</p>
        <p>This will copy the following fields:</p>
        <ul>
            <li>Description</li>
            <li>Template</li>
            <li>Expedition Type</li>
            <li>Tags</li>
            <li>Expedition Image</li>
            <li>Expedition Background Image</li>
            <li>Picklist Institution</li>
            <li>Tutorial Info</li>
            <li>Map settings</li>
        </ul>
    </div>

    <div class="form-group">
        <label for="newName" class="control-label">New expedition name:</label>
        <g:textField name="newName" id="expeditionName" class="form-control" value="Copy of ${project?.name}"/>
    </div>

    <div class="modal-footer">
        <button type="button" class="btn btn-default" id="btnCancelCloneProject">Cancel</button>
        <g:submitButton class="btn btn-success" id="btnCopyProject" name="Clone Expedition" />
    </div>
</g:form>

<script>

    $("#expeditionName").select().focus();

    $("#btnCancelCloneProject").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

</script>