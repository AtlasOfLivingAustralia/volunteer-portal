<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>My Field Notebook</title>
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>
    <script src="${resource(dir: 'js', file: 'markerclusterer.js')}" type="text/javascript"></script>

    <style type="text/css">

        #localityMap {
            /*float: left;*/
            height: 400px;
            width: 100%;
            margin-right: 5px;
        }

        #localityMap img {
            max-width: none !important;
        }

    </style>

</head>

<body>
    <cl:headerContent title="My Field Notebook" crumbLabel="${userInstance.displayName}" selectedNavItem="userDashboard">
        <%
            pageScope.crumbs = [
            ]
        %>
    </cl:headerContent>

    <div class="row" id="content">
        <div class="span12">

            <div class="tabbable">

                <ul class="nav nav-tabs" style="margin-bottom: 0px">
                    <li class="active"><a href="#mainTab" data-toggle="tab">Dashboard</a></li>
                    <li><a href="#mapTab" data-toggle="tab">Maps</a></li>
                    <li><a href="#badgesTab" data-toggle="tab">Badges</a></li>
                    <li><a href="#socialTab" data-toggle="tab">Social</a></li>
                </ul>

                <div class="tab-content">
                    <div class="tab-pane active" id="mainTab">
                    </div>
                    <div class="tab-pane" id="mapTab">
                        <div id="localityMap"></div>
                    </div>
                    <div class="tab-pane" id="badgesTab">
                    </div>
                    <div class="tab-pane" id="socialTab">
                    </div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>

<r:script>

    var map, infowindow;
    google.load("maps", "3.3", {other_params: "sensor=false"});

    $(document).ready(function () {
        $('a[data-toggle="tab"]').on('shown', function (e) {
            var tabHref = $(this).attr('href');
            if (tabHref == "#mainTab") {
                loadMainTab();
            } else if (tabHref == "#mapTab") {
                loadMap();
            } else if (tabHref == "#badgesTab") {
                $.ajax("${createLink(controller:'user', action:'badgesFragment', id: userInstance.id)}").done(function(content) {
                    $("#badgesTab").html(content);
                });
            } else if (tabHref == "#socialTab") {
            }
        });

        loadMainTab();

    });

    function loadMainTab() {
        $.ajax("${createLink(controller:'user', action:'dashboardMainFragment', id: userInstance.id)}").done(function(content) {
            $("#mainTab").html(content);
        });
    }

    function loadMap() {

        var mapElement = $("#localityMap");

        if (!mapElement) {
            return;
        }

        var myOptions = {
            scaleControl: true,
            center: new google.maps.LatLng(-24.766785, 134.824219), // centre of Australia
            zoom: 3,
            minZoom: 1,
            streetViewControl: false,
            scrollwheel: true,
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

        map = new google.maps.Map(document.getElementById("localityMap"), myOptions);

        infowindow = new google.maps.InfoWindow();
        // load markers via JSON web service
        var tasksJsonUrl = "${createLink(controller: "user", action:'ajaxGetPoints', id:userInstance.id)}";
        $.get(tasksJsonUrl, {}, drawMarkers);

    }

    function drawMarkers(data) {

        if (data) {
            var markers = [];
            $.each(data, function (i, task) {
                var latlng = new google.maps.LatLng(task.lat, task.lng);
                var marker = new google.maps.Marker({
                    position: latlng,
                    map: map,
                    title: "record: " + task.taskId,
                    animation: google.maps.Animation.DROP
                });
                markers.push(marker);
                google.maps.event.addListener(marker, 'click', function () {
                    infowindow.setContent("[loading...]");
                    // load info via AJAX call
                    load_content(marker, task.taskId);
                });
            }); // end each
            var markerCluster = new MarkerClusterer(map, markers, { maxZoom: 18 });
        }

        function load_content(marker, id) {
            $.ajax("${createLink(controller: 'task', action:'details')}/" + id + ".json").done(function(data) {
                var content = "<div style='font-size:12px;line-height:1.3em;'>Catalogue No.: " + data.cat + "<br/>Taxon: " + data.name + "<br/>Transcribed by: " + data.transcriber + "</div>";
                infowindow.close();
                infowindow.setContent(content);
                infowindow.open(map, marker);
            });

        }


    }


</r:script>
