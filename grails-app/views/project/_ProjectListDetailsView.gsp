<style>

[inactive=true] {
    background-color: #F0F0E8;
}

[inactive=true] div[class*='span'] {
    opacity: 0.5;
}

tr[inactive=true] .admin-link {
    opacity: 1;
}

.column-sort-btn a {
    font-weight: bold;
}

.volunteer-count, .project-type {
    text-align: center;
}

@media (max-width: 768px) {
    .volunteer-count, .project-type {
        text-align: left;
    }

    .sort-btn-bar {
        display: none;
    }

}

</style>

<div class="row-fluid">
    <div class="span12">

        <table class="table table-condensed" style="border: 1px solid gainsboro">
            <thead>
            <tr>
                <td>
                    <div class="row-fluid">
                        <div class="span6">
                            <g:if test="${filteredProjectsCount != totalProjectCount}">
                                <h4>
                                    <g:if test="${projects}">
                                        ${filteredProjectsCount} matching projects
                                    </g:if>
                                    <g:else>
                                        No matching projects
                                    </g:else>
                                </h4>
                            </g:if>
                        </div>

                        <div class="span6">
                            <div class="pull-right">
                                <span>
                                    <a style="vertical-align: middle;" href="#" class="fieldHelp"
                                       title="Enter search text here to find expeditions"><span
                                            class="help-container">&nbsp;</span></a>
                                </span>
                                <g:textField id="searchbox" value="${params.q}" name="searchbox"/>
                                <button class="btn" id="btnSearch">Search</button>
                            </div>
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div class="row-fluid sort-btn-bar">
                        <g:set var="additionalParams"
                               value="statusFilter=${params.statusFilter ?: ""}&activeFilter=${params.activeFilter ?: ""}"/>
                        <g:set var="columns"
                               value="${[['name', 'Name', 'span2'], ['completed', 'Tasks completed', 'span3'], ['volunteers', 'Volunteers', 'span2 volunteer-count'], ['institution', 'Sponsoring Institution', 'span3'], ['type', 'Type', 'span2 project-type']]}"/>
                        <g:each in="${columns}" var="colkvp">
                            <div class="${colkvp[2]} column-sort-btn"><a
                                    href="?sort=${colkvp[0]}&order=${params.sort == colkvp[0] && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&${additionalParams}"
                                    class="btn ${params.sort == colkvp[0] ? 'active' : ''}">${colkvp[1]}</a></div>
                        </g:each>
                    </div>
                </td>
            </tr>
            </thead>
            <tbody>
            <g:each in="${projects}" status="i" var="projectSummary">
                <tr inactive="${projectSummary.project.inactive}">
                    <td>
                        <div class="row-fluid">
                            <div class="span9">
                                <h3><a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}">${projectSummary.project.featuredLabel}</a>
                                    <g:if test="${projectSummary.project.inactive}">- Deactivated</g:if>
                                </h3>
                            </div>

                            <div class="span3 admin-link">
                                <cl:ifAdmin>

                                    <div class="btn-group pull-right ">
                                        <a class="btn btn-small btn-warning dropdown-toggle " data-toggle="dropdown"
                                           href="#">
                                            <i class="icon-cog icon-white"></i>&nbsp;<span class="caret"></span>
                                        </a>
                                        <ul class="dropdown-menu">
                                            <li>
                                                <g:link controller="project" action="edit"
                                                        id="${projectSummary.project.id}"><i
                                                        class="icon-cog icon-white"></i>&nbsp;Expedition settings</g:link>
                                            </li>
                                            <li class="divider"></li>
                                            <li>
                                                <g:link controller="task" action="projectAdmin"
                                                        id="${projectSummary.project.id}"><i
                                                        class="icon-wrench icon-white"></i>&nbsp;Expedition administration</g:link>
                                            </li>
                                        </ul>
                                    </div>

                                </cl:ifAdmin>
                            </div>
                        </div>

                        <div class="row-fluid">
                            <%-- Project thumbnail --%>
                            <div class="span2">
                                <img src="${projectSummary.project.featuredImage}" width="147" height="81"/>
                            </div>
                            <%-- Progress bar --%>
                            <div class="span3">
                                <g:render template="../project/projectSummaryProgressBar"
                                          model="${[projectSummary: projectSummary]}"/>
                            </div>
                            <%-- Volunteer count --%>
                            <div class="span2">
                                <div class="volunteer-count">
                                    <strong>${projectSummary.transcriberCount}</strong>
                                </div>
                            </div>
                            <%-- Institution --%>
                            <div class="span3">
                                <g:if test="${projectSummary.project.institution}">
                                    <a href="${createLink(controller: 'institution', action: 'index', id: projectSummary.project.institution.id)}">${projectSummary.project.institution.name}</a>
                                </g:if>
                                <g:else>
                                    ${projectSummary.project.featuredOwner}
                                </g:else>
                            </div>

                            <div class="span2">
                                <div class="project-type">
                                    <img src="${projectSummary.iconImage}" width="40" height="36" alt="">
                                    <br/>
                                    ${projectSummary.iconLabel}
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>

        <div class="pagination">
            <g:paginate total="${filteredProjectsCount}" prev="" next=""
                        params="${[q: params.q] + (extraParams ?: [:])}"/>
        </div>
    </div>
</div>