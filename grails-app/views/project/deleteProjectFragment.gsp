<div>

    <g:if test="${taskCount}">
        <div class="alert alert-danger">
            The <strong>${projectInstance.name}</strong> expedition currently has <strong>${taskCount}</strong> tasks.
        </div>
    </g:if>

    <div class="alert alert-danger">
        <strong>Warning:</strong> This action cannot be undone. Are you sure you wish to delete this expedition?
    </div>

    <div class="form-horizontal">
        <div class="control-group">
            <div class="controls">
                <g:form controller="project" action="delete" id="${projectInstance.id}">
                    <button class="btn" id="btnCancelDeleteExpedition">Cancel</button>
                    <button class="btn btn-primary" type="submit">Delete expedition</button>
                </g:form>
            </div>
        </div>
    </div>

</div>

<script>

    $("#btnCancelDeleteExpedition").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

</script>
