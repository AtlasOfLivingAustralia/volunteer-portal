<div class="row">
    <div class="col-sm-12">
        <div class="row">
            <g:each in="${projects}" status="i" var="projectSummary">
                <div class="col-sm-12">
                    <div class="thumbnail row-style">
                        <div class="row">
                            <div class="col-xs-3">
                                <a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}">
                                    <cl:featuredImage project="${projectSummary.project}" class="${projectSummary.project?.inactive ? 'expedition-inactive' : ''}" />
                                </a>
                                <div class="text-center">
                                    <cl:ifInstitutionAdmin institution="${projectSummary.project.institution}">
                                    <div class="btn-group ">
                                        <button type="button" class="btn btn-sm btn-warning dropdown-toggle " data-toggle="dropdown" href="#">
                                            <i class="fa fa-lg fa-cog"></i>&nbsp;<span class="caret"></span>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li>
                                                <a href="${createLink(controller: 'project', action: 'edit', id: projectSummary.project.id)}"><i class="icon-cog icon-white"></i>&nbsp;Expedition settings</a>
                                            </li>
                                            <li>
                                                <a href="${createLink(controller: 'task', action: 'projectAdmin', id: projectSummary.project.id)}"><i class="icon-wrench icon-white"></i>&nbsp;Expedition administration</a>
                                            </li>
                                        </ul>
                                    </div>
                                    </cl:ifInstitutionAdmin>
                                </div>
                            </div>
                            <div class="col-xs-9 ${projectSummary.project?.inactive ? 'expedition-inactive' : ''}">
                                <g:render template="/project/projectSummary" model="[projectSummary: projectSummary, includeDescription: true]" />
                            </div>
                        </div>
                    </div>
                </div>
            </g:each>

            <div class="pagination foo">
                <g:paginate total="${filteredProjectsCount}" prev="" next=""
                            id="${params.id}" params="${[q: params.q, mode: 'list', tag: params.tag] + (extraParams ?: [:])}"/>
            </div>
        </div>
    </div>
</div>