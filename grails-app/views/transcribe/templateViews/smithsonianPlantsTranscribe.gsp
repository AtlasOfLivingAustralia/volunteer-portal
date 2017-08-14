<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>
        <title><cl:pageTitle title="${(validator) ? message(code: 'transcribe.templateViews.all.validate') : message(code: 'transcribe.templateViews.all.expedition')} ${taskInstance?.project?.i18nName}" /></title>
    </head>
    <content tag="templateView">
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

                    <div class="transcribeSectionHeaderLabel"><g:message code="transcribe.templateViews.all.specimen"/></div>
                    <ul>
                        <li><span class="metaDataLabel"><g:message code="transcribe.templateViews.all.institution"/></span> <span
                                id="institutionCode">${recordValues?.get(0)?.institutionCode}</span></li>
                        <li><span class="metaDataLabel"><g:message code="transcribe.templateViews.all.project"/></span> ${taskInstance?.project?.i18nName}</li>
                        <li><span class="metaDataLabel"><g:message code="transcribe.templateViews.all.catalogue_no"/></span> ${recordValues?.get(0)?.catalogNumber}
                        </li>
                        <li><span class="metaDataLabel"><g:message code="transcribe.templateViews.all.taxa"/></span> ${recordValues?.get(0)?.scientificName}</li>
                        <g:hiddenField name="recordValues.0.basisOfRecord" class="basisOfRecord"
                                       id="recordValues.0.basisOfRecord"
                                       value="${recordValues?.get(0)?.basisOfRecord ?: TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.basisOfRecord, template)?.defaultValue}"/>
                    </ul>

                    <span>
                        <button type="button" class="btn btn-small btn-info btnCopyFromPreviousTask"
                                href="#task_selector"
                                style=""><g:message code="transcribe.templateViews.all.copy_values_from_a_previous_task"/></button>
                        <a href="#" class="btn btn-default btn-xs fieldHelp"
                           title="${message(code: 'transcribe.templateViews.all.clicking_this_button.description')}"><i
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
                <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. ${allTextField?.label ?: message(code: 'transcribe.templateViews.all.transcribe_all_text_as_it_appears')}</span> <g:message code="transcribe.templateViews.all.record_exactly_what_appears.description"/>
                <a href="#" class="btn btn-default btn-xs fieldHelp"
                   title='${allTextField?.helpText ?: message(code: 'transcribe.templateViews.all.translate_all_text_as_it_appears_in_the_labels')}'><i
                        class="fa fa-question help-container"></i></a>
                <g:textArea class="col-md-12" name="recordValues.0.occurrenceRemarks"
                            value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks"
                            rows="6" cols="42"/>
                <div>
                    <button type="button" class="insert-symbol-button" symbol="&deg;"
                            title="${message(code: 'transcribe.templateViews.all.insert_degree')}"></button>
                    <button type="button" class="insert-symbol-button" symbol="&#39;"
                            title="${message(code: 'transcribe.templateViews.all.insert_apostophe')}"></button>
                    <button type="button" class="insert-symbol-button" symbol="&quot;"
                            title="${message(code: 'transcribe.templateViews.all.insert_quote')}"></button>
                    <button type="button" class="insert-symbol-button" symbol="&#x2642;"
                            title="${message(code: 'transcribe.templateViews.all.insert_male_gender_symbol')}"></button>
                    <button type="button" class="insert-symbol-button" symbol="&#x2640;"
                            title="${message(code: 'transcribe.templateViews.all.insert_frmale_gender_symbol')}"></button>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="panel panel-default transcribeSection">
    <div class="panel-body">
        <div class="row transcribeSectionHeader">
            <div class="col-md-12">
                <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. <g:message code="transcribe.templateViews.all.collection_event.description"/>
                <a style="float:right" class="closeSectionLink" href="#"><g:message code="transcribe.templateViews.all.shrink"/></a>
            </div>
        </div>

        <div class="transcribeSectionBody">

            <div class="row">

                <div class="col-md-6">
                    <g:renderFieldBootstrap fieldType="${DarwinCoreField.verbatimLocality}"
                                            recordValues="${recordValues}" task="${taskInstance}" labelClass="col-md-4"
                                            valueClass="col-md-8"/>
                </div>

                <div class="col-md-6">
                    <g:renderFieldBootstrap fieldType="${DarwinCoreField.stateProvince}" recordValues="${recordValues}"
                                            task="${taskInstance}" labelClass="col-md-4" valueClass="col-md-8"/>
                    <g:renderFieldBootstrap fieldType="${DarwinCoreField.country}" recordValues="${recordValues}"
                                            task="${taskInstance}" labelClass="col-md-4" valueClass="col-md-8"/>
                </div>

            </div>

            <div class="row">
                <div class="col-md-2">
                    ${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.recordedBy)?.label ?: message(code: 'transcribe.templateViews.all.collectors')}
                </div>

                <div class="col-md-10">
                    <div class="row">
                        <g:each in="${0..3}" var="idx">
                            <div class="col-md-3">
                                <input type="text" name="recordValues.${idx}.recordedBy" maxlength="200"
                                       class="form-control recordedBy autocomplete" id="recordValues.${idx}.recordedBy"
                                       value="${recordValues[idx]?.recordedBy?.encodeAsHTML()}"/>&nbsp;
                            <g:hiddenField name="recordValues.${idx}.recordedByID" class="recordedByID"
                                           id="recordValues.${idx}.recordedByID"
                                           value="${recordValues[idx]?.recordedByID?.encodeAsHTML()}"/>
                            </div>
                        </g:each>
                    </div>
                </div>
            </div>

            <g:templateFieldsForCategory category="${FieldCategory.collectionEvent}" task="${taskInstance}"
                                         recordValues="${recordValues}" labelClass="col-md-4" valueClass="col-md-8"/>

        </div>
    </div>
</div>

<g:renderFieldCategorySection category="${FieldCategory.miscellaneous}" task="${taskInstance}"
                              recordValues="${recordValues}" title="${message(code: 'transcribe.templateViews.smithsonianPlants.misc')}"
                              description="${message(code: 'transcribe.templateViews.smithsonianPlants.this_section_is_for_a_range.description')}"/>

<g:renderFieldCategorySection category="${FieldCategory.identification}" task="${taskInstance}"
                              recordValues="${recordValues}" title="${message(code: 'transcribe.templateViews.smithsonianPlants.identification')}"
                              description="${message(code: 'transcribe.templateViews.smithsonianPlants.if_a_label_contains_information.description')}"/>

    </content>
</g:applyLayout>