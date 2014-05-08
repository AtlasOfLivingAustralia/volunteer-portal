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
        <label class="control-label">Upload task images and create new tasks</label>
        <div class="controls">
            %{--<a class="btn" href="${createLink(controller: 'task', action: 'load', id: projectInstance.id)}">Load tasks (CSV File)...</a>--}%
            <a id="btnTaskStaging" class="btn" href="${createLink(controller: 'task', action: 'staging', params: [projectId: projectInstance.id])}">Load Tasks (Image Staging)</a>

        </div>
    </div>

    <div class="control-group">
        <label class="control-label">Upload data to existing task images</label>
        <div class="controls">
            <a class="btn" href="${createLink(controller: 'task', action: 'loadTaskData', params: [projectId: projectInstance.id])}">Load Task Data</a>
        </div>
    </div>


    <div class="control-group">
        <label class="control-label">Delete all tasks</label>
        <div class="controls">
            <span style="padding-left:7px; padding-top: 8px; padding-right: 5px; padding-bottom: 11px; background-image: url(${resource(dir: '/images', file: 'warning-button.png')})">
                <button id="btnDeleteAllTasks" class="btn btn-danger"><i class="icon-trash icon-white"></i>&nbsp;Delete All Tasks</button>
                %{--<g:actionSubmit class="delete btn btn-danger" action="deleteTasks" value="Delete all tasks" onclick="return confirmDeleteAllTasks()"/>--}%
            </span>
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
