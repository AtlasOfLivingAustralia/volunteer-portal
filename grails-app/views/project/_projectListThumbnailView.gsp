<g:each in="${projects}" var="projectSummary" status="i">
    <div class="col-sm-12 col-md-6">
        <div class="thumbnail">
            <g:link controller="project" action="index" class="thumbImg" id="${projectSummary.project?.id}">
                <img class="img-responsive cropme" src="" realsrc="${projectSummary.project?.featuredImage}" style="width: inherit; height: 236px;"/>
            </g:link>
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