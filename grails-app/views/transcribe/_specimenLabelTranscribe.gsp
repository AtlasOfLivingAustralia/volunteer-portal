<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>

<g:set var="collectionEventInsitutionCode"
       value="${taskInstance?.project?.collectionEventLookupCollectionCode ?: taskInstance?.project.featuredOwner}"/>

<r:require module="gmaps"/>

<div class="container-fluid">
    <div class="row">
        <div class="col-md-8">
            <div class="panel panel-default">
                <div class="panel-body">
                    <g:set var="multimedia" value="${taskInstance.multimedia.first()}"/>
                    <g:imageViewer multimedia="${multimedia}"/>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="panel panel-default">
                <div class="panel-body">
                    <div id="taskMetadata">
                        <div id="institutionLogo"></div>

                        <div class="transcribeSectionHeaderLabel">Specimen Information</div>
                        <ul>
                            <li><span class="metaDataLabel">Institution:</span> <span
                                    id="institutionCode">${recordValues?.get(0)?.institutionCode}</span></li>
                            <li><span class="metaDataLabel">Project:</span> ${taskInstance?.project?.name}</li>
                            <li><span class="metaDataLabel">Catalogue No.:</span> ${recordValues?.get(0)?.catalogNumber}
                            </li>
                            <li><span class="metaDataLabel">Taxa:</span> ${recordValues?.get(0)?.scientificName}</li>
                            <g:hiddenField name="recordValues.0.basisOfRecord" class="basisOfRecord"
                                           id="recordValues.0.basisOfRecord"
                                           value="${recordValues?.get(0)?.basisOfRecord ?: TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.basisOfRecord, template)?.defaultValue}"/>
                        </ul>

                        <span>
                            <button type="button" class="btn btn-info btnCopyFromPreviousTask" href="#task_selector"
                                    style="">Copy values from a previous task</button>
                            <a href="#" class="btn btn-default btn-xs fieldHelp"
                               title="Clicking this button will allow you to select a previously transcribed task to copy values from"><i
                                    class="help-container fa fa-question">
                        </span>

                        <div style="display: none;">
                            <div id="task_selector">
                                <div id="task_selector_content">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="row">
                        <g:set var="allTextField"
                               value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}"/>
                        <div class="col-md-12">
                            <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${allTextField?.label ?: "Transcribe All Text"}</span> &ndash; Record exactly what appears in the labels so we have a searchable reference for them
                        </div>

                        <div class="col-md-12" style="margin-top: 5px">
                            All text
                            <a href="#" class="btn btn-default btn-xs fieldHelp"
                               title='${allTextField?.helpText ?: "Transcribe all text as it appears in the labels"}'><i
                                    class="fa fa-question help-container"></i></a>
                        </div>

                        <div class="col-md-12">
                            <g:textArea class="form-control" name="recordValues.0.occurrenceRemarks"
                                        value="${recordValues?.get(0)?.occurrenceRemarks}"
                                        id="recordValues.0.occurrenceRemarks"
                                        rows="4" cols="42"/>
                        </div>

                        <div class="col-md-12">
                            <button type="button" class="insert-symbol-button" symbol="&deg;"
                                    title="Insert a degree symbol"></button>
                            <button type="button" class="insert-symbol-button" symbol="&#39;"
                                    title="Insert an apostrophe (minutes) symbol"></button>
                            <button type="button" class="insert-symbol-button" symbol="&quot;"
                                    title="Insert a quote (minutes) symbol"></button>
                            <button type="button" class="insert-symbol-button" symbol="&#x2642;"
                                    title="Insert the male gender symbol"></button>
                            <button type="button" class="insert-symbol-button" symbol="&#x2640;"
                                    title="Insert the female gender symbol"></button>
                        </div>

                        <div class="col-md-12" style="margin-top: 5px">
                            Verbatim Locality <a href='#' class='btn btn-default btn-xs fieldHelp'
                                                 title='Enter (or cut and paste from the box above) the locality information into this box'><i
                                    class='fa fa-question help-container'></i></a>
                        </div>

                        <div class="col-md-12">
                            <textarea class="form-control" name="recordValues.0.verbatimLocality" cols="38" rows="2"
                                      class="verbatimLocality noAutoComplete"
                                      id="recordValues.0.verbatimLocality">${recordValues?.get(0)?.verbatimLocality}</textarea>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <g:hiddenField name="recordValues.0.eventID" class="eventID" id="recordValues.0.eventID"
                   value="${recordValues?.get(0)?.eventID ?: TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.eventID, template)?.defaultValue}"/>
    <g:hiddenField name="recordValues.0.locationID" class="locationID" id="recordValues.0.locationID"
                   value="${recordValues?.get(0)?.locationID ?: TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.locationID, template)?.defaultValue}"/>

    <div class="panel panel-default transcribeSection">
        <div class="panel-body">
            <div class="row transcribeSectionHeader">
                <div class="col-md-12">
                    <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Collection Event</span> &ndash; a collecting event is a unique combination of who (collector), when (date) and where (locality) a specimen was collected
                    <a class="closeSectionLink" href="#">Shrink</a>
                </div>
            </div>

            <div class="transcribeSectionBody">

                <div class="row">
                    <div class="col-md-2">
                        <h4>Step 1</h4>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-10 col-md-offset-2">
                        <strong>Enter Collector and Event Date</strong>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-2">
                        ${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.recordedBy)?.label ?: "Collector(s)"}
                    </div>

                    <div class="col-md-10">
                        <div class="row">
                            <g:each in="${0..3}" var="idx">
                                <div class="col-md-3">
                                    <input type="text" name="recordValues.${idx}.recordedBy" maxlength="200"
                                           class="form-control recordedBy autocomplete"
                                           id="recordValues.${idx}.recordedBy"
                                           value="${recordValues[idx]?.recordedBy?.encodeAsHTML()}"/>&nbsp;
                                <g:hiddenField name="recordValues.${idx}.recordedByID" class="recordedByID"
                                               id="recordValues.${idx}.recordedByID"
                                               value="${recordValues[idx]?.recordedByID?.encodeAsHTML()}"/>
                                </div>
                            </g:each>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-12">
                        <g:renderFieldBootstrap fieldType="${DarwinCoreField.eventDate}" recordValues="${recordValues}"
                                                task="${taskInstance}" labelClass="col-md-2" valueClass="col-md-3"/>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-1">
                        <h4>Step 2 -</h4>
                    </div>

                    <div class="col-md-1">
                        <h4>EITHER</h4>
                    </div>

                    <div class="col-md-6 collectionEventSection">
                        <strong>a.</strong>&nbsp; <button type="button" class="btn btn-default"
                                                          id="show_collection_event_selector">Find existing collection event</button>
                    </div>

                    <div class="col-md-4">
                        <div id="boundCollectionEvent" class="alert alert-success" style="display:none"></div>
                    </div>
                </div>

                <div class="existingLocalitySection">
                    <div class="row">
                        <div class="col-md-1 col-md-offset-1">
                            <h4>OR</h4>
                        </div>

                        <div class="col-md-10">
                            <strong>b. Create a new Collection Event</strong> &ndash; you have already entered a collector and date above so now you need to enter a locality
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 col-md-offset-2">
                            <strong>i.</strong>&nbsp;<button type="button" class="btn btn-default"
                                                             id="showLocalitySelector">Find existing locality</button>&nbsp;<strong>OR</strong>
                        </div>

                        <div class="col-md-4">
                            <div id="boundLocality" class="alert alert-success" style="display:none"></div>
                        </div>
                    </div>
                </div>

                <div class="newLocalitySection">
                    <div class="row">
                        <div class="col-md-10 col-md-offset-2">
                            <strong>ii.&nbsp;Create a new locality</strong>
                        </div>
                    </div>

                    <div class="row" style="margin-bottom: 10px">
                        <div class="col-md-10 col-md-offset-2">
                            <button type="button" class="btn btn-small btn-info"
                                    id="btnGeolocate">Mapping tool <i class="fa fa-map-pin"></i></button>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <g:renderFieldBootstrap fieldType="${DarwinCoreField.locality}"
                                                    recordValues="${recordValues}"
                                                    task="${taskInstance}" labelClass="col-md-4" valueClass="col-md-8"/>
                        </div>

                        <div class="col-md-6">
                            <g:renderFieldBootstrap fieldType="${DarwinCoreField.stateProvince}"
                                                    recordValues="${recordValues}" task="${taskInstance}"
                                                    labelClass="col-md-4"
                                                    valueClass="col-md-8"/>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <g:renderFieldBootstrap fieldType="${DarwinCoreField.decimalLatitude}"
                                                    recordValues="${recordValues}" task="${taskInstance}"
                                                    labelClass="col-md-4"
                                                    valueClass="col-md-8"/>
                        </div>

                        <div class="col-md-6">
                            <g:renderFieldBootstrap fieldType="${DarwinCoreField.country}"
                                                    recordValues="${recordValues}"
                                                    task="${taskInstance}" labelClass="col-md-4" valueClass="col-md-8"/>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <g:renderFieldBootstrap fieldType="${DarwinCoreField.decimalLongitude}"
                                                    recordValues="${recordValues}" task="${taskInstance}"
                                                    labelClass="col-md-4"
                                                    valueClass="col-md-8"/>
                        </div>

                        <div class="col-md-6">
                            <g:renderFieldBootstrap fieldType="${DarwinCoreField.coordinateUncertaintyInMeters}"
                                                    recordValues="${recordValues}" task="${taskInstance}"
                                                    labelClass="col-md-4"
                                                    valueClass="col-md-8"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <g:renderFieldCategorySection category="${FieldCategory.miscellaneous}" task="${taskInstance}"
                                  recordValues="${recordValues}" title="Miscellaneous"
                                  description="This section is for a range of fields. Many labels will not contain information for any or all of these fields."/>

    <g:renderFieldCategorySection category="${FieldCategory.identification}" task="${taskInstance}"
                                  recordValues="${recordValues}" title="Identification"
                                  description="If a label contains information on the name of the organism then record the name and associated information in this section"/>

</div>

<r:script>

    $("#show_collection_event_selector").click(function(e) {
        e.preventDefault();
        showCollectionEventSelector();
    });

    $("#showLocalitySelector").click(function(e) {
        e.preventDefault();
            showLocalitySelector();
    });

    function showLocalitySelector() {
        var verbatimLocality = $('#recordValues\\.0\\.verbatimLocality').val();
        verbatimLocality = verbatimLocality.replace(/(\r\n|\n|\r)/gm, ' ');
        var contentUrl = "${createLink(controller: 'locality', action: 'searchFragment', params: [taskId: taskInstance.id])}&verbatimLocality=" + encodeURIComponent(verbatimLocality);
        bvp.showModal({
            url: contentUrl,
            width:800,
            height:650,
            title: 'Find Existing Collecting Event'
        });
    }

    function showCollectionEventSelector() {
        if (checkFindCollectionEventAvailability()) {
            var queryParams = "";
            for (i = 0; i < 4; i++) {
              queryParams += "&collector" + i + "=" + encodeURIComponent($('#recordValues\\.' + i + '\\.recordedBy').val());
            }
            queryParams += '&eventDate=' + encodeURIComponent($('#recordValues\\.0\\.eventDate').val());
            var contentUrl = "${createLink(controller: 'collectionEvent', action: 'searchFragment', params: [taskId: taskInstance.id])}" + queryParams;

            bvp.showModal({
                url: contentUrl,
                width:800,
                height:650,
                hideHeader: false,
                title: 'Find Existing Collecting Event',
                onShown: function() {
                }
            });

        } else {
            alert("You must first enter either a date or at least one collector!")
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

    function updateLocalityBindStatus(externalLocalityId) {

        if($.isNumeric(externalLocalityId)) {
            // its an external event id need to extract from server...
            var url = "${createLink(controller: 'locality', action: 'getLocalityJSON')}?externalLocalityId=" + externalLocalityId;
            $.ajax(url).done(function (locality) {
                var localityDesc = '<span>' + renderLocalityDescription(locality) + '</span>';
                var html = "This specimen is linked with an existing Locality: <br/>" + localityDesc + '<span
        style="float:right"><a href="#" id="unlinkLocality">Undo</a></span>'
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
var html = "This specimen is linked with an existing collection event: <br/>" + eventDesc + '</span><span
        style="float:right"><a href="#" id="unlinkCollectionEvent">Undo</a></span>'
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

    function setFieldValue(fieldName, value) {
        var id = "recordValues\\.0\\." + fieldName;
        $("#" + id).val(value);
    }

    function getFieldValue(fieldName) {
      var id = "recordValues\\.0\\." + fieldName;
      return $("#" + id).val();
    }

    updateBindStatus();

</r:script>