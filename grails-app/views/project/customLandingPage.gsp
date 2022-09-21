<%@ page import="au.org.ala.volunteer.ProjectActiveFilterType; au.org.ala.volunteer.ProjectStatusFilterType; au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'project.label', default: 'Expedition')}"/>
    <title><cl:pageTitle title="${g.message(code:"default.list.label", args:['Expedition'])}"/></title>

    <g:set var="bgurl" value="${landingPageInstance.landingPageImage ? cl.imageUrlPrefix(type: 'landingPage', name: landingPageInstance.landingPageImage) : asset.assetPath(src: 'wildlifespotter.jpg')}" />
    <asset:stylesheet src="digivol-image-resize"/>
</head>

<body class="digivol">

    <cl:headerContent title="${landingPageInstance.title}" selectedNavItem="${landingPageInstance.shortUrl}" complexBodyMarkup="true" />

    <div class="a-feature wildlifespotter" style="background-image: url('${bgurl}');">
        <div class="container">
            <h1><span>${landingPageInstance.title}</span></h1>

            <g:if test="${landingPageInstance.bodyCopy}">
                <markdown:renderHtml text="${landingPageInstance.bodyCopy}" />
            </g:if>
            <g:else>
                <p>Help save threatened species and preserve Australia’s iconic wildlife!</p>

                <p>Become a citizen scientist and assist researchers by looking for animals in wilderness photos taken by automated cameras around Australia.</p>

                <p>Anyone can join in and you can do it all online.

            </g:else>
            <div class="cta-primary">
                %{--<a class="btn btn-primary btn-lg" href="#expeditionList" role="button">Start Classifying <span class="glyphicon glyphicon-arrow-down"></span></a>--}%
            </div>

            <div class="row">
                <div class="col-sm-12 image-origin">
                    <g:if test="${landingPageInstance.imageAttribution}">
                        <p>Image ${landingPageInstance.imageAttribution}</p>
                    </g:if>
                </div>
            </div>
        </div>

    </div>

    <section id="main-content">
        <div class="container">
            <div class="row">
                <div class="col-sm-8">
                    <div class="row">
                        <div class="col-sm-6">
                            %{--<h2 class="heading">--}%
                                %{--Camera Trap Expeditions--}%
                                %{--<div class="subheading">Showing <g:formatNumber number="${filteredProjectsCount}" type="number"/> expeditions</div>--}%
                            %{--</h2>--}%
                            <g:if test="${params.q}">
                                Expeditions matching:
                                    <span class="tag currentFilter">
                                        <span>${params.q}</span>
                                        <a href="${createLink(mapping: 'landingPage', params: queryStringParams + [resetSearch: true])}">
                                            <i class="remove glyphicon glyphicon-remove-sign glyphicon-white"></i>
                                        </a>
                                    </span>
                            </g:if>
                        </div>

                        <div class="col-sm-6">
                            <div class="card-filter">
                                <div class="btn-group pull-right" role="group" aria-label="...">
                                    <a href="${createLink(mapping: 'landingPage', params: queryStringParams + [mode: 'grid'])}"
                                       class="btn btn-default btn-xs ${params.mode != 'grid' ? '' : 'active'}">
                                        <i class="glyphicon glyphicon-th-large "></i>
                                    </a>
                                    <a href="${createLink(mapping: 'landingPage', params: queryStringParams)}"
                                       class="btn btn-default btn-xs ${params.mode == 'grid' ? '' : 'active'}">
                                        <i class="glyphicon glyphicon-th-list"></i>
                                    </a>
                                </div>

                                <div class="custom-search-input body">
                                    <div class="input-group">
                                        <input type="text" id="searchbox" class="form-control input-lg" placeholder="Search"/>
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
                                <div class="btn-group pull-right" style="padding-right: 10px; margin-bottom: 10px; margin-top: -10px;">
                                    <g:each in="${ProjectActiveFilterType.values()}" var="mode">
                                        <g:set var="href" value="?${(urlParams + [activeFilter: mode]).collect { it }.join('&')}" />
                                        <a href="${href}" class="btn btn-warning btn-small ${activeFilterMode == mode?.toString() ? "active" : ""}">${mode.description}</a>
                                    </g:each>
                                </div>
                            </cl:ifAdmin>
                        </div>
                    </div>

                    <g:set var="model" value="${[extraParams:[statusFilter: statusFilterMode?.toString(), activeFilter: activeFilterMode?.toString(), shortUrl: landingPageInstance.shortUrl]]}" />
                    <g:if test="${params.mode == 'grid'}">
                        <g:render template="projectListThumbnailView" model="${model}"/>
                    </g:if>
                    <g:else>
                        <g:render template="ProjectListDetailsView" model="${model}" />
                    </g:else>
                </div>
                <div class="col-sm-4">
                    %{--<g:set var="model" value="${[institutionName: 'Wildlife Spotter', projectType: projectType, tagName, tags]}" />--}%
                    <g:render template="/leaderBoard/stats" model="[institutionName: landingPageInstance.title, tagName: tags, projectType: projectType, disableContribution: true, disableForumActivity: true]" />
                </div>
            </div>
        </div>
    </section>
<asset:javascript src="digivol-image-resize" asset-defer=""/>
<asset:script type="text/javascript">

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

        function doSearch() {
            var q = $("#searchbox").val();
            var url = "${createLink(mapping: 'landingPage', params: [shortUrl: landingPageInstance.shortUrl])}?statusFilter=${params.statusFilter}&activeFilter=${params.activeFilter}&offset=${params.offset}&max=${params.max}&sort=${params.sort}&order=${params.order}&q=" + encodeURIComponent(q);
                window.location = url;
            }
        });

</asset:script>
</body>
</html>
