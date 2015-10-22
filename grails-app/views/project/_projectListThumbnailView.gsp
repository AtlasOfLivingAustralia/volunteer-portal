<g:each in="${projects}" var="projectSummary" status="i">
    <div class="col-sm-12 col-md-6">
        <div class="thumbnail">
            <g:if test="${includeWeirdAnchorLabel}"><a class="btn btn-info btn-xs label">${projectSummary.project?.institutionName}</a></g:if>
            <g:link controller="project" action="index" id="${projectSummary.project?.id}"><img class="img-responsive" src="${projectSummary.project?.featuredImage}"></g:link>
            <g:render template="/project/projectSummary" model="[projectSummary: projectSummary]" />
        </div>
    </div>
    <g:if test="${(i+1) % 2 == 0}"><div class="clearfix visible-md-block visible-lg-block"></div></g:if>
</g:each>
<g:if test="${!disablePagination}">
    <div class="pagination">
        <g:paginate total="${filteredProjectsCount}" prev="" next=""
                    params="${[q: params.q, mode: 'thumbs'] + (extraParams ?: [:])}"/>
    </div>
</g:if>