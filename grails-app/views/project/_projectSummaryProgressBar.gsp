
<div class="expedition-progress">
    <div class="progress">
        <div class="progress-bar progress-bar-success" style="width:${projectSummary.percentValidated}%">
            <span class="sr-only">${projectSummary.percentValidated}% Complete (success)</span>
        </div>
        <div class="progress-bar progress-bar-transcribed" style="width: ${projectSummary.percentTranscribed}%">
            <span class="sr-only">${projectSummary.percentTranscribed}% Complete (warning)</span>
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
