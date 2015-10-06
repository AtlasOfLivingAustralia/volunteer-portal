<!doctype html>
<html>
<head>
    <meta name="layout" content="projectSettingsLayout"/>
</head>

<body class="continer">

<style>
#recordsMap {
    width: 280px;
    height: 280px;
    max-height: 280px;
    max-width: 280px;
    margin: 0 0;
}

#recordsMap img {
    max-width: none !important;
    max-height: none !important;
}
</style>

<content tag="pageTitle">Map settings</content>

<content tag="adminButtonBar">
</content>

<g:set var="initZoom" value="${projectInstance.mapInitZoomLevel ?: 3}"/>
<g:set var="initLatitude" value="${projectInstance.mapInitLatitude ?: -27.76133033947936}"/>
<g:set var="initLongitude" value="${projectInstance.mapInitLongitude ?: 134.47265649999997}"/>

<g:form method="post" class="form-horizontal" name="updateForm" action="updateMapSettings">

    <g:hiddenField name="id" value="${projectInstance?.id}"/>
    <g:hiddenField name="version" value="${projectInstance?.version}"/>

    <div class="control-group">
        <label for="showMap" class="checkbox">
            Show the map on the expedition landing page&nbsp;<g:checkBox name="showMap"
                                                                         checked="${projectInstance.showMap}"/>
        </label>
    </div>

    <div id="mapPositionControls" class="control-group">

        <div class="alert">
            Position the map to how you would like it to appear on the project start page
        </div>

        <table style="width: 100%">
            <tr>
                <td width="280px">
                    <div id="recordsMap"></div>
                </td>
                <td>
                    <div class="control-group">
                        <label class="control-label" for="mapZoomLevel">Zoom</label>

                        <div class="controls">
                            <g:textField name="mapZoomLevel" value="${initZoom}"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="mapLatitude">Center Latitude:</label>

                        <div class="controls">
                            <g:textField name="mapLatitude" value="${initLatitude}"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="mapLongitude">Center Longitude:</label>

                        <div class="controls">
                            <g:textField name="mapLongitude" value="${initLongitude}"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <div class="controls">
                            <g:actionSubmit class="save btn btn-primary" action="updateMapSettings"
                                            value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                        </div>
                    </div>

                </td>
            </tr>
        </table>
    </div>

</g:form>

<script type='text/javascript' src='https://www.google.com/jsapi'></script>

<script type='text/javascript'>

    google.load("maps", "3.3", {other_params: "sensor=false"});

    var map, infowindow;
    var mapListenerActive = true;

    $(document).ready(function () {

        $('input:checkbox').bootstrapSwitch({
            size: "small",
            onText: "yes",
            offText: "no"
        });

        bvp.bindTooltips();
        bvp.suppressEnterSubmit();

        $('input:checkbox').on('switchChange.bootstrapSwitch', function (event, state) {
            $("#updateForm").submit();
        });

        $("#btnNext").click(function (e) {
            e.preventDefault();
            bvp.submitWithWebflowEvent($(this));
        });

        loadMap();
        updateMapDisplay();
    });

    function loadMap() {

        var mapElement = $("#recordsMap");

        if (!mapElement) {
            return;
        }

        var myOptions = {
            scaleControl: false,
            center: new google.maps.LatLng(${initLatitude}, ${initLongitude}),
            zoom: ${initZoom},
            minZoom: 1,
            streetViewControl: false,
            scrollwheel: true,
            mapTypeControl: false,
            navigationControl: true,
            navigationControlOptions: {
                style: google.maps.NavigationControlStyle.SMALL // DEFAULT
            },
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };

        map = new google.maps.Map(document.getElementById("recordsMap"), myOptions);

        google.maps.event.addListener(map, 'zoom_changed', function () {
            if (mapListenerActive) {
                updateFieldsFromMap();
            }
        });

        google.maps.event.addListener(map, 'center_changed', function () {
            if (mapListenerActive) {
                updateFieldsFromMap();
            }
        });
    }

    function updateFieldsFromMap() {
        var zoomLevel = map.getZoom();

        $("#mapZoomLevel").val(zoomLevel);

        var center = map.getCenter();
        $("#mapLatitude").val(center.lat());
        $("#mapLongitude").val(center.lng());
    }

    function updateMapDisplay() {
        if ($("#showMap").attr("checked")) {
            $("#mapPositionControls").css("opacity", "1");
        } else {
            $("#mapPositionControls").css("opacity", "0.2");
        }
    }

</script>
</body>
</html>
