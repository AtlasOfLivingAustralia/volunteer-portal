<%@ page contentType="text/html; charset=UTF-8" %>
<div>

    <p>
        <g:message code="project.delete_all_tasks_fragment.overview" args="${ [projectInstance.i18nName, taskCount] }" />
    </p>

    <div class="alert alert-danger">

        <g:message code="project.delete_all_tasks_fragment.confirmation" args="${ [projectInstance.i18nName] }" />

    </div>

    <div class="form-horizontal">
        <div class="control-group">
            <div class="controls">
                <g:form controller="project" action="deleteTasks" id="${projectInstance.id}">
                    <button class="btn btn-default" id="btnCancelDeleteAllTasks"><g:message code="default.cancel"/></button>
                    <button class="btn btn-primary" type="submit"><g:message code="project.delete_all_tasks"/></button>
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
