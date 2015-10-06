<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.mappingtool.label" default="Administration - Mapping tool"/></title>
    <script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.4&sensor=false"></script>
    <style type="text/css">

    /* hide the close button that would normally be shown on the modal dialog, as well as the other control buttons */
    .close, #geolocationToolButtons {
        display: none;
    }

    .geocoded-value {
        font-size: 1.2em
    }

    div#mapWidgets {
        width: 950px;
        height: 500px;
        overflow: hidden;
    }

    #mapWidgets img {
        max-width: none !important;
    }

    #mapWidgets #mapWrapper {
        width: 500px;
        height: 500px;
        float: left;
        padding-right: 10px;
    }

    #mapWidgets #mapCanvas {
        width: 500px;
        height: 500px;
        /*// height: 94%;*/
        margin-bottom: 6px;
    }

    #mapWidgets #mapInfo {
        float: left;
        height: 100%;
        width: 44%;
        padding: 0 0 0 10px;
        text-align: left;
        border-left: 2px solid #cccccc;
    }

    #mapWidgets #sightingAddress {
        margin-bottom: 4px;
        line-height: 22px;
    }

    #mapWidgets .searchHint {
        font-size: 12px;
        padding: 4px 0;
        line-height: 1.2em;
        color: #666;
    }

    #mapWidgets #address {
        width: 360px;
    }

    </style>

    <r:script type='text/javascript'>

            $(document).ready(function() {
                $.ajax("${createLink(controller: 'transcribe', action: 'geolocationToolFragment')}").done(function(content) {
                    $("#mappingToolContent").html(content);
                });

                $("#btnToggleFullData").click(function(e) {
                    e.preventDefault();
                    $("#allDataDiv").toggle();
                });
            });

            var geocodeCallback = function(results) {

                // clear all values
                $(".geocoded-value").html("");

                if (!results) {
                    return;
                }

                var locationObj = results.address_components;

                // $('#infoLat').html() && $('#infoLng').html()
                $("#gc_latitude").html($('#infoLat').html());
                $("#gc_longitude").html($('#infoLng').html());

                for (var i = 0; i < locationObj.length; i++) {
                    var name = locationObj[i].long_name;
                    var type = locationObj[i].types[0];
                    // go through each avail option
                    if (type == 'country') {
                        $('#gc_country').html(name);
                    } else if (type == 'locality') {
                        $("#gc_locality").html(name);
                    } else if (type == 'administrative_area_level_1') {
                        $('#gc_state').html(name);
                    }
                }

                if (JSON) {
                    var allData = JSON.stringify(results, null, 4);
                    $("#geocodeAllData").html(allData);
                }

            }

    </r:script>
</head>

<body>

<cl:headerContent title="${message(code: 'default.tools.label', default: 'Mapping tool')}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Admin')],
                [link: createLink(controller: 'admin', action: 'tools'), label: message(code: 'default.tools.label', default: 'Tools')]
        ]
    %>
</cl:headerContent>


<div class="row">
    <div class="span12">
        Either drag the marker to a location, or search for a locality by name in the box below.
    </div>
</div>

<div class="row">
    <div class="span12">
        <div class="well well-small" id="mappingToolContent">
            <cl:spinner/>&nbsp;Loading...
        </div>
    </div>
</div>

<div class="row">
    <div class="span12 form-horizontal">
        <table class="table">
            <tr>
                <td>Locality</td>
                <td>State</td>
                <td>Country</td>
                <td>Latitude</td>
                <td>Longitude</td>
            </tr>
            <tr>
                <td>
                    <span class="geocoded-value" id="gc_locality"></span>
                </td>
                <td>
                    <span class="geocoded-value" id="gc_state"></span>
                </td>
                <td>
                    <span class="geocoded-value" id="gc_country"></span>
                </td>
                <td>
                    <span class="geocoded-value" id="gc_latitude"></span>
                </td>
                <td>
                    <span class="geocoded-value" id="gc_longitude"></span>
                </td>
            </tr>
        </table>
        %{--<div>--}%
        %{--Locality: <span class="geocoded-value" id="gc_locality"></span> State: <span class="geocoded-value" id="gc_state"></span> Country: <span class="geocoded-value" id="gc_country"></span>--}%
        %{--Latitude: <span class="geocoded-value" id="gc_latitude"></span> Longitude: <span class="geocoded-value" id="gc_longitude" ></span>--}%
        %{--</div>--}%
    </div>
</div>
<button class="btn" id="btnToggleFullData">Toggle full geolocate data</button>

<div class="row">
    <div class="span12 form-horizontal" style="display: none" id="allDataDiv">
        <pre>
            <code id="geocodeAllData" class="prettyprint"></code>
        </pre>
    </div>
</div>

</body>
</html>
