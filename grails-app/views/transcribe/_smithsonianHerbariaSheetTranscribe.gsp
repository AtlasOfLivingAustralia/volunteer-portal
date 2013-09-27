<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />

<div class="container-fluid">
    <div class="row-fluid">
        <div class="span12">
            <div class="well well-small">
                <g:set var="multimedia" value="${taskInstance.multimedia.first()}" />
                <g:imageViewer multimedia="${multimedia}" />
            </div>
        </div>
    </div>
    <div id="taskMetadata" class="row-fluid">
        <div class="span12">
            <div class="well well-small">
                <span class="metaDataLabel">Catalogue No.:</span> ${recordValues?.get(0)?.catalogNumber}
                <span class="metaDataLabel">Taxa:</span> ${recordValues?.get(0)?.scientificName}

                <span>
                    <button class="btn" id="show_task_selector" href="#task_selector" style="">Copy values from a previous task</button>
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
        </div>
    </div>

    <div class="well well-small transcribeSection">
        <div class="row-fluid transcribeSectionHeader">
            <div class="span12">
                <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Collection Event</span> &ndash; a collecting event is a unique combination of who (collector), when (date) and where (locality) a specimen was collected
                <a style="float:right" class="closeSectionLink" href="#">Shrink</a>
            </div>
        </div>
        <div class="transcribeSectionBody">

            <div class="row-fluid">

                <g:renderFieldLabelAndWidgetSpans task="${taskInstance}" fieldType="${DarwinCoreField.verbatimLocality}" recordValues="${recordValues}" labelClass="span2" widgetClass="span4" />

                <div class="span6">
                    <div class="row-fluid">
                        <g:renderFieldLabelAndWidgetSpans task="${taskInstance}" fieldType="${DarwinCoreField.county}" recordValues="${recordValues}" labelClass="span4" widgetClass="span8" />
                    </div>
                    <div class="row-fluid">
                        <g:renderFieldLabelAndWidgetSpans fieldType="${DarwinCoreField.stateProvince}" recordValues="${recordValues}" task="${taskInstance}" labelClass="span4" widgetClass="span8" />
                    </div>
                    <div class="row-fluid">
                        <g:renderFieldLabelAndWidgetSpans fieldType="${DarwinCoreField.country}" recordValues="${recordValues}" task="${taskInstance}" labelClass="span4" widgetClass="span8" />
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span2">
                    ${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.recordedBy)?.label ?: "Collector(s)"}
                </div>
                <div class="span9">
                    <g:each in="${0..3}" var="idx">
                        <div class="span3">
                            <input type="text" name="recordValues.${idx}.recordedBy" maxlength="200" class="span12 recordedBy autocomplete" id="recordValues.${idx}.recordedBy" value="${recordValues[idx]?.recordedBy?.encodeAsHTML()}"/>&nbsp;
                            <g:hiddenField name="recordValues.${idx}.recordedByID" class="recordedByID" id="recordValues.${idx}.recordedByID" value="${recordValues[idx]?.recordedByID?.encodeAsHTML()}"/>
                        </div>
                    </g:each>
                </div>
            </div>

            <div class="row-fluid">
                <g:renderFieldLabelAndWidgetSpans fieldType="${DarwinCoreField.recordedByID}" recordValues="${recordValues}" task="${taskInstance}" labelClass="span2" widgetClass="span4" />
                <g:renderFieldLabelAndWidgetSpans fieldType="${DarwinCoreField.eventDate}" recordValues="${recordValues}" task="${taskInstance}" labelClass="span2" widgetClass="span4"  />
            </div>

            <div class="row-fluid">
                <g:renderFieldLabelAndWidgetSpans fieldType="${DarwinCoreField.habitat}" recordValues="${recordValues}" task="${taskInstance}" labelClass="span2" widgetClass="span10" />
            </div>


        </div>
    </div>

    <g:renderFieldCategorySection category="${FieldCategory.location}" task="${taskInstance}" recordValues="${recordValues}" title="Interpreted Location" />

    <g:renderFieldCategorySection category="${FieldCategory.miscellaneous}" task="${taskInstance}" recordValues="${recordValues}" title="Miscellaneous" description="This section is for a range of fields. Many labels will not contain information for any or all of these fields." />

    <g:renderFieldCategorySection category="${FieldCategory.identification}" task="${taskInstance}" recordValues="${recordValues}" title="Identification" description="If a label contains information on the name of the organism then record the name and associated information in this section" />

</div>
