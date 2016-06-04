
<div class="expedition-progress">
    <div class="progress">
        <g:set var="diffPercent" value="${(projectSummary?.percentTranscribed as Integer) - (projectSummary?.percentValidated as Integer)}"/>
        <div class="progress-bar progress-bar-success" style="width:${projectSummary?.percentValidated}%">
            <span class="sr-only">${projectSummary?.percentValidated}% <g:message code="complete.success" /></span>
        </div>
        <div class="progress-bar progress-bar-transcribed" style="width: ${diffPercent}%">
            <span class="sr-only">${diffPercent}% <g:message code="transcribed.label" /></span>
        </div>
    </div>

    <div class="progress-legend">
        <div class="row">
            <div class="col-xs-4 col-sm-4">
                <b>${projectSummary.percentValidated}%</b> <g:message code="validated.label" />
            </div>
            <div class="col-xs-4 col-sm-4">
                <b>${projectSummary.percentTranscribed}%</b> <g:message code="transcribed.label" />
            </div>
            <div class="col-xs-4 col-sm-4">
                <b>${projectSummary.taskCount}</b> <g:message code="tasks.label" />
            </div>
        </div>
    </div>
</div>
