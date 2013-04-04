<html>
<%@ page import="au.org.ala.volunteer.Template; au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Picklist" %>
<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<%@ page import="au.org.ala.volunteer.TemplateField" %>
<%@ page import="au.org.ala.volunteer.field.*" %>
<%@ page import="au.org.ala.volunteer.FieldCategory" %>
<%@ page import="au.org.ala.volunteer.DarwinCoreField" %>

<g:set var="collectionEventInsitutionCode" value="${taskInstance?.project?.collectionEventLookupCollectionCode ?: taskInstance?.project.featuredOwner}" />


<%@ page contentType="text/html; UTF-8" %>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="${grailsApplication.config.ala.skin}"/>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
<title>${(validator) ? 'Validate' : 'Transcribe'} Task ${taskInstance?.id} : ${taskInstance?.project?.name}</title>
<script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'validationEngine.jquery.css')}"/>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.validationEngine.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.validationEngine-en.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.qtip-1.0.0-rc3.min.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.cookie.js')}"></script>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'gmaps.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.jqzoom-core.js')}"></script>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'jquery.jqzoom.css')}"/>
<script type="text/javascript" src="${resource(dir: 'js', file: 'specimenTranscribe.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.mousewheel.min.js')}"></script>
<script type="text/javascript" src="${resource(dir: 'js', file: 'jquery-panZoom.js')}"></script>

<script type="text/javascript">

    // global Object
    var VP_CONF = {
        taskId: "${taskInstance?.id}",
        picklistAutocompleteUrl: "${createLink(action:'autocomplete', controller:'picklistItem')}",
        updatePicklistUrl: "${createLink(controller:'picklistItem', action:'updateLocality')}",
        nextTaskUrl:  "${createLink(controller:(validator) ? "validate" : "transcribe", action:'showNextFromProject', id:taskInstance?.project?.id)}",
        isReadonly: "${isReadonly}",
        isValid: ${(taskInstance?.isValid) ? "true" : "false"}
    };

    $(document).ready(function() {

      $(window).scroll(function(e) {
        if ($("#floatingImage").is(":visible")) {
          var parent = $("#floatingImage").parents('.ui-dialog');
          var position = parent.position();
          var top = position.top - $(window).scrollTop();
          if (top < 0) {
            $("#floatingImage").dialog("option", "position", [position.left, 10]);
          } else if (top + parent.height() > $(window).height() ) {
            $("#floatingImage").dialog("option", "position", [position.left, $(window).scrollTop() + $(window).height() - (parent.height() + 20) ]);
          }
        }
      });

      $("#pinImage").click(function(e) {
        e.preventDefault();
        if ($(".pan-image").css("position") == 'fixed') {
          $(".pan-image").css({"position": "relative", top: 'inherit', left: 'inherit', 'border':'none' });
          $(".new-window-control").css({'background-image': "url(${resource(dir:'images', file:'pin-image.png')})"});
          $(".pan-image a").attr("title", "Fix the image in place in the browser window");
        } else {
          $(".pan-image").css({"position": "fixed", top: 10, left: 10, "z-index":600, 'border': '2px solid #535353' });
          $(".new-window-control").css("background-image", "url(${resource(dir:'images', file:'unpin-image.png')})");
          $("#imageContainer").css("background", "darkgray");
          $(".pan-image a").attr("title", "Return the image to its normal position");
        }

      });

      $(".pan-image img").panZoom({
        pan_step: 10,
        zoom_step: 5,
        min_width: 200,
        min_height: 200,
        mousewheel:true,
        mousewheel_delta: 2,
        'zoomIn'    :  $('#zoomin'),
        'zoomOut'   :  $('#zoomout'),
        'panUp'     :  $('#pandown'),
        'panDown'   :  $('#panup'),
        'panLeft'   :  $('#panright'),
        'panRight'  :  $('#panleft')
      });

      $(".pan-image img").panZoom('fit');


      var task_selector_opts = {
          titleShow: false,
          onComplete: function() {},
          autoDimensions: false,
          scrolling: 'no',
          onStart: function() {
              $.fancybox.showActivity();
            $.ajax({url:"${createLink(controller: 'task', action:'taskBrowserFragment', params: [projectId: taskInstance.project.id, taskId: taskInstance.id])}", success: function(html) {
                var dest = $("#task_selector_content");
                dest.html(html);
                $.fancybox.hideActivity();
            }});
          },
          width: 640,
          height: 500
      }

      $('#show_task_selector').fancybox(task_selector_opts);

      var collection_event_selector_opts = {
          titleShow: false,
          onComplete: function() { },
          autoDimensions: false,
          scrolling: 'no',
          onStart: function() {
            $.fancybox.showActivity();

            var queryParams = ""
            for (i = 0; i < 4; i++) {
              queryParams += "&collector" + i + "=" + encodeURIComponent($('#recordValues\\.' + i + '\\.recordedBy').val())
            }
            queryParams += '&eventDate=' + encodeURIComponent($('#recordValues\\.0\\.eventDate').val())

            $.ajax({url:"${createLink(controller: 'collectionEvent', action:'searchFragment', params: [taskId: taskInstance.id])}" + queryParams, success: function(data) {
              $("#collection_event_selector_content").html(data);
              $.fancybox.hideActivity();
            }});

          },
          width: 800,
          height: 520
      }

      $('#collectionEventSelectorLink').fancybox(collection_event_selector_opts);

      $('#show_collection_event_selector').click(function(e) {
          e.preventDefault();
          if (checkFindCollectionEventAvailability()) {
              $('#collectionEventSelectorLink').click();
          } else {
              alert("You must first enter either a date or at least one collector!")
          }
      });

      var locality_selector_opts = {
          titleShow: false,
          onComplete: initialize,
          autoDimensions: false,
          scrolling: 'no',
          onStart: function() {
            $.fancybox.showActivity();
            var verbatimLocality = $('#recordValues\\.0\\.verbatimLocality').val();
            verbatimLocality = verbatimLocality.replace(/(\r\n|\n|\r)/gm, ' ');
            $.ajax("${createLink(controller: 'locality', action:'searchFragment', params: [taskId: taskInstance.id])}&verbatimLocality=" + encodeURIComponent(verbatimLocality)).done( function(data) {
              $("#locality_selector_content").html(data);
              $.fancybox.hideActivity();
            });
          },
          width: 800,
          height: 520
      }

      $('#locality_selector_link').fancybox(locality_selector_opts);

      $('#showLocalitySelector').click(function(e) {
          e.preventDefault();
          $('#locality_selector_link').click();
      });

      $(".insert-symbol-button").each(function(index) {
        $(this).html($(this).attr("symbol"));
      });

      $(".insert-symbol-button").click(function(e) {
          e.preventDefault();
          var input = $("#recordValues\\.0\\.occurrenceRemarks");
          $(input).insertAtCaret($(this).attr('symbol'));
          $(input).focus();
      });

      checkFindCollectionEventAvailability();

      // display previous journal page in new window
      $("#showImageButton").click(function(e) {
          e.preventDefault();
          var uri = "${createLink(controller: 'task', action:'showImage', id: taskInstance.id)}"
          newwindow = window.open(uri,'journalWindow','directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
          if (window.focus) {newwindow.focus()}
      });


      $(".closeSection").click(function(e) {
        e.preventDefault();
        var body = $(this).closest("table").find('tbody');
        if (body.css('display') == 'none') {
          body.css('display', 'block');
          $(this).text("Shrink")
        } else {
          body.css('display', 'none');
          $(this).text("Expand")
        }
      });

      updateBindStatus();

    });

    function updateBindStatus() {
      var eventId = getFieldValue("eventID");
      if ($.isNumeric(eventId)) {
        updateEventBindStatus(eventId)
        return;
      }
      var localityId = getFieldValue("locationID");
      if ($.isNumeric(localityId)) {
        updateLocalityBindStatus(localityId);
      }
    }

    function checkFindCollectionEventAvailability() {
      var hasCollector = false;
      $("input[name$='recordedBy']").each(function (e) {
        if (this.value != null && this.value != '') {
          hasCollector = true;
        }
      });

      var hasDate = false;
      $("input[name$='eventDate']").each(function (e) {
        if (this.value != null && this.value != '') {
          hasDate = true;
        }
      });

      if (hasCollector || hasDate) {
        return true;
      }

      return false;
    }

    function clearLocalityFields() {
      setFieldValue("locality", "");
      setFieldValue("stateProvince", "");
      setFieldValue("decimalLatitude", "");
      setFieldValue("country", "");
      setFieldValue("decimalLongitude");
      setFieldValue("coordinateUncertaintyInMeters", "");
    }

    function bindToCollectionEvent(externalEventId) {
      if (externalEventId == null) {
        setFieldValue('eventID', "");
        setFieldValue('locationID', "");
        updateEventBindStatus(null);
      } else {
        var url = "${createLink(controller: 'collectionEvent', action: 'getCollectionEventJSON')}?externalCollectionEventId=" + externalEventId + "&institutionCode=${collectionEventInsitutionCode}";
        $.ajax(url).done(function (collectionEvent) {
          clearLocalityFields();
          setFieldValue('eventID', collectionEvent.externalEventId);
          setFieldValue('locationID', collectionEvent.externalLocalityId);
          updateEventBindStatus(collectionEvent.externalEventId);
        });
      }
    }

    function bindToLocality(localityId) {
      if (localityId == null) {
        setFieldValue('locationID', "");
        updateLocalityBindStatus(null);
      } else {
        var url = "${createLink(controller: 'locality', action: 'getLocalityJSON')}?localityId=" + localityId;
        $.ajax(url).done(function (locality) {
          clearLocalityFields();
          setFieldValue('locationID', locality.externalLocalityId)
          updateLocalityBindStatus(locality.externalLocalityId);
        });
      }

    }

    function disableSection(classSelector) {
      $(classSelector + " :input").attr("disabled", "true");
      $(classSelector).css("opacity","0.5");
    }

    function enableSection(classSelector) {
      $(classSelector + " :input").removeAttr("disabled");
      $(classSelector).css("opacity","1");
    }

    function renderLocalityDescription(locality) {
      var s = "";

      if (locality.locality) {
        s += "<em>" + locality.locality + "</em>";
      }

      if (locality.township) {
        if (s) s += ', ';
        s+= locality.township;
      }

      if (locality.state) {
        if (s) s += ', ';
        s+= locality.state;
      }

      if (locality.country) {
        if (s) s += ', ';
        s += locality.country;
      }

      s += " (" + locality.longitude + ", " + locality.latitude + ")";

      return s;
    }

    function updateLocalityBindStatus(externalLocalityId) {

      if($.isNumeric(externalLocalityId)) {
        // its an external event id need to extract from server...
        var url = "${createLink(controller: 'locality', action: 'getLocalityJSON')}?externalLocalityId=" + externalLocalityId;
        $.ajax(url).done(function (locality) {
          var localityDesc = '<span>' + renderLocalityDescription(locality) + '</span>';
          var html = "This specimen is linked with an existing Locality: <br/>" + localityDesc + '<span style="float:right"><a href="#" id="unlinkLocality">Undo</a></span>'
          $("#boundLocality").html(html).css("display","block");
          $("#unlinkLocality").click(function(e) {
            e.preventDefault();
            bindToLocality(null);
          });
          disableSection(".collectionEventSection");
          disableSection(".newLocalitySection");
        });

      } else {
        $("#boundLocality").css("display","none");
        enableSection(".collectionEventSection");
        enableSection(".newLocalitySection");
      }
    }


    function updateEventBindStatus(externalEventId) {

      if($.isNumeric(externalEventId)) {
        // its an external event id
        // need to extract from server...
        var url = "${createLink(controller: 'collectionEvent', action: 'getCollectionEventJSON')}?externalCollectionEventId=" + externalEventId + "&institutionCode=${collectionEventInsitutionCode}";
        $.ajax(url).done(function (collectionEvent) {
          var eventDesc = '<span>' + renderLocalityDescription(collectionEvent) + '<br/>' + collectionEvent.collector + " (" + collectionEvent.eventDate + ")";
          var html = "This specimen is linked with an existing collection event: <br/>" + eventDesc + '</span><span style="float:right"><a href="#" id="unlinkCollectionEvent">Undo</a></span>'
          $("#boundCollectionEvent").html(html).css("display","block");
          $("#unlinkCollectionEvent").click(function(e) {
            e.preventDefault();
            bindToCollectionEvent(null);
          });
          disableSection(".existingLocalitySection");
          disableSection(".newLocalitySection");
        });

      } else {
        $("#boundCollectionEvent").css("display","none");
        enableSection(".existingLocalitySection");
        enableSection(".newLocalitySection");
      }

    }

    function setFieldValue(fieldName, value) {
        var id = "recordValues\\.0\\." + fieldName;
        $("#" + id).val(value);
    }

    function getFieldValue(fieldName) {
      var id = "recordValues\\.0\\." + fieldName;
      return $("#" + id).val();
    }

  </script>

  <style type="text/css">

    button:disabled {
      opacity : 0.4;
      filter: alpha(opacity=40); // msie
    }

    button[disabled]:hover {
      opacity : 0.4;
      filter: alpha(opacity=40); // msie
    }

    .insert-symbol-button {
      font-family: courier;
      color: #DDDDDD;
      background: #4075C2;
      -moz-border-radius: 4px;
      -webkit-border-radius: 4px;
      -o-border-radius: 4px;
      -icab-border-radius: 4px;
      -khtml-border-radius: 4px;
      border-radius: 4px;
    }

    .insert-symbol-button:hover {
      background: #0046AD;
      color: #DDDDDD;
    }

    .zoomPup {
      background-color: pink;
      background-image: url(${resource(dir:'images', file:'zoom.png')});
      background-repeat: no-repeat;
      background-position: bottom right;
      border: 1px solid black;
    }

    .step_heading {
      font-weight: bold;
    }

    .boundInfo {
      background-color: #D2F5C4;
      border: 1px solid #A2F283;
      padding: 5px;
      margin-right: 30px;
    }

    .pan-image {
      height: 400px;
      width: 600px;
      overflow: hidden;
      background-color: #808080;
      float: left;
      cursor: move;
      /* margin: 10px auto;*/
    }

    .new-window-control {
        position: absolute;
        top: 370px;
        right: 7px;
        background: url(${resource(dir:'images', file:'pin-image.png')}) no-repeat;
        height: 24px;
        width: 24px;
        opacity: 0.9;
    }

    .new-window-control a {
        height: 24px;
        width: 24px;
        display: block;
        text-indent: -999em;
        position: absolute;
        outline: none;
    }

    .new-window-control a:hover {
        background: #535353;
        opacity: 0.4;
        filter: alpha(opacity=40);
    }

  </style>
</head>

<body class="sublevel sub-site volunteerportal">


  <cl:navbar selected="expeditions" />

  <header id="page-header">
    <div class="inner">
      <nav id="breadcrumb">
        <ol>
          <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
          <li><a href="${createLink(controller: 'project', action:'list')}"><g:message code="default.projects.label"/></a></li>
          <li><g:link controller="project" action="index" id="${taskInstance?.project?.id}" class="crumb">${taskInstance?.project?.name}</g:link></li>
          <li class="last">${(validator) ? 'Validate' : 'Transcribe'} Task - ${(recordValues?.get(0)?.catalogNumber) ? recordValues?.get(0)?.catalogNumber : taskInstance?.id}</li>
        </ol>
      </nav>
      <hgroup>
        <h1>${(validator) ? 'Validate' : 'Transcribe'} Task: ${taskInstance?.project?.name} (ID: ${taskInstance?.externalIdentifier})</h1>
        <vpf:taskTopicButton task="${taskInstance}" />
      </hgroup>
    </div>
  </header>

<div class="inner">


    <cl:messages />

    <g:hasErrors bean="${taskInstance}">
        <div class="errors">
            There was a problem saving your edit: <g:renderErrors bean="${taskInstance}" as="list" />
        </div>
    </g:hasErrors>

    <g:if test="${taskInstance?.project?.tutorialLinks}">
      ${taskInstance.project.tutorialLinks}
    </g:if>

    %{--<button id="showImageButton">Show image in seperate window</button>--}%
    <g:if test="${taskInstance}">
        <g:form class="transcribeForm">
            <g:hiddenField name="recordId" value="${taskInstance?.id}"/>
            <g:hiddenField name="redirect" value="${params.redirect}"/>

            <g:hiddenField name="recordValues.0.eventID" class="eventID" id="recordValues.0.eventID" value="${recordValues?.get(0)?.eventID?:TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.eventID, template)?.defaultValue}"/>
            <g:hiddenField name="recordValues.0.locationID" class="locationID" id="recordValues.0.locationID" value="${recordValues?.get(0)?.locationID?:TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.locationID, template)?.defaultValue}"/>

            <div class="dialog" style="clear: both">
                <g:each in="${taskInstance.multimedia}" var="m">
                    <g:set var="imageUrl" value="${grailsApplication.config.server.url}${m.filePath}"/>
                    <g:set var="imageInfo" value="${imageMetaData?.getAt(m.id) ?: [height: 0, width: 0]}" />
                    <div id="imageContainer" style="float: left; width:600px; height: 400px">
                        <div class="pan-image" style="margin-top: 0px; padding-top: 0px">
                            <img src="${imageUrl}" alt="Task Image" image-height="${imageInfo.height}" image-width="${imageInfo.width}"/>
                            <div class="map-control">
                                <a id="panleft" href="#left" class="left">Left</a>
                                <a id="panright" href="#right" class="right">Right</a>
                                <a id="panup" href="#up" class="up">Up</a>
                                <a id="pandown" href="#down" class="down">Down</a>
                                <a id="zoomin" href="#zoom" class="zoom">Zoom</a>
                                <a id="zoomout" href="#zoom_out" class="back">Back</a>
                            </div>
                            <div class="new-window-control">
                              <a id="pinImage" href="#" title="Fix the image in place in the browser window">Pin image in place</a>
                            </div>
                        </div>
                    </div>

                </g:each>

                <div id="taskMetadata">
                    <div id="institutionLogo"></div>
                    <h3>Specimen Information</h3>
                    <ul>
                        <li><div>Institution:</div> <span id="institutionCode">${recordValues?.get(0)?.institutionCode}</span></li>
                        <li><div>Project:</div> ${taskInstance?.project?.name}</li>
                        <li><div>Catalogue No.:</div> ${recordValues?.get(0)?.catalogNumber}</li>
                        <li><div>Taxa:</div> ${recordValues?.get(0)?.scientificName}</li>
                        <g:hiddenField name="recordValues.0.basisOfRecord" class="basisOfRecord" id="recordValues.0.basisOfRecord"
                                       value="${recordValues?.get(0)?.basisOfRecord?:TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.basisOfRecord, template)?.defaultValue}"/>
                    </ul>

                    <span style="">
                        <button id="show_task_selector" href="#task_selector" style="">Copy values from a previous task</button>
                        <a href="#" class="fieldHelp" title="Clicking this button will allow you to select a previously transcribed task to copy values from"><span class="help-container">&nbsp;</span></a>
                    </span>
                  <div style="display: none;">
                    <div id="task_selector" >
                      <div id="task_selector_content">
                      </div>
                    </div>
                  </div>

                    <table>
                        <thead>
                            <tr>
                                <th>
                                    <h3>1. Transcribe All Text</h3> &ndash; Record exactly what appears in the labels so we have a searchable reference for them
                                </th>
                            </tr>
                        </thead>
                        <tbody>

                            <tr>
                              <td style="padding-bottom:0px; margin-bottom:0px; margin-top: 0px; padding-top:0px">
                                All text
                              </td>
                            </tr>
                            <tr>
                                <td style="padding-bottom: 0px; margin-top:0px">
                                    <g:textArea name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks" rows="6" cols="38" />
                                    <a href='#' class='fieldHelp' title='Transcribe all text as it appears in the labels''><span class='help-container'>&nbsp;</span></a>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-top: 0px;">
                                    <button class="insert-symbol-button" symbol="&deg;" title="Insert a degree symbol" />
                                    <button class="insert-symbol-button" symbol="&#39;" title="Insert an apostrophe (minutes) symbol" />
                                    <button class="insert-symbol-button" symbol="&quot;" title="Insert a quote (minutes) symbol" />
                                    <button class="insert-symbol-button" symbol="&#x2642;" title="Insert the male gender symbol" />
                                    <button class="insert-symbol-button" symbol="&#x2640;" title="Insert the female gender symbol" />
                                </td>
                            </tr>

                            <tr>
                              <td style="padding-bottom:0px; margin-bottom:0px; padding-top:0px;">
                                Verbatim Locality
                              </td>
                            </tr>
                            <tr>
                                <td style="padding-top:0px; margin-top: 0px; margin-bottom: 0px; padding-bottom: 0px">
                                    <textarea name="recordValues.0.verbatimLocality" cols="38" rows="2" class="verbatimLocality noAutoComplete" id="recordValues.0.verbatimLocality">${recordValues?.get(0)?.verbatimLocality}</textarea>
                                    <a href='#' class='fieldHelp' title='Enter (or cut and paste from the box above) the locality information into this box'><span class='help-container'>&nbsp;</span></a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div style="clear:both;"></div>

                <div id="collectionEventFields">

                    <table style="width: 100%">
                        <thead>
                            <tr>
                                <th colspan="4">
                                  <h3>2. Collection Event</h3> &ndash; a collecting event is a unique combination of who (collector), when (date) and where (locality) a specimen was collected
                                  <a style="float:right" class="closeSection" href="#">Shrink</a>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                        <tr>
                          <td style="padding-top: 0px; padding-bottom: 0px; font-size: 1.2em">
                            <span class="step_heading">Step 1</span>
                          </td>
                        </tr>
                        <tr class="prop">
                          <td class="name"/>
                          <td class="name" style="text-align: left;" >
                            <span class="step_heading">Enter Collector and Event date</span>
                          </td>
                        </tr>
                        <tr class="prop">
                          <td class="name">
                            Collector(s)
                          </td>
                          <td class="value" style="" colspan="3" >
                            <g:each in="${0..3}" var="idx">
                              <input style="width:170px" type="text" name="recordValues.${idx}.recordedBy" maxlength="200" class="recordedBy autocomplete ac_input" id="recordValues.${idx}.recordedBy" value="${recordValues[idx]?.recordedBy?.encodeAsHTML()}" />&nbsp;
                              <g:hiddenField name="recordValues.${idx}.recordedByID" class="recordedByID" id="recordValues.${idx}.recordedByID" value="${recordValues[idx]?.recordedByID?.encodeAsHTML()}" />
                            </g:each>
                          </td>
                        </tr>

                        <g:fieldFromTemplateField templateField="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.eventDate, template)}" recordValues="${recordValues}" />

                        <tr>
                          <td style="padding-top: 0px; padding-bottom: 0px; font-size: 1.2em; vertical-align: top;">
                            <span class="step_heading">Step 2&nbsp;-&nbsp;EITHER</span>
                          </td>
                          <td class="name collectionEventSection" style="text-align: left; vertical-align: top" >
                            <span><b>a.</b>&nbsp;</span><button id="show_collection_event_selector">Find existing collection event</button>
                            <div style="display: none;">
                              <a id="collectionEventSelectorLink" href="#collection_event_selector"></a>
                              <div id="collection_event_selector" >
                                <div id="collection_event_selector_content">
                                </div>
                              </div>
                            </div>
                            <a href="#" class="fieldHelp" title="Find an existing collection event based on the collector names and the event date you have entered."><span class="help-container">&nbsp;</span></a>
                          </td>
                          <td colspan="3" style="border-bottom: none">
                            <div id="boundCollectionEvent" class="boundInfo" style="display:none"></div>
                          </td>

                        </tr>

                        <tr class="prop existingLocalitySection">
                          <td class="name" style="text-align: left; padding-left: 50px" >
                            <span class="step_heading">OR</span>
                          </td>
                          <td class="name" colspan="3" style="text-align: left;" colspan="3" >
                            <span class="step_heading">b. Create a new Collection event</span> &ndash; you have already entered a collector and date above so now you need to enter a locality
                          </td>
                        </tr>

                        <tr class='prop existingLocalitySection'>
                            <td/>
                            <td class="name" style="text-align: left" >
                              <span><b>i. </b>&nbsp;</span><button id="showLocalitySelector">Find existing locality</button>
                              <div style="display: none;">
                                <a id="locality_selector_link" href="#locality_selector"></a>
                                <div id="locality_selector" >
                                  <div id="locality_selector_content">
                                  </div>
                                </div>
                              </div>
                              <span>&nbsp;<b>OR</b></span>
                            </td>
                            <td colspan="3" style="border-bottom: none">
                              <div id="boundLocality" class="boundInfo" style="display:none"></div>
                            </td>
                        </tr>

                        <tr class="prop newLocalitySection">
                          <td/>
                          <td colspan="3"><b>ii. Create a new locality</b>
                            <a href="#" class="fieldHelp" title="if no existing locality can be found use the mapping tool to create a new one. Type the location details in the entry box in the tool until you get a
                                                      suitable location. Please also choose a suitable coordinate uncertainty in metres"><span class="help-container">&nbsp;</span></a>
                            </td>
                        </tr>

                        <tr class="prop newLocalitySection">
                          <td/>
                          <td>
                            <button id="geolocate" href="#mapWidgets" title="Show geolocate tools popup">Use mapping tool</button>
                          </td>
                        </tr>

                        <tr class="prop newLocalitySection" >
                          <g:fieldTDPair fieldType="${DarwinCoreField.locality}" recordValues="${recordValues}" task="${taskInstance}" />
                          <g:fieldTDPair fieldType="${DarwinCoreField.stateProvince}" recordValues="${recordValues}" task="${taskInstance}" />
                        </tr>

                        <tr class="prop newLocalitySection">
                          <g:fieldTDPair fieldType="${DarwinCoreField.decimalLatitude}" recordValues="${recordValues}" task="${taskInstance}" />
                          <g:fieldTDPair fieldType="${DarwinCoreField.country}" recordValues="${recordValues}" task="${taskInstance}" />
                        </tr>

                        <tr class="prop newLocalitySection">
                          <g:fieldTDPair fieldType="${DarwinCoreField.decimalLongitude}" recordValues="${recordValues}" task="${taskInstance}" />
                          <g:fieldTDPair fieldType="${DarwinCoreField.coordinateUncertaintyInMeters}" recordValues="${recordValues}" task="${taskInstance}" />
                        </tr>

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
                                    <textarea name="address" id="address" size="32" rows="2" value=""></textarea>
                                    <input id="locationSearch" type="button" value="Search" style="display:table-cell;vertical-align: top;"/>
                                    <div class="searchHint">If the initial search doesn’t find an existing locality try expanding abbreviations, inserting or removing spaces and commas or simplifying the locality description. Choose a location, or move the pin to a location that you think represents the Verbatim Locality as sensibly as possible. Where the map tool cant find a location simply fill in the State/territory and Country fields</div>
                                </div>
                                <h3>Coordinate Uncertainty</h3>
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
                                        accurately then the uncertainty value can be smaller"><span class="help-container">&nbsp;</span></a>
                                    </div>
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
                </div>

                <div id="transcribeFields">
                    <table style="width: 100%">
                        <thead>
                        <tr style="width: 950px">
                          <th style="width:950px">
                            <h3>3. Miscellaneous</h3> &ndash; This section is for a range of fields. Many labels will not contain information for any or all of this fields.
                            <a style="float:right" class="closeSection" href="#">Shrink</a>
                          </th></tr>
                        </thead>
                        <tbody>
                        <g:each in="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.miscellaneous, template, [sort:'displayOrder'])}" var="field">
                            <g:fieldFromTemplateField templateField="${field}" recordValues="${recordValues}"/>
                        </g:each>
                        </tbody>
                    </table>

                    <table style="width: 100%">
                        <thead>
                        <tr style="width:950px">
                          <th style="width:950px">
                            <h3>4. Identification</h3> &ndash; If a label contains information on the name of the organism then record the name and associated information in this section
                            <a style="float:right" class="closeSection" href="#">Shrink</a>
                          </th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.identification, template, [sort:'displayOrder'])}" var="field">
                            <g:fieldFromTemplateField templateField="${field}" recordValues="${recordValues}"/>
                        </g:each>
                        </tbody>
                    </table>
                    <table style="width: 100%">
                        <thead>
                        <tr style="width:950px">
                          <th style="width:950px">
                            <h3>5. Notes</h3> &ndash; Record any comments here that may assist in validating this specimen
                            <a style="float:right" class="closeSection" href="#">Shrink</a>
                          </th>
                        </tr>
                        </thead>
                        <tbody>
                            <tr class="prop">
                                <td class="name">${(validator) ? 'Transcriber' : 'Your'} Notes</td>
                                <td class="value"><g:textArea name="recordValues.0.transcriberNotes" value="${recordValues?.get(0)?.transcriberNotes}"
                                    id="transcriberNotes" rows="5" cols="40" style="width: 100%"/></td>
                            </tr>
                            <g:if test="${validator}">
                                <tr class="prop">
                                <td class="name">Validator Notes</td>
                                <td class="value"><g:textArea name="recordValues.0.validatorNotes" value="${recordValues?.get(0)?.validatorNotes}"
                                    id="transcriberNotes" rows="5" cols="40" style="width: 100%"/></td>
                            </tr>
                            </g:if>
                        </tbody>
                    </table>

                    <cl:taskComments task="${taskInstance}"/>

                </div>
            </div>

        <g:if test="${!isReadonly}">
            <div class="vp-buttons" style="clear: both">
                <g:hiddenField name="id" value="${taskInstance?.id}"/>
                <g:if test="${validator}">
                    <span class="button"><g:actionSubmit class="validate" action="validate"
                             value="${message(code: 'default.button.validate.label', default: 'Validate')}"/></span>
                    <span class="button"><g:actionSubmit class="dontValidate" action="dontValidate"
                             value="${message(code: 'default.button.dont.validate.label', default: 'Dont validate')}"/></span>
                    <span class="button"><button id="showNextFromProject" class="skip">Skip</button></span>
                    <cl:validationStatus task="${taskInstance}" />
                </g:if>
                <g:else>
                    <span class="button">
                        <g:actionSubmit class="save" action="save" value="${message(code: 'default.button.save.label', default: 'Submit for validation')}"/>
                    </span>
                    <span class="button">
                        <g:actionSubmit class="savePartial button" action="savePartial" value="${message(code: 'default.button.save.partial.label', default: 'Save unfinished record')}"/></span>
                    <cl:isLoggedIn>
                        <span class="button"><button id="showNextFromProject" class="skip">Skip</button></span>
                    </cl:isLoggedIn>
                </g:else>
            </div>
          </g:if>

            <cl:timeoutPopup />
        </g:form>
    </g:if>
    <g:else>
        No tasks loaded for this project !
    </g:else>
  </div>

  <div id="floatingImage" style="display:none"></div>

</body>
</html>
