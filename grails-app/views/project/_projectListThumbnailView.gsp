<div class="row">
<g:each in="${projects}" var="projectSummary" status="i">
    <div class="col-sm-12 col-md-6">
        <div class="thumbnail">
            <div class="expedition-thumb-settings-btn-group">
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
            </div>
            <div class="${projectSummary.project?.inactive ? 'expedition-inactive' : ''}">
                <g:link controller="project" action="index" class="thumbImg" id="${projectSummary.project?.id}">
                    <img class="img-responsive cropme " src="" realsrc="${projectSummary.project?.featuredImage}" style="width: inherit; height: 236px;"/>
                </g:link>
                <g:render template="/project/projectSummary" model="[projectSummary: projectSummary]" />
            </div>
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
</div>