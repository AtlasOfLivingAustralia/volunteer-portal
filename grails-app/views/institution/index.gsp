<%@ page import="au.org.ala.volunteer.ProjectActiveFilterType; au.org.ala.volunteer.ProjectStatusFilterType" contentType="text/html;charset=UTF-8" %>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><cl:pageTitle title="${institutionInstance.name ?: 'unknown'}" /></title>
    <content tag="primaryColour">${institutionInstance.themeColour}</content>
    <content tag="pageType">institution</content>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>

    <r:require modules="digivol-image-resize"/>
    <r:script>

        $(document).ready(function () {

            $("#searchbox").keydown(function(e) {
                if (e.keyCode ==13) {
                    doSearch();
                }
            });

            $("#btnSearch").click(function(e) {
                e.preventDefault();
                doSearch();
            });

            $("#searchbox").focus();
        });

        function doSearch() {
            var q = $("#searchbox").val();
            var url = "${createLink(controller: 'institution', action: 'index', id: institutionInstance.id)}?mode=${params.mode}&q=" + encodeURIComponent(q) + "&statusMode=${statusFilterMode}&activeMode=${activeFilterMode}";
            window.location = url;
        }

    </r:script>

</head>

<body class="content ${institutionInstance.themeColour}">
<cl:headerContent title="${institutionInstance.name}" selectedNavItem="institutions" hideTitle="${true}" complexBodyMarkup="1">
    <%pageScope.crumbs = [[link: createLink(controller: 'institution', action: 'list'), label: message(code: 'default.institutions.label', default: 'Institutions')]] %>
    <div class="row">
        <div class="col-sm-4 col-sm-push-8">
            <img src="<cl:institutionLogoUrl id="${institutionInstance.id}"/>" class="img-responsive institution-logo-main">
            <table class="table table-striped contact">
                <tbody>
                <tr>
                    <th scope="row">Email</th>
                    <td><a href="mailto:${institutionInstance.contactEmail}">${institutionInstance.contactName}</td>
                </tr>
                <tr>
                    <th scope="row">Phone</th>
                    <td>${institutionInstance.contactPhone}</td>
                </tr>
                <tr>
                    <th scope="row">Website</th>
                    <td><a href="${(institutionInstance.websiteUrl?.startsWith("http")) ? "" : "http://"}${institutionInstance.websiteUrl}" target="_blank">${(institutionInstance.websiteUrl?.startsWith("http")) ? institutionInstance.websiteUrl?.substring(7) : institutionInstance.websiteUrl}</a></td>
                </tr>
                </tbody>
            </table>
        </div>
        <div class="col-sm-8 col-sm-pull-4">
            <h1 class="">${institutionInstance.name}</h1>
            <p style="margin-top: 20px;">${institutionInstance.shortDescription}</p>
            <div class="cta-primary ">
                <a class="btn btn-primary btn-lg" href="#expeditionList" role="button">See our expeditions
                    <span class="glyphicon glyphicon-arrow-down"></span></a>
                <a class="btn btn-lg btn-hollow grey hidden">Learn more</a>
                <cl:ifAdmin>
                    <g:link style="margin-right: 5px; color: white" class="btn btn-lg btn-warning pull-rightZ"
                            controller="institutionAdmin" action="edit" id="${institutionInstance.id}"><i
                            class="glyphicon glyphicon-cog icon-white"></i>&nbsp;Settings</g:link>&nbsp;
                </cl:ifAdmin>
            </div>
        </div>
    </div>
    <div class="progress-summary ">
        <div class="container">
            <div class="row">
                <div class="col-sm-6">
                    <div class="expedition-progress">
                        <g:set var="tv" value="${(taskCounts?.percentTranscribed as Integer) - (taskCounts?.percentValidated as Integer)}"/>
                        <div class="progress">
                            <div class="progress-bar progress-bar-success" style="width: ${taskCounts?.percentValidated}%">
                                <span class="sr-only">${taskCounts?.percentValidated}% Complete</span>
                            </div>
                            <div class="progress-bar progress-bar-transcribed" style="width: ${tv}%">
                                <span class="sr-only">${tv}% Complete</span>
                            </div>
                        </div>
                        <div class="progress-legend">
                            <div class="row">
                                <div class="col-xs-4">
                                    <b>${taskCounts?.percentValidated}%</b> Validated
                                </div>
                                <div class="col-xs-4">
                                    <b>${taskCounts?.percentTranscribed}%</b> Transcribed
                                </div>
                                <div class="col-xs-4">
                                    <b>${taskCounts?.taskCount}</b> Tasks
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-3 col-xs-6">
                    <h3><b>${underwayProjects} Expeditions</b>Underway</h3>
                </div>
                <div class="col-sm-3 col-xs-6">
                    <h3><b>${completedProjects} Expeditions</b>Completed</h3>
                </div>
                <a name="expeditionList"></a>
            </div>
        </div>
    </div>

</cl:headerContent>

<section id="main-content">
    <div class="container">
        <div class="row">
            <div class="col-sm-8">
                <div class="row">
                    <div class="col-sm-6">
                        <h2 class="heading">
                            <g:if test="${params.q}">
                                Expeditions matching:
                                <span class="tag currentFilter">
                                    <span>${params.q.replaceAll('tag:','')}</span>
                                    <a href="?mode=${params.mode}&q="><i class="remove glyphicon glyphicon-remove-sign glyphicon-white"></i></a>
                                </span>
                            </g:if>
                            <g:else>
                                All Expeditions
                            </g:else>
                            <div class="subheading">Showing <g:formatNumber number="${filteredProjectsCount}" type="number"/> expeditions</div>
                        </h2>
                    </div>

                    <div class="col-sm-6">
                        <div class="card-filter">
                            <div class="btn-group pull-right" role="group" aria-label="...">
                                <a href="?mode=" class="btn btn-default btn-xs ${params.mode != 'list' ? 'active' : ''}"><i class="glyphicon glyphicon-th-large "></i></a>
                                <a href="?mode=list" class="btn btn-default btn-xs ${params.mode == 'list' ? 'active' : ''}"><i class="glyphicon glyphicon-th-list"></i></a>
                            </div>

                            <div class="custom-search-input body">
                                <div class="input-group">
                                    <input type="text" id="searchbox" class="form-control input-lg" placeholder="Search e.g. Bivalve"/>
                                    <span class="input-group-btn">
                                        <button id="btnSearch" class="btn btn-info btn-lg" type="button">
                                            <i class="glyphicon glyphicon-search"></i>
                                        </button>
                                    </span>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="row ">
                    <div class="col-sm-12">
                        <g:set var="statusFilterMode" value="${ params.statusFilter ?: ProjectStatusFilterType.showAll}" />
                        <g:set var="activeFilterMode" value="${ params.activeFilter ?: ProjectActiveFilterType.showAll}" />
                        <g:set var="urlParams" value="${[sort: params.sort ?: "", order: params.order ?: "", offset: 0, q: params.q ?: "", mode: params.mode ?: "", statusFilter:statusFilterMode, activeFilter: activeFilterMode]}" />

                        <div class="btn-group pull-right hide" style="padding-right: 10px">
                            <g:each in="${ProjectStatusFilterType.values()}" var="mode">
                                <g:set var="href" value="?${(urlParams + [statusFilter: mode]).collect { it }.join('&')}" />
                                <a href="${href}" class="btn btn-small ${statusFilterMode == mode?.toString() ? "active" : ""}">${mode.description}</a>
                            </g:each>
                        </div>

                        <cl:ifAdmin>
                            <div class="btn-group pull-right" style="padding-right: 10px; margin-bottom: 10px;margin-top: -20px;">
                                <g:each in="${ProjectActiveFilterType.values()}" var="mode">
                                    <g:set var="href" value="?${(urlParams + [activeFilter: mode]).collect { it }.join('&')}" />
                                    <a href="${href}" class="btn btn-warning btn-small ${activeFilterMode == mode?.toString() ? "active" : ""}">${mode.description}</a>
                                </g:each>
                            </div>
                        </cl:ifAdmin>
                    </div>
                </div>

                <g:set var="model" value="${[extraParams:[statusFilter: statusFilterMode?.toString(), activeFilter: activeFilterMode?.toString()]]}" />
                <g:if test="${params.mode == 'list'}">
                    <g:render template="/project/ProjectListDetailsView" model="${model}" />
                </g:if>
                <g:else>
                    <g:render template="/project/projectListThumbnailView" model="${model}"/>
                </g:else>

            </div>
            <div class="col-sm-4">
                <g:render template="/leaderBoard/stats"/>
            </div>
        </div>
    </div>
</section>
</body>
</html>