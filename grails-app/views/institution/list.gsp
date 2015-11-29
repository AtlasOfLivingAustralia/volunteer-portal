<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'institutions.label', default: 'Institution')}"/>
    <title><cl:pageTitle title="${g.message(code:'default.list.label', args:[entityName])}" /></title>
    <style type="text/css">
    tr.institution-details-row, .institution-details-row td {
        border-top: none;
    }
    </style>
    <r:script>

            $(function() {

                $("#searchbox").keydown(function(e) {
                    if (e.keyCode ==13) {
                        doSearch();
                    }
                });

                $("#btnSearch").click(function(e) {
                    e.preventDefault();
                    doSearch();
                });

                $("a.fieldHelp").qtip({
                    tip: true,
                    position: {
                        corner: {
                            target: 'topMiddle',
                            tooltip: 'bottomLeft'
                        }
                    },
                    style: {
                        width: 400,
                        padding: 8,
                        background: 'white', //'#f0f0f0',
                        color: 'black',
                        textAlign: 'left',
                        border: {
                            width: 4,
                            radius: 5,
                            color: '#E66542'// '#E66542' '#DD3102'
                        },
                        tip: 'bottomLeft',
                        name: 'light' // Inherit the rest of the attributes from the preset light style
                    }
                }).bind('click', function(e) {
                    e.preventDefault();
                    return false;
                });

                $("#searchbox").focus();

                $('[data-toggle="tooltip"]').tooltip();

            });

            function doSearch() {
                var q = $("#searchbox").val();
                var url = "${createLink(controller: 'institution', action: 'list')}?mode=${params.mode}&q=" + encodeURIComponent(q);
                window.location = url;
            }

    </r:script>
</head>

<body class="digivol">

<cl:headerContent title="${message(code: 'default.institutionlist.label', default: "Institutions")}"
                  selectedNavItem="institutions">
    <cl:ifAdmin>
        </div>
        <div class="col-sm-2">
            <a class="btn btn-primary" href="${createLink(controller: 'institutionAdmin', action: 'index')}">Manage</a>
    </cl:ifAdmin>
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
                                All institutions
                            </g:else>
                            <div class="subheading">Showing <g:formatNumber number="${totalInstitutions}" type="number"/> institutions</div>
                        </h2>
                    </div>

                    <div class="col-sm-6">
                        <div class="card-filter">
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

                <g:each in="${institutions}" status="i" var="inst">
                    <div class="col-md-6">
                        <div class="thumbnail institution">
                            <div class="institution-settings-btn">
                                <cl:ifInstitutionAdmin institution="${inst}">
                                    <a class="btn btn-warning btn-sm pull-right" title="Settings" data-toggle="tooltip"
                                            href="${createLink(controller: 'institutionAdmin', action: 'edit', id: inst.id)}"><i
                                            class="fa fa-cog"></i></a>
                                </cl:ifInstitutionAdmin>
                            </div>
                            <div class="logo-centre">
                                <a href="${createLink(controller: 'institution', action: 'index', id: inst.id)}">
                                    <img class="img-responsive cropme" src="<cl:institutionLogoUrl id="${inst.id}"/>" style="max-height: 200px;"/>
                                </a>
                            </div>
                            <div class="caption">
                                <h4><a href="${createLink(controller: 'institution', action: 'index', id: inst.id)}">${inst.name}</a></h4>

                                <div class="expedition-progress">
                                    <div class="progress-legend">
                                        <div class="row">
                                            <div class="col-xs-4">
                                                <g:set var="projectCount" value="${projectCounts[inst] ?: 0}"/>
                                                <strong>${projectCount}</strong> Expedition${projectCount == 1 ? '' : 's'}
                                            </div>
                                            <div class="col-xs-4">
                                                <g:set var="volunteerCount" value="${projectVolunteers[inst.id] ?: 0}"/>
                                                <strong>${volunteerCount}</strong> Volunteers
                                            </div>
                                            <div class="col-xs-4">
                                                <g:set var="taskCount" value="${taskCounts[inst.id] ?: 0}"/>
                                                <strong>${taskCount}</strong> Tasks
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <g:if test="${(i+1) % 2 == 0}"><div class="clearfix visible-md-block visible-lg-block"></div></g:if>
                </g:each>
                <div class="row">
                    <div class="col-sm-12">
                        <div class="pagination">
                            <g:paginate total="${totalInstitutions}" prev="" next="" params="${[q: params.q]}"/>
                        </div>
                    </div>
                </div><!-- /.row -->

                %{--</div>--}%
            </div><!-- /.col-sm-8 -->

            <div class="col-sm-4">
                <g:render template="/leaderBoard/stats"/>
            </div>
        </div>
    </div>
</section>
</body>
</html>
