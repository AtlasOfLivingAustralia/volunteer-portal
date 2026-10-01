
<div class="expedition-progress">
    <div class="progress">
        <g:set var="diffPercent" value="${(projectSummary?.percentTranscribed as Integer) - (projectSummary?.percentValidated as Integer)}"/>
        <div class="progress-bar progress-bar-success" style="width:${projectSummary?.percentValidated}%">
            <span class="visually-hidden">${projectSummary?.percentValidated}% <g:message code="complete.success" /></span>
        </div>
        <div class="progress-bar progress-bar-transcribed" style="width: ${diffPercent}%">
            <span class="visually-hidden">${diffPercent}% <g:message code="transcribed.label" /></span>
        </div>
    </div>

    <g:if test="${showLegend != false}">
%{--        <div class="progress-legend">--}%
%{--            <div class="row">--}%
%{--                <div class="col-4 col-sm-4">--}%
%{--                    <b>${projectSummary.percentValidated}%</b> <g:message code="validated.label" />--}%
%{--                </div>--}%
%{--                <div class="col-4 col-sm-4">--}%
%{--                    <b>${projectSummary.percentTranscribed}%</b> <g:message code="transcribed.label" />--}%
%{--                </div>--}%
%{--                <div class="col-4 col-sm-4">--}%
%{--                    <b>${projectSummary.taskCount}</b> <g:message code="tasks.label" />--}%
%{--                </div>--}%
%{--            </div>--}%
%{--        </div>--}%

        <div class="row row-cols-1 row-cols-sm-3 g-3 project-stat-cards">
            <div class="col">
                <div class="card project-stat-card h-100 text-center">
                    <div class="card-body">
                        <div class="project-stat-value">${projectSummary.percentTranscribed}%</div>
                        <div class="project-stat-label"><g:message code="transcribed.label" /></div>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="card project-stat-card h-100 text-center">
                    <div class="card-body">
                        <div class="project-stat-value">${projectSummary.percentValidated}%</div>
                        <div class="project-stat-label"><g:message code="validated.label" /></div>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="card project-stat-card h-100 text-center">
                    <div class="card-body">
                        <div class="project-stat-value">${projectSummary.taskCount}</div>
                        <div class="project-stat-label"><g:message code="tasks.label" /></div>
                    </div>
                </div>
            </div>
        </div>
    </g:if>
</div>
