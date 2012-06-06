<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>

<style type="text/css">

  #search_header, #current_task_header {
    background: #3D464C;
    color: white;
  }

  #search_header h3, #current_task_header h3 {
    color: white;
    padding-bottom: 6px;
  }

  #search_header hr, #current_task_header hr {
    clear: both;
    height: 1px;
    width: auto;
    background-color: #D1D1D1;
    margin-bottom: 6px;
    border:none;
  }

  #search_results {
    overflow-y:auto;
    height: 250px
  }

  #collection_search_content table {
    width: 100%;
    margin-bottom: 0px;
  }

  #collection_search_content td {
    text-align: left;
    padding: 5px
  }

  #search_header td {
    padding-bottom: 0px;
    margin: 2px;
  }

  .even {
    background: #F0F0E8
  }

  #event_map {
    float:left;
    height: 250px;
    width: 250px;
    margin-right: 5px;
  }

</style>

<script type="text/javascript">

    function doSearch() {

        $('#search_results').html("<div>Searching...</div>")

        var queryParams = ""
        for (i = 0; i < 4; i++) {
            queryParams += "&collector" + i + "=" + encodeURIComponent($('#search_collector_' + i).val())
        }
        queryParams += '&eventDate=' + encodeURIComponent($('#search_event_date').val());

        var taskUrl = "${createLink(controller: 'collectionEvent', action:'searchResultsFragment', params: [taskId:taskInstance.id])}" + queryParams;

        console.log(taskUrl)

        $.ajax({url:taskUrl, success: function(data) {
            $("#search_results").html(data);
        }})

    }

    var event_map;

    $(document).ready(function(e) {
      event_map = new GMaps({
        div: '#event_map',
        lat: -34.397,
        lng: 150.644,
        zoom: 10
      });
    });

//
//    var latLng = new google.maps.LatLng(-34.397, 150.644);
//
//    var eventMapOptions = {
//        zoom: 10,
//        center: latLng,
//        scrollwheel: false,
//        scaleControl: true,
//        mapTypeId: google.maps.MapTypeId.ROADMAP
//    };
//
//    var eventmap = new google.maps.Map(document.getElementById("event_map"), eventMapOptions);

</script>

<div id="collection_search_content">
  <g:if test="${taskInstance}">
    <div id="current_task_header">
      <h3>Image from current task</h3>
      <hr/>
    </div>
    <div class="dialog" id="imagePane" >
      <g:each in="${taskInstance.multimedia}" var="m" status="i">
        <g:if test="${!m.mimeType || m.mimeType.startsWith('image/')}">
          <g:set var="imageUrl" value="${ConfigurationHolder.config.server.url}${m.filePath}"/>
          <div class="pageViewer" id="journalPageImg" style="height:240px">
              <div><img id="image_${i}" src="${imageUrl}" style="width:100%;"/></div>
          </div>
        </g:if>
      </g:each>
    </div>
    <div style="height: 6px"></div>
  </g:if>

  <div id="search_header">
    <table>
      <tr>
        <td>Collector(s)</td>
        <td>
          <g:each in="${collectors}" var="collector" status="i">
            <input id="search_collector_${i}" type="text" value="${collector}"></span>&nbsp;
          </g:each>
        </td>
        <td rowspan="2" style="vertical-align: middle">
          <button id="event_search_button">Search</button>
          <button id="close_event_popup_button">Cancel</button>
        </td>

      </tr>
    <tr>
      <td>
        Event date
      </td>
      <td>
        <input type="text" id="search_event_date" value="${eventDate}" />
      </td>
    </tr>
  </table>

    <hr/>
  </div>

  <div id="event_map">

  </div>

  <div id="search_results">
  </div>

  <script type="text/javascript">

    $("#close_event_popup_button").click(function(e) {
      $.fancybox.close();
    });

    $("#event_search_button").click(function(e) {
       doSearch();
    });

    $(":input").keydown(function (e) {
       if (e.keyCode == 13) {
         doSearch();
       }
    });

    doSearch();

  </script>
</div>