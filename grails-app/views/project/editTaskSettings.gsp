<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body>

<content tag="pageTitle"><g:message code="project.tasks"/></content>

<content tag="adminButtonBar">
</content>

    <div class="alert alert-warning">
        <a href=<g:message code="project.edit_task.overview" args="${ [taskCount, createLink(controller: 'task', action: 'list', id: projectInstance.id)] }" />
    </div>

<div class="form-horizontal">

    <div class="form-group">
        <label class="control-label col-md-5"><g:message code="project.edit_task.upload_images"/></label>

        <div class="col-md-6">
            %{--<a class="btn" href="${createLink(controller: 'task', action: 'load', id: projectInstance.id)}">Load tasks (CSV File)...</a>--}%
            <a id="btnTaskStaging" class="btn btn-default"
               href="${createLink(controller: 'task', action: 'staging', params: [projectId: projectInstance.id])}"><g:message code="project.load_tasks_image_staging"/></a>

        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-5"><g:message code="project.edit_task.attach_new_data_to_existing_tasks"/></label>

        <div class="col-md-6">
            <a class="btn btn-default"
               href="${createLink(controller: 'task', action: 'loadTaskData', params: [projectId: projectInstance.id])}"><g:message code="project.load_task_data"/></a>
        </div>
    </div>


    <div class="form-group">
        <label class="control-label col-md-5"><g:message code="project.edit_task.remove_all_tasks"/></label>

        <div class="col-md-6">
            <button id="btnDeleteAllTasks" class="btn btn-danger"><i
                    class="icon-trash icon-white"></i>&nbsp;<g:message code="project.edit_task.delete_all_tasks"/></button>
        </div>
    </div>

</div>

<asset:script type='text/javascript'>

    $(document).ready(function () {

        $("#btnDeleteAllTasks").click(function (e) {
            e.preventDefault();
            var opts = {
                url: "${createLink(action:'deleteAllTasksFragment', id: projectInstance.id)}",
                title: "${message(code: 'project.edit_task.delete_all_tasks.confirmation')}"
            };
            bvp.showModal(opts);
        });
    });

</asset:script>

</body>
</html>
