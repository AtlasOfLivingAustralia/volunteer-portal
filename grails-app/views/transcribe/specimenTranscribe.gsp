<html>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Picklist" %>
<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<%@ page import="au.org.ala.volunteer.TemplateField" %>
<%@ page import="au.org.ala.volunteer.field.*" %>
<%@ page import="au.org.ala.volunteer.FieldCategory" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="main"/>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
<title>Transcribe Task ${taskInstance?.id} : ${taskInstance?.project?.name}</title>
<!--  <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.jqzoom-core-pack.js')}"></script>
  <link rel="stylesheet" href="${resource(dir: 'css', file: 'jquery.jqzoom.css')}"/>-->
<script type="text/javascript" src="${resource(dir: 'js', file: 'mapbox.min.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.mousewheel.min.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>
<script type="text/javascript" src="${resource(dir: 'js', file: 'ui.datepicker.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'css/smoothness', file: 'ui.all.css')}"/>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.validationEngine.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.validationEngine-en.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'validationEngine.jquery.css')}"/>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.qtip-1.0.0-rc3.min.js')}"></script>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
<script type="text/javascript">
    var map, marker, circle, locationObj;
    var quotaCount = 0;

    function initialize() {
        geocoder = new google.maps.Geocoder();
        var lat = $('.decimalLatitude').val();
        var lng = $('.decimalLongitude').val();
        var coordUncer = $('.coordinateUncertaintyInMeters').val();
        var latLng;

        if (lat && lng && coordUncer) {
            latLng = new google.maps.LatLng(lat, lng);
            $('#infoUncert').val(coordUncer);
        } else {
            latLng = new google.maps.LatLng(-34.397, 150.644);
        }

        var myOptions = {
            zoom: 10,
            center: latLng,
            scrollwheel: false,
            scaleControl: true,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };

        map = new google.maps.Map(document.getElementById("mapCanvas"), myOptions);

        marker = new google.maps.Marker({
                    position: latLng,
                    //map.getCenter(),
                    title: 'Specimen Location',
                    map: map,
                    draggable: true
                });
        //console.log("adding marker: " + latLng + " (count: " + quotaCount +")");
        // Add a Circle overlay to the map.
        var radius = parseInt($(':input#infoUncert').val());
        circle = new google.maps.Circle({
                    map: map,
                    radius: radius,
                    // 3000 km
                    strokeWeight: 1,
                    strokeColor: 'white',
                    strokeOpacity: 0.5,
                    fillColor: '#2C48A6',
                    fillOpacity: 0.2
                });
        // bind circle to marker
        circle.bindTo('center', marker, 'position');

        // Add dragging event listeners.
        google.maps.event.addListener(marker, 'dragstart',
                function() {
                    updateMarkerAddress('Dragging...');
                });

        google.maps.event.addListener(marker, 'drag',
                function() {
                    updateMarkerStatus('Dragging...');
                    updateMarkerPosition(marker.getPosition());
                });

        google.maps.event.addListener(marker, 'dragend',
                function() {
                    updateMarkerStatus('Drag ended');
                    geocodePosition(marker.getPosition());
                    map.panTo(marker.getPosition());
                });

        var localityStr = $(':input.verbatimLocality').val();
        if (!$(':input#address').val()) {
            $(':input#address').val($(':input.verbatimLocality').val());
        }
        if (lat && lng) {
            geocodePosition(latLng);
            updateMarkerPosition(latLng);
        } else if ($('.verbatimLatitude').val() && $('.verbatimLongitude').val()) {
            $(':input#address').val($('.verbatimLatitude').val() + "," + $('.verbatimLongitude').val())
            codeAddress();
        } else if (localityStr) {
            codeAddress();
        }
    }

    /**
     * Google geocode function
     */
    function geocodePosition(pos) {
        geocoder.geocode({
                    latLng: pos
                },
                function(responses) {
                    if (responses && responses.length > 0) {
                        //console.log("geocoded position", responses[0]);
                        updateMarkerAddress(responses[0].formatted_address, responses[0]);
                    } else {
                        updateMarkerAddress('Cannot determine address at this location.');
                    }
                });
    }

    /**
     * Reverse geocode coordinates via Google Maps API
     */
    function codeAddress() {
        var address = $(':input#address').val();

        if (geocoder && address) {
            //geocoder.getLocations(address, addAddressToPage);
            quotaCount++
            geocoder.geocode({
                        'address': address,
                        region: 'AU'
                    },
                    function(results, status) {
                        if (status == google.maps.GeocoderStatus.OK) {
                            // geocode was successful
                            var latLng = results[0].geometry.location;
                            var lat = latLng.lat();
                            var lon = latLng.lng();
                            var locationStr = results[0].formatted_address;
                            updateMarkerAddress(locationStr, results[0]);
                            updateMarkerPosition(latLng);
                            //initialize();
                            //console.log("moving marker: " + latLng + " (count: " + quotaCount +")");
                            marker.setPosition(latLng);
                            map.panTo(latLng);
                            return true;
                        } else {
                            alert("Geocode was not successful for the following reason: " + status + " (count: " + quotaCount + ")");
                        }
                    });
        }
    }

    function updateMarkerStatus(str) {
        //$(':input.locality').val(str);
    }

    function updateMarkerPosition(latLng) {
        //var rnd = 1000000;
        var precisionMap = {
            100: 1000000,
            1000: 10000,
            10000: 100,
            100000: 1
        }
        var coordUncertainty = $("#infoUncert").val();
        var key = (coordUncertainty) ? coordUncertainty : 1000;
        var rnd = precisionMap[key];
        // round to N decimal places
        var lat = Math.round(latLng.lat() * rnd) / rnd;
        var lng = Math.round(latLng.lng() * rnd) / rnd;
        $('#infoLat').html(lat);
        $('#infoLng').html(lng);
    }

    function updateMarkerAddress(str, addressObj) {
        //$('#markerAddress').html(str);
        $('#infoLoc').html(str);
        //$('#mapFlashMsg').fadeIn('fast').fadeOut('slow');
        // update form fields with location parts
        if (addressObj && addressObj.address_components) {
            var addressComps = addressObj.address_components;
            locationObj = addressComps; // save to global var
        }
    }

    $(document).ready(function() {
        // Google maps API code
        //initialize();

        // trigger Google geolocation search on search button
        $('#locationSearch').click(function(e) {
            e.preventDefault();
            // ignore the href text - used for data
            codeAddress();
        });

        $('input#address').keypress(function(e) {
            //alert('form key event = ' + e.which);
            if (e.which == 13) {
                codeAddress();
            }
        });

        // Catch Coordinate Uncertainty select (mapping tool) change
        $('.coordinatePrecision, #infoUncert').change(function(e) {
            var rad = parseInt($(this).val());
            circle.setRadius(rad);
            updateMarkerPosition(marker.getPosition());
            //updateTitleAttr(rad);
        })

        $("input.scientificName").autocomplete('http://bie.ala.org.au/search/auto.jsonp', {
                extraParams: {
                    limit: 100
                },
                dataType: 'jsonp',
                parse: function(data) {
                    var rows = new Array();
                    data = data.autoCompleteList;
                    for (var i = 0; i < data.length; i++) {
                        rows[i] = {
                            data: data[i],
                            value: data[i].matchedNames[0],
                            result: data[i].matchedNames[0]
                        };
                    }
                    return rows;
                },
                matchSubset: true,
                formatItem: function(row, i, n) {
                    return row.matchedNames[0];
                },
                cacheLength: 10,
                minChars: 3,
                scroll: false,
                max: 10,
                selectFirst: false
            }).result(function(event, item) {
                // user has selected an autocomplete item
                $(':input.taxonConceptID').val(item.guid);
            });

        $("input.recordedBy").autocomplete("${createLink(action:'autocomplete', controller:'picklistItem')}", {
            extraParams: {
                picklist: "recordedBy"
            },
            dataType: 'json',
            parse: function(data) {
                var rows = new Array();
                data = data.autoCompleteList;
                for (var i = 0; i < data.length; i++) {
                    rows[i] = {
                        data: data[i],
                        value: data[i].name,
                        result: data[i].name
                    };
                }
                return rows;
            },
            matchSubset: true,
            formatItem: function(row, i, n) {
                return row.name;
            },
            cacheLength: 10,
            minChars: 1,
            scroll: false,
            max: 10,
            selectFirst: false
        }).result(function(event, item) {
            // user has selected an autocomplete item
            $(':input.recordedByID').val(item.key);
        });

        // MapBox for image zooming & panning
        $('#viewport').mapbox({
            'zoom': true, // does map zoom?
            'pan': true,
            'doubleClickZoom': true,
            'layerSplit': 2,
            'mousewheel': true
        });
        
        $(".map-control a").click(function() {//control panel
            var viewport = $("#viewport");
            //this.className is same as method to be called
            if (this.className == "zoom" || this.className == "back") {
                viewport.mapbox(this.className, 2);//step twice
            }
            else {
                viewport.mapbox(this.className);
            }
            return false;
        });

        // prevent enter key submitting form (for geocode search mainly)
        $(".transcribeForm").keypress(function(e) {
            //alert('form key event = ' + e.which);
            if (e.which == 13) {
                var $targ = $(e.target);

                if (!$targ.is("textarea") && !$targ.is(":button,:submit")) {
                    var focusNext = false;
                    $(this).find(":input:visible:not([disabled],[readonly]), a").each(function() {
                        if (this === e.target) {
                            focusNext = true;
                        }
                        else if (focusNext) {
                            $(this).focus();
                            return false;
                        }
                    });

                    return false;
                }
            }
        });

        // show map popup
        var opts = {
            titleShow: false,
            onComplete: initialize,
            autoDimensions: false,
            width: 978,
            height: 520
        }
        $('button#geolocate').fancybox(opts);

        // catch the clear button
        $('button#clearLocation').click(function() {
            $('form.transcribeForm').validate();
            $('form.transcribeForm').submit();
        });

        // catch button on map
        $('#setLocationFields').click(function(e) {
            e.preventDefault();

            if ($('#infoLat').html() && $('#infoLng').html()) {
                // copy map fields into main form
                $('.decimalLatitude').val($('#infoLat').html());
                $('.decimalLongitude').val($('#infoLng').html());
                $(':input.coordinateUncertaintyInMeters').val($('#infoUncert').val());
                // locationObj is a global var set from geocoding lookup
                for (var i = 0; i < locationObj.length; i++) {
                    var name = locationObj[i].long_name;
                    var type = locationObj[i].types[0];
                    var hasLocality = false;
                    //console.log(i+". type: "+type+" = "+name);
                    // go through each avail option
                    if (type == 'country') {
                        //$(':input.countryCode').val(name1);
                        $(':input.country').val(name);
                    } else if (type == 'locality') {
                        $(':input.locality').val(name);
                        hasLocality = true;
                    } else if (type == 'administrative_area_level_1') {
                        $(':input.stateProvince').val(name);
                    } else {
                        //$(':input.locality').val(name);
                    }
                }

                $.fancybox.close(); // close the popup
            } else {
                alert('Location data is empty. Use the search and/or drag the map icon to set the location first.');
            }

        });

        // form validation
        //$("form.transcribeForm").validationEngine();

        $(":input.save").click(function(e) {
            //e.preventDefault();
            // TODO: Fix this - not working anymore?
            if (!$("form.transcribeForm").validationEngine({returnIsValid:true})) {
                //alert("Validation failed.");
                e.preventDefault();
                $("form.transcribeForm").validationEngine();
                //console.log("Validation failed");
            }
        });

        // Date Picker
        $(":input.datePicker").datepicker({
                    showOn: "button",
                    buttonImage: "${resource(dir: 'images', file: 'calendar.png')}",
                    yearRange: '-200:+00',
                    dateFormat: 'yy-mm-dd',
                    appendText: '(YYYY-MM-DD)'
                }
        ).css('width', '140px'); //

        // Add institution logo to page
        var institutionCode = $("span#institutionCode").html();
        if (institutionCode) {
            var url =  "http://collections.ala.org.au/ws/institution/summary.json?acronym="+institutionCode;
            $.getJSON(url + "&callback=?", null, function(data) {
                if (data.length > 0) {
                    var institutionLogoHtml = '<img src="' + data[0].logo + '" alt="institution logo"/>';
                    $("#institutionLogo").html(institutionLogoHtml);
                }
            });
        }

        // Context sensitive help popups
        $("a.fieldHelp").qtip({
            tip: true,
            position: {
                corner: {
                    target: 'topMiddle',
                    tooltip: 'bottomMiddle'
                }
            },
            style: {
                //width: 450,
                padding: 8,
                background: 'white', //'#f0f0f0',
                color: 'black',
                textAlign: 'left',
                border: {
                    width: 4,
                    radius: 5,
                    color: '#E66542'// '#E66542' '#DD3102'
                },
                tip: 'bottomMiddle',
                name: 'light' // Inherit the rest of the attributes from the preset light style
            }
        }).bind('click', function(e){ e.preventDefault(); return false; });

    }); // end document ready

</script>
</head>

<body class="two-column-right">
<div class="nav">
    <a class="crumb" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    <g:link controller="project" action="list" class="crumb">Projects</g:link>
    <a class="crumb" href="${createLink(action: 'project', controller: 'task', id: taskInstance?.project?.id)}"><g:message
            code="default.task.label" default="${taskInstance?.project?.name}"/></a>
    ${(validator) ? 'Validate' : 'Transcribe'} Task - ${(recordValues?.get(0)?.catalogNumber) ? recordValues?.get(0)?.catalogNumber : taskInstance?.id}
</div>

<div class="body">
    <g:hasErrors bean="${taskInstance}">
    <div class="errors">
        There was a problem saving your edit: <g:renderErrors bean="${taskInstance}" as="list" />
    </div>
    </g:hasErrors>
    <h1>${(validator) ? 'Validate' : 'Transcribe'} Task: ${taskInstance?.project?.name} (ID: ${taskInstance?.id})</h1>
    <g:if test="${taskInstance}">
        <g:form controller="${validator ? "transcribe" : "validate"}" class="transcribeForm">
            <g:hiddenField name="recordId" value="${taskInstance?.id}"/>
            <div class="dialog" style="clear: both">
                <g:each in="${taskInstance.multimedia}" var="m">
                    <g:set var="imageUrl" value="${ConfigurationHolder.config.server.url}${m.filePath}"/>
                    <div class="imageWrapper">
                        <div id="viewport">
                            <div style="background: url(${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_small.$1')}) no-repeat; width: 600px; height: 400px;">
                                <!--top level map content goes here-->
                            </div>
                            <div style="height: 1280px; width: 1920px;">
                                <img src="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_medium.$1')}" alt=""/>
                                <div class="mapcontent"><!--map content goes here--></div>
                            </div>
                            <div style="height: 2000px; width: 3000px;">
                                <img src="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_large.$1')}" alt=""/>
                                <div class="mapcontent"><!--map content goes here--></div>
                            </div>
                            <div style="height: 3168px; width: 4752px;">
                                <img src="${imageUrl}" alt=""/>
                                <div class="mapcontent"><!--map content goes here--></div>
                            </div>
                        </div>
                        <div class="map-control">
                            <a href="#left" class="left">Left</a>
                            <a href="#right" class="right">Right</a>
                            <a href="#up" class="up">Up</a>
                            <a href="#down" class="down">Down</a>
                            <a href="#zoom" class="zoom">Zoom</a>
                            <a href="#zoom_out" class="back">Back</a>
                        </div>
                    </div>

                </g:each>
                <div id="taskMetadata">
                    <div id="institutionLogo"></div>
                    <h3>Specimen Metadata</h3>
                    <ul>
                        <li><div>Institution:</div> <span id="institutionCode">${recordValues?.get(0)?.institutionCode}</span></li>
                        <li><div>Project:</div> ${taskInstance?.project?.name}</li>
                        <li><div>Catalogue No.:</div> ${recordValues?.get(0)?.catalogNumber}</li>
                        <li><div>Taxa:</div> ${recordValues?.get(0)?.scientificName}</li>
                    </ul>
                    <table style="width: 100%">
                        <thead>
                        <tr><th><h3>1. Enter all label text into the box below</h3></th></tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>
                                    <g:textArea name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}" rows="10" cols="40" style="width: 100%"/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div style="clear:both;"></div>

                <div id="transcribeFields">

                    <table style="width: 100%">
                        <thead>
                        <tr><th><h3>2. Collection Event</h3>&nbsp;&nbsp;(Complete fields below using text from the labels as entered in step 1.)</th></tr>
                        </thead>
                        <tbody>
                        <g:each in="${TemplateField.findAllByCategory(FieldCategory.collectionEvent, [sort:'id'])}" var="field">
                            <g:fieldFromTemplateField templateField="${field}" recordValues="${recordValues}"/>
                        </g:each>
                        </tbody>
                    </table>

                    <table style="width: 100%">
                        <thead>
                        <tr>
                            <th><h3>3. Interpreted Location</h3></th>
                            <th><button id="geolocate" href="#mapWidgets" title="Show geolocate tools popup">Show
                                    mapping tool</button> (Use the mapping tool before attempting to enters values manually)</th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${TemplateField.findAllByCategory(FieldCategory.location, [sort:'id'])}" var="field">
                            <g:fieldFromTemplateField templateField="${field}" recordValues="${recordValues}"/>
                        </g:each>
                        </tbody>
                    </table>

                    <div style="display:none">
                        <div id="mapWidgets">
                            <div id="mapWrapper">
                                <div id="mapCanvas"></div>
                                <div class="searchHint">Hint: you can also drag & drop the marker icon to set the location data</div>
                            </div>
                            <div id="mapInfo">
                                <div id="sightingAddress">
                                    <h3>Locality Search</h3>
                                    %{--<label for="address">Locality/Coodinates: </label>
                                    <input type="button" value="Copy verbatim locality into search box" onclick="$(':input#address').val($(':input.verbatimLocality').val())"/>
                                    <br/>--}%
                                    <textarea name="address" id="address" size="32" rows="2" value=""></textarea>
                                    <input id="locationSearch" type="button" value="Search" style="display:table-cell;vertical-align: top;"/>
                                    <div class="searchHint">Search for a locality, place of interest, address, postcode or GPS coordinates
                                    (as lat, long). You may need to edit the verbatim locality to get a match from the Google location search.</div>
                                </div>
                                <h3>Coordinate Uncertainty</h3>
                                <div>Adjust Uncertainty (in metres):
                                    <select id="infoUncert">
                                        <option>100</option>
                                        <option selected="selected">1000</option>
                                        <option>10000</option>
                                        <option>100000</option>
                                    </select>
                                    <div class="searchHint">Changing this value will increase or decrease the grey "uncertainty" circle on the map</div>
                                </div>
                                <h3>Location Data</h3>
                                <div>Latitude: <span id="infoLat"></span></div>
                                <div>Longitude: <span id="infoLng"></span></div>
                                <div>Location: <span id="infoLoc"></span></div>
                                <div style="text-align: center; padding: 10px; font-size: 12px;">
                                    <input id="setLocationFields" type="button" value="Copy values to main form"/>
                                </div>
                            </div>
                        </div>
                    </div>
                    <table style="width: 100%">
                        <thead>
                        <tr><th><h3>4. Identification</h3></th></tr>
                        </thead>
                        <tbody>
                        <g:each in="${TemplateField.findAllByCategory(FieldCategory.identification, [sort:'id'])}" var="field">
                            <g:fieldFromTemplateField templateField="${field}" recordValues="${recordValues}"/>
                        </g:each>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="buttons" style="clear: both">
                <g:hiddenField name="id" value="${taskInstance?.id}"/>
                <g:if test="${validator}">
                    <span class="button"><g:actionSubmit class="validate" action="validate"
                             value="${message(code: 'default.button.validate.label', default: 'Validate')}"/></span>
                    <span class="button"><g:actionSubmit class="dontValidate" action="dontValidate"
                             value="${message(code: 'default.button.dont.validate.label', default: 'Dont validate')}"/></span>
                </g:if>
                <g:else>
                    <span class="button"><g:actionSubmit class="save" action="save"
                             value="${message(code: 'default.button.save.label', default: 'Save')}"/></span>
                    <span class="button"><g:actionSubmit class="savePartial" action="savePartial"
                             value="${message(code: 'default.button.save.partial.label', default: 'Save partially complete')}"/></span>
                    <span class="button"><g:actionSubmit class="skip" action="showNextFromAny"
                             value="${message(code: 'default.button.skip.label', default: 'Skip')}"/></span>
                </g:else>
            </div>
        </g:form>
    </g:if>
    <g:else>
        No tasks loaded for this project !
    </g:else>
</div>
</body>
</html>
