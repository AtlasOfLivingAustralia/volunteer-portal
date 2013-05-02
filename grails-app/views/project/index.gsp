<%@ page contentType="text/html;charset=UTF-8"  %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="au.org.ala.volunteer.FieldSyncService" %>
<g:set var="tasksDone" value="${tasksTranscribed?:0}"/>
<g:set var="tasksTotal" value="${taskCount?:0}"/>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Volunteer Portal - ${projectInstance.name?:'Atlas of Living Australia'}</title>
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>
    <script src="${resource(dir:'js', file:'markerclusterer.js')}" type="text/javascript"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
    <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>

    <script type='text/javascript'>
        google.load('visualization', '1', {packages:['gauge']});

        function loadChart() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Label');
            data.addColumn('number', 'Value');
            data.addRows(3);
            data.setValue(0, 0, '%');
            data.setValue(0, 1, <g:formatNumber number="${percentComplete}" format="#"/>);

            var chart = new google.visualization.Gauge(document.getElementById('recordsChartWidget'));
            var options = {width: 150, height: 150, minorTicks: 5, majorTicks: ["0%","25%","50%","75%","100%"]};
            chart.draw(data, options);
        }

        google.load("maps", "3.3", {other_params:"sensor=false"});
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
            var tasksJsonUrl = "${resource(dir: "project/tasksToMap", file: params.id)}";
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
                        title:"record: " + task.cat
                    });
                    markers.push(marker);
                    google.maps.event.addListener(marker, 'click', function() {
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

        function load_content(marker, id){
            $.ajax({
                url: "${resource(dir: "task/details", file: '/')}" + id + ".json",
                success: function(data){
                    var content = "<div style='font-size:12px;line-height:1.3em;'>Catalogue No.: "+data.cat
                            +"<br/>Taxon: "+data.name+"<br/>Transcribed by: "+data.transcriber+"</div>";
                    infowindow.close();
                    infowindow.setContent(content);
                    infowindow.open(map, marker);
                }
            });
        }

        $(document).ready(function() {
            // load chart
            $("#recordsChartWidget").progressbar({ value: <g:formatNumber number="${percentComplete}" format="#"/> });
            <g:if test="${projectInstance.showMap}">
              //load map
              loadMap();
            </g:if>

            var opts = {
                titleShow: false,
                autoDimensions: false,
                width: 500
            }
            $('button#show_icon_selector').fancybox(opts);

        });

        showIconSelector = function() {
          $("#icon_selector").css("display", "block");
          return true
        }
    </script>

    <style type="text/css">

    .ui-widget-header {
      border: 1px solid #3A5C83;
      background: white url(${resource(dir:'images/vp',file:'progress_1x100b.png')}) 50% 50% repeat-x;
    }

    .ui-widget-content {
      border: 1px solid #3A5C83;
    }

    #recordsMap img {
      max-width: none;
      max-height: none;
    }


    </style>
</head>

<body class="sublevel sub-site volunteerportal">

  <header id="page-header">
    <div class="inner">
      <cl:messages />
      <nav id="breadcrumb">
        <ol>
          <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
          <li><a href="${createLink(controller: 'project', action:'list')}"><g:message code="default.projects.label"/></a></li>
          <li class="last">${projectInstance.featuredLabel?:'Volunteer Portal'}</li>
        </ol>
      </nav>
      <hgroup>
        <h1>Welcome to the ${projectInstance.name?:'Volunteer Portal'}</h1>
      </hgroup>
    </div>
  </header>


  <div class="inner">
    <div class="col-narrow margin-bottom-0">
      <section class="boxed attached">
        <section class="padding-bottom centertext">
          <a href="${createLink(controller: 'transcribe', action:'index', id: projectInstance.id)}" class="button orange fullwidth">Start transcribing <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_transcribe-orange.png" width="37" height="18" alt=""></a><br>
          <a href="${createLink(controller: 'tutorials', action:'index')}" class="button">View tutorials <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_viewtutorials.png" width="18" height="18" alt=""></a>
          <a href="${createLink(controller: 'user', action:'myStats', params: [projectId:projectInstance.id])}" class="button last">My tasks <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_mytasks.png" width="12" height="18" alt=""></a><br>
          <g:if test="${au.org.ala.volunteer.FrontPage.instance().enableForum}">
            <a style="margin-top: 8px;" href="${createLink(controller: 'forum', action:'projectForum', params: [projectId:projectInstance.id])}" class="button">Visit the Project Forum&nbsp;<img src="${resource(dir:'images', file:'forum.png')}" width="18" height="18" alt="Forum"></a>
          </g:if>
        </section>
        <section class="padding-bottom">
          <h2>${projectInstance.featuredLabel} progress</h2>
          <div id="recordsChart">
            <strong>${tasksDone}</strong> tasks of <strong>${taskCount}</strong> completed (<strong><g:formatNumber number="${percentComplete}" format="#"/>%</strong>)</div>
            <div id="recordsChartWidget1" class="ui-progressbar ui-widget ui-widget-content ui-corner-all" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="41">
              <div class="ui-progressbar-value ui-widget-header ui-corner-left" style="width: ${formatNumber(format:"#", number: percentComplete)}%; "></div>
            </div>
        </section>

        <g:if test="${projectInstance.showMap}">
          <h2>Transcribed records</h2>
          <div id="recordsMap" style="margin-bottom: 12px"></div>
          <p/>
        </g:if>

      </section>
    </div>

    <div class="col-wide last">
      <section class="no-padding">
        <section>
        <h2>${projectInstance.featuredLabel} overview</h2>
        <span class="alignleft size-full">
          <img src="${projectInstance.featuredImage}" alt="" title="${projectInstance.name}" width="200" height="124" />
          <g:if test="${projectInstance.featuredImageCopyright}">
            <div class="copyright-label">${projectInstance.featuredImageCopyright}</div>
          </g:if>
        </span>
          ${projectInstance.description}
        <g:if test="${!projectInstance.disableNewsItems && newsItem}">
          <h2>${projectInstance.featuredLabel} news</h2>
          <article class="margin-bottom-0">
            <time datetime="${formatDate(format: "dd MMMM yyyy", date: newsItem.created)}"><g:formatDate format="dd MMMM yyyy" date="${newsItem.created}" /></time>
            <br />
            <h3><a href="${createLink(controller: 'newsItem', action: 'list', id: projectInstance.id)}">${newsItem.title}</a></h3>
            ${newsItem.body}
            %{--<g:link controller="newsItem" action="list" id="${projectInstance.id}">All ${projectInstance.featuredLabel} news...</g:link>--}%
          </article>

        </g:if>
        </section>

        <section id="tutorial">
          <g:if test="${projectInstance?.tutorialLinks}">
            ${projectInstance.tutorialLinks}
          </g:if>
        </section>

        <section id="personnel">
          <h2>${projectInstance.featuredLabel} personnel</h2>
          <g:each in="${roles}" status="i" var="role">
            <section>
              <g:set var="iconIndex"  value="${(((role.name == 'Expedition Leader') && projectInstance.leaderIconIndex) ? projectInstance.leaderIconIndex : 0)}" scope="page"/>
              <g:set var="roleIcon" value="${role.icons[iconIndex]}" />
              <h3><img src='<g:resource file="${roleIcon?.icon}"/>' width="100" height="99" title="${roleIcon?.name}" alt="${roleIcon?.name}">
              ${role.name}
              <g:if test="${role?.name == 'Expedition Leader'}">
                  <g:if test="${leader?.userId == currentUserId}">
                    <span style="">
                        <button id="show_icon_selector" href="#icon_selector" style="font-size: 0.6em; font-style: normal; font-weight: normal;">Change leader icon</button>
                    </span>
                    <div style="display: none;">
                      <div id="icon_selector" >
                        <table>
                          <thead>
                            <tr>
                              <th colspan="2">
                                <h3>As expedition leader you have the privilege of selecting the icon for the expedition leader of the project</h3>
                              </th>
                            </tr>
                          </thead>
                          <g:each in="${role.icons}" var="icon" status="imgIndex">
                            <tr>
                                <td style="vertical-align: top;">
                                  <a href="${createLink(controller: 'project', action:'setLeaderIconIndex', id:projectInstance.id, params:[iconIndex: imgIndex])}">
                                    <img src='<g:resource file="${icon.icon}"/>' width="100" height="99" alt="">
                                  </a>
                                </td>
                                <td style="text-align: left">
                                  <b><a href="${createLink(controller: 'project', action:'setLeaderIconIndex', id:projectInstance.id, params:[iconIndex: imgIndex])}">${icon.name}</a></b><br />
                                  ${icon.bio}
                                </td>
                            </tr>
                          </g:each>
                        </table>
                      </div>
                    </div>
                  </g:if>
                  <g:else>
                    <span style="">
                      <button disabled="true" title="Only the expedition leader can choose the leader's icon" id="show_icon_selector" href="" style="color: #808080; font-size: 0.6em; font-style: normal; font-weight: normal;">Change leader icon</button>
                    </span>
                  </g:else>

              </g:if>

            </h3>

              <ol>
                <g:each in="${role.members}" var="member">
                  <li><a href="${createLink(controller: 'user', action:'show', id: member.id, params:[projectId:projectInstance.id])}">${member.name} (${member.count})</a>
                  </li>
                </g:each>
              </ol>
            </section>
          </g:each>
        </section>

        <cl:ifValidator project="${projectInstance}">
          <section id="validator">
            <button href="${createLink(controller: 'task', action:'projectAdmin', id:projectInstance.id)}">Validate tasks</button>
          </section>
        </cl:ifValidator>

      </section>
    </div>
    <cl:isLoggedIn>
      <cl:ifAdmin>
        <g:link controller="task" action="projectAdmin" id="${projectInstance.id}" style="color:#DDDDDD;">Admin</g:link>&nbsp;
        <g:link controller="project" action="edit" id="${projectInstance.id}" style="color:#DDDDDD;">Edit</g:link>
      </cl:ifAdmin>
    </cl:isLoggedIn>
</div>
</body>
</html>