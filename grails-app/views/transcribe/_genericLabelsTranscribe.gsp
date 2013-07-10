<%@ page import="au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />

<style type="text/css">

    #image-container {
        width: 100%;
        height: 400px;
        overflow: hidden;
    }

    #image-container img {
        max-width: inherit !important;
    }

    .transcribeSectionHeaderLabel {
        font-weight: bold;
    }

    .prop .name {
        vertical-align: top;
    }

</style>

<div class="container-fluid">
    <div class="row-fluid">
        <div class="span8">
            <div class="well well-small">
                <g:set var="multimedia" value="${taskInstance.multimedia.first()}" />
                <g:imageViewer multimedia="${multimedia}" />
            </div>
        </div>
        <div class="span4">
            <div class="well well-small">
                <div id="taskMetadata">
                    <div id="institutionLogo"></div>

                    <div class="transcribeSectionHeaderLabel">Specimen Information</div>
                    <ul>
                        <li><span class="metaDataLabel">Institution:</span> <span id="institutionCode">${recordValues?.get(0)?.institutionCode}</span></li>
                        <li><span class="metaDataLabel">Project:</span> ${taskInstance?.project?.name}</li>
                        <li><span class="metaDataLabel">Catalogue No.:</span> ${recordValues?.get(0)?.catalogNumber}</li>
                        <li><span class="metaDataLabel">Taxa:</span> ${recordValues?.get(0)?.scientificName}</li>
                        <g:hiddenField name="recordValues.0.basisOfRecord" class="basisOfRecord" id="recordValues.0.basisOfRecord"
                                       value="${recordValues?.get(0)?.basisOfRecord ?: TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.basisOfRecord, template)?.defaultValue}"/>
                    </ul>

                    <span>
                        <button class="btn btn-small" id="show_task_selector" href="#task_selector" style="">Copy values from a previous task</button>
                        <a href="#" class="fieldHelp" title="Clicking this button will allow you to select a previously transcribed task to copy values from"><span class="help-container">&nbsp;</span></a>
                    </span>

                    <div style="display: none;">
                        <div id="task_selector">
                            <div id="task_selector_content">
                            </div>
                        </div>
                    </div>

                </div>
            </div>
            <div class="well well-small">
                <g:set var="allTextField" value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}" />
                <span class="transcribeSectionHeaderLabel">1. ${allTextField?.label ?: "Transcribe All Text"}</span> &ndash; Record exactly what appears in the labels so we have a searchable reference for them
                <a href='#' class='fieldHelp' title='${allTextField?.helpText ?: "Transcribe all text as it appears in the labels"}'><span class='help-container'>&nbsp;</span></a>
                <g:textArea class="span12" name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks" rows="6" cols="42"/>
                <div>
                    <button class="insert-symbol-button" symbol="&deg;" title="Insert a degree symbol"></button>
                    <button class="insert-symbol-button" symbol="&#39;" title="Insert an apostrophe (minutes) symbol"></button>
                    <button class="insert-symbol-button" symbol="&quot;" title="Insert a quote (minutes) symbol"></button>
                    <button class="insert-symbol-button" symbol="&#x2642;" title="Insert the male gender symbol"></button>
                    <button class="insert-symbol-button" symbol="&#x2640;" title="Insert the female gender symbol"></button>
                </div>
            </div>
        </div>
    </div>

    <div class="well well-small transcribeSection">
        <table style="width: 100%; margin-bottom: 0">
            <thead>
                <tr>
                    <th colspan="4">
                        <span class="transcribeSectionHeaderLabel">2. Collection Event</span> &ndash; a collecting event is a unique combination of who (collector), when (date) and where (locality) a specimen was collected
                        <a style="float:right" class="closeSection" href="#">Shrink</a>
                    </th>
                </tr>
            </thead>
            <tbody>
                <tr class="prop">
                    <g:set var="localityField" value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.verbatimLocality)}" />
                    <td class="name" style="padding-bottom:0px; margin-bottom:0px; padding-top:0px;">
                         ${localityField?.label ?: "Verbatim Locality"}
                    </td>
                    <td style="padding-top:0px; margin-top: 0px; margin-bottom: 0px; padding-bottom: 0px">
                        <textarea name="recordValues.0.verbatimLocality" cols="38" rows="4" class="span4 verbatimLocality" id="recordValues.0.verbatimLocality">${recordValues?.get(0)?.verbatimLocality}</textarea>
                        <a href='#' class='fieldHelp' title='${localityField?.helpText ?: "Enter (or cut and paste from the box above) the locality information into this box"}'><span class='help-container'>&nbsp;</span>
                        </a>
                    </td>
                    <td colspan="2" style="padding: 0">
                        <table>
                            <tr>
                                <g:fieldTDPair fieldType="${DarwinCoreField.stateProvince}" recordValues="${recordValues}" task="${taskInstance}"/>
                            </tr>
                            <tr>
                                <g:fieldTDPair fieldType="${DarwinCoreField.country}" recordValues="${recordValues}" task="${taskInstance}"/>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="prop">
                    <td class="name">
                        ${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.recordedBy)?.label ?: "Collector(s)"}
                    </td>
                    <td class="value" colspan="3">
                        <g:each in="${0..3}" var="idx">
                            <input type="text" name="recordValues.${idx}.recordedBy" maxlength="200" class="span2 recordedBy autocomplete ac_input" id="recordValues.${idx}.recordedBy" value="${recordValues[idx]?.recordedBy?.encodeAsHTML()}"/>&nbsp;
                            <g:hiddenField name="recordValues.${idx}.recordedByID" class="recordedByID" id="recordValues.${idx}.recordedByID" value="${recordValues[idx]?.recordedByID?.encodeAsHTML()}"/>
                        </g:each>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

</div>


<r:script>

    $("#show_task_selector").click(function(e) {
        e.preventDefault();
        showModal({
            url: "${createLink(controller: 'task', action:'taskBrowserFragment', params: [projectId: taskInstance.project.id, taskId: taskInstance.id])}",
            width:700,
            height:600,
            hideHeader: false,
            title: 'Previously transcribed tasks'

        });
    });

    function setupPanZoom() {
        var target = $("#image-container img");

        target.panZoom({
            pan_step:10,
            zoom_step:10,
            min_width:200,
            min_height:200,
            mousewheel:true,
            mousewheel_delta:2,
            'zoomIn':$('#zoomin'),
            'zoomOut':$('#zoomout'),
            'panUp':$('#pandown'),
            'panDown':$('#panup'),
            'panLeft':$('#panright'),
            'panRight':$('#panleft')
        });

        target.panZoom('fit');
    }

    setupPanZoom();

    $("#pinImage").click(function (e) {
        e.preventDefault();
        if ($("#image-container").css("position") == 'fixed') {
            $("#image-container").css({"position":"relative", top:'inherit', left:'inherit', 'border':'none' });
            $(".pin-image-control").css({'background-image':"url(${resource(dir:'images', file:'pin-image.png')})"});
            $(".pin-image-control a").attr("title", "Fix the image in place in the browser window");
        } else {
            $("#image-container").css({"position":"fixed", top:10, left:10, "z-index":600, 'border':'2px solid #535353' });
            $(".pin-image-control").css("background-image", "url(${resource(dir:'images', file:'unpin-image.png')})");
            $(".pin-image-control a").attr("title", "Return the image to its normal position");
        }

    });


</r:script>