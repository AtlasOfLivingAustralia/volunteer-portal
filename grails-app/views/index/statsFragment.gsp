<table style="width: 100%">
    <tr>
        <td>
            <h3>Expedition stats</h3>
        </td>
        <td>
            <img class="pull-right" src="${resource(file: "/images/vp/compassrose.png")}"/>
        </td>
    </tr>
</table>

<strong>${completedTasks}</strong> tasks of <strong>${totalTasks}</strong> completed
<br/>
<strong>${transcriberCount}</strong> volunteer <a
        href="${createLink(controller: 'user', action: 'list')}">transcribers</a>.
