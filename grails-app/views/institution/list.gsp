<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <content tag="pageType">institution</content>
    <g:set var="entityName" value="${message(code: 'institutions.label', default: 'Institution')}"/>
    <title><cl:pageTitle title="${g.message(code:'default.list.label', args:[entityName])}" /></title>
    <style type="text/css">
    tr.institution-details-row, .institution-details-row td {
        border-top: none;
    }
    </style>
    <asset:script>

            $(function() {
                $("#searchForm").on('submit', function (e) {
                    e.preventDefault();
                    doSearch();
                });

                $("#searchbox").focus();

                new bootstrap.Tooltip($('[data-bs-toggle="tooltip"]'));
            });

            function doSearch() {
                const q = $("#searchbox").val();
                window.location = "${createLink(controller: 'institution', action: 'list')}?mode=${params.mode}&q=" + encodeURIComponent(q);
            }

    </asset:script>
</head>

<body class="digivol">

<cl:headerContent title="${message(code: 'default.institutionlist.label', default: "Institutions")}"
                  selectedNavItem="institutions">
    <cl:ifSiteAdmin>
        </div>
        <div class="col-sm-2">
            <a class="btn btn-secondary" href="${createLink(controller: 'institutionAdmin', action: 'index')}">Manage</a>
    </cl:ifSiteAdmin>

</cl:headerContent>

<section id="main-content">
    <div class="container">
        <div class="row">
            <div class="col-12 col-lg-12 col-xl-8">
                <div class="row">
                    <div class="col-sm-6">
                        <h2 class="heading">
                            <g:if test="${params.q || params.tag}">
                                Expeditions matching:
                                <g:if test="${params.q}">
                                    <span class="tag currentFilter">
                                        <span>${params.q}</span>
                                        <a href="?mode=${params.mode}&q="><i class="remove fa fa-remove"></i></a>
                                    </span>
                                </g:if>
                                <g:if test="${params.tag}">
                                    <span class="tag currentFilter">
                                        <span>${params.tag}</span>
                                        <a href="?mode=${params.mode}&tag="><i class="remove fa fa-remove"></i></a>
                                    </span>
                                </g:if>
                            </g:if>
                            <g:else>
                                All institutions
                            </g:else>
                            <div class="subheading">Showing <g:formatNumber number="${totalInstitutions}" type="number"/> institutions</div>
                        </h2>
                    </div>

                    <div class="col-sm-6">
                        <div class="card-filter">
                            <div class="custom-search-input body">
                                <form id="searchForm" role="search">
                                    <label class="visually-hidden" for="searchbox">Search expeditions</label>
                                    <div class="input-group">
                                        <input type="search" id="searchbox" class="form-control" placeholder="Search e.g. Bivalve"/>
                                        <button id="btnSearch" class="btn" type="submit">
                                            <i class="fa fa-search" aria-hidden="true"></i>
                                            <span class="visually-hidden">Search</span>
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <g:each in="${institutions}" status="i" var="inst">
                        <div class="col-12 col-lg-6">
                            <div class="thumbnail institution shadow-sm">
                                <div class="institution-settings-btn">
                                    <cl:ifInstitutionAdmin institution="${inst}">
                                        <a class="btn btn-outline-secondary btn-sm float-end" title="Settings" data-bs-toggle="tooltip" href="${createLink(controller: 'institutionAdmin', action: 'edit', id: inst.id)}">
                                            <i class="fa fa-cog"></i>
                                        </a>
                                    </cl:ifInstitutionAdmin>
                                </div>
                                <g:link controller="institution" action="index" id="${inst.id}" class="thumbImg">
                                    <img class="img-fluid cropme" src="<cl:institutionLogoUrl id="${inst.id}"/>" style="max-height: 200px;" alt="${inst.name}"/>
                                </g:link>
                                <div class="caption">
                                    <h4><a href="${createLink(controller: 'institution', action: 'index', id: inst.id)}">${inst.name}</a></h4>

                                    <g:set var="projectCount" value="${projectCounts[inst] ?: 0}"/>
                                    <g:set var="volunteerCount" value="${projectVolunteers[inst.id] ?: 0}"/>
                                    <g:set var="taskCount" value="${taskCounts[inst.id] ?: 0}"/>

                                    <div class="row row-cols-1 row-cols-sm-3 g-3 project-stat-cards">
                                        <div class="col">
                                            <div class="card project-stat-card h-100 text-center">
                                                <div class="card-body">
                                                    <div class="project-stat-value">${projectCount}</div>
                                                    <div class="project-stat-label">Expeditions</div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col">
                                            <div class="card project-stat-card h-100 text-center">
                                                <div class="card-body">
                                                    <div class="project-stat-value">${volunteerCount}</div>
                                                    <div class="project-stat-label">Volunteers</div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col">
                                            <div class="card project-stat-card h-100 text-center">
                                                <div class="card-body">
                                                    <div class="project-stat-value">${taskCount}</div>
                                                    <div class="project-stat-label">Tasks</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </g:each>

                    <cl:paginate total="${totalInstitutions}" params="${[q: params.q]}"/>
                </div>
%{--                <div class="row">--}%
%{--                    <div class="col-sm-12">--}%
%{--                        --}%
%{--                    </div>--}%
%{--                </div>--}%

            </div>

            <div class="col-12 col-lg-12 col-xl-4">
                <g:render template="/leaderBoard/stats" model="[disableContribution: true, disableForumActivity: true]"/>
            </div>

        </div>
    </div>

</section>
</body>
</html>
