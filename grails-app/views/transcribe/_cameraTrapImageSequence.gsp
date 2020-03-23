<div id="ct-image-sequence" class="film-strip">
    <g:set var="tasks" value="${taskSequence(number: sequenceNumber, count: 3, task:taskInstance)}"/>
    <g:each in="${tasks.previous}" var="task">
        <div class="film-cell" data-seq-no="${task.sequenceNumber}">
            <cl:multimediaThumbnail multimedia="${task.multimedia}" seqNo="${task.sequenceNumber}"/>
        </div>
    </g:each>
    <div class="film-cell active default" data-seq-no="${sequenceNumber}">
        <cl:multimediaThumbnail multimedia="${tasks.current.multimedia}" seqNo="${tasks.current.sequenceNumber}"/>
    </div>
    <g:each in="${tasks.next}" var="task">
        <div class="film-cell" data-seq-no="${task.sequenceNumber}">
            <cl:multimediaThumbnail multimedia="${task.multimedia}" seqNo="${task.sequenceNumber}"/>
        </div>
    </g:each>
</div>