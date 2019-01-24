<div id="ct-image-sequence" class="film-strip">
    <g:set var="sequences" value="${sequenceNumbers(project: taskInstance.project, number: sequenceNumber, count: 3)}"/>
    <g:each in="${sequences.previous}" var="p">
        <div class="film-cell" data-seq-no="${p}">
            <cl:sequenceThumbnail project="${taskInstance.project}" seqNo="${p}"/>
        </div>
    </g:each>
    <div class="film-cell active default" data-seq-no="${sequenceNumber}">
        <cl:taskThumbnail task="${taskInstance}" fixedHeight="${false}" withHidden="${true}"/>
    </div>
    <g:each in="${sequences.next}" var="n">
        <div class="film-cell" data-seq-no="${n}">
            <cl:sequenceThumbnail project="${taskInstance.project}" seqNo="${n}"/>
        </div>
    </g:each>
</div>