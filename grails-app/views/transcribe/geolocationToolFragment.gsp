<%@ page import="au.org.ala.volunteer.PicklistItem; au.org.ala.volunteer.Picklist" %>
<div>
    <div id="mapWidgets">
        <div id="mapWrapper">
            <div id="mapCanvas"></div>

            <div class="searchHint">Hint: you can also drag & drop the marker icon to set the location data</div>
        </div>

        <div id="mapInfo">
            <div id="sightingAddress">
                <h4>Locality Search</h4>
                <textarea name="address" id="address" size="32" rows="2" value=""></textarea>
                <button id="locationSearch" class="btn btn-small">Search</button>
                <div class="searchHint">If the initial search doesn’t find an existing locality try expanding abbreviations, inserting or removing spaces and commas or simplifying the locality description. Choose a location, or move the pin to a location that you think represents the Verbatim Locality as sensibly as possible. Where the map tool cant find a location simply fill in the State/territory and Country fields</div>
            </div>

            <h4>Coordinate Uncertainty</h4>

            <div>Adjust Uncertainty (in metres):
                <select id="infoUncert">
                    <g:set var="coordinateUncertaintyPL" value="${Picklist.findByName('coordinateUncertaintyInMeters')}"/>
                    <g:each in="${PicklistItem.findAllByPicklist(coordinateUncertaintyPL)}" var="item">
                        <g:set var="isSelected"><g:if test="${(item.value == '1000')}">selected='selected'</g:if></g:set>
                        <option ${isSelected}>${item.value}</option>
                    </g:each>
                </select>

                <div class="searchHint">Please choose an uncertainty value from the list that best represents the area
                described by a circle with radius of that value from the given location. This can be seen as the
                circle around the point on the map <a href="#" class="fieldHelp" title="If in doubt
                                    choose a larger area. For example if the location is simply a small town then
                                    choose an uncertainty value that encompasses the town and some surrounding area.
                                    The larger the town the larger the uncertainty would need to be. If the locality
                                    description (verbatim locality) is quite detailed and you can find that location
                                    accurately then the uncertainty value can be smaller"><span class="help-container">&nbsp;</span>
                </a>
                </div>
            </div>

            <h4>Location Data</h4>

            <div>Latitude: <span id="infoLat"></span></div>

            <div>Longitude: <span id="infoLng"></span></div>

            <div>Location: <span id="infoLoc"></span></div>

            <div style="text-align: center">
                <button id="setLocationFields" class="btn btn-primary">Copy values to main form</button>
            </div>

        </div>
    </div>
</div>

<script type="text/javascript">

    var map, marker, circle, locationObj, geocoder;
    var quotaCount = 0;

    function initializeGeolocateTool() {
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
            scrollwheel: true,
            scaleControl: true,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };

        var mapCanvas = document.getElementById("mapCanvas");
        if (mapCanvas) {
            map = new google.maps.Map(document.getElementById("mapCanvas"), myOptions);
        }

        marker = new google.maps.Marker({
                    position: latLng,
                    //map.getCenter(),
                    title: 'Specimen Location',
                    map: map,
                    draggable: true
                });
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
            var latLongRegex = /([-]{0,1}\d+)[^\d](\d+)[^\d](\d+).*?([-]{0,1}\d+)[^\d](\d+)[^\d](\d+)/;
            var match = latLongRegex.exec(localityStr);
            if (match) {
                var interpretedLatLong = match[1] + '°' + match[2] + "'" + match[3] + '" ' + match[4] + '°' + match[5] + "'" + match[6] + '"';
                $(':input#address').val(interpretedLatLong);
            } else {
                $(':input#address').val(localityStr);
            }
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
        var address = $(':input#address').val().replace(/\n/g, " ");
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
                            marker.setPosition(latLng);
                            map.panTo(latLng);
                            return true;
                        } else {
                            // alert("Geocode was not successful for the following reason: " + status + " (count: " + quotaCount + ")");
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
            100000: 10,
            1000000: 1
        }
        var coordUncertainty = $("#infoUncert").val();
        var key = (coordUncertainty) ? coordUncertainty : 1000;
        var rnd;

        if (precisionMap[key]) {
            rnd = precisionMap[key];
        } else {
            if (key > 100000) {
                rnd = 1;
            } else if (key >= 10000) {
                rnd = 10;
            } else if (key >= 5000) {
                rnd = 100;
            } else if (key >= 1000) {
                rnd = 1000;
            } else {
                rnd = 10000;
            }
        }

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
    });

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

            // update the verbatimLocality picklist on the server
            var url = VP_CONF.updatePicklistUrl;
            var params = {
                name: $(":input.verbatimLocality").val(),
                lat: $(":input.decimalLatitude").val(),
                lng: $(":input.decimalLongitude").val(),
                cuim: $(':input.coordinateUncertaintyInMeters').val()
            };
            $.getJSON(url, params, function(data) {
                // only interested in return text for debugging problems
                //alert(url + " returned: " + data);
            });

            hideModal();
        } else {
            alert('Location data is empty. Use the search and/or drag the map icon to set the location first.');
        }

    });


</script>
