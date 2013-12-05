<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="au.org.ala.volunteer.FieldSyncService" %>
<g:set var="tasksDone" value="${tasksTranscribed ?: 0}"/>
<g:set var="tasksTotal" value="${taskCount ?: 0}"/>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Volunteer Portal - ${projectInstance.name ?: 'Atlas of Living Australia'}</title>
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>
    <script src="${resource(dir: 'js', file: 'markerclusterer.js')}" type="text/javascript"></script>

    <r:script>
        google.load('visualization', '1', {packages: ['gauge']});

        function loadChart() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Label');
            data.addColumn('number', 'Value');
            data.addRows(3);
            data.setValue(0, 0, '%');
            data.setValue(0, 1, <g:formatNumber number="${percentComplete}" format="#"/>);

            var chart = new google.visualization.Gauge(document.getElementById('recordsChartWidget'));
            var options = {width: 150, height: 150, minorTicks: 5, majorTicks: ["0%", "25%", "50%", "75%", "100%"]};
            chart.draw(data, options);
        }

        google.load("maps", "3.3", {other_params: "sensor=false"});
        var map, infowindow;

        function loadMap() {

            var mapElement = $("#recordsMap");

            if (!mapElement) {
                return;
            }

            var myOptions = {
                scaleControl: true,
                center: new google.maps.LatLng(-24.766785, 134.824219), // centre of Australia
                zoom: 3,
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
            var tasksJsonUrl = "${createLink(controller: "project", action:'tasksToMap', id: params.id)}";
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

                url: "${createLink(controller: 'task', action:'details')}/" + id + ".json",
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
            resizeMap();
            </g:if>

            $(window).resize(function(e) {
                resizeMap();
            });

            $("#btnShowIconSelector").click(function(e) {
                e.preventDefault();
                showIconSelector();
            });

        });

        function showIconSelector() {
            showModal({
                url: "${createLink(action:'projectLeaderIconSelectorFragment', id: projectInstance.id)}",
                width:800,
                height:500,
                title: 'Select Expedition Leader Icon'
            });
        }

    </r:script>

    <style type="text/css">

        .ui-widget-header {
            border: 1px solid #3A5C83;
            background: white url(${resource(dir:'images/vp',file:'progress_1x100b.png')}) 50% 50% repeat-x;
        }

        .ui-widget-content {
            border: 1px solid #3A5C83;
        }
        .projectContent {
            margin-top: 10px;
        }

        #recordsMap img {
            max-width: none;
            max-height: none;
        }

        #projectSideBar {
            position: relative;
            top: -1px;
            padding: 10px;
            background-color: #f0f0e8;
            border: 1px solid #d1d1d1;
            border-top: 1px solid #f0f0e8;
            border-bottom-left-radius: 5px;
            border-bottom-right-radius: 5px;
        }

        #buttonSection {
            text-align: center;
        }

        #page-header {
            margin-bottom: 0px;
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


    </style>
</head>

<body>

    <cl:headerContent title="Welcome to the ${projectInstance.name ?: 'Volunteer Portal'}" selectedNavItem="expeditions">
        <%
            pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'list'), label: message(code: 'default.expeditions.label', default: 'Expeditions')]
            ]
        %>

        <div>
            <cl:ifValidator project="${projectInstance}">
                <g:link style="margin-right: 5px" class="btn pull-right" controller="task" action="projectAdmin" id="${projectInstance.id}">Validate tasks</g:link>
            </cl:ifValidator>
            <cl:isLoggedIn>
                <cl:ifAdmin>
                    <g:link style="margin-right: 5px; color: white" class="btn btn-warning pull-right" controller="task" action="projectAdmin" id="${projectInstance.id}">Admin</g:link>&nbsp;
                    <g:link style="margin-right: 5px; color: white" class="btn btn-warning pull-right" controller="project" action="edit" id="${projectInstance.id}">Edit</g:link>&nbsp;
                </cl:ifAdmin>
            </cl:isLoggedIn>
        </div>
    </cl:headerContent>

    <div class="row" style="margin-top: 10px">

        <div class="span4" id="sidebarDiv">

            <div class="well well-small">
                <section id="projectSideBarxxx">

                    <section id="buttonSection">
                        <a href="${createLink(controller: 'transcribe', action: 'index', id: projectInstance.id)}" class="btn btn-large" id="transcribeButton">
                            Start transcribing <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_transcribe-orange.png" width="37" height="18" alt="">
                        </a>
                        <br>
                        <a href="${createLink(controller: 'tutorials', action: 'index')}" class="btn btn-small">
                            View tutorials <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_viewtutorials.png" width="18" height="18" alt="">
                        </a>
                        <a href="${createLink(controller: 'user', action: 'myStats', params: [projectId: projectInstance.id])}" class="btn btn-small">
                            My tasks <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_mytasks.png" width="12" height="18" alt="">
                        </a>
                        <br>
                        <g:if test="${au.org.ala.volunteer.FrontPage.instance().enableForum}">
                            <a style="margin-top: 8px;" href="${createLink(controller: 'forum', action: 'projectForum', params: [projectId: projectInstance.id])}" class="btn btn-small">
                                Visit the Project Forum&nbsp;<img src="${resource(dir: 'images', file: 'forum.png')}" width="18" height="18" alt="Forum">
                            </a>
                        </g:if>
                    </section>

                    <section class="padding-bottom">
                        <h4>${projectInstance.featuredLabel} progress</h4>

                        <div id="recordsChart">
                            <strong>${tasksDone}</strong> tasks of <strong>${taskCount}</strong> completed (<strong><g:formatNumber number="${percentComplete}" format="#"/>%</strong>)
                        </div>

                        <div id="recordsChartWidget1" class="ui-progressbar ui-widget ui-widget-content ui-corner-all" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="41">
                            <div class="ui-progressbar-value ui-widget-header ui-corner-left" style="width: ${formatNumber(format: "#", number: percentComplete)}%; "></div>
                        </div>
                    </section>

                    <g:if test="${projectInstance.showMap}">
                        <h3>Transcribed records</h3>
                        <div id="recordsMap" style="margin-bottom: 12px"></div>
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
                            <img src="${projectInstance.featuredImage}" alt="" title="${projectInstance.name}" />
                            <g:if test="${projectInstance.featuredImageCopyright}">
                                <div class="copyright-label">${projectInstance.featuredImageCopyright}</div>
                            </g:if>
                        </div>
                        <div class="span8">
                            ${projectInstance.description}
                        </div>
                    </div>

                    <g:if test="${!projectInstance.disableNewsItems && newsItem}">
                        <div>
                            <h3>${projectInstance.featuredLabel} news</h3>
                            <small>
                                <time datetime="${formatDate(format: "dd MMMM yyyy", date: newsItem.created)}"><g:formatDate format="dd MMMM yyyy" date="${newsItem.created}"/></time>
                            </small>
                            <h4 style="margin-top: 0px">
                                <a href="${createLink(controller: 'newsItem', action: 'list', id: projectInstance.id)}">${newsItem.title}</a>
                            </h4>
                            ${newsItem.body}
                            %{--<g:link controller="newsItem" action="list" id="${projectInstance.id}">All ${projectInstance.featuredLabel} news...</g:link>--}%
                        </div>
                    </g:if>
                </section>

                <section id="tutorial">
                    <g:if test="${projectInstance?.tutorialLinks}">
                        ${projectInstance.tutorialLinks}
                    </g:if>
                </section>

                <section id="personnel">
                    <h3>${projectInstance.featuredLabel} personnel</h3>
                    <div class="row">
                        <g:each in="${roles}" status="i" var="role">
                            <div class="span2">
                                <g:set var="iconIndex" value="${(((role.name == 'Expedition Leader') && projectInstance.leaderIconIndex) ? projectInstance.leaderIconIndex : 0)}" scope="page"/>
                                <g:set var="roleIcon" value="${role.icons[iconIndex]}"/>
                                <h4 style="text-align: center">
                                    <img src='<g:resource file="${roleIcon?.icon}"/>' width="100" height="99" title="${roleIcon?.name}" alt="${roleIcon?.name}">
                                    ${role.name}
                                    <g:if test="${role?.name == 'Expedition Leader'}">
                                        <g:if test="${leader?.userId == currentUserId}">
                                            <span style="">
                                                <button class="btn btn-small" id="btnShowIconSelector" href="#icon_selector" style="font-size: 0.8em; font-style: normal; font-weight: normal;">Change leader icon</button>
                                            </span>
                                        </g:if>
                                        <g:else>
                                            <span style="">
                                                <button class="btn btn-small" disabled="true" title="Only the expedition leader can choose the leader's icon" id="" href="" style="color: #808080; font-size: 0.8em; font-style: normal; font-weight: normal;">Change leader icon</button>
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