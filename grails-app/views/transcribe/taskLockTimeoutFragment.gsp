<div>
    <div class="text-center">
        You have been working on this task for a long time.
    </div>

    <div class="text-center">
        Please submit this task to avoid losing your selection or you can continue working.
    </div>
    <br/>

    <div class="text-center">
        <button type="button" id="btnDefaultSaveTask" class="btn btn-primary">Close task</button>
        <button type="button" id="btnIdleCancelModal" class="btn btn-default">Continue working</button>
    </div>
    <br/>

    <div class="text-center">
        <small>
            NOTE: The task will be automatically closed in <span
                id="reloadCounter">5</span> minutes if no action is taken.
        </small>
    </div>

</div>
<script>

    var i = 5; // minutes to countdown before reloading page
    var countdownInterval = 60 * 1000; // One minute intervals
    var countdownTimerId;

    function countDownByOne() {
        $("#reloadCounter").html(--i);
        if (i > 0) {
            countdownTimerId = window.setTimeout(countDownByOne, countdownInterval);
        } else {
            defaultSaveAction();
        }
    }
    window.setTimeout(countDownByOne, countdownInterval);

    $("#btnDefaultSaveTask").click(function (e) {
        e.preventDefault();
        defaultSaveAction();
    });

    $('#btnIdleCancelModal').click(function(e) {
        e.preventDefault();
        window.clearTimeout(countdownTimerId);
        bvp.hideModal();
    });

    function defaultSaveAction() {
        // Close task
    <g:if test="${isValidator}">
        var url = "${createLink(controller: 'task', action: 'projectAdmin', id: taskInstance.project.id)}";
    </g:if>
    <g:else>
        var url = "${createLink(controller: 'project', action: 'index', id: taskInstance.project.id)}";
    </g:else>
        window.location = url;
    }

</script>