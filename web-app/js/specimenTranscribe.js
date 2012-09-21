// NOTE global var VP_CONF is set by calling page

jQuery.fn.extend({
insertAtCaret: function(myValue){
      return this.each(function(i) {
        if (document.selection) {
          //For browsers like Internet Explorer
          this.focus();
          var sel = document.selection.createRange();
          sel.text = myValue;
          this.focus();
        } else if (this.selectionStart || this.selectionStart == '0') {
          //For browsers like Firefox and Webkit based
          var startPos = this.selectionStart;
          var endPos = this.selectionEnd;
          var scrollTop = this.scrollTop;
          this.value = this.value.substring(0, startPos)+myValue+this.value.substring(endPos,this.value.length);
          this.focus();
          this.selectionStart = startPos + myValue.length;
          this.selectionEnd = startPos + myValue.length;
          this.scrollTop = scrollTop;
        } else {
          this.value += myValue;
          this.focus();
        }
      })
    }
});

var map, marker, circle, locationObj, geocoder;
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

$(window).load(function() {


});

$(document).ready(function() {

    var mainImageWidth = $("#mainImage").width();
    var mainImageHeight = $("#mainImage").height();

    var setSize = function(selector, ratio) {
        var scaleWidth = mainImageWidth * ratio;
        var scaleHeight = mainImageHeight * ratio;
//        console.log("Setting " + selector + " height=" + scaleHeight + " width=" + scaleWidth + "  " + mainImageHeight + "<>" + mainImageWidth);
        $(selector).css("width", scaleWidth + "px").css("height", scaleHeight + "px");
        $(selector).offset({left:0, top:0});
    };

    setSize(".mediumImage", 0.5);
    setSize(".largeImage", 0.75);
    setSize(".actualImage", 1);

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
    });

    $("input.scientificName, input.originalNameUsage").autocomplete('http://bie.ala.org.au/search/auto.jsonp', {
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

    $("input.recordedBy").autocomplete(VP_CONF.picklistAutocompleteUrl, {
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
        // There can be multiple collector boxes on a transcribe form, so we need to update the correct collector id...
        var matches = $(this).attr("id").match(/^recordValues[.](\d+)[.]recordedBy$/);
        if (matches.length > 0) {
            var recordIdx = matches[1]
            $('#recordValues\\.' + recordIdx + '\\.recordedByID').val(item.key);
            // We store the collector name in the form attribute so we can compare it on a change event
            // to see if we need to wipe the collectorid out should the name in the inputfield change
            $('#recordValues\\.' + recordIdx + '\\.recordedByID').attr('collector_name', item.name);
        } else {
            $(':input.recordedByID').val(item.key);
        }

    });

    $("input.recordedBy").change(function(e) {
        // If the value of the recordedBy field does not match the name in the collector_name attribute
        // of the recordedByID element it means that the collector name no longer matches the id, so the id
        // must be cleared.
        var matches = $(this).attr("id").match(/^recordValues[.](\d+)[.]recordedBy$/);
        var value = $(this).val();
        if (matches.length > 0) {
            var recordIdx = matches[1]
            var elemSelector = '#recordValues\\.' + recordIdx + '\\.recordedByID'
            var collectorName = $(elemSelector).attr("collector_name");
            if (value != collectorName) {
                $(elemSelector).val('');
                $(elemSelector).attr("collector_name", "");
            }
        }
    });

    $(":input.verbatimLocality").not('[noAutoComplete]').autocomplete(VP_CONF.picklistAutocompleteUrl, {
        extraParams: {
            picklist: "verbatimLocality"
        },
        dataType: 'json',
        parse: function(data) {
            var rows = new Array();
            data = data.autoCompleteList;
            for (var i = 0; i < data.length; i++) {
                rows[i] = {
                    data: data[i],
                    value: data[i].name,
                    result: data[i].name.split("|")[0]
                };
            }
            return rows;
        },
        matchSubset: true,
        formatItem: function(row, i, n) {
            var nameBits = row.name.split("|");
            return nameBits[0];
        },
        cacheLength: 10,
        minChars: 1,
        scroll: false,
        max: 10,
        selectFirst: false
    }).result(function(event, item) {
        // user has selected an autocomplete item
        // populate verbatim lat, lng & coord uncert
        var nameBits = item.name.split("|");
        if (nameBits[1]) $(':input.decimalLatitude').val(nameBits[1]);
        if (nameBits[2]) $(':input.decimalLongitude').val(nameBits[2]);
        if (nameBits[3]) $(':input.coordinateUncertaintyInMeters').val(nameBits[3]);
        $("#geolocate").click(); // does geolocation lookup for other fields
        var msg = "Please confirm this location by clicking the button labelled 'Copy values to main form'";
        setTimeout(function() {alert(msg);} , 1000);

        // populate verbatimLocalityID
        $(':input.verbatimLocalityID').val(item.key);
    });

    // MapBox for image zooming & panning
    $('#viewport').mapbox({
        'zoom': true, // does map zoom?
        'pan': true,
        'doubleClickZoom': true,
        'layerSplit': 1,
        'mousewheel': true
    });

    $(".map-control a").click(function() {//control panel
        var viewport = $("#viewport");
        //this.className is same as method to be called
        if (this.className == "zoom" || this.className == "back") {
            viewport.mapbox(this.className, 1);//step twice
        }
        else {
            viewport.mapbox(this.className, 100);
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

    // catch "copy values..." button on map
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
        }
    });

    // Date fields
    $(":input.datePicker").css('width', '150px').after("&nbsp;[YYYY-MM-DD]"); //

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

    // timeout on page to prompt user to save or reload
    $("#promptUserLink").fancybox({
        modal: false,
        centerOnScroll: true,
        hideOnOverlayClick: false,
        //title: "Alert - lock has expired",
        //titlePosition: "over",
        padding: 20,
        onComplete: function() {
            var i = 5; // minutes to countdown before reloading page
            var countdownInterval = 1 * 60 * 1000;
            function countDownByOne() {
                i--;
                $("#reloadCounter").html(i);
                if (i > 0) {
                    window.setTimeout(countDownByOne, countdownInterval);
                } else {
                    //window.location.reload();
                    $(":input[name='_action_save']").click();
                }
            }
            window.setTimeout(countDownByOne, countdownInterval);
        }
    });

    $(".saveUnfinishedTaskButton").click(function(e) {
        e.preventDefault();
        clickSaveButton();
    });

    function clickSaveButton() {
      $(":input[name='_action_save']").click();
    }

    var isReadonly = VP_CONF.isReadonly;
    if (isReadonly) {
        // readonly more
        $(":input").not('.skip,.comment-control :input').hover(function(e){alert('You do not have permission to edit this task.')}).attr('disabled','disabled').attr('readonly','readonly');
    } else {
        // editing mode
        var timeoutMinutes = 90;
        window.setTimeout(function() { $("#promptUserLink").click(); }, timeoutMinutes * 60 * 1000);
    }

    // disable submit if validated
    if (VP_CONF.isValid) {
        //$(":input.save, :input.savePartial, :input.validate, :input.dontValidate").attr("disabled","disabled").attr("title","Task readonly - already validated");
    }
    // save "all text" to cookie so we can load into next task
    $("#transcribeAllText").blur(function(e) {
        if ($(this).val()) {
            $.cookie('transcribeAllText', $(this).val());
        }
    });
    // load it from cookie after asking user
    if (false && !$("#transcribeAllText").val()) {
        //$("#transcribeAllText").val($.cookie('transcribeAllText'))
        if (confirm("Carry over the \"1. Transcribe All Text\" content from from previous task?")) {
            $("#transcribeAllText").val($.cookie('transcribeAllText'));
            $("#transcribeAllText").focus();
        }
    }

    if ($.cookie('transcribeAllText')) {
        $("#copyAllTextButton").click(function(e) {
            e.preventDefault();
            $("#transcribeAllText").val($.cookie('transcribeAllText'));
            $("#transcribeAllText").focus();
        });
    } else {
        $("#copyAllTextButton").attr('disabled','disabled');
    }

    // Add clickable icons for deg, min sec in lat/lng inputs
    var title = "Click to insert this symbol";
    var icons = " symbols: <span class='coordsIcons'>" +
            "<a href='#' title='"+title+"' class='&deg;'>&deg;</a>&nbsp;" +
            "<a href='#' title='"+title+"' class='&#39;'>&#39;</a>&nbsp;" +
            "<a href='#' title='"+title+"' class='&quot;'>&quot;</a></span>";
    $(":input.verbatimLatitude, :input.verbatimLongitude").each(function() {
        $(this).css('width', '140px');
        $(this).after(icons);
    });
    $(":input.#transcribeAllText").after(icons);


    $(".coordsIcons a").click(function(e) {
        e.preventDefault();
        var input = $(this).parent().prev(':input');
        var text = $(input).val();
        var char = $(this).attr('class');
        $(input).val(text + char);
        $(input).focus();
    });

    // skip/next task button

    $("#showNextFromProject").click(function(e) {
        e.preventDefault();
        var url = VP_CONF.nextTaskUrl + "?taskId=" + VP_CONF.taskId;
        location.href = url;
    });

}); // end document ready
