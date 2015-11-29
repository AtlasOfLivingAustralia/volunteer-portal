<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body>

<content tag="pageTitle">Tasks</content>

<content tag="adminButtonBar">
</content>

    <div class="alert alert-warning">
        There are <strong>${taskCount}</strong> <a
            href="${createLink(controller: 'task', action: 'list', id: projectInstance.id)}">tasks</a> loaded.
    </div>

<div class="form-horizontal">

    <div class="form-group">
        <label class="control-label col-md-5">Upload images and create new tasks</label>

        <div class="col-md-6">
            %{--<a class="btn" href="${createLink(controller: 'task', action: 'load', id: projectInstance.id)}">Load tasks (CSV File)...</a>--}%
            <a id="btnTaskStaging" class="btn btn-default"
               href="${createLink(controller: 'task', action: 'staging', params: [projectId: projectInstance.id])}">Load Tasks (Image Staging)</a>

        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-5">Attach new data to existing tasks</label>

        <div class="col-md-6">
            <a class="btn btn-default"
               href="${createLink(controller: 'task', action: 'loadTaskData', params: [projectId: projectInstance.id])}">Load Task Data</a>
        </div>
    </div>


    <div class="form-group">
        <label class="control-label col-md-5">Permanently remove all tasks and their images</label>

        <div class="col-md-6">
            <button id="btnDeleteAllTasks" class="btn btn-danger"><i
                    class="icon-trash icon-white"></i>&nbsp;Delete All Tasks</button>
        </div>
    </div>

</div>

<script type='text/javascript'>

    $(document).ready(function () {

        $("#btnDeleteAllTasks").click(function (e) {
            e.preventDefault();
            var opts = {
                url: "${createLink(action:'deleteAllTasksFragment', id: projectInstance.id)}",
                title: "Delete all tasks?"
            };
            bvp.showModal(opts);
        });
    });

</script>

</body>
</html>
