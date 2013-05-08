<%@ page import="au.org.ala.volunteer.Project" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}"/>
        <title><g:message code="default.list.label" args="[entityName]"/></title>
        <style type="text/css">

        .ui-widget-header {
            border: 1px solid #3A5C83;
            background: white url(${resource(dir:'images/vp',file:'progress_1x100b.png')}) 50% 50% repeat-x;
        }

        .ui-widget-content {
            border: 1px solid #3A5C83;
        }

        [inactive=true] {
            background-color: #d3d3d3;
            opacity: 0.5;
        }

        tr .adminLink {
            color: #d3d3d3;
        }

        tr[inactive=true] .adminLink {
            color: black;
            opacity: 1;
        }

        </style>

        <script type="text/javascript">

            $(document).ready(function() {

                $("#searchbox").keydown(function(e) {
                    if (e.keyCode ==13) {
                        doSearch();
                    }
                })

                $("#btnSearch").click(function(e) {
                    e.preventDefault();
                    doSearch();
                })

            });

            function doSearch() {
                var q = $("#searchbox").val();
                var url = "${createLink(controller: 'project',action:'list')}?q=" + encodeURIComponent(q);
                window.location = url;
            }

        </script>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.projectlist.label', default: "Volunteer for a virtual expedition")}" selectedNavItem="expeditions"/>

        <div class="row">
            <div class="span12">
                <h2>${numberOfUncompletedProjects} expeditions need your help. Join now!</h2>
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
                                    <h2><a href="${createLink(controller: 'project', action: 'index', id: projectSummary.project.id)}">${projectSummary.project.featuredLabel}</a>
                                        <g:if test="${projectSummary.project.inactive}">
                                            - Deactivated
                                        </g:if>
                                    </h2>
                                </th>
                                <th align="center" style="border-bottom: none">
                                    <cl:ifAdmin>
                                        <g:link class="adminLink" controller="project" action="edit" id="${projectSummary.project.id}">Edit</g:link>
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
                                    <div id="recordsChart">
                                        <strong>${projectSummary.countComplete}</strong> tasks completed (<strong>${projectSummary.percentComplete}%</strong>)
                                    </div>

                                    <div id="recordsChartWidget${i}" class="ui-progressbar ui-widget ui-widget-content ui-corner-all" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="${projectSummary.percentComplete}">
                                        <div class="ui-progressbar-value ui-widget-header ui-corner-left ui-corner-right" style="width: ${projectSummary.percentComplete}%; "></div>
                                    </div>
                                </td>
                                <%-- Volunteer count --%>
                                <td style="border-top: none" class="bold centertext">${projectSummary.volunteerCount}</td>
                                <%-- Institution --%>
                                <td style="border-top: none">${projectSummary.project.featuredOwner}</td>
                                <%-- Project type --%>
                                <td style="border-top: none" class="type">
                                    <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/${projectSummary.iconImage}" width="40" height="36" alt="">
                                    <br/>
                                    ${projectSummary.iconLabel}
                                </td>

                            </tr>
                        </g:each>
                    </tbody>
                </table>

                <div class="paginateButtons">
                    <g:paginate total="${projectInstanceTotal}" prev="" next="" params="${[q:params.q]}" />
                </div>
            </div>
        </div>
    </body>
</html>
