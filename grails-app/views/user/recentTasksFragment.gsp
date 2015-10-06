<style>

.taskProjectLabel {
    font-size: 0.8em;
    font-style: italic;
}

.taskThumbnail img {
    height: 100px;
}

</style>

<div>
    <ul class="thumbnails">
        <g:each in="${recentTasks}" var="task">
            <li>
                <div class="thumbnail taskThumbnail" style="text-align: center">
                    <a href="${createLink(controller: 'task', action: 'show', id: task.id)}">
                        <g:set var="multimedia" value="${task.multimedia?.first()}"/>
                        <g:set var="imageUrl" value="${grailsApplication.config.server.url}${multimedia?.filePath}"/>
                        <img src="${imageUrl}"/>
                        <br/>
                        ${task.externalIdentifier}
                    </a>

                    <div class="taskProjectLabel">${task.project.featuredLabel}, ${task.dateFullyTranscribed?.format("dd MMM, yyyy")}</div>
                </div>
            </li>
        </g:each>
    </ul>
</div>