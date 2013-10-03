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

                <table style="width: 100%">
                    <tr>
                        <td>
                            <span class="metaDataLabel">Catalogue No.:</span> ${recordValues?.get(0)?.catalogNumber}
                            <span class="metaDataLabel">Taxa:</span> ${recordValues?.get(0)?.scientificName}
                        </td>
                        <td style="text-align: right">
                            <span>
                                <button class="btn" id="show_task_selector" href="#task_selector" style="">Copy values from a previous task</button>
                                <a href="#" class="fieldHelp" title="Clicking this button will allow you to select a previously transcribed task to copy values from"><span class="help-container">&nbsp;</span></a>
                            </span>

                        </td>
                    </tr>
                </table>

                <div style="display: none;">
                    <div id="task_selector">
                        <div id="task_selector_content">
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
                <div class="control-group">
                    <div class="span6">
                        <g:renderFieldLabelAndWidgetSpans task="${taskInstance}" fieldType="${DarwinCoreField.verbatimLocality}" recordValues="${recordValues}" labelClass="span4" widgetClass="span8" />
                    </div>
                </div>

                <div class="control-group">
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
            </div>

            <g:templateFieldsForCategory category="${FieldCategory.collectionEvent}" task="${taskInstance}" recordValues="${recordValues}" labelClass="span4" valueClass="span8" />


        </div>
    </div>

    <g:renderFieldCategorySection category="${FieldCategory.location}" task="${taskInstance}" recordValues="${recordValues}" title="Interpreted Location" />

    <g:renderFieldCategorySection category="${FieldCategory.miscellaneous}" task="${taskInstance}" recordValues="${recordValues}" title="Museum Details" description="" />

    <g:renderFieldCategorySection category="${FieldCategory.identification}" task="${taskInstance}" recordValues="${recordValues}" title="Identification" description="If a label contains information on the name of the organism then record the name and associated information in this section" />

</div>
