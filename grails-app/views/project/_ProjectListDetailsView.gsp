<div class="row">
    <div class="col-sm-12">
        <div class="row">
            <g:each in="${projects}" status="i" var="projectSummary">
                <div class="col-sm-12">
                    <div class="thumbnail row-style">
                        <div class="row">
                            <div class="col-xs-3">
                                <a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}"><img src="${projectSummary.project?.featuredImage}"></a> %{--g.createLink(url:'/img/placeholder/1.jpg') --}%
                            </div>
                            <div class="col-xs-9">
                                <g:render template="/project/projectSummary" model="[projectSummary: projectSummary]" />
                            </div>
                        </div>
                    </div>
                </div>
            </g:each>

            <div class="pagination foo">
                <g:paginate total="${filteredProjectsCount}" prev="" next=""
                            id="${params.id}" params="${[q: params.q] + (extraParams ?: [:])}"/>
            </div>
        </div>
    </div>
</div>