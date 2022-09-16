<div class="row">
<g:each in="${projects}" var="projectSummary" status="i">
    <div class="col-sm-12 col-md-6">
        <div class="thumbnail">
            <cl:ifInstitutionAdmin institution="${projectSummary.project.institution}">
            <div class="expedition-thumb-settings-btn-group">
                <div class="btn-group ">
                    <button type="button" class="btn btn-sm btn-warning dropdown-toggle " data-toggle="dropdown" href="#">
                        <i class="fa fa-lg fa-cog"></i>&nbsp;<span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <li>
                            <a href="${createLink(controller: 'project', action: 'edit', id: projectSummary.project.id)}"><i class="icon-cog icon-white"></i>&nbsp;<g:message code="expedition.settings.label" /></a>
                        </li>
                        <li>
                            <a href="${createLink(controller: 'task', action: 'projectAdmin', id: projectSummary.project.id)}"><i class="icon-wrench icon-white"></i>&nbsp;<g:message code="expedition.administration.label" /></a>
                        </li>
                    </ul>
                </div>
            </div>
            </cl:ifInstitutionAdmin>
            <div class="${projectSummary.project?.inactive ? 'expedition-inactive' : ''}">
                <g:link controller="project" action="index" class="thumbImg" id="${projectSummary.project?.id}">
                    <cl:featuredImage project="${projectSummary.project}"
                                      preLoad="true"
                                      class="img-responsive cropme"
                                      style="width: 100%; height: 236px;"
                                      data-error-url="${resource(file: '/banners/default-expedition-large.jpg')}"/>
                </g:link>
                <g:render template="/project/projectSummary" model="[projectSummary: projectSummary, includeDescription: false, extraParams: extraParams]" />
            </div>
        </div>
    </div>
    <g:if test="${(i+1) % 2 == 0}"><div class="clearfix visible-md-block visible-lg-block"></div></g:if>
</g:each>
<g:if test="${!disablePagination}">
    <div class="pagination">
        <g:paginate total="${filteredProjectsCount}" prev="" next=""
                    id="${params.id}" params="${[q: params.q] + (extraParams ?: [:])}"/>
    </div>
</g:if>
</div>