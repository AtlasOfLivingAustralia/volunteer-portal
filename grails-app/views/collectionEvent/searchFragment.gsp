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

  .collection_search_content td {
    text-align: left;
    padding: 5px
  }

  .collection_search_content td[colspan="2"] {
    border-bottom: none;
  }

  #search_header td {
    padding-bottom: 0px;
    margin: 2px;
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
        queryParams += '&search_locality=' + encodeURIComponent($('#search_locality').val());

        var taskUrl = "${createLink(controller: 'collectionEvent', action:'searchResultsFragment', params: [taskId:taskInstance.id])}" + queryParams;
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

</script>

<div id="collection_search_content" class="collection_search_content">
  <g:if test="${taskInstance}">
    <div id="current_task_header">
      <h3>Image from current task</h3>
      <hr/>
    </div>
    <div class="dialog" id="imagePane" >
      <g:each in="${taskInstance.multimedia}" var="m" status="i">
        <g:if test="${!m.mimeType || m.mimeType.startsWith('image/')}">
          <g:set var="imageUrl" value="${ConfigurationHolder.config.server.url}${m.filePath}"/>
            <a href="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_medium.$1')}" class="image_viewer" title="">
                <img src="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_small.$1')}" title="" style="height: 150px">
            </a>
            %{--<div class="pageViewer" id="journalPageImg" style="height:240px">--}%
              %{--<div><img id="image_${i}" src="${imageUrl}" style="width:100%;"/></div>--}%
          %{--</div>--}%
        </g:if>
      </g:each>
    </div>
    <div style="height: 6px"></div>
  </g:if>

  <div id="search_header">
    <table>
      <tr>
        <td><span>Collector(s)</span></td>

          <g:each in="${collectors}" var="collector" status="i">
              <td>
                <input style="width:100%" id="search_collector_${i}" type="text" value="${collector}"></span>
              </td>
          </g:each>
          <td style="vertical-align: middle; width: 150px; text-align: center"><button id="event_search_button">Search</button>&nbsp;<button id="close_event_popup_button">Cancel</button></td>
      </tr>
    <tr>
      <td>
        Event date
      </td>
      <td>
        <input style="width:100%" type="text" id="search_event_date" value="${eventDate}" />
      </td>
      <td style="text-align: right"><span>Locality</span></td>
      <td colspan="2"><g:textField name="search_locality" id="search_locality" style="width:100%"/></td>
      <td style="vertical-align: middle; width: 150px; text-align: center">
        <span id="search_results_status" />
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

    $(".collection_search_content :input").keydown(function (e) {
       if (e.keyCode == 13) {
         doSearch();
       }
    });

    doSearch();
    var zoom_options = {
        zoomType: 'drag',
        lens:true,
        preloadImages: true,
        alwaysOn:true,
        zoomWidth: 300,
        zoomHeight: 150,
        xOffset:90,
        yOffset:0,
        position:'left'
    };

    var imageWidth = $('.image_viewer').first().width();
    var zoomWidth = 500;
    if (imageWidth > 0) {
      zoomWidth = 800 - imageWidth;
    }

    var zopts = {
        zoomType: 'drag',
        zoomWidth: zoomWidth - 15,
        zoomHeight: 150,
        lens:true
    }
    $('.image_viewer').jqzoom(zopts);

  </script>
</div>