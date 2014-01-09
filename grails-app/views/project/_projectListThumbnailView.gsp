<div class="row">
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
                <th><a href="?sort=name&order=${params.sort == 'name' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&mode=thumbs" class="btn ${params.sort == 'name' ? 'active' : ''}">Name</a></th>
                <th><a href="?sort=completed&order=${params.sort == 'completed' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&mode=thumbs" class="btn ${params.sort == 'completed' ? 'active' : ''}">Tasks&nbsp;completed</a></th>
                <th><a href="?sort=volunteers&order=${params.sort == 'volunteers' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&mode=thumbs" class="btn ${params.sort == 'volunteers' ? 'active' : ''}">Volunteers</a></th>
                <th><a href="?sort=institution&order=${params.sort == 'institution' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&mode=thumbs" class="btn ${params.sort == 'institution' ? 'active' : ''}">Sponsoring&nbsp;Institution</a></th>
                <th><a href="?sort=type&order=${params.sort == 'type' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}&mode=thumbs" class="btn ${params.sort == 'type' ? 'active' : ''}">Type</a></th>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>
</div>
<div class="row">
    <ul class="thumbnails">
        <g:each in="${projects}" var="projectSummary">

            <li class="span3" inactive="${projectSummary.project.inactive}">
                <div class="thumbnail" style="text-align: center; background-color: white">
                    <div>
                        <strong>
                            ${projectSummary.project.featuredLabel}
                        </strong>
                    </div>
                    <a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}">
                        <img src="${projectSummary.project.featuredImage}" width="147" height="81"/>
                    </a>
                    <div>
                        <table style="width: 100%">
                            <tr>
                                <td style="text-align: left"><img src="${projectSummary.iconImage}" width="16" height="20" alt="${projectSummary.iconLabel}"></td>
                                <td>
                                    <small>${projectSummary.project.featuredOwner}</small>
                                </td>
                                <td style="text-align: right">${projectSummary.percentComplete}%</td>
                            </tr>
                        </table>
                    </div>
                </div>
            </li>
        </g:each>
    </ul>
    <div class="pagination">
        <g:paginate total="${projectInstanceTotal}" prev="" next="" params="${[q:params.q, mode:'thumbs']}" />
    </div>
</div>
