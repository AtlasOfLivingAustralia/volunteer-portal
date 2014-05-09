<!doctype html>
<html>
<head>
    <meta name="layout" content="projectSettingsLayout"/>
</head>

<body>

<content tag="pageTitle">Tasks</content>

<content tag="adminButtonBar">
</content>

<div class="form-horizontal">
    <div class="control-group">
        <div class="controls">
            There are <strong>${taskCount}</strong> <a href="${createLink(controller: 'task', action: 'list', id: projectInstance.id)}">tasks</a> loaded.
        </div>
    </div>

    <div class="control-group">
        <label class="control-label">Upload images and create new tasks</label>
        <div class="controls">
            %{--<a class="btn" href="${createLink(controller: 'task', action: 'load', id: projectInstance.id)}">Load tasks (CSV File)...</a>--}%
            <a id="btnTaskStaging" class="btn" href="${createLink(controller: 'task', action: 'staging', params: [projectId: projectInstance.id])}">Load Tasks (Image Staging)</a>

        </div>
    </div>

    <div class="control-group">
        <label class="control-label">Attach new data to existing tasks</label>
        <div class="controls">
            <a class="btn" href="${createLink(controller: 'task', action: 'loadTaskData', params: [projectId: projectInstance.id])}">Load Task Data</a>
        </div>
    </div>


    <div class="control-group">
        <label class="control-label">Permanently remove all tasks and their images</label>
        <div class="controls">
            <button id="btnDeleteAllTasks" class="btn btn-danger"><i class="icon-trash icon-white"></i>&nbsp;Delete All Tasks</button>
        </div>
    </div>

</div>

    <script type='text/javascript'>

        $(document).ready(function () {

            $("#btnDeleteAllTasks").click(function(e) {
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
