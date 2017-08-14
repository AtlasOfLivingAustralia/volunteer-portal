<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>
        <title><cl:pageTitle title="${(validator) ? message(code: 'transcribe.templateViews.all.validate') : message(code: 'transcribe.templateViews.all.expedition')} ${taskInstance?.project?.i18nName}" /></title>
    </head>
<content tag="templateView">
<div class="container-fluid">

    <div class="row-fluid">
        <div class="span12">
            <span id="journalPageButtons">
                <button type="button" class="btn btn-small" id="showPreviousJournalPage"
                        title="${message(code: 'transcribe.templateViews.all.display_in_new_window')}" ${prevTask ? '' : 'disabled="true"'}><asset:image
                        src="left_arrow.png" /> <g:message code="transcribe.templateViews.all.show_previous_journal"/></button>
                <button type="button" class="btn btn-small" id="showNextJournalPage"
                        title="${message(code: 'transcribe.templateViews.all.display_in_new_window')}" ${nextTask ? '' : 'disabled="true"'}><g:message code="transcribe.templateViews.all.show_next_journal_page"/> <asset:image
                        src="right_arrow.png" /></button>
                <button type="button" class="btn btn-small" id="rotateImage"
                        title="${message(code: 'transcribe.templateViews.all.rotate_image')}"><g:message code="transcribe.templateViews.all.rotate"/>&nbsp;<asset:image
                        style="vertical-align: middle; margin: 0 !important;"
                        src="rotate.png" /></button>
            </span>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <div class="well well-small">
                <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                    <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                        <g:imageViewer multimedia="${multimedia}"/>
                    </g:if>
                </g:each>
            </div>
        </div>
    </div>

    <g:set var="entriesField"
           value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.individualCount, template)}"/>
    <g:if test="${isPreview && !entriesField}">
        <div class="alert alert-danger">
            <g:message code="transcribe.templateViews.journalTranscribe.requirements_description"/>
        </div>
    </g:if>

    <g:set var="fieldList"
           value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort: 'displayOrder'])}"/>
    <g:set var="viewParams" value="${taskInstance.project.template?.viewParams}"/>
    <g:set var="numberOfTextRows" value="${12}"/>



    <div class="well well-small transcribeSection">
        <div class="row-fluid transcribeSectionHeader">
            <div class="span12">
                <g:set var="allTextField"
                       value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}"/>
                <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. ${allTextField?.label ?: "Transcribe All Text"}</span>
                <a href="#" class="btn btn-default btn-xs fieldHelp" tooltipPosition="bottomLeft"
                   title='${allTextField?.helpText ?: "${message(code: 'transcribe.templateViews.journalTranscribe.translate_all_text_as_it_appears')}"}'><i
                        class="fa fa-question help-container"></i></a>
                <a style="float:right" class="closeSectionLink" href="#"><g:message code="transcribe.templateViews.journalTranscribe.shrink"/></a>
            </div>
        </div>

        <div class="transcribeSectionBody">
            <div class="row-fluid">
                <g:textArea class="span12" name="recordValues.0.occurrenceRemarks"
                            value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks"
                            rows="${numberOfTextRows}" cols="42"/>
            </div>
        </div>
    </div>

    <div class="well well-small transcribeSection">
        <div class="row-fluid transcribeSectionHeader">
            <div class="span12">
                <span class="transcribeSectionHeaderLabel"><g:sectionNumber />.  <g:message code="transcribe.templateViews.journalTranscribe.for_each_entry_please_transcribe_information"/></span>
                <a style="float:right" class="closeSectionLink" href="#"><g:message code="transcribe.templateViews.journalTranscribe.shrink"/></a>
            </div>
        </div>

        <div class="transcribeSectionBody">
            <g:render template="/transcribe/dynamicDatasetRows"
                      model="${[recordValues: recordValues, fieldList: fieldList, entriesField: entriesField]}"/>
        </div>
    </div>

</div>
</content>
</g:applyLayout>