<div id="ct-image-sequence" class="film-strip">
    <g:set var="tasks" value="${taskSequence(number: sequenceNumber, count: 3, task:taskInstance)}"/>
    <g:each in="${tasks.previous}" var="task">
        <div class="film-cell" data-seq-no="${task.sequenceNumber}">
            <cl:multimediaThumbnail task="${task.task}" seqNo="${task.sequenceNumber}"/>
        </div>
    </g:each>
    <div class="film-cell active default" data-seq-no="${sequenceNumber}">
        <cl:taskThumbnail task="${taskInstance}" fixedHeight="${false}" withHidden="${true}"/>
    </div>
    <g:each in="${tasks.next}" var="task">
        <div class="film-cell" data-seq-no="${task.sequenceNumber}">
            <cl:multimediaThumbnail task="${task.task}" seqNo="${task.sequenceNumber}"/>
        </div>
    </g:each>
</div>