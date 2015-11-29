<div>

    <p>
        The <strong>${projectInstance.name}</strong> expedition currently has <strong>${taskCount}</strong> tasks.
    </p>

    <div class="alert alert-danger">
        <strong>Warning:</strong> This action cannot be undone. Are you sure you wish to remove all tasks (including those already transcribed) from expedition '${projectInstance.name}'?
    </div>

    <div class="form-horizontal">
        <div class="control-group">
            <div class="controls">
                <g:form controller="project" action="deleteTasks" id="${projectInstance.id}">
                    <button class="btn" id="btnCancelDeleteAllTasks">Cancel</button>
                    <button class="btn btn-primary" type="submit">Delete all tasks</button>
                </g:form>
            </div>
        </div>
    </div>

</div>

<script>

    $("#btnCancelDeleteAllTasks").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

</script>
