<div class="caption">
    <h4 class="ellipsis"><g:link controller="project" action="index"
                                 id="${projectSummary.project?.id}">${projectSummary.project?.featuredLabel}</g:link></h4>

    <div class="not-a-badge-row ellipsis primary-color">
        <g:link controller="project" action="list" params="[mode: params.mode, q: 'tag:' + projectSummary.iconLabel]"
                class="not-a-badge"><span
                class="glyphicon glyphicon-tag icon-flipped"></span>${projectSummary.iconLabel}</g:link><g:link
            controller="institution" action="index" id="${projectSummary.project?.institutionId}"
            class="not-a-badge"><span
                class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${projectSummary.project?.institutionName}</g:link>
    </div>

    <g:set var="descrptionSnippet"><cl:truncate
            maxlength="${params.mode == 'thumbs' ? '90' : '150'}">${raw(projectSummary.project?.description)}</cl:truncate></g:set>
    <g:if test="${descrptionSnippet?.size() > 5}">
        <p>${raw(descrptionSnippet)}</p>
    </g:if>

    <g:render template="/project/projectSummaryProgressBar"
              model="${[projectSummary: projectSummary]}"/>
</div>