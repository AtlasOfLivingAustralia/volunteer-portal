<%@ page import="au.org.ala.volunteer.ProjectSummary" %>
<style>

.thumbnails a {
    text-decoration: none;
}

.thumbnails a:hover {
    text-decoration: underline;
}

[inactive=true] {
    opacity: 0.5;
}

</style>

<div class="row">
    <div class="span12">
        <table class="table table-condensed" style="border: 1px solid gainsboro">
            <colgroup>
                <col style="width:165px"/>
            </colgroup>
            <thead>
            <tr>
                <td colspan="2">
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
                </td>
                <td colspan="3" style="text-align: right">
                    <span>
                        <a style="vertical-align: middle;" href="#" class="fieldHelp"
                           title="Enter search text here to find expeditions"><span class="help-container">&nbsp;</span>
                        </a>
                    </span>
                    <g:textField id="searchbox" value="${params.q}" name="searchbox"/>
                    <button class="btn" id="btnSearch">Search</button>
                </td>
            </tr>
            <tr>
                <g:set var="additionalParams"
                       value="mode=thumbs&statusFilter=${params.statusFilter ?: ""}&activeFilter=${params.activeFilter ?: ""}"/>
                <g:set var="columns"
                       value="${[['name', 'Name'], ['completed', 'Tasks completed'], ['volunteers', 'Volunteers'], ['institution', 'Sponsoring Institution'], ['type', 'Type']]}"/>
                <g:each in="${columns}" var="colkvp">
                    <th><a href="?sort=${colkvp[0]}&order=${params.sort == colkvp[0] && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&${additionalParams}"
                           class="btn ${params.sort == colkvp[0] ? 'active' : ''}">${colkvp[1]}</a></th>
                </g:each>
            </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>
</div>
<ul class="thumbnails">
    <g:each in="${projects}" var="projectSummary">
        <li class="span3">
            <div class="thumbnail" inactive="${projectSummary.project.inactive}"
                 style="text-align: center; background-color: white;">
                <div style="height: 50px; max-height: 50px">
                    <strong>
                        <a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}">
                            ${projectSummary.project.featuredLabel}
                        </a>
                    </strong>
                </div>
                <a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}">
                    <img src="${projectSummary.project.featuredImage}" style="max-height: 156px"/>
                </a>

                <div style="height: 25px; max-height: 25px">
                    <table style="width: 100%">
                        <tr>
                            <td style="text-align: left"><img src="${projectSummary.iconImage}"
                                                              alt="${projectSummary.iconLabel}" width="16" height="20">
                            </td>
                            <td style="text-align: center">
                                <small>${projectSummary.project.featuredOwner ?: "&nbsp;"}</small>
                            </td>
                            <td style="text-align: right">${projectSummary.percentTranscribed}%</td>
                        </tr>
                    </table>
                </div>
            </div>
        </li>
    </g:each>
</ul>

<div class="pagination">
    <g:paginate total="${filteredProjectsCount}" prev="" next=""
                params="${[q: params.q, mode: 'thumbs'] + (extraParams ?: [:])}"/>
</div>

