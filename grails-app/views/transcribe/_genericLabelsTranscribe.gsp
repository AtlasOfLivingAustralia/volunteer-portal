<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
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
                <a href="#" class="fieldHelp" title='${allTextField?.helpText ?: "Transcribe all text as it appears in the labels"}'><span class="help-container">&nbsp;</span></a>
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
        <div class="row-fluid transcribeSectionHeader">
            <div class="span12">
                <span class="transcribeSectionHeaderLabel">2. Collection Event</span> &ndash; a collecting event is a unique combination of who (collector), when (date) and where (locality) a specimen was collected
                <a style="float:right" class="closeSection" href="#">Shrink</a>
            </div>
        </div>
        <div class="transcribeSectionBody">

            <div class="row-fluid">

                <div class="span6">
                    <g:renderFieldBootstrap fieldType="${DarwinCoreField.verbatimLocality}" recordValues="${recordValues}" task="${taskInstance}" labelClass="span4" valueClass="span8" />
                </div>

                <div class="span6">
                    <g:renderFieldBootstrap fieldType="${DarwinCoreField.stateProvince}" recordValues="${recordValues}" task="${taskInstance}" labelClass="span4" valueClass="span8" />
                    <g:renderFieldBootstrap fieldType="${DarwinCoreField.country}" recordValues="${recordValues}" task="${taskInstance}" labelClass="span4" valueClass="span8" />
                </div>

            </div>

            <div class="row-fluid">
                <div class="span2">
                    ${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.recordedBy)?.label ?: "Collector(s)"}
                </div>
                <div class="span10">
                    <div class="row-fluid">
                        <g:each in="${0..3}" var="idx">
                            <div class="span3">
                                <input type="text" name="recordValues.${idx}.recordedBy" maxlength="200" class="span12 recordedBy" id="recordValues.${idx}.recordedBy" value="${recordValues[idx]?.recordedBy?.encodeAsHTML()}"/>&nbsp;
                                <g:hiddenField name="recordValues.${idx}.recordedByID" class="recordedByID" id="recordValues.${idx}.recordedByID" value="${recordValues[idx]?.recordedByID?.encodeAsHTML()}"/>
                            </div>
                        </g:each>
                    </div>
                </div>
            </div>

            <g:templateFieldsForCategory category="${FieldCategory.collectionEvent}" task="${taskInstance}" recordValues="${recordValues}" labelClass="span4" valueClass="span8" />

        </div>
    </div>

    <g:renderFieldCategorySection category="${FieldCategory.location}" task="${taskInstance}" recordValues="${recordValues}" title="3. Interpreted Location" description="Use the mapping tool before attempting to enter values manually">
        <button class="btn btn-small btn-info" id="btnGeolocate">Use mapping tool</button>
    </g:renderFieldCategorySection>

    <g:renderFieldCategorySection category="${FieldCategory.miscellaneous}" task="${taskInstance}" recordValues="${recordValues}" title="4. Miscellaneous" description="This section is for a range of fields. Many labels will not contain information for any or all of this fields." />

    <g:renderFieldCategorySection category="${FieldCategory.identification}" task="${taskInstance}" recordValues="${recordValues}" title="4. Miscellaneous" description="This section is for a range of fields. Many labels will not contain information for any or all of this fields." />

</div>


<r:script>

    $("#show_task_selector").click(function(e) {
        e.preventDefault();
        showPreviousTaskBrowser();
    });

    $("#btnGeolocate").click(function(e) {
        e.preventDefault();
        showGeolocationTool();
    });

</r:script>