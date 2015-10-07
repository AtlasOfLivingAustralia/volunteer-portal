<%@ page import="au.org.ala.volunteer.ProjectActiveFilterType; au.org.ala.volunteer.ProjectStatusFilterType; au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>

    <style type="text/css">
    </style>

    <r:script>

        $(document).ready(function() {

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
                var url = "${createLink(controller: 'project', action: 'list')}?mode=${params.mode}&q=" + encodeURIComponent(q);
                window.location = url;
            }
        });

    </r:script>
</head>

<body class="digivol">

    <cl:headerContent title="${message(code:'default.projectlist.label', default: "Volunteer for a virtual expedition")}" selectedNavItem="expeditions">
        ${numberOfUncompletedProjects} expeditions need your help. Join now!
    </cl:headerContent>

    <section id="main-content">
        <div class="container">
            <div class="row">
                %{--<div class="span6">--}%
                %{--<h2>${numberOfUncompletedProjects} expeditions need your help. Join now!</h2>--}%
                %{--</div>--}%
                <div class="col-sm-8">
                    <div class="row">
                        <div class="col-sm-4">
                            <h2 class="heading">
                                All Expeditions
                            </h2>
                        </div>

                        <div class="col-sm-8">
                            <div class="card-filter">
                                <div class="btn-group pull-right" role="group" aria-label="...">
                                    <a href="${createLink(action:'list', params:[mode:'thumbs'])}" class="btn btn-default btn-xs ${params.mode == 'thumbs' ? 'active' : ''}"><i class="glyphicon glyphicon-th-large "></i></a>
                                    <a href="${createLink(action:'list')}" class="btn btn-default btn-xs ${params.mode != 'thumbs' ? 'active' : ''}"><i class="glyphicon glyphicon-th-list"></i></a>
                                </div>

                                <div class="custom-search-input body">
                                    <div class="input-group">
                                        <input type="text" id="searchbox" class="form-control input-lg" value="${params.q}" placeholder="Search e.g. Bivalve"/>
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

                    <div class="row hide">
                        <div class="col-sm-12">
                            <g:set var="statusFilterMode" value="${ params.statusFilter ?: ProjectStatusFilterType.showAll}" />
                            <g:set var="activeFilterMode" value="${ params.activeFilter ?: ProjectActiveFilterType.showAll}" />
                            <g:set var="urlParams" value="${[sort: params.sort ?: "", order: params.order ?: "", offset: 0, q: params.q ?: "", mode: params.mode ?: "", statusFilter:statusFilterMode, activeFilter: activeFilterMode]}" />

                            %{--<div class="btn-group pull-right">--}%
                                %{--<a href="${createLink(action:'list')}" class="btn btn-small ${params.mode != 'thumbs' ? 'active' : ''}" title="View expedition list">--}%
                                    %{--<i class="icon-th-list"></i>--}%
                                %{--</a>--}%
                                %{--<a href="${createLink(action:'list', params:[mode:'thumbs'])}" class="btn btn-small ${params.mode == 'thumbs' ? 'active' : ''}" title="View expedition thumbnails">--}%
                                    %{--<i class="icon-th"></i>--}%
                                %{--</a>--}%
                            %{--</div>--}%

                            <div class="btn-group pull-right" style="padding-right: 10px">
                                <g:each in="${ProjectStatusFilterType.values()}" var="mode">
                                    <g:set var="href" value="?${(urlParams + [statusFilter: mode]).collect { it }.join('&')}" />
                                    <a href="${href}" class="btn btn-small ${statusFilterMode == mode?.toString() ? "active" : ""}">${mode.description}</a>
                                </g:each>
                            </div>

                            <cl:ifAdmin>
                                <div class="btn-group pull-right" style="padding-right: 10px">
                                    <g:each in="${ProjectActiveFilterType.values()}" var="mode">
                                        <g:set var="href" value="?${(urlParams + [activeFilter: mode]).collect { it }.join('&')}" />
                                        <a href="${href}" class="btn btn-warning btn-small ${activeFilterMode == mode?.toString() ? "active" : ""}">${mode.description}</a>
                                    </g:each>
                                </div>
                            </cl:ifAdmin>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-12">
                            <g:set var="model" value="${[extraParams:[statusFilter: statusFilterMode?.toString(), activeFilter: activeFilterMode?.toString()]]}" />

                            <g:if test="${params.mode == 'thumbs'}">
                                <g:render template="projectListThumbnailView" model="${model}"/>
                            </g:if>
                            <g:else>
                                <g:render template="ProjectListDetailsView2" model="${model}" />
                            </g:else>
                        </div>
                    </div>


                </div>
                <div class="col-sm-4">

                    <div class="panel panel-default volunteer-stats">
                        <!-- Default panel contents -->
                        <h2 class="heading">Digivol Stats<i class="fa fa-users fa-sm pull-right"></i></h2>
                        <h3><a href="#"><g:formatNumber number="${totalUsers}" type="number" /> Volunteers</a></h3>
                        <p>233983 tasks of 254875 completed.</p>
                    </div><!-- Digivol Stats Ends Here -->
                    <div class="panel panel-default leaderboard">
                        <!-- Default panel contents -->
                        <h2 class="heading">Leaderboard <i class="fa fa-trophy fa-sm pull-right"></i></h2>
                        <!-- Table -->
                        <table class="table">
                            <thead>
                            <tr>
                                <th colspan="2">Day Tripper</th>
                                <th class="view-more"><a href="#">View Top 20</a></th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <th scope="row"><a href="#"><img src="https://randomuser.me/api/portraits/med/women/35.jpg" class="img-circle"></a></th>
                                <th><a href="#">Rachel Lee</a></th>
                                <td class="transcribed-amount">3982</td>
                            </tr>
                            </tbody>
                            <thead>
                            <tr>
                                <th colspan="2">Weekly Wonder</th>
                                <th class="view-more"><a href="#">View Top 20</a></th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <th scope="row"><a href="#"><img src="https://randomuser.me/api/portraits/med/women/12.jpg" class="img-circle"></a></th>
                                <th><a href="#">Teresa Van Der Heul</a></th>
                                <td class="transcribed-amount">1223</td>
                            </tr>
                            </tbody>
                            <thead>
                            <tr>
                                <th colspan="2">Digivol Legend</th>
                                <th class="view-more"><a href="#">View Top 20</a></th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <th scope="row"><a href="#"><img src="https://randomuser.me/api/portraits/med/women/19.jpg" class="img-circle"></a></th>
                                <th><a href="#">Megan Ede</a></th>
                                <td class="transcribed-amount">989</td>
                            </tr>
                            </tbody>
                            <thead>
                            <tr>
                                <th colspan="2">Day Tripper</th>
                                <th class="view-more"><a href="#">View Top 20</a></th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <th scope="row"><a href="#"><img src="https://randomuser.me/api/portraits/med/women/22.jpg" class="img-circle"></a></th>
                                <th><a href="#">Rachel Lee</a></th>
                                <td class="transcribed-amount">124</td>
                            </tr>
                            </tbody>
                        </table>
                    </div><!-- Leaderboard Ends Here -->

                    <h2 class="heading">
                        Latest Contributions
                    </h2>
                    <ul class="media-list">


                        <li class="media">
                            <div class="media-left">
                                <a href="#">
                                    <img src="https://randomuser.me/api/portraits/med/women/62.jpg" class="img-circle">
                                </a>
                            </div>
                            <div class="media-body">
                                <span class="time">5 hours ago</span>
                                <h4 class="media-heading"><a href="#">Margret Kin</a></h4>
                                <p>Transcribed 7 items from the <a href="#">Bivalve expedition</a></p>
                                <div class="transcribed-thumbs">
                                    <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc">  <img src="http://placehold.it/40x40/ccc"> <a href="#"><span>+2</span>More</a>
                                </div>
                                <a class="btn btn-default btn-xs join" href="#" role="button">Join expedition »</a>
                            </div>

                        </li>
                        <li class="media">
                            <div class="media-left">
                                <a href="#">
                                    <img src="https://randomuser.me/api/portraits/med/women/62.jpg" class="img-circle">
                                </a>
                            </div>
                            <div class="media-body">
                                <span class="time">5 hours ago</span>
                                <h4 class="media-heading"><a href="#">Margret Kin</a></h4>
                                <p>Transcribed 7 items from the <a href="#">Bivalve expedition</a></p>
                                <div class="transcribed-thumbs">
                                    <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc">  <img src="http://placehold.it/40x40/ccc"> <a href="#"><span>+2</span>More</a>
                                </div>
                                <a class="btn btn-default btn-xs join" href="#" role="button">Join expedition »</a>
                            </div>

                        </li>

                        <li class="media">
                            <div class="media-left">
                                <a href="#">
                                    <img src="https://randomuser.me/api/portraits/med/men/51.jpg" class="img-circle">
                                </a>
                            </div>
                            <div class="media-body">
                                <span class="time">5 hours ago</span>
                                <h4 class="media-heading"><a href="#">Warren Lee</a></h4>
                                <p>Has posted in the forum: <a href="#">Hawaiian Mouthparts expedition</a></p>
                                <div class="transcribed-thumbs">
                                    <img src="http://placehold.it/40x40/ccc">
                                </div>
                                <a class="btn btn-default btn-xs join" href="#" role="button">Join discussion »</a>
                            </div>

                        </li>
                        <li class="media">
                            <div class="media-left">
                                <a href="#">
                                    <img src="https://randomuser.me/api/portraits/med/women/62.jpg" class="img-circle">
                                </a>
                            </div>
                            <div class="media-body">
                                <span class="time">5 hours ago</span>
                                <h4 class="media-heading"><a href="#">Margret Kin</a></h4>
                                <p>Transcribed 3 items from the <a href="#">Bivalve expedition</a></p>
                                <div class="transcribed-thumbs">
                                    <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc">
                                </div>
                                <a class="btn btn-default btn-xs join" href="#" role="button">Join expedition »</a>
                            </div>

                        </li>
                        <li class="media">
                            <div class="media-left">
                                <a href="#">
                                    <img src="https://randomuser.me/api/portraits/med/women/62.jpg" class="img-circle">
                                </a>
                            </div>
                            <div class="media-body">
                                <span class="time">5 hours ago</span>
                                <h4 class="media-heading"><a href="#">Margret Kin</a></h4>
                                <p>Transcribed 2 items from the <a href="#">Bivalve expedition</a></p>
                                <div class="transcribed-thumbs">
                                    <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc">
                                </div>
                                <a class="btn btn-default btn-xs join" href="#" role="button">Join expedition »</a>
                            </div>

                        </li>
                    </ul>
                    <a href="#">View all contributors »</a>
                </div>
            </div>
        </div>
    </section>
</body>
</html>
