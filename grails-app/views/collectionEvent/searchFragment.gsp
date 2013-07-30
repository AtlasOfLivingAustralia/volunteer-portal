<style type="text/css">

#search_header, #current_task_header {
    background: #3D464C;
    padding-left: 10px;
    padding-right: 10px;
    color: white;
}

#search_header {
    padding-top: 10px;
}

#search_header h3, #current_task_header h3 {
    color: white;
    margin: 0;
}

#search_results {
    overflow-y: auto;
    height: 224px
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
    float: left;
    height: 250px;
    width: 250px;
    margin-right: 5px;
}

#taskImage {
    height: 200px;
    width: 670px;
}

#taskImage img {
    max-width: inherit !important;
}

#event_map img {
    max-width: none !important;
}

</style>

<div id="collection_search_content" class="collection_search_content">

    <g:if test="${taskInstance}">
        <div class="row-fluid">
            <div class="span12" id="current_task_header">
                <h3>Image from current task</h3>
            </div>
        </div>

        <div id="imagePane">
            <g:set var="mm" value="${taskInstance.multimedia?.first()}" />
            <div id="taskImageViewer" style="height: 200px; overflow: hidden">
                <g:imageViewer multimedia="${mm}" elementId="taskImage" hideControls="${true}"/>
            </div>
        </div>

    </g:if>

    <div id="search_header">
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
                <g:textField class="span12" name="search_locality" id="search_locality" />
            </div>
            <div class="span3">
                <label class="checkbox" for="expandedSearch">
                    <g:checkBox name="expandedSearch" checked="true" value="checked" id="expandedSearch" />
                    Use expanded search
                </label>
            </div>
        </div>
        %{--<div class="row-fluid">--}%
            %{--<div class="span10 offset2" class="form-horizontal">--}%
                %{--<div class="control-group">--}%
                    %{--<div class="controls">--}%
                        %{--<label class="checkbox" for="expandedSearch">--}%
                            %{--<g:checkBox name="expandedSearch" checked="true" value="checked" id="expandedSearch" />--}%
                            %{--Use expanded search--}%
                        %{--</label>--}%
                    %{--</div>--}%
                %{--</div>--}%
            %{--</div>--}%
        %{--</div>--}%
    </div>

    <div id="event_map">

    </div>

    <div id="search_results">
    </div>

    <script type="text/javascript">

        $("#close_event_popup_button").click(function (e) {
            // $.fancybox.close();
        });

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
            $.ajax({url:taskUrl, success: function(data) {
                $("#search_results").html(data);
            }})

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
            pan_step:10,
            zoom_step:10,
            min_width:100,
            min_height:100,
            mousewheel:true,
            mousewheel_delta:6
        });

    </script>
</div>