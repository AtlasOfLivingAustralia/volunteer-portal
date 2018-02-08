<%@ page contentType="text/html; charset=UTF-8" %>
<g:if test="${viewedTask}">

    <table class="table table-striped table-bordered">
        <tr>
            <td><g:message code="task.viewedTaskFragment.task"/></td>
            <td>${viewedTask.task.externalIdentifier ?: viewedTask.task.id}</td>
        </tr>
        <tr>
            <td><g:message code="task.viewedTaskFragment.last_viewed_by"/></td>
            <td><cl:userDisplayName userId="${viewedTask.userId}"/></td>
        </tr>
        <tr>
            <td><g:message code="task.viewedTaskFragment.last_viewed_on"/></td>
            <td>${lastViewedDate?.format("dd MMM, yyyy HH:mm:ss")} (${agoString})</td>
        </tr>

    </table>

    <button id="btnCloseViewedTask" class="btn"><g:message code="default.close"/></button>

</g:if>

<script>

    $("#btnCloseViewedTask").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

</script>