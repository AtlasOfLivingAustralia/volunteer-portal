<div class="caption">
    <h4 class="ellipsis"><g:link controller="project" action="index"
                                 id="${projectSummary.project?.id}">${projectSummary.project?.featuredLabel}</g:link></h4>

    <div class="not-a-badge-row ellipsis primary-color">
        <g:link controller="project" action="list" params="[mode: params.mode, tag: projectSummary.iconName, statusFilter: statusFilterMode, activeFilter: activeFilterMode]"
                class="not-a-badge">
            <span class="fa fa-tag icon-flipped"></span>${projectSummary.iconLabel}</g:link>
        <g:link controller="institution" action="index" id="${projectSummary.project?.institutionId}"
                class="not-a-badge">
            <span class="fa fa-bookmark icon-flipped"></span>${projectSummary.project?.institutionName}</g:link>
        <cl:ifAdmin>
            <g:if test="${projectSummary.project.archived == true}">
                <br />
                <g:link controller="project" action="list" params="[mode: params.mode, activeFilter: 'showArchivedOnly']"
                        class="not-a-badge"><span class="fa fa-archive icon-flipped"></span>Archived</g:link>
            </g:if>
        </cl:ifAdmin>
    </div>

    <g:if test="${includeDescription}">
        <g:set var="descrptionSnippet">
            <cl:truncate maxlength="${Integer.toString(maxDescriptionLen) ?: '200'}">
                <g:if test="${projectSummary.project?.shortDescription}">
                    ${raw(projectSummary.project?.shortDescription)}
                </g:if>
                <g:else>
                    ${raw(projectSummary.project?.description)}
                </g:else>
            </cl:truncate>
        </g:set>
        <p class="projectDescription">${raw(descrptionSnippet)}</p>
    </g:if>

    <g:render template="/project/projectSummaryProgressBar"
              model="${[projectSummary: projectSummary, showLegend: false]}"/>

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
</div>