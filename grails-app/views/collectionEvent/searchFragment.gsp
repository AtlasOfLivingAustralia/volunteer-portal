<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="transcribeTool"/>
</head>

<body>
<style type="text/css">

#search_results {
    overflow-y: auto;
    height: 224px
}

#event_map {
    float: left;
    height: 250px;
    width: 250px;
    margin-right: 5px;
}

#event_map img {
    max-width: none !important;
}

</style>

<div id="toolContentHeader">
    <div class="row-fluid">
        <div class="span2">
            Collector(s)
        </div>

        <g:each in="${collectors}" var="collector" status="i">
            <div class="span2">
                <input class="span12" id="search_collector_${i}" type="text" value="${collector}">
            </div>
        </g:each>

        <div class="span2">
            <button class="btn btn-small btn-primary span12" id="event_search_button">Search</button>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span2">
            Event date
        </div>

        <div class="span2">
            <input class="span12" type="text" id="search_event_date" value="${eventDate}"/>
        </div>

        <div class="span2">
            Locality
        </div>

        <div class="span3">
            <g:textField class="span12" name="search_locality" id="search_locality"/>
        </div>

        <div class="span3">
            <label class="checkbox" for="expandedSearch">
                <g:checkBox name="expandedSearch" checked="true" value="checked" id="expandedSearch"/>
                Use expanded search
            </label>

            <div style="text-align: center">
                <span class="text-success" id="search_results_status"></span>
            </div>
        </div>

    </div>
</div>

<div id="event_map">

</div>

<div id="search_results">
</div>

<script type="text/javascript">

    $("#event_search_button").click(function (e) {
        doSearch();
    });

    $(".collection_search_content :input").keydown(function (e) {
        if (e.keyCode == 13) {
            doSearch();
        }
    });

    function doSearch() {

        $('#search_results').html("<div>Searching...</div>")

        var queryParams = ""
        for (i = 0; i < 4; i++) {
            queryParams += "&collector" + i + "=" + encodeURIComponent($('#search_collector_' + i).val())
        }
        queryParams += '&eventDate=' + encodeURIComponent($('#search_event_date').val());
        queryParams += '&search_locality=' + encodeURIComponent($('#search_locality').val());
        queryParams += '&expandedSearch=' + $('#expandedSearch').is(':checked');

        var taskUrl = "${createLink(controller: 'collectionEvent', action: 'searchResultsFragment', params: [taskId: taskInstance.id])}" + queryParams;
        $.ajax({
            url: taskUrl, success: function (data) {
                $("#search_results").html(data);
            }
        })

    }

    var event_map;
    event_map = new GMaps({
        div: '#event_map',
        lat: -34.397,
        lng: 150.644,
        zoom: 10
    });

    doSearch();

    var target = $("#taskImage img");

    target.panZoom({
        pan_step: 10,
        zoom_step: 10,
        min_width: 100,
        min_height: 100,
        mousewheel: true,
        mousewheel_delta: 6
    });

</script>
</body>
</html>
