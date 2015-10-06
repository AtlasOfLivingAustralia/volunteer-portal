<style>

.expedition-progress {
    height: 30px;
    margin-bottom: 0;
}

.expedition-progress .bar-warning {
    background: white url(${resource(dir:'images/vp',file:'progress_1x100b.png')}) 50% 50% repeat-x;
}

.expedition-progress .bar-success {
    background: white url(${resource(dir:'images/vp',file:'progress_1x100g.png')}) 50% 50% repeat-x;
}

.validated-percent {
    color: #43924C;
}

.transcribed-percent {
    color: #6B84A2;
}

</style>

<div>
    <span><strong
            class="transcribed-number">${projectSummary.transcribedCount}</strong> of <strong>${projectSummary.taskCount}</strong> tasks transcribed (<strong
            class="transcribed-percent">${projectSummary.percentTranscribed}%</strong>)</span>
</div>

<div class="progress expedition-progress">
    <div class="bar bar-success" style="width: ${projectSummary.percentValidated}%"></div>

    <div class="bar bar-warning"
         style="width: ${projectSummary.percentTranscribed - projectSummary.percentValidated}%"></div>
</div>
<g:if test="${projectSummary.percentValidated > 0}">
    <div>
        <span><strong
                class="validated-number">${projectSummary.validatedCount}</strong> task${projectSummary.validatedCount != 1 ? 's' : ''} validated (<strong
                class="validated-percent">${projectSummary.percentValidated}%</strong>)</span>
    </div>
</g:if>
