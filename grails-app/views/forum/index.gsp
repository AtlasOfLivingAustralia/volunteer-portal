<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'vp.css')}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>
        <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
        <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>

        <style type="text/css">
        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

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
                var url = "${createLink(controller: 'forum', action:'index')}?q=" + encodeURIComponent(q);
                window.location = url;
            }

        </script>

        <cl:navbar selected="forum"/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li class="last"><g:message code="default.forum.label" default="Forum"/></li>
                    </ol>
                </nav>

                <h1><g:message code="default.forum.label" default="Forum"/></h1>
            </div>
        </header>

        <div class="inner">
            <h2>Welcome to the Volunteer Portal Forum!</h2>
            The forum is organised into a number of sections...
            <h3><a href="${createLink(controller: 'forum', action: 'generalDiscussion')}">General Discussion Topics</a>
            </h3>
            This section is for general comments and queries about the Biodiversity Volunteer Portal in general
            <p/>

            <h3>Project Specific Forums</h3>
            <table class="bvp-expeditions">
                <colgroup>
                    <col style="width:165px"/>
                </colgroup>
                <thead>
                    <tr>
                        <td colspan="2">
                            <g:if test="${params.q}">
                                <h4>
                                    <g:if test="${projectSummaryList.matchingProjectCount}">
                                        ${projectSummaryList.matchingProjectCount} matching projects
                                    </g:if>
                                    <g:else>
                                        No matching projects
                                    </g:else>
                                </h4>
                            </g:if>
                        </td>
                        <td colspan="2" style="text-align: right">
                            <span>
                                <a style="vertical-align: middle;" href="#" class="fieldHelp" title="Enter search text here to find expeditions"><span class="help-container">&nbsp;</span>
                                </a>
                            </span>
                            <g:textField style="margin-top: 10px; margin-bottom: 10px" id="searchbox" value="${params.q}" name="searchbox"/>
                            <button id="btnSearch">Search</button>
                        </td>
                    </tr>
                    <tr>
                        <th>
                            <a href="?sort=name&order=${params.sort == 'name' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}" class="button ${params.sort == 'name' ? 'current' : ''}">Name</a>
                        </th>
                        <th>
                            <a href="?sort=completed&order=${params.sort == 'completed' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}" class="button ${params.sort == 'completed' ? 'current' : ''}">Tasks completed</a>
                        </th>
                        <th>
                            <a href="?sort=type&order=${params.sort == 'type' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}" class="button ${params.sort == 'type' ? 'current' : ''}">Type</a>
                        </th>
                        <th>
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <g:each in="${projectSummaryList.projectRenderList}" status="i" var="projectSummary">
                        <tr inactive="${projectSummary.project.inactive}">
                            <%-- Project thumbnail --%>
                            <td><a href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectSummary.project.id])}">
                                <img src="${projectSummary.project.featuredImage}" width="147" height="81" style="padding-top: 5px"/>
                            </a>
                            </td>
                            <%-- Progress bar --%>
                            <td>
                                <h3><a href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectSummary.project.id])}">${projectSummary.project.featuredLabel}</a></h3>
                                <div id="recordsChart">
                                    <strong>${projectSummary.countComplete}</strong> tasks completed (<strong>${projectSummary.percentComplete}%</strong>)
                                </div>
                                <div style="height: 5px" id="recordsChartWidget${i}" class="ui-progressbar ui-widget ui-widget-content ui-corner-all" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="${projectSummary.percentComplete}">
                                    <div class="ui-progressbar-value ui-widget-header ui-corner-left ui-corner-right" style="width: ${projectSummary.percentComplete}%; "></div>
                                </div>
                            </td>
                            <%-- Project type --%>
                            <td class="type">
                                <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/${projectSummary.iconImage}" width="40" height="36" alt="">
                            </td>
                            <td style="text-align: right">
                                <a class="button" href="${createLink(controller:"project", action:"index", id:projectSummary.project.id)}">Visit Project</a>
                                <a class="button" href="${createLink(controller:"forum", action:"projectForum", params:[projectId: projectSummary.project.id])}">Visit Project Forum</a>
                            </td>
                        </tr>
                    </g:each>
                </tbody>
            </table>

            <div class="paginateButtons">
                <g:paginate total="${projectSummaryList.totalProjectCount}" prev="" next="" params="${[q: params.q]}"/>
            </div>

        </div>

    </body>
</html>
