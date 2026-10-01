<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="au.org.ala.volunteer.FieldSyncService" %>
<g:set var="tasksDone" value="${tasksTranscribed ?: 0}"/>
<g:set var="tasksTotal" value="${taskCount ?: 0}"/>
<sitemesh:parameter name="includeBack" value="${true}"/>
<cl:hasProjectBackgroundImage project="${projectInstance}">
    <sitemesh:parameter name="includeBackGrey" value="${false}"/>
</cl:hasProjectBackgroundImage>
<cl:hasNoProjectBackgroundImage project="${projectInstance}">
    <sitemesh:parameter name="includeBackGrey" value="${true}"/>
</cl:hasNoProjectBackgroundImage>

<sitemesh:parameter name="backHref" value="${projectInstance.institutionId ? createLink(controller: 'institution', action: 'index', id: projectInstance.institutionId) : createLink(controller: 'project', action: 'list')}" />
<sitemesh:parameter name="backText" value="${projectInstance.institutionId ? projectInstance.institution.name : 'Expedition List'}" />
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-expedition"/>
    <title><cl:pageTitle title="${(projectInstance.name ?: 'Atlas of Living Australia') + (projectInstance.institutionName ? " : ${projectInstance.institutionName}" : '')}"/></title>
    <content tag="primaryColour">${projectInstance.institution?.themeColour}</content>
    <cl:googleMapsScript callback="onGmapsReady" if="${projectInstance.showMap}"/>

    <style type="text/css">

    <cl:hasProjectBackgroundImage project="${projectInstance}">
        .a-feature.expedition {
        <g:if test="${projectInstance.backgroundImageOverlayColour}">
            background-image: linear-gradient(${projectInstance.backgroundImageOverlayColour}, ${projectInstance.backgroundImageOverlayColour}), url(<cl:backgroundImageUrl project="${projectInstance}"/>);
        </g:if>
        <g:else>
            background-image: url(<cl:backgroundImageUrl project="${projectInstance}"/>);
        </g:else>
        }
    </cl:hasProjectBackgroundImage>
    </style>
</head>

<body class="digivol expedition-landing">

<cl:hasProjectBackgroundImage project="${projectInstance}">
    <g:set var="oldClass" value="light" />
    <g:set var="divClass" value="" />
</cl:hasProjectBackgroundImage>
<cl:hasNoProjectBackgroundImage project="${projectInstance}">
    <g:set var="oldClass" value="secondary" />
    <g:set var="divClass" value="old" />
</cl:hasNoProjectBackgroundImage>

<div class="a-feature expedition ${divClass}">
    <div class="container project-info-panel">
        <div class="row">
            <div class="col-sm-12">
                <div class="logo-holder">
                    <img src="<cl:institutionLogoUrl id="${projectInstance.institution?.id?:-1}"/>" class="img-fluid institution-logo-main" alt="${projectInstance.institution?.name ?: projectInstance.name}">
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-8">
                <h1>${projectInstance.name}</h1>
                <h2><g:if test="${projectInstance.archived}"> <small><span class="badge badge--archived"><g:message code="status.archived" /></span></small></g:if>
                    <g:if test="${projectInstance.inactive}"> <small><span class="badge badge--inactive"><g:message code="status.inactive" /></span></small></g:if></h2>
                <div id="projectDescription"> <!--class="hidden" -->
                    <p>${raw(projectInstance.description)}</p><!-- end description -->
%{--                    <a href="#" title="read more" class="readmore">Read more »</a>--}%
                </div>
                <div class="cta-primary">
                    <g:if test="${percentComplete < 100}">
                        <a href="${createLink(controller: 'transcribe', action: 'index', id: projectInstance.id)}" class="btn btn-primary btn-lg" role="button">Get Started <span class="fa fa-arrow-right"></span></a>
                        <g:if test="${projectInstance.tutorialLinks || projectInstance.tutorials.size() > 0}">
                            <a href="#tutorial" class="btn btn-lg btn-outline-secondary tutorial">Tutorial Information</a>
                            <div id="tutorialContent" class="d-none">
                                <g:if test="${projectInstance.tutorialLinks}">
                                <h4>Expedition Tutorial Information</h4>
                                <div id="tutorial-intro">
                                ${raw(projectInstance.tutorialLinks)}
                                </div>
                                </g:if>
                                <g:if test="${tutorialList}">
                                <h4 style="padding-top: 1rem;">Expedition Tutorial List</h4>
                                <div id="tutorialList">
                                    <table class="table table-striped">
                                        <g:each in="${tutorialList}" var="tutorial">
                                        <tr>
                                            <td><cl:tutorialLink tutorial="${tutorial}">${tutorial.name}</cl:tutorialLink></td>
                                        </tr>
                                        </g:each>
                                    </table>
                                </div>
                                </g:if>
                                <g:else>
                                    <h4>Expedition Tutorial List</h4>
                                    <div id="tutorial-intro">
                                        <p>No tutorial information available.</p>
                                        <p>You can find other tutorials for ${projectInstance.institution.name}
                                        <g:link controller="tutorials" action="groupList" params="${[institution: projectInstance.institution.id]}" target="_blank">here</g:link>.</p>
                                    </div>
                                </g:else>
                            </div>
                        </g:if>
                    </g:if>
                    <g:else>
                        <a class="btn btn-success btn-lg disabled" href="#" aria-disabled="true" role="button" tabindex="-1">Expedition complete <span class="fa fa-check"></span></a>
                        <a href="${g.createLink(controller:"project", action:"list", params: [tag: projectInstance.projectType.name?:'' ])}" class="btn btn-lg btn-outline-${oldClass}">See similar expeditions</a>
                    </g:else>

                </div>
                <a href="${createLink(controller: 'forum', action: 'index', params: [projectId: projectInstance.id])}" class="forum-link">Visit Expedition Forum »</a>
            </div>
            <div class="col-sm-4">
                <cl:hasNoProjectBackgroundImage project="${projectInstance}">
                    <cl:featuredImage project="${projectInstance}" alt="expedition icon" title="${projectInstance.name}" class="thumb-old img-fluid" />
                </cl:hasNoProjectBackgroundImage>
                <div class="projectActionLinks">
                    <cl:isLoggedIn>
                        <cl:ifInstitutionAdmin project="${projectInstance}">
                            <g:link class="btn btn-outline-secondary" controller="task" action="projectAdmin" id="${projectInstance.id}"><i class="fa fa-table"></i> Task Admin</g:link>
                            <g:link class="btn btn-outline-secondary" controller="project" action="edit" id="${projectInstance.id}"><i class="fa fa-cog"></i> Settings</g:link>
                        </cl:ifInstitutionAdmin>
                    </cl:isLoggedIn>
                    <cl:ifValidator project="${projectInstance}">
                        <g:link class="btn btn-secondary" controller="task" action="projectAdmin"
                                id="${projectInstance.id}">Validate tasks</g:link>
                    </cl:ifValidator>
                </div>
            </div>
        </div>

        <cl:hasProjectBackgroundImage project="${projectInstance}">
            <div class="row">
                <div class="col-sm-12 image-origin">
                    <p><g:if test="${projectInstance.backgroundImageAttribution}"><g:message code="image.attribution.prefix" /> ${projectInstance.backgroundImageAttribution}</g:if></p>
                </div>
            </div>
        </cl:hasProjectBackgroundImage>
    </div>

    <div class="progress-summary">
        <div class="container">
            <div class="row">
                <div class="col-12">
                    <g:render template="projectSummaryProgressBar" model="${[projectSummary: projectSummary, showLegend: false]}"/>
                </div>
            </div>

            <div class="row row-cols-1 row-cols-sm-2 row-cols-lg-4 g-3 project-stat-cards">
                <div class="col">
                    <div class="card project-stat-card h-100 text-center">
                        <div class="card-body">
                            <div class="project-stat-value">${transcriberCount}</div>
                            <div class="project-stat-label">Volunteers</div>
                        </div>
                    </div>
                </div>
                <div class="col">
                    <div class="card project-stat-card h-100 text-center">
                        <div class="card-body">
                            <div class="project-stat-value">${tasksTotal}</div>
                            <div class="project-stat-label">Tasks</div>
                        </div>
                    </div>
                </div>
                <div class="col">
                    <div class="card project-stat-card h-100 text-center">
                        <div class="card-body">
                            <div class="project-stat-value">${tasksDone}</div>
                            <div class="project-stat-label">Transcribed</div>
                        </div>
                    </div>
                </div>
                <div class="col">
                    <div class="card project-stat-card h-100 text-center">
                        <div class="card-body">
                            <div class="project-stat-value">${projectSummary?.validatedCount ?: 0}</div>
                            <div class="project-stat-label">Validated</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<g:if test="${projectInstance.showMap}">
    <section id="record-locations">
        <div class="container">
            <div class="row">
                <div class="col-sm-12 col-lg-4">
                    <div class="map-header">
                        <h2 class="heading">Record Locations</h2>
                        <p>On this map you'll find all the location of transcribed records of the ${projectInstance.name} expedition</p>
                    </div>
                </div>
            </div>
        </div>

        <div id="recordsMap"></div>
    </section>
</g:if>

<section id="main-content">
    <div class="container">
        <div class="row">
            <div class="col-xl-8">
                <div class="row">
                    <div class="col-sm-12">
                        <h2 class="heading">
                            Expedition Volunteers
                        </h2>
                    </div>
                </div>

                <g:if test="${roles.find{it.members?.size()}}">
                    <div class="expedition-team">
                        <div class="row g-4">
                            <g:each in="${roles}" status="i" var="role">
%{--                                <g:set var="roleIcon" value="${role.icons[0]}"/>--}%
%{--                                <div class="col-3 col-sm-2 roleIcon">--}%
%{--                                    <img src='<g:resource file="${roleIcon?.icon}"/>' width="100" height="99" class="img-fluid" title="${roleIcon?.name}" alt="${roleIcon?.name}">--}%
%{--                                </div>--}%
%{--                                <div class="col-9 col-sm-4 roleList">--}%
%{--                                    <h3>${role.name}</h3>--}%
%{--                                    <ul>--}%
%{--                                        <g:each in="${role.members}" var="member">--}%
%{--                                            <li><a href="${createLink(controller: 'user', action: 'show', id: member.id, params: [projectId: projectInstance.id])}">${member.name} (${member.count})</a>--}%
%{--                                            </li>--}%
%{--                                        </g:each>--}%
%{--                                    </ul>--}%
%{--                                </div>--}%

                                <g:set var="largeList" value="${role.members.size() > 7}"/>
                                <div class="col-lg-6">
                                    <div class="card h-100 shadow-sm border-0">
                                        <div class="card-header bg-role text-white d-flex align-items-center ${largeList ? 'justify-content-between' : ''} gap-2 py-3">
                                            <g:if test="${largeList}">
                                            <div class="d-flex align-items-center gap-2">
                                            </g:if>
                                            <g:if test="${i == 0}"><i class="fa fa-compass fs-5"></i></g:if>
                                            <g:elseif test="${i == 1}"><i class="fa fa-flask fs-5"></i></g:elseif>
                                            <g:elseif test="${i == 2}"><i class="fa fa-address-book fs-5"></i></g:elseif>
                                            <g:else><i class="fa fa-gear fs-5"></i></g:else>
                                            <h6 class="card-title mb-0 fw-bold">${role.name}</h6>
                                            <g:if test="${largeList}">
                                            </div>
                                            <span class="badge bg-light text-dark rounded-pill">${role.members.size()}</span>
                                            </g:if>
                                        </div>

                                    <g:if test="${!largeList}">
                                        <div class="card-body p-0">
                                            <ul class="list-group list-group-flush">
                                                <g:if test="${role.members.size() > 0}">
                                                <g:each in="${role.members}" var="member">
                                                    <li class="list-group-item d-flex justify-content-between align-items-center py-2">
                                                        <a href="#" class="text-decoration-none text-dark fw-medium">${member.name}</a>
                                                        <span class="badge bg-primary-subtle text-primary rounded-pill">${member.count}</span>
                                                    </li>
                                                </g:each>
                                                </g:if>
                                                <g:else>
                                                    <li class="list-group-item d-flex justify-content-between align-items-center py-2">
                                                        No volunteers in this role.
                                                    </li>
                                                </g:else>
                                            </ul>
                                        </div>
                                    </g:if>
                                    <g:else>
                                        <div class="card-body p-0 overflow-auto" style="max-height: 280px;">
                                            <ul class="list-group list-group-flush">
                                                <g:each in="${role.members}" var="member">
                                                <li class="list-group-item d-flex justify-content-between align-items-center py-2">
                                                    <a href="${createLink(controller: 'user', action: 'show', id: member.id, params: [projectId: projectInstance.id])}"
                                                       class="text-decoration-none text-dark fw-medium">${member.name}</a>
                                                    <span class="badge bg-primary-subtle text-primary rounded-pill">${member.count}</span>
                                                </li>
                                                </g:each>
                                            </ul>
                                        </div>
                                    </g:else>

                                    </div>
                                </div>



                            </g:each>
                        </div>
                    </div>
                </g:if>
                <g:else>
                    [ No transcriptions recorded ]
                </g:else>
            </div>

            <div class="col-xl-4">
                %{-- mini leaderboard --}%
                <g:render template="/leaderBoard/stats" model="[disableStats: true, disableHonourBoard: true, disableContribution: true, projectId: projectInstance.id, maxContributors: 2]"/>
            </div>
        </div>
    </div>
</section>
<asset:javascript src="markerclusterer.js" asset-defer=""/>
<script src="https://cdnjs.cloudflare.com/ajax/libs/cuttr/1.4.3/cuttr.min.js"></script>
<g:if test="${projectInstance.showMap}">
    <asset:script type="text/javascript">

        var map, infowindow;

        if (gmapsReady) {
          loadMap();
        } else {
          $(window).on('digivol.gmapsReady', function() {
            loadMap();
          });
        }

        function loadMap() {

            var mapElement = $("#recordsMap");

            if (!mapElement) {
                return;
            }

            var myOptions = {
                scaleControl: true,
                center: new google.maps.LatLng(${projectInstance.mapInitLatitude ?: -24.766785},${projectInstance.mapInitLongitude ?: 134.824219}), // defaults to centre of Australia
                zoom: ${projectInstance.mapInitZoomLevel ?: 3},
                minZoom: 1,
                streetViewControl: false,
                scrollwheel: false,
                mapTypeControl: true,
                mapTypeControlOptions: {
                    style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
                },
                navigationControl: true,
                navigationControlOptions: {
                    style: google.maps.NavigationControlStyle.SMALL // DEFAULT
                },
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            map = new google.maps.Map(document.getElementById("recordsMap"), myOptions);
            infowindow = new google.maps.InfoWindow();
            // load markers via JSON web service
            var tasksJsonUrl = "${createLink(controller: "project", action: 'tasksToMap', id: params.id)}";
            $.get(tasksJsonUrl, {}, drawMarkers);
        }

        function drawMarkers(data) {

            if (data) {
                //var bounds = new google.maps.LatLngBounds();
                var markers = [];
                $.each(data, function (i, task) {
                    var latlng = new google.maps.LatLng(task.lat, task.lng);
                    var marker = new google.maps.Marker({
                        position: latlng,
                        //map: map,
                        title: "record: " + (task.cat || task.filename),
                        icon: BVP_JS_URLS.singleMarkerPath
                    });
                    markers.push(marker);
                    google.maps.event.addListener(marker, 'click', function () {
                        infowindow.setContent("[loading...]");
                        // load info via AJAX call
                        load_content(marker, task.id);
                    });
                    //bounds.extend(latlng);
                }); // end each
                var markerCluster = new MarkerClusterer(map, markers, { maxZoom: 18, imagePath: BVP_JS_URLS.markersPath });

                //map.fitBounds(bounds);  // breaks with certain data so removing for now TODO: fix properly
            }
        }

        function load_content(marker, id) {
            $.ajax({

                url: "${createLink(controller: 'task', action: 'details')}/" + id,
                success: function (data) {
                    var content = "<div style='font-size:12px;line-height:1.3em;'>Task: " + data.id + "<br/>";
                <cl:ifValidator project="${projectInstance}">
                    content += "File: <a href=\"${createLink(controller: 'task', action: 'showDetails')}/" + id + "\" target=\"_blank\">" + data.filename + "</a><br/>";
                </cl:ifValidator>
                <cl:ifNotValidator project="${projectInstance}">
                    content += "File: " + data.filename + "<br/>";
                </cl:ifNotValidator>
                    content += "Transcribed by: " + data.transcriber + "</div>";
                    infowindow.close();
                    infowindow.setContent(content);
                    infowindow.open(map, marker);
                }
            });
        }

        function resizeMap() {
            var mapDiv = $("#recordsMap");
            if (mapDiv) {
                var newSize = $('#sidebarDiv').width() - 20;
                mapDiv.css("max-width", "" + newSize + "px")
                mapDiv.css("max-height", "" + newSize + "px")
                mapDiv.css("width", "" + newSize + "px")
                mapDiv.css("height", "" + newSize + "px")
            }
        }
    </asset:script>
</g:if>
<asset:script type="text/javascript">
$(document).ready(function () {

    $("#btnShowIconSelector").click(function(e) {
        e.preventDefault();
        showIconSelector();
    });

    /*
     * Truncate the project description text
     */
    new Cuttr('#projectDescription', {
        //options here
        truncate: 'words',
        length: 100,
        readMore: true,
        readMoreText: 'Read more',
        readLessText: 'Read less',
        readMoreBtnPosition: 'after',
        readMoreBtnAdditionalClasses: 'btn btn-sm btn-outline-secondary'
    });

    // Show tutorial modal if content is present
    $(".tutorial").click(function(e) {
        if ($(this).attr('href') == "#tutorial") {
            e.preventDefault();
            showTutorialModal();
        }

    });

    <g:if test="${showTutorial}">
        showTutorialModal();
    </g:if>
});

function showTutorialModal() {
    var content = $("#tutorialContent").html();
    bvp.showModal({
        id: 'tutorialModal',
        title: 'Getting started',
        message: content,
        size: 'large',
        backdrop: true
    });
}

function showIconSelector() {
    bvp.showModal({
        url: "${createLink(action: 'projectLeaderIconSelectorFragment', id: projectInstance.id)}",
        size: 'large',
        title: 'Select Expedition Leader Icon'
    });
}

</asset:script>
</body>
</html>