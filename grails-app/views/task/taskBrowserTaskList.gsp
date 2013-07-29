<%@ page contentType="text/html;charset=UTF-8" %>
<g:if test="${taskList?.size() > 0}">
    <div id="task_list" style="display: none" currentTaskIndex="0" taskCount="${taskList.size}">
        <g:each in="${taskList}" var="task" status="index">
            <div id="task_${index}" task_id="${task.id}" transcribed="${task.lastEdit}">${task.id}</div>
        </g:each>
    </div>
    <r:script type="text/javascript">
        loadTask(${taskList.size() - 1});
    </r:script>
</g:if>
<g:else>
    <div id="task_list" style="display: none" currentTaskIndex="-1" taskCount="0">
    </div>
    <r:script type="text/javascript">
        updateLocation();
    </r:script>
</g:else>