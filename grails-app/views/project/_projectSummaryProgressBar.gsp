
<div class="expedition-progress">
    <div class="progress">
        <g:set var="diffPercent" value="${(projectSummary?.percentTranscribed as Integer) - (projectSummary?.percentValidated as Integer)}"/>
        <div class="progress-bar progress-bar-success" style="width:${projectSummary?.percentValidated}%">
            <span class="sr-only">${projectSummary?.percentValidated}% Complete (success)</span>
        </div>
        <div class="progress-bar progress-bar-transcribed" style="width: ${diffPercent}%">
            <span class="sr-only">${diffPercent}% Transcribed</span>
        </div>
    </div>

    <div class="progress-legend">
        <div class="row">
            <div class="col-xs-4 col-sm-4">
                <b>${projectSummary.percentValidated}%</b> Validated
            </div>
            <div class="col-xs-4 col-sm-4">
                <b>${projectSummary.percentTranscribed}%</b> Transcribed
            </div>
            <div class="col-xs-4 col-sm-4">
                <b>${projectSummary.taskCount}</b> Tasks
            </div>
        </div>
    </div>
</div>
