<table style="width: 100%">
    <tr>
        <td>
            <h3><g:message code="index.expedition_stats.title"/></h3>
        </td>
        <td>
            <img class="pull-right" src="${resource(file: "/images/vp/compassrose.png")}"/>
        </td>
    </tr>
</table>

<g:message code="index.expedition_stats.completed" args="${[completedTasks, totalTasks]}"/>
<br/>
<g:message code="index.expedition_stats.transcribers" args="${[transcriberCount, createLink(controller: 'user', action: 'list')]}"/>
