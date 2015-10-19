<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="au.org.ala.volunteer.FieldSyncService" %>
<g:set var="tasksDone" value="${tasksTranscribed ?: 0}"/>
<g:set var="tasksTotal" value="${taskCount ?: 0}"/>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-expedition"/>
    <title><g:message code="default.application.name"/> - ${projectInstance.name ?: 'Atlas of Living Australia'}</title>
    <content tag="primaryColour">${projectInstance.institution?.themeColour}</content>
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>
    <script src="${resource(dir: 'js', file: 'markerclusterer.js')}" type="text/javascript"></script>
    <r:require modules="dotdotdot, bootbox"/>

    <r:script>

        google.load("maps", "3.3", {other_params: "sensor=false"});
        var map, infowindow;

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
                        title: "record: " + task.cat
                    });
                    markers.push(marker);
                    google.maps.event.addListener(marker, 'click', function () {
                        infowindow.setContent("[loading...]");
                        // load info via AJAX call
                        load_content(marker, task.id);
                    });
                    //bounds.extend(latlng);
                }); // end each
                var markerCluster = new MarkerClusterer(map, markers, { maxZoom: 18 });

                //map.fitBounds(bounds);  // breaks with certain data so removing for now TODO: fix properly
            }
        }

        function load_content(marker, id) {
            $.ajax({

                url: "${createLink(controller: 'task', action: 'details')}/" + id,
                success: function (data) {
                    var content = "<div style='font-size:12px;line-height:1.3em;'>Catalogue No.: " + data.cat + "<br/>Taxon: " + data.name + "<br/>Transcribed by: " + data.transcriber + "</div>";
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

        $(document).ready(function () {
            <g:if test="${projectInstance.showMap}">
                loadMap();
                //resizeMap();

                $(window).resize(function(e) {
                    //resizeMap();
                });
            </g:if>

            $("#btnShowIconSelector").click(function(e) {
                e.preventDefault();
                showIconSelector();
            });

            /*
             * Truncate the project description text
             */
            var descriptionDiv = "#projectDescription";
            $(descriptionDiv).removeClass("hidden"); // prevent content jumping
            $(descriptionDiv).dotdotdot({
                after: "a.readmore",
                height: 200
            });
            // read more link to show full description
            $("a.readmore").click(function(e) {
                e.preventDefault();
                var content = $(descriptionDiv).triggerHandler("originalContent");
                $(descriptionDiv).trigger("destroy");
                $(descriptionDiv).html( content );
                $(descriptionDiv + " a.readmore").addClass('hidden');
            });

            // Show tutorial modal if content is present
            $(".tutorial").click(function(e) {
                if ($(this).attr('href') == "#tutorial") {
                    e.preventDefault();
                    var content = $("#tutorialContent").html();
                    bootbox.alert(content);
                }

            });
        });

        function showIconSelector() {
            bvp.showModal({
                url: "${createLink(action: 'projectLeaderIconSelectorFragment', id: projectInstance.id)}",
                    width:800,
                    height:500,
                    title: 'Select Expedition Leader Icon'
            });
        }

    </r:script>

    <style type="text/css">

    .projectContent {
        margin-top: 10px;
    }

    #recordsMap img {
        max-width: none;
        max-height: none;
    }

    #buttonSection {
        text-align: center;
    }

    #transcribeButton {
        margin-bottom: 5px;
        background: #df4a21;
        color: white;
    }

    .copyright-label {
        font-style: italic;
        text-align: center;
        font-size: 0.9em;
    }

    <g:if test="${projectInstance.institution}">
        <cl:ifInstitutionHasBanner institution="${projectInstance.institution}">
            #page-header {
                background-image: url(<cl:institutionBannerUrl id="${projectInstance.institution.id}" />);
            }
        </cl:ifInstitutionHasBanner>
    </g:if>

    </style>
</head>

<body class="digivol expedition-landing">

<div class="a-feature expedition old">
    <div class="container">
        <div class="row">

            <div class="col-sm-12">
                <div class="logo-holder">
                    <img src="<cl:institutionLogoUrl id="${projectInstance.institution?.id}"/>" class="img-responsive institution-logo-main">
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-8">
                <h1>${projectInstance.name}</h1>
                <div id="projectDescription" class="hidden">
                    <p>${raw(projectInstance.description)}</p><!-- end description -->
                    <a href="#" title="read more" class="readmore">Read more »</a>
                </div>
                <div class="cta-primary">
                    <g:if test="${!projectInstance.inactive}">
                        <a href="${createLink(controller: 'transcribe', action: 'index', id: projectInstance.id)}" class="btn btn-primary btn-lg" role="button">Get Started <span class="glyphicon glyphicon-arrow-right"></span></a>
                        <g:if test="${projectInstance.tutorialLinks}">
                            <a href="${(projectInstance.tutorialLinks ? '#tutorial' : createLink(controller: 'tutorials', action: 'index'))}" class="btn btn-lg btn-hollow grey tutorial">View tutorial</a>
                            <div id="tutorialContent" class="hidden">${raw(projectInstance.tutorialLinks)}</div>
                        </g:if>
                        <g:else>
                            <a href="${createLink(controller: 'tutorials', action: 'index')}" class="btn btn-lg btn-hollow grey tutorial">View tutorial</a>
                        </g:else>
                    </g:if>
                    <g:else>
                        <a class="btn btn-primary btn-lg btn-complete" disabled="disabled" href="#" role="button">Expedition complete <span class="glyphicon glyphicon-ok"></span></a>
                        <a href="#similarExpeditions" class="btn btn-lg btn-hollow grey">See similar expeditions</a>
                    </g:else>
                </div>
                <a href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectInstance.id])}" class="forum-link">Visit Project Forum »</a>
            </div>
            <div class="col-sm-4">
                <img src="${projectInstance.featuredImage}" alt="expedition icon" title="${projectInstance.name}" class="thumb-old img-responsive">
                <div style="margin-top: 20px;">
                    <cl:ifValidator project="${projectInstance}">
                        <g:link style="margin-right: 5px" class="btn pull-right" controller="task" action="projectAdmin"
                                id="${projectInstance.id}">Validate tasks</g:link>
                    </cl:ifValidator>
                    <cl:isLoggedIn>
                        <cl:ifAdmin>
                            <g:link style="margin-right: 5px; color: white" class="btn btn-warning pull-right" controller="task"
                                    action="projectAdmin" id="${projectInstance.id}">Admin</g:link>&nbsp;
                            <g:link style="margin-right: 5px; color: white" class="btn btn-warning pull-right" controller="project"
                                    action="edit" id="${projectInstance.id}"><i
                                    class="icon-cog icon-white"></i> Settings</g:link>&nbsp;
                        </cl:ifAdmin>
                    </cl:isLoggedIn>
                </div>
            </div>

        </div>
    </div>

    <div class="progress-summary">
        <div class="container">
            <div class="row">
                <div class="col-sm-6">
                    <g:render template="../project/projectSummaryProgressBar" model="${[projectSummary: projectSummary]}"/>
                </div>

                <div class="col-sm-3 col-xs-6">
                    <h3><b>${transcriberCount}</b>Volunteers</h3>
                </div>

                <div class="col-sm-3 col-xs-6">
                    <h3><b>${projectInstance.tasks?.size()}</b>Tasks</h3>
                </div>
            </div>
        </div>
    </div>

</div>
<g:if test="${projectInstance.showMap}">
    <section id="record-locations">
        <div class="container">
            <div class="row">
                <div class="col-sm-4">
                    <div class="map-header">
                        <h2 class="heading">Record Locations</h2>
                        <p>On this map you'll find all the location of transcribed records of the Gastropod expedition</p>
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
            <div class="col-sm-8">

                <div class="row">
                    <div class="col-sm-12">
                        <h2 class="heading">
                            Expedition Citizen Scientists
                        </h2>
                    </div>
                </div>


                <div class="expedition-team">

                    <div class="row">
                        <div class="col-xs-3 col-sm-2">
                            <img src="img/team/teamExpeditionLeader.png" class="img-responsive">
                        </div>
                        <div class="col-xs-9 col-sm-4">
                            <h3>Expedition Leaders</h3>
                            <ul>
                                <li><a href="#">John Smithy (65)</a></li>
                                <li><a href="#">Peter Singer (65)</a></li>
                                <li><a href="#">John Smithy (65)</a></li>
                                <li><a href="#">Peter Singer (65)</a></li>
                            </ul>
                        </div>

                        <div class="col-xs-3 col-sm-2">
                            <img src="img/team/teamScientist.png" class="img-responsive">
                        </div>
                        <div class="col-xs-9 col-sm-4">
                            <h3>Scientists</h3>
                            <ul>
                                <li><a href="#">John Smithy (65)</a></li>
                                <li><a href="#">Peter Singer (65)</a></li>
                            </ul>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-xs-3 col-sm-2">
                            <img src="img/team/teamTechnicalOfficer.png" class="img-responsive">
                        </div>
                        <div class="col-xs-9 col-sm-4">
                            <h3>Technical Officers</h3>
                            <ul>
                                <li><a href="#">John Smithy (65)</a></li>
                                <li><a href="#">Peter Singer (65)</a></li>
                            </ul>
                        </div>

                        <div class="col-xs-3 col-sm-2">
                            <img src="img/team/teamCollectionsManager.png" class="img-responsive">
                        </div>
                        <div class="col-xs-9 col-sm-4">
                            <h3>Collection Managers</h3>
                            <ul>
                                <li><a href="#">John Smithy (65)</a></li>
                                <li><a href="#">Peter Singer (65)</a></li>
                                <li><a href="#">John Smithy (65)</a></li>
                                <li><a href="#">Peter Singer (65)</a></li>
                            </ul>
                        </div>
                    </div><!--/row-->
                </div>


            </div>

            <div class="col-sm-4">
                <h2 class="heading">
                    Latest Contributions
                </h2>
                <ul class="media-list">

                    <li class="media">
                        <div class="media-left">
                            <a href="#">
                                <img src="https://randomuser.me/api/portraits/med/men/51.jpg" class="img-circle img-responsive">
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

                </ul>

            </div>
        </div>
    </div>
</section>


<div class="row hidden" style="margin-top: 10px">

    <div class="span4" id="sidebarDiv">

        <div class="well well-small">
            <section>

                <section id="buttonSection">
                    <a href="${createLink(controller: 'transcribe', action: 'index', id: projectInstance.id)}"
                       class="btn btn-large" id="transcribeButton">
                        Start transcribing <img
                            src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_transcribe-orange.png"
                            width="37" height="18" alt="">
                    </a>
                    <br>
                    <a href="${createLink(controller: 'tutorials', action: 'index')}" class="btn btn-small">
                        View tutorials <img
                            src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_viewtutorials.png"
                            width="18" height="18" alt="">
                    </a>
                    <a href="${createLink(controller: 'user', action: 'myStats', params: [projectId: projectInstance.id])}"
                       class="btn btn-small">
                        My tasks <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_mytasks.png"
                                      width="12" height="18" alt="">
                    </a>
                    <br>
                    <g:if test="${au.org.ala.volunteer.FrontPage.instance().enableForum}">
                        <a style="margin-top: 8px;"
                           href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectInstance.id])}"
                           class="btn btn-small">
                            Visit the Project Forum&nbsp;<img src="${resource(dir: 'images', file: 'forum.png')}"
                                                              width="18" height="18" alt="Forum">
                        </a>
                    </g:if>
                </section>

                <section class="padding-bottom">
                    <h4>${projectInstance.featuredLabel} progress</h4>
                    <g:render template="../project/projectSummaryProgressBar" model="${[projectSummary: projectSummary]}"/>
                    %{--<div id="recordsChart">--}%
                    %{--<strong>${tasksDone}</strong> tasks of <strong>${taskCount}</strong> completed (<strong><g:formatNumber number="${percentComplete}" format="#"/>%</strong>)--}%
                    %{--</div>--}%
                    %{--<div class="progress expedition-progress">--}%
                    %{--<div class="bar bar-success" style="width: ${projectSummary.percentValidated}%"></div>--}%
                    %{--<div class="bar bar-warning" style="width: ${projectSummary.percentTranscribed - projectSummary.percentValidated}%"></div>--}%
                    %{--</div>--}%
                </section>

                <g:if test="${projectInstance.showMap}">
                    <h3>Transcribed records</h3>

                    <div id="recordsMapX" style="margin-bottom: 12px"></div>
                </g:if>
            </section>
        </div>
    </div>

    <div class="span8">
        <section class="projectContent">
            <section>
                <h2>${projectInstance.featuredLabel} overview</h2>

                <div class="row-fluid">
                    <div class="span4">
                        <img src="${projectInstance.featuredImage}" alt="" title="${projectInstance.name}"/>
                        <g:if test="${projectInstance.featuredImageCopyright}">
                            <div class="copyright-label">${projectInstance.featuredImageCopyright}</div>
                        </g:if>
                    </div>

                    <div class="span8">
                        ${projectInstance.description}
                    </div>
                </div>


                <g:if test="${projectInstance?.tutorialLinks}">
                    <div class="tutorialLinks alert" style="margin-top: 10px">
                        ${projectInstance.tutorialLinks}
                    </div>
                </g:if>

                <g:if test="${!projectInstance.disableNewsItems && newsItem}">
                    <div class="" style="margin-top: 10px">
                        <legend>
                            Expedition news
                            <small class="pull-right">
                                <g:formatDate format="MMM d, yyyy" date="${newsItem.created}"/>
                                %{--<time datetime="${formatDate(format: "dd MMMM yyyy", date: newsItem.created)}"></time>--}%
                            </small>

                        </legend>
                        <h4 style="margin-top: 0px">
                            <a href="${createLink(controller: 'newsItem', action: 'list', id: projectInstance.id)}">${newsItem.title}</a>
                        </h4>

                        <div>
                            ${newsItem.body}
                        </div>
                        <g:if test="${newsItems?.size() > 1}">
                            <small>
                                <g:link controller="newsItem" action="list"
                                        id="${projectInstance.id}">Read older news...</g:link>
                            </small>
                        </g:if>
                    </div>
                </g:if>
            </section>

            <section id="personnel">
                <h3>${projectInstance.featuredLabel} personnel</h3>

                <div class="row">
                    <g:each in="${roles}" status="i" var="role">
                        <div class="span2" style="text-align: center">
                            <g:set var="iconIndex"
                                   value="${(((role.name == 'Expedition Leader') && projectInstance.leaderIconIndex) ? projectInstance.leaderIconIndex : 0)}"
                                   scope="page"/>
                            <g:set var="roleIcon" value="${role.icons[iconIndex]}"/>
                            <img src='<g:resource file="${roleIcon?.icon}"/>' width="100" height="99"
                                 title="${roleIcon?.name}" alt="${roleIcon?.name}">
                            <h4 style="text-align: center">
                                ${role.name}
                                <g:if test="${role?.name == 'Expedition Leader'}">
                                    <g:if test="${leader?.userId == currentUserId}">
                                        <span style="">
                                            <button class="btn btn-small" id="btnShowIconSelector" href="#icon_selector"
                                                    style="font-size: 0.8em; font-style: normal; font-weight: normal;">Change leader icon</button>
                                        </span>
                                    </g:if>
                                    <g:else>
                                        <span style="">
                                            <button class="btn btn-small" disabled="true"
                                                    title="Only the expedition leader can choose the leader's icon"
                                                    id="" href=""
                                                    style="color: #808080; font-size: 0.8em; font-style: normal; font-weight: normal;">Change leader icon</button>
                                        </span>
                                    </g:else>
                                </g:if>
                            </h4>

                            <ol style="margin-left: 40px">
                                <g:each in="${role.members}" var="member">
                                    <li><a href="${createLink(controller: 'user', action: 'show', id: member.id, params: [projectId: projectInstance.id])}">${member.name} (${member.count})</a>
                                    </li>
                                </g:each>
                            </ol>
                        </div>
                    </g:each>
                </div>
            </section>
        </section>
    </div>
</div>
</body>
</html>