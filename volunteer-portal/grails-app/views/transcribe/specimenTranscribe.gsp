<html>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Picklist" %>
<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<%@ page import="au.org.ala.volunteer.field.*" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
  <title>Transcribe Task ${taskInstance?.id} : ${taskInstance?.project?.name}</title>
  <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.jqzoom-core-pack.js')}"></script>
  <link rel="stylesheet" href="${resource(dir: 'css', file: 'jquery.jqzoom.css')}"/>
  <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
  <script type="text/javascript">
      var map, marker, circle;

      function initialize() {
          var lat = $('.decimalLatitude').val();
          var lng = $('.decimalLongitude').val();
          var latLng;
          if (lat && lng) {
              latLng = new google.maps.LatLng(lat, lng);
          } else {
              latLng = new google.maps.LatLng( - 34.397, 150.644);
          }
          var myOptions = {
              zoom: 10,
              center: latLng,
              scrollwheel: false,
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
          var radius = parseInt($('.coordinatePrecision').val());
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

          geocoder = new google.maps.Geocoder();
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
          var address = $('input#address').val();

          if (geocoder && address) {
              //geocoder.getLocations(address, addAddressToPage);
              geocoder.geocode({
                  'address': address,
                  region: 'AU'
              },
              function(results, status) {
                  if (status == google.maps.GeocoderStatus.OK) {
                      // geocode was successful
                      var lat = results[0].geometry.location.lat();
                      var lon = results[0].geometry.location.lng();
                      var locationStr = results[0].formatted_address;
                      updateMarkerAddress(locationStr, results[0]);
                      updateMarkerPosition(results[0].geometry.location);
                      initialize();
                  } else {
                      alert("Geocode was not successful for the following reason: " + status);
                  }
              });
          }
      }

      function updateMarkerStatus(str) {
          $(".locality").val(str);
      }

      function updateMarkerPosition(latLng) {
          var rnd = 100000000;
          var lat = Math.round(latLng.lat() * rnd) / rnd;
          // round to 8 decimal places
          var lng = Math.round(latLng.lng() * rnd) / rnd;
          // round to 8 decimal places
          $('.decimalLatitude').val(lat);
          $('.decimalLongitude').val(lng);
      }

      function updateMarkerAddress(str, addressObj) {
          //$('#markerAddress').html(str);
          $('#sightingLocation').val(str);
          // update form fields with location parts
          if (addressObj && addressObj.address_components) {
              var addressComps = addressObj.address_components;
              // array
              for (var i = 0; i < addressComps.length; i++) {
                  var name1 = addressComps[i].short_name;
                  var name2 = addressComps[i].long_name;
                  var type = addressComps[i].types[0];
                  // go through each avail option
                  if (type == 'country') {
                      $(':input.countryCode').val(name1);
                      $(':input.country').val(name2);
                  } else if (type == 'locality') {
                      $(':input.locality').val(name2);
                  } else if (type == 'administrative_area_level_1') {
                      $(':input.stateProvince').val(name2);
                  }
              }
          }
      }


      $(document).ready(function() {
          // Google maps API code
          initialize();

          // trigger Google geolocation search on search button
          $('#locationSearch').click(function(e) {
              e.preventDefault();
              // ignore the href text - used for data
              codeAddress();
          });

          $('.coordinatePrecision').change(function(e) {
              var rad = parseInt($(this).val());
              circle.setRadius(rad);
              //updateTitleAttr(rad);
          })

          jQuery("input.scientificName").autocomplete('http://bie.ala.org.au/search/auto.jsonp', {
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
              $('input.taxonConceptID').val(item.guid);
          });
          
          // JQZoom tool for image zooming
          var options = {
              zoomType: 'drag',
              lens: true,
              preloadImages: true,
              alwaysOn: false,
              zoomWidth: 300,
              zoomHeight: 300,
              imageOpacity: 0.7,
              title: false
              //xOffset:90,
              //yOffset:30,
              //position:'right'
          };
          $('.taskImage').jqzoom(options);
          
          // prevent enter key submitting form (for geocode search mainly)
          $(".transcribeForm").keypress(function(e) {
              //alert('form key event = ' + e.which);
              if (e.which == 13) {
                  var $targ = $(e.target);

                  if (!$targ.is("textarea") && !$targ.is(":button,:submit")) {
                      var focusNext = false;
                      $(this).find(":input:visible:not([disabled],[readonly]), a").each(function(){
                          if (this === e.target) {
                              focusNext = true;
                          }
                          else if (focusNext){
                              $(this).focus();
                              return false;
                          }
                      });

                      return false;
                  }
              }
          });
          
          // set a few default values if blank
          var fieldMap = {
              country: "Australia",
              coordinatePrecision: 1000
          }
          
          for (key in fieldMap) {
              console.log("key = " + key)
              $(":input." + key).each(function() {
                  console.log("val() = " + $(this).val())
                  if (!$(this).val()) $(this).val(fieldMap[key]);
                  if (!$(this).val()) $(this).val(fieldMap[key]);
              });
          }
      });
      
  </script>
</head>
<body class="two-column-right">
<div id="content">
  <div class="section">
    <div class="body">
      <g:if test="${validator}">
        <h1>Validate Task ${taskInstance?.id} : ${taskInstance?.project?.name}</h1>
      </g:if>
      <g:else>
        <h1>Transcribe Task ${taskInstance?.id} : ${taskInstance?.project?.name}</h1>
      </g:else>

      <g:if test="${taskInstance}">
      <g:form controller="transcribe" action="saveTranscription" class="transcribeForm">
        <g:hiddenField name="recordId" value="${taskInstance?.id}"/>
      <div class="dialog">
        <g:each in="${taskInstance.multimedia}" var="m">
          %{--<img src="${ConfigurationHolder.config.server.url}${m.filePath}" alt="specimen image"/>--}%
          <g:set var="imageUrl" value="${ConfigurationHolder.config.server.url}${m.filePath}"/><!-- imageUrl = ${imageUrl} -->
          <div class="multimedia">
            <a href="${imageUrl}" class="taskImage" title="${taskInstance?.project?.name}">
              <img src="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/,'_small.$1')}" title="image: ${taskInstance?.project?.name}">
            </a>
          </div>

        </g:each>
        <div style="clear:both;">&nbsp;</div>
        <div id="transcribeFields">
          <table style="float:left;">
            <thead>
              <tr><th><h3>Identification</h3></th></tr>
            </thead>
            <tbody>
              <g:each in="${Identification}" var="field">
                <g:if test="${field.name() == 'foo'}">
                  <tr class="prop">
                    <td valign="top" class="name">
                      <g:message code="record.${field}.label" default="${field.label}"/>
                    </td>
                    <td valign="top" class="value">
                      <g:select name="recordValues.0.${field}" from="${PicklistItem.findAllByPicklist(Picklist.findByName(field.name()))}"
                        value="${recordValues?.get(0)?.(field.name())}" optionValue="value" optionKey="value" 
                        noSelection="${['':'Select an option...']}" class="${field}" />
                    </td>
                  </tr>
                </g:if>
                <g:else>
                  <tr class="prop">
                    <td valign="top" class="name">
                    <g:message code="record.${field}.label" default="${field.label}"/>
                   </td>
                   <td valign="top" class="value">
                     <g:textField name="recordValues.0.${field}" maxlength="200" value="${recordValues?.get(0)?.(field.name())}" class="${field}"/>
                   </td>
                  </tr>
                </g:else>
              </g:each>
            </tbody>
          </table>
          <table style="float:left;">
            <thead>
              <tr><th><h3>Dataset</h3></th></tr>
            </thead>
            <tbody>
              <g:each in="${Dataset}" var="field">
                <g:if test="${field.name() == 'typeStatus'}">
                  <tr class="prop">
                    <td valign="top" class="name">
                      <g:message code="record.${field}.label" default="${field.label}"/>
                    </td>
                    <td valign="top" class="value">
                      <g:select name="recordValues.0.${field}" from="${PicklistItem.findAllByPicklist(Picklist.findByName(field.name()))}"
                        value="${recordValues?.get(0)?.(field.name())}" optionValue="value" optionKey="value" 
                        noSelection="${['':'Select an option...']}" class="${field}" />
                    </td>
                  </tr>
                </g:if>
                <g:else>
                  <tr class="prop">
                    <td valign="top" class="name">
                    <g:message code="record.${field}.label" default="${field.label}"/>
                   </td>
                   <td valign="top" class="value">
                     <g:textField name="recordValues.0.${field}" maxlength="200" value="${recordValues?.get(0)?.(field.name())}" class="${field}"/>
                   </td>
                  </tr>
                </g:else>
              </g:each>
            </tbody>
          </table>
          <div style="clear:both;">&nbsp;</div>
          <table style="float:left;">
            <thead>
              <tr><th><h3>Location</h3></th></tr>
            </thead>
              <tbody>
                <g:each in="${Location}" var="field">
                  <g:if test="${field.name() == 'country' || field.name() == 'stateProvince'}">
                    <tr class="prop">
                      <td valign="top" class="name">
                        <g:message code="record.${field}.label" default="${field.label}"/>
                      </td>
                      <td valign="top" class="value">
                        <g:select name="recordValues.0.${field}" from="${PicklistItem.findAllByPicklist(Picklist.findByName(field.name()))}"
                          value="${recordValues?.get(0)?.(field.name())}" optionValue="value" optionKey="value" 
                          noSelection="${['':'Select an option...']}" class="${field}" />
                      </td>
                    </tr>
                  </g:if>
                  <g:elseif test="${field.name() == 'coordinatePrecision'}">
                    <tr class="prop">
                      <td valign="top" class="name">
                        <g:message code="record.${field}.label" default="${field.label}"/>
                      </td>
                      <td valign="top" class="value">
                        <g:select name="recordValues.0.${field}" from="${[10, 50, 100, 500, 1000, 10000]}"
                          value="${recordValues?.get(0)?.(field.name())}" optionValue="value" optionKey="value" class="${field}" />
                      </td>
                    </tr>
                  </g:elseif>
                  <g:else>
                    <tr class="prop">
                      <td valign="top" class="name">
                        <g:message code="record.${field}.label" default="${field.label}"/>
                      </td>
                      <td valign="top" class="value">
                        <g:textField name="recordValues.0.${field}" maxlength="200" value="${recordValues?.get(0)?.(field.name())}" class="${field}"/>
                      </td>
                    </tr>
                  </g:else>
                </g:each>
              </tbody>
            </table>
            <div id="mapWidgets">
              <div id="sightingAddress">
                  <label for="address">Geocode a location: </label>
                  <input name="address" id="address" size="36" value=""/>
                  <input id="locationSearch" type="button" value="Search"/>
              </div>
              <div id="mapCanvas"></div>
            </div>
        </div>
      </div>
      <div class="buttons" style="clear: both">
          <g:hiddenField name="id" value="${taskInstance?.id}"/>
          <g:if test="${validator}">
            <span class="button"><g:actionSubmit class="validate" action="validate" value="${message(code: 'default.button.validate.label', default: 'Validate')}"/></span>
            <span class="button"><g:actionSubmit class="dontValidate" action="dontValidate" value="${message(code: 'default.button.dont.validate.label', default: 'Dont validate')}"/></span>
          </g:if>
          <g:else>
            <span class="button"><g:actionSubmit class="save" action="save" value="${message(code: 'default.button.save.label', default: 'Save')}"/></span>
            <span class="button"><g:actionSubmit class="savePartial" action="savePartial" value="${message(code: 'default.button.save.partial.label', default: 'Save partially complete')}"/></span>
            <span class="button"><g:actionSubmit class="skip" action="showNextFromAny" value="${message(code: 'default.button.skip.label', default: 'Skip')}"/></span>
          </g:else>
      </div>
      </g:form>
      </g:if>
      <g:else>
        No tasks loaded for this project !
      </g:else>
    </div>
  </div>
</div>
</body>
</html>
