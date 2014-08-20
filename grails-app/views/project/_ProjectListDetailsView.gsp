<style>
    .expedition-progress {
        height: 30px;
    }

    .expedition-progress .bar-warning {
        background: white url(${resource(dir:'images/vp',file:'progress_1x100b.png')}) 50% 50% repeat-x;
    }

    .expedition-progress .bar-success {
        background: white url(${resource(dir:'images/vp',file:'progress_1x100g.png')}) 50% 50% repeat-x;
    }

</style>

<div class="row-fluid">
    <div class="span12">

        <table class="table table-condensed" style="border: 1px solid gainsboro">
            <colgroup>
                <col style="width:165px"/>
            </colgroup>
            <thead>
                <tr>
                    <td colspan="3">
                        <g:if test="${params.q}">
                            <h4>
                                <g:if test="${projects}">
                                    ${projectInstanceTotal} matching projects
                                </g:if>
                                <g:else>
                                    No matching projects
                                </g:else>
                            </h4>
                        </g:if>
                        <g:if test="${extraParams.transcriberCount}">
                            <span><g:message code="institution.transcribers.label" default="Total Transcribers"/>: ${transcriberCount}.</span>
                        </g:if>
                        <g:if test="${extraParams.projectTypes}">
                            <span><g:each in="${projectTypes}" var="pt" status="i">${pt.key} <g:message code="institution.projectTypes.label" default="projects"/>: ${pt.value}<g:if test="${i < (projectTypes.size() - 1)}">, </g:if> </g:each></span>
                        </g:if>
                    </td>
                    <td colspan="2" style="text-align: right">
                        <span>
                          <a style="vertical-align: middle;" href="#" class="fieldHelp" title="Enter search text here to find expeditions"><span class="help-container">&nbsp;</span></a>
                        </span>
                        <g:textField id="searchbox" value="${params.q}" name="searchbox" />
                        <button class="btn" id="btnSearch">Search</button>
                    </td>
                </tr>
                <tr>
                    <th><a href="?sort=name&order=${params.sort == 'name' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}" class="btn ${params.sort == 'name' ? 'active' : ''}">Name</a></th>
                    <th><a href="?sort=completed&order=${params.sort == 'completed' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}" class="btn ${params.sort == 'completed' ? 'active' : ''}">Tasks&nbsp;completed</a></th>
                    <th><a href="?sort=volunteers&order=${params.sort == 'volunteers' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}" class="btn ${params.sort == 'volunteers' ? 'active' : ''}">Volunteers</a></th>
                    <th><a href="?sort=institution&order=${params.sort == 'institution' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}" class="btn ${params.sort == 'institution' ? 'active' : ''}">Sponsoring&nbsp;Institution</a></th>
                    <th><a href="?sort=type&order=${params.sort == 'type' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}" class="btn ${params.sort == 'type' ? 'active' : ''}">Type</a></th>
                </tr>
            </thead>
            <tbody>
                <g:each in="${projects}" status="i" var="projectSummary">
                    <tr inactive="${projectSummary.project.inactive}">
                        <th colspan="4" style="border-bottom: none">
                            <h3><a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}">${projectSummary.project.featuredLabel}</a>
                                <g:if test="${projectSummary.project.inactive}">
                                    - Deactivated
                                </g:if>
                            </h3>
                        </th>
                        <th align="center" style="border-bottom: none">
                            <cl:ifAdmin>
                                <g:link class="adminLink" controller="project" action="edit" id="${projectSummary.project.id}">Settings</g:link>
                                <g:link class="adminLink" controller="task" action="projectAdmin" id="${projectSummary.project.id}">Admin</g:link>
                            </cl:ifAdmin>
                        </th>
                    </tr>
                    <tr inactive="${projectSummary.project.inactive}" style="border: none">
                        <%-- Project thumbnail --%>
                        <td style="border-top: none"><a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}">
                            <img src="${projectSummary.project.featuredImage}" width="147" height="81"/>
                        </a>
                        </td>
                        <%-- Progress bar --%>
                        <td style="border-top: none">
                            <div>
                                <strong>${projectSummary.percentTranscribed}%</strong> of ${projectSummary.taskCount} tasks transcribed
                                <span class="pull-right"><strong>${projectSummary.percentValidated}%</strong> validated.</span>
                            </div>

                            <div class="progress expedition-progress">
                                <div class="bar bar-success" style="width: ${projectSummary.percentValidated}%"></div>
                                <div class="bar bar-warning" style="width: ${projectSummary.percentTranscribed - projectSummary.percentValidated}%"></div>
                            </div>

                        </td>
                        <%-- Volunteer count --%>
                        <td style="border-top: none" class="bold centertext">${projectSummary.volunteerCount}</td>
                        <%-- Institution --%>
                        <td style="border-top: none">
                        <g:if test="${projectSummary.project.institution}">
                            <a href="${createLink(controller:'institution', action:'index', id:projectSummary.project.institution.id)}">${projectSummary.project.institution.name}</a>
                        </g:if>
                        <g:else>
                            ${projectSummary.project.featuredOwner}
                        </g:else>
                    </td>
                        <%-- Project type --%>
                        <td style="border-top: none" class="type">
                            <img src="${projectSummary.iconImage}" width="40" height="36" alt="">
                            <br/>
                            ${projectSummary.iconLabel}
                        </td>

                    </tr>
                </g:each>
            </tbody>
        </table>

        <div class="pagination">
            <g:paginate total="${projectInstanceTotal}" prev="" next="" params="${[q:params.q] + (extraParams ?: [:])}" />
        </div>
    </div>
</div>