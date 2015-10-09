
<g:each in="${projects}" var="projectSummary" status="i">
    <g:if test="${(i % 2) == 0}"><div class="row ."></g:if>
    <div class="col-md-6">
        <div class="thumbnail">
            <a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}"><img src="${projectSummary.iconImage}"></a>
            <g:render template="projectSummary" model="[projectSummary: projectSummary]" />
        </div>
    </div><!-- /.col-md-6 |${i}| -->
    <g:if test="${(i % 2) == 1 || (i + 1) == projects.size()}"></div><!-- /.row --></g:if>
</g:each>

<div class="pagination">
    <g:paginate total="${filteredProjectsCount}" prev="" next=""
                params="${[q: params.q, mode: 'thumbs'] + (extraParams ?: [:])}"/>
</div>

