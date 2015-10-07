
<div class="row">
    <g:each in="${projects}" status="i" var="projectSummary">
        <div class="col-sm-12">
            <div class="thumbnail row-style">
                <div class="row">
                    <div class="col-xs-3">
                        <a href="#"><img src="${projectSummary.iconImage}"></a> %{--g.createLink(url:'/img/placeholder/1.jpg') --}%
                    </div>

                    <div class="col-xs-9">
                        <div class="caption">
                            <h4><a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}">${projectSummary.project.featuredLabel}</a></h4>

                            <a class="badge"><span class="glyphicon glyphicon-tag icon-flipped"></span>${projectSummary.iconLabel}</a>

                            <g:if test="${projectSummary.project.institution}">
                                <a href="${createLink(controller: 'institution', action: 'index', id: projectSummary.project.institution.id)}" class="badge"><span class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${projectSummary.project.institution}</a>
                            </g:if>
                            <g:elseif test="${projectSummary.project.featuredOwner}">
                                <a href="#" class="badge"><span class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${projectSummary.project.featuredOwner}</a>
                            </g:elseif>

                            <g:set var="descrptionSnippet"><cl:truncate maxlength="150">${raw(projectSummary.project?.description)}</cl:truncate></g:set>
                            <g:if test="${descrptionSnippet?.size() > 5}">
                                <p>${raw(descrptionSnippet)}</p>
                            </g:if>

                            <g:render template="../project/projectSummaryProgressBar"
                                      model="${[projectSummary: projectSummary]}"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </g:each>

    <div class="pagination">
        <g:paginate total="${filteredProjectsCount}" prev="" next=""
                    params="${[q: params.q] + (extraParams ?: [:])}"/>
    </div>
</div>