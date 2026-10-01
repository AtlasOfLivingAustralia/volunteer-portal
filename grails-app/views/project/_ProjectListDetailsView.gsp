<div class="row">
    <div class="col-sm-12">
        <div class="row">
            <g:each in="${projects}" status="i" var="projectSummary">
                <div class="col-sm-12">
                    <div class="thumbnail row-style shadow-sm">
                        <div class="row">
                            <div class="d-none d-md-block col-md-3 position-relative">
                                <cl:ifInstitutionAdmin institution="${projectSummary.project.institution}">
                                    <div class="position-absolute top-0 start-1 p-3" style="z-index: 2;">
                                        <div class="btn-group">
                                            <button type="button" class="btn btn-sm btn-light border-secondary dropdown-toggle shadow-sm" data-bs-toggle="dropdown" href="#">
                                                <i class="fa fa-lg fa-cog"></i>
                                            </button>
                                            <ul class="dropdown-menu bg-white shadow">
                                                <li>
                                                    <a href="${createLink(controller: 'project', action: 'edit', id: projectSummary.project.id)}"><i class="fa fa-cog"></i>&nbsp;Expedition settings</a>
                                                </li>
                                                <li>
                                                    <a href="${createLink(controller: 'task', action: 'projectAdmin', id: projectSummary.project.id)}"><i class="fa fa-wrench"></i>&nbsp;Expedition administration</a>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
                                </cl:ifInstitutionAdmin>
                                <a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}">
                                    <cl:featuredImage project="${projectSummary.project}" class="img-fluid cropme${projectSummary.project?.inactive ? ' expedition-inactive' : ''}" />
                                </a>
                            </div>
                            <div class="col-12 col-md-9 ${projectSummary.project?.inactive ? 'expedition-inactive' : ''}">
                                <g:render template="/project/projectSummary" model="[projectSummary: projectSummary, includeDescription: true, maxDescriptionLen: 250]" />
                            </div>
                        </div>
                    </div>
                </div>
            </g:each>

            <cl:paginate total="${filteredProjectsCount}" id="${params.id}" params="${[q: params.q, mode: 'list', tag: params.tag] + (extraParams ?: [:])}"/>

        </div>
    </div>
</div>