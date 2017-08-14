<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>
        <title><cl:pageTitle title="${(validator) ? message(code: 'transcribe.templateViews.all.validate') : message(code: 'transcribe.templateViews.all.expedition')} ${taskInstance?.project?.i18nName}" /></title>
    </head>
    <content tag="templateView">
<div class="row">
    <div class="col-md-12">
        <span id="journalPageButtons">
            <button type="button" class="btn btn-small" id="showPreviousJournalPage"
                    title="${message(code: 'transcribe.templateViews.all.display_in_new_window')}" ${prevTask ? '' : 'disabled="true"'}><asset:image
                    src="left_arrow.png" /> </button>
            <button type="button" class="btn btn-small" id="showNextJournalPage"
                    title="${message(code: 'transcribe.templateViews.all.display_in_new_window')}" ${nextTask ? '' : 'disabled="true"'}><g:message code="transcribe.templateViews.all.show_next_journal_page"/>
                    <asset:image src="right_arrow.png" /></button>
            <button type="button" class="btn btn-small" id="rotateImage"
                    title="${message(code: 'transcribe.templateViews.all.rotate_image')}"><g:message code="transcribe.templateViews.all.rotate"/>&nbsp;<asset:image
                    style="vertical-align: middle; margin: 0 !important;"
                    src="rotate.png" /></button>
        </span>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
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
       value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.sightingCount, template)}"/>
<g:if test="${isPreview && !entriesField}">
    <div class="alert alert-danger">
        <g:message code="transcribe.templateViews.observationDiaryTranscribe.requirements"/>
    </div>
</g:if>
<g:set var="fieldList"
       value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort: 'displayOrder'])}"/>
<g:set var="viewParams" value="${taskInstance.project.template?.viewParams}"/>

<g:if test="${isPreview && !fieldList}">
    <div class="alert alert-danger">
        <g:message code="transcribe.templateViews.observationDiaryTranscribe.this_template_requires_at_least"/>
    </div>
</g:if>

<g:if test="${viewParams?.showMonth}">
    <div class="well well-small transcribeSection">
        <div class="row transcribeSectionHeader">
            <div class="col-md-12">
                <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. <g:message code="transcribe.templateViews.observationDiaryTranscribe.enter_the_month"/></span>
                <a style="float:right" class="closeSectionLink" href="#"><g:message code="transcribe.templateViews.all.shrink"/></a>
            </div>
        </div>

        <div class="transcribeSectionBody">
            <div class="row">
                <div class="col-md-1">
                    Month
                </div>

                <div class="col-md-1">
                    <g:textField class="form-control" id="recordValues.0.verbatimEventDate"
                                 name="recordValues.0.verbatimEventDate"
                                 value="${recordValues?.get(0)?.get('verbatimEventDate')}"/>
                </div>
            </div>
        </div>
    </div>
</g:if>

<div class="well well-small transcribeSection">
    <div class="row transcribeSectionHeader">
        <div class="col-md-12">
            <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. <g:message code="transcribe.templateViews.observationDiaryTranscribe.transcribe_each_record_as_follows"/>
                <a style="float:right" class="closeSectionLink" href="#"><g:message code="transcribe.templateViews.all.shrink"/></a>
        </div>
    </div>

    <div class="transcribeSectionBody">
        <g:render template="/transcribe/dynamicDatasetRows"
                  model="${[recordValues: recordValues, fieldList: fieldList, entriesField: entriesField]}"/>
    </div>
</div>
    </content>
</g:applyLayout>