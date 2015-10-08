<div class="caption">
    <h4><a href="${projectUrl}">${projectSummary.project?.featuredLabel}</a></h4>

    <a href="?mode=${params.mode}&q=label:${projectSummary.iconLabel}" class="badge"><span class="glyphicon glyphicon-tag icon-flipped"></span>${projectSummary.iconLabel}</a>

    <g:if test="${projectSummary.project.institution}">
        <a href="${createLink(controller: 'institution', action: 'index', id: projectSummary.project.institution.id)}" class="badge"><span class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${projectSummary.project.institution?.name}</a>
    </g:if>
    <g:elseif test="${projectSummary.project.featuredOwner}">
        <a href="#" class="badge"><span class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${projectSummary.project.featuredOwner}</a>
    </g:elseif>

    <g:set var="descrptionSnippet"><cl:truncate maxlength="${params.mode == 'thumbs' ? '90' : '150'}">${raw(projectSummary.project?.description)}</cl:truncate></g:set>
    <g:if test="${descrptionSnippet?.size() > 5}">
        <p>${raw(descrptionSnippet)}</p>
    </g:if>

    <g:render template="../project/projectSummaryProgressBar"
              model="${[projectSummary: projectSummary]}"/>
</div>