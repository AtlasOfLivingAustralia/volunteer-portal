

<g:each in="${projects}" var="projectSummary">
    <div class="col-sm-12 col-md-6">
        <div class="thumbnail">
            <a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}"><img src="${projectSummary.iconImage}"></a>
            <g:render template="projectSummary" model="[projectSummary: projectSummary]" />
        </div>
    </div>
</g:each>

<div class="pagination">
    <g:paginate total="${filteredProjectsCount}" prev="" next=""
                params="${[q: params.q, mode: 'thumbs'] + (extraParams ?: [:])}"/>
</div>

