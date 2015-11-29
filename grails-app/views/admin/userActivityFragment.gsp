<%@ page import="com.sun.xml.internal.ws.model.RuntimeModeler" %>
<g:set var="now" value="${new Date()}"/>
<div class="panel-body">
    ${activities?.size()} Users currently online
    <small>(Last refreshed ${formatDate(date: now, format: "yyyy-MM-dd HH:mm:ss")})</small>
</div>
<table class="table"> <!-- table-condensed table-striped table-bordered -->
    <thead>
    <tr>
        <th>User</th>
        <th>Started</th>
        <th>Last Activity</th>
        <th>Last Request</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${activities}" var="activity">
        <tr>
            <td>${activity.userId}</td>
            <td>${activity.timeFirstActivity} (<cl:timeAgo startTime="${activity.timeFirstActivity}"
                                                           endTime="${now}"/>)</td>
            <td>${activity.timeLastActivity} (<cl:timeAgo startTime="${activity.timeLastActivity}"
                                                          endTime="${now}"/>)</td>
            <td>${activity.lastRequest}</td>

        </tr>
    </g:each>
    </tbody>

</table>