<%@ page import="au.org.ala.volunteer.ProjectType; au.org.ala.volunteer.Template" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Create a new Expedition - Summary</title>

    <script type='text/javascript' src='https://www.google.com/jsapi'></script>

    <g:if test="${project.showMap}">
        <g:set var="initZoom" value="${project.mapInitZoomLevel ?: 3}" />
        <g:set var="initLatitude" value="${project.mapInitLatitude ?: -27.76133033947936}" />
        <g:set var="initLongitude" value="${project.mapInitLongitude ?: 134.47265649999997}" />
    </g:if>

    <r:script type="text/javascript">

            google.load("maps", "3.3", {other_params: "sensor=false"});

            var map, infowindow;
            var mapListenerActive = true;

            $(document).ready(function() {

                bvp.bindTooltips();
                bvp.suppressEnterSubmit();

                <g:if test="${project.showMap}">
                    loadMap();
                </g:if>
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

    .prop-value {
        font-weight: bold;
    }

    </style>

</head>
<body>

    <cl:headerContent title="Create a new Expedition - Expedition summary" selectedNavItem="expeditions">
        <% pageScope.crumbs = [] %>
    </cl:headerContent>

    <div class="">

        <p>
            Your expedition is almost ready! Please review the following, and if everything is correct, click on the 'Create Expedition' button.
        </p>
        <p>
            If you find a mistake, or you wish to change something you can click the 'Back' button until you find the item you wish to change.
        </p>

        <table class="table table-bordered table-striped">
            <tr>
                <td class="prop-name">Expedition institution</td>
                <td class="prop-value">${project.featuredOwner}</td>
            </tr>
            <tr>
                <td class="prop-name">Expedition name</td>
                <td class="prop-value">${project.name}</td>
            </tr>
            <tr>
                <td class="prop-name">Short description</td>
                <td class="prop-value">${project.shortDescription}</td>
            </tr>
            <tr>
                <td class="prop-name">Long description</td>
                <td class="prop-value">${project.longDescription}</td>
            </tr>
            <tr>
                <td class="prop-name">Template</td>
                <td class="prop-value">${templateName}</td>
            </tr>
            <tr>
                <td class="prop-name">Expedition type</td>
                <td class="prop-value">

                    <span style="vertical-align: middle">
                        ${projectTypeLabel}
                    </span>
                    <g:if test="${projectTypeImageUrl}">
                        <img style="margin-left: 10px; vertical-align: middle" src="${projectTypeImageUrl}" />
                    </g:if>
                </td>
            </tr>

            <tr>
                <td class="prop-name">Expedition image</td>
                <td class="prop-value">
                    <g:if test="${projectImageUrl}">
                        <image src="${projectImageUrl}" />
                    </g:if>
                    <g:else>
                        <em>No image uploaded</em>
                    </g:else>
                </td>
            </tr>
            <tr>
                <td class="prop-name">Image copyright text</td>
                <td class="prop-value">${project.imageCopyright}</td>
            </tr>

            <tr>
                <td class="prop-name">Show map on expedition page</td>
                <td class="prop-value">${project.showMap ? "Yes" : "No"}</td>
            </tr>

            <g:if test="${project.showMap}">
                <tr>
                    <td class="prop-name">
                        Map position
                    </td>
                    <td class="prop-value">
                        <div id="recordsMap"></div>
                        <div>
                            Zoom: ${project.mapInitZoomLevel} Longitude: ${project.mapInitLongitude} Latitude: ${project.mapInitLatitude}
                        </div>
                    </td>
                </tr>
            </g:if>

            <tr>
                <td class="prop-name">
                    <g:message code="project.picklistInstitutionCode.label" default="Picklist Collection Code"/>
                </td>
                <td class="prop-value">
                    ${project.picklistId}
                </td>
            </tr>
            <tr>
                <td class="prop-name">Labels</td>
                <td class="prop-value">
                    <div id="labels">
                        <g:each in="${labels}" var="l">
                            <span class="label ${labelColourMap[l.category]}" title="${l.category}">${l.value}</span>
                        </g:each>
                    </div>
                </td>
            </tr>

        </table>

        <div class="form-horizontal">
            <div class="control-group" style="margin-top: 10px">
                <div class="controls">
                    <g:link class="btn" event="cancel">Cancel</g:link>
                    <g:link class="btn" event="back"><i class="icon-chevron-left"></i>&nbsp;Back</g:link>
                    <g:link class="btn btn-primary" event="continue">Create Expedition</g:link>
                </div>
            </div>
        </div>

    </div>
</body>
</html>