<g:if test="${viewedTask}">

    <table class="table table-striped table-bordered">
        <tr>
            <td>Task</td>
            <td>${viewedTask.task.externalIdentifier ?: viewedTask.task.id}</td>
        </tr>
        <tr>
            <td>Last viewed by</td>
            <td><cl:userDisplayName userId="${viewedTask.userId}"/></td>
        </tr>
        <tr>
            <td>Last viewed on</td>
            <td>${lastViewedDate?.format("dd MMM, yyyy HH:mm:ss")} (${agoString})</td>
        </tr>

    </table>

    <button id="btnCloseViewedTask" class="btn">Close</button>

</g:if>

<script>

    $("#btnCloseViewedTask").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

</script>