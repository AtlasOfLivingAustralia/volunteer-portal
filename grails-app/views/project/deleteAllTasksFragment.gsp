<div>

    <p>
        The <strong>${projectInstance.name}</strong> expedition currently has <strong>${taskCount}</strong> tasks.
    </p>

    <div id="confirm">
    <div class="alert alert-danger">
        <strong>Warning:</strong> This action cannot be undone. Are you sure you wish to remove all tasks (including those already transcribed) from expedition '${projectInstance.name}'?
    </div>

    <div class="form-horizontal">
        <div class="control-group">
            <div class="controls">
                <button class="btn btn-default" id="btnCancelDeleteAllTasks">Cancel</button>
                <button class="btn btn-primary" id="btnSubmitDeleteAllTasks">Delete all tasks</button>
            </div>
        </div>
    </div>
    </div>

    <div id="progress" class="hidden">
        <div class="progress">
            <div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0;">
                <span class="sr-only">0% Complete</span>
            </div>
        </div>

        <p>
            Tasks are now being removed.  If you leave this page tasks will continue to be removed but you
            will no longer be able to view the progress bar.
        </p>
    </div>



</div>

<script>
    const url = "${createLink(controller: 'project', action: 'deleteTasks', id: projectInstance.id)}";
    let taskCount = 0;
    let id = ${projectInstance.id};

    $("#btnCancelDeleteAllTasks").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

    let $progress = $('#progress');
    let $confirm = $('#confirm');

    $("#btnSubmitDeleteAllTasks").click(function (e) {
        let $this = $(this);
        $this.disabled = true;
        $.post(url).done(function (data, status, xhr) {
            digivolNotifications.addMessageListener('deleteTasks', messageHandler);
            $progress.removeClass('hidden');
            $confirm.addClass('hidden');
        }).fail(function(xhr, status, error) {
           console.log("Couldn't delete tasks", status, error);
           alert("Couldn't delete tasks");
        });
    });

    function messageHandler(e) {
        console.log("got message", e);
        const data = JSON.parse(e.data);
        if (id === data.projectId) {
            // console.log(data);

            if (data.count === -1) {
                console.log("Error");
                alert('There was an error deleting tasks.  The page will refresh, please try again and if the error persists contact the system administrators.');
                digivolNotifications.removeMessageListener('deleteTasks', messageHandler);
                window.location.reload(true);
            }

            let count = data.count;
            let pct = Math.round((count / taskCount) * 100);

            if (pct >= 100 && count !== taskCount) pct = 99;

            let $bar = $progress.find('.progress-bar');
            // console.log("pct: " + pct);
            $bar.attr('aria-valuenow', pct);
            $bar.css('width', pct + '%');
            $bar.find('.sr-only').text(pct + '% Complete');

            if (data.complete) {
                digivolNotifications.removeMessageListener('deleteTasks', messageHandler);
                window.location.reload(true);
            }
        }
    }

</script>
