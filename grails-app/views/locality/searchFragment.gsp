<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <meta name="layout" content="transcribeTool"/>
</head>
<body>

  <style type="text/css">

  #localityMap {
    float:left;
    height: 250px;
    width: 250px;
    margin-right: 5px;
  }

    #localitySearchResults {
      overflow-y:auto;
      height: 250px
    }

  </style>

  <div id="toolContentHeader">
    <table>
      <tr>
        <td>
          Locality
        </td>
        <td>
          <input style="width:100%" type="text" id="localitySearch" value="${verbatimLocality}" />
        </td>
        <td>
          <a href="#" class="fieldHelp" title="If the initial search doesn’t find an existing locality try expanding abbreviations, inserting or removing spaces and commas or simplifying the locality description, eg by deleting the state. Example If &quot;Broome,  WA&quot; doesn’t get a result try &quot;Broome&quot; or &quot;Broome Western Australia&quot;. Only choose an existing location if you think it adequately represents the verbatim locality."><span class="help-container">&nbsp;</span></a>
        </td>
        <td style="vertical-align: middle; width: 150px; text-align: center">
          <span id="searchResultsStatus" />
          <td style="vertical-align: middle; width: 150px; text-align: center"><button class="toolSearchButton">Search</button>&nbsp;<button class="closeFancyBoxButton">Cancel</button></td>
        </td>
      </tr>
    </table>
    <hr/>
  </div>

  <div id="localityMap">

  </div>

  <div id="localitySearchResults">

  </div>

  <script type="text/javascript">

    if (toolOpts) {
      toolOpts.doSearch = function(e) {
        doLocalitySearch();
      }
    }

    function doLocalitySearch() {

      $('#localitySearchResults').html("<div>Searching...</div>")

      var searchTerm = $('#localitySearch').val();
      if (searchTerm == '') {
        alert("You must enter some part of the locality to search for!");
        return;
      }

      var queryParams = '&searchLocality=' + encodeURIComponent(searchTerm);

      var searchUrl = "${createLink(controller: 'locality', action:'searchResultsFragment', params: [taskId:taskInstance.id])}" + queryParams;
      $.ajax(searchUrl).done(function(data) {
          $("#localitySearchResults").html(data);
      });

    }

    var localityMap;

    $(document).ready(function(e) {

      localityMap = new GMaps({
        div: '#localityMap',
        lat: -34.397,
        lng: 150.644,
        zoom: 10
      });

      $('#localitySearch').keydown(function(e) {
        if (e.keyCode == 13) {
          doLocalitySearch();
        }
      });

      var searchTerm = $('#localitySearch').val();
      if (searchTerm != '') {
        doLocalitySearch();
      }

    // Context sensitive help popups
    $("a.fieldHelp").qtip({
        tip: true,
        position: {
            corner: {
                target: 'topMiddle',
                tooltip: 'bottomRight'
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
            tip: 'bottomRight',
            name: 'light' // Inherit the rest of the attributes from the preset light style
        }
    }).bind('click', function(e){ e.preventDefault(); return false; });

    });

  </script>
</body>
</html>