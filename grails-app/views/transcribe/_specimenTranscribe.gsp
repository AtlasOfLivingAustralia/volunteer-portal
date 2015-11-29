<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>

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
                                class="fa fa-question help-container"></i></a>
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
                <g:set var="allTextField"
                       value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}"/>
                <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${allTextField?.label ?: "Transcribe All Text"}</span> &ndash; Record exactly what appears in the labels so we have a searchable reference for them
                <a href="#" class="btn btn-default btn-xs fieldHelp"
                   title='${allTextField?.helpText ?: "Transcribe all text as it appears in the labels"}'><i
                        class="help-container fa fa-question"></i></a>
                <g:textArea class="col-md-12" name="recordValues.0.occurrenceRemarks"
                            value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks"
                            rows="6" cols="42"/>
                <div>
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
            </div>
        </div>
    </div>
</div>

<g:renderFieldCategorySection category="${FieldCategory.collectionEvent}" task="${taskInstance}"
                              recordValues="${recordValues}" title="Collection Event"
                              description="This records information directly from the label about when, where and by whom the specimen was collected. Only fill in fields for which information appears in the labels"/>

<g:renderFieldCategorySection category="${FieldCategory.location}" task="${taskInstance}"
                              recordValues="${recordValues}" title="Interpreted Location"
                              description="Use the mapping tool before attempting to enter values manually">
    <button type="button" class="btn btn-small btn-info" id="btnGeolocate">Mapping tool <i class="fa fa-map-pin"></i></button>
</g:renderFieldCategorySection>

<g:renderFieldCategorySection category="${FieldCategory.miscellaneous}" task="${taskInstance}"
                              recordValues="${recordValues}" title="Miscellaneous"
                              description="This section is for a range of fields. Many labels will not contain information for any or all of these fields."/>

<g:renderFieldCategorySection category="${FieldCategory.identification}" task="${taskInstance}"
                              recordValues="${recordValues}" title="Identification"
                              description="If a label contains information on the name of the organism then record the name and associated information in this section"/>

