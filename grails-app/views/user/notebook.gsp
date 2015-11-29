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

    #mainTab dt, #mainTab dd {
        padding-bottom: 15px;
    }

    </style>
    <r:require modules="greyscale"/>
    <script type="application/javascript" src="https://www.google.com/jsapi"></script>
    <script type="application/javascript">
        google.load("visualization", "1", {packages: ["corechart"]});
    </script>
</head>

<body>
<cl:headerContent title="My Notebook" crumbLabel="${cl.displayNameForUserId(id: userInstance.userId)}"
                  selectedNavItem="userNotebook">
    <%
        pageScope.crumbs = [
        ]
    %>
</cl:headerContent>

<div class="row" id="content">
    <div class="span12">

        <div class="tabbable">

            <ul class="nav nav-tabs" style="margin-bottom: 0px">
                <li class="active"><a href="#mainTab" data-toggle="tab">My Achievements</a></li>
                <li><a href="#badgesTab" data-toggle="tab">Badges</a></li>
                %{--<li><a href="#stats" data-toggle="tab">Stats</a></li>--}%
                <li><a href="#mapTab" data-toggle="tab">Maps</a></li>
                <li><a href="#socialTab" data-toggle="tab">Social</a></li>
                <li><a href="#transcribedTab" data-toggle="tab">Tasks Transcribed</a></li>
                <li><a href="#savedTab" data-toggle="tab">Saved Tasks</a></li>
                <cl:ifValidator><li><a href="#validatedTab" data-toggle="tab">Tasks Validated</a></li></cl:ifValidator>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="mainTab">
                </div>

                <div class="tab-pane" id="badgesTab">
                </div>

                <div class="tab-pane" id="statsTab">
                </div>

                <div class="tab-pane" id="mapTab">
                    <div id="localityMap"></div>
                </div>

                <div class="tab-pane" id="socialTab">
                </div>

                <div class="tab-pane" id="transcribedTab">
                </div>

                <div class="tab-pane" id="savedTab">
                </div>

                <div class="tab-pane" id="validatedTab">
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

       function getTimezoneName() {
            var timezone = jstz.determine();
            return timezone.name();
        }

    $(document).ready(function () {

        $('a[data-toggle="tab"]').on('shown', function (e) {
            var tabHref = $(this).attr('href');
            if (tabHref == "#mainTab") {
                loadMainTab();
            } else if (tabHref == "#mapTab") {
                loadMap();
            } else if (tabHref == "#badgesTab") {
                $.ajax("${createLink(controller: 'user', action: 'badgesFragment', id: userInstance.id)}").done(function(content) {
                    $("#badgesTab").html(content);
                });
            } else if (tabHref == "#socialTab") {
                $.ajax("${createLink(controller: 'user', action: 'socialFragment', id: userInstance.id)}").done(function(content) {
                    $("#socialTab").html(content);
                });
            } else if (tabHref == "#transcribedTab") {
                $.ajax("${createLink(controller: 'user', action: 'transcribedTasksFragment', id: userInstance.id)}").done(function(content) {
                    $("#transcribedTab").html(content);
                });
            } else if (tabHref == "#savedTab") {
                $.ajax("${createLink(controller: 'user', action: 'savedTasksFragment', id: userInstance.id)}").done(function(content) {
                    $("#savedTab").html(content);
                });
            } else if (tabHref == "#validatedTab") {
                $.ajax("${createLink(controller: 'user', action: 'validatedTasksFragment', id: userInstance.id)}").done(function(content) {
                    $("#validatedTab").html(content);
                });
            }
        });

        loadMainTab();

      $('body').click('a[data-switch-tab]', function(e) {
        var jTarget = $(e.target);
        var cA = jTarget.closest('a');
        var tab = cA.attr("data-switch-tab");
        $('a[href="#'+tab+'"]').tab('show');
      });
    });

    function loadMainTab() {
        $.ajax("${createLink(controller: 'user', action: 'notebookMainFragment', id: userInstance.id)}").done(function(content) {
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
        var tasksJsonUrl = "${createLink(controller: "user", action: 'ajaxGetPoints', id: userInstance.id)}";
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
            $.ajax("${createLink(controller: 'task', action: 'details')}/" + id).done(function(data) {
                var content = "<div
        style='font-size:12px;line-height:1.3em;'>Catalogue No.: " + data.cat + "<br/>Taxon: " + data.name + "<br/>Transcribed by: " + data.transcriber + "
</div>";
                infowindow.close();
                infowindow.setContent(content);
                infowindow.open(map, marker);
            });

        }


    }

</r:script>
