<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title>Create a new Expedition - Map Options</title>

        <script type='text/javascript' src='https://www.google.com/jsapi'></script>

        <g:set var="initZoom" value="${project.mapInitZoomLevel ?: 3}" />
        <g:set var="initLatitude" value="${project.mapInitLatitude ?: -27.76133033947936}" />
        <g:set var="initLongitude" value="${project.mapInitLongitude ?: 134.47265649999997}" />

        <r:script type="text/javascript">

            google.load("maps", "3.3", {other_params: "sensor=false"});

            var map, infowindow;
            var mapListenerActive = true;

            $(document).ready(function() {

                bvp.bindTooltips();
                bvp.suppressEnterSubmit();

                $("#showMap").change(function(e) {
                    updateMapDisplay();
                });

                $("#btnNext").click(function(e) {
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

                google.maps.event.addListener(map, 'zoom_changed', function() {
                    if (mapListenerActive) {
                        updateFieldsFromMap();
                    }
                });

                google.maps.event.addListener(map, 'center_changed', function() {
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

        </r:script>

        <style type="text/css">

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

    </head>
    <body>

        <cl:headerContent title="Create a new Expedition - Map Options" selectedNavItem="expeditions">
            <% pageScope.crumbs = [] %>
        </cl:headerContent>

        <div class="well well-small">
            <g:form>
                <div class="form-horizontal">

                    <div class="control-group">
                        <div class="controls">
                            <label for="showMap" class="checkbox">
                                <g:checkBox name="showMap" checked="${project.showMap}"/>&nbsp;Show the map on the expedition landing page
                            </label>
                        </div>
                    </div>

                    <div id="mapPositionControls" class="control-group" style="opacity: 0.2">

                        <div class="controls">
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
                                                <g:textField name="mapZoomLevel" value="${initZoom}" />
                                            </div>
                                        </div>

                                        <div class="control-group">
                                            <label class="control-label" for="mapLatitude">Center Latitude:</label>
                                            <div class="controls">
                                                <g:textField name="mapLatitude"  value="${initLatitude}" />
                                            </div>
                                        </div>

                                        <div class="control-group">
                                            <label class="control-label" for="mapLongitude">Center Longitude:</label>
                                            <div class="controls">
                                                <g:textField name="mapLongitude"  value="${initLongitude}" />
                                            </div>
                                        </div>

                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div class="control-group" style="margin-top: 10px">
                        <div class="controls">
                            <g:link class="btn" event="cancel">Cancel</g:link>
                            <g:link class="btn" event="back"><i class="icon-chevron-left"></i>&nbsp;Back</g:link>
                            <button id="btnNext" event="continue" class="btn btn-primary">Next&nbsp;<i class="icon-chevron-right icon-white"></i></button>
                        </div>
                    </div>

                </div>
            </g:form>
        </div>
    </body>
</html>