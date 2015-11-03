<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>

<style type="text/css">
</style>

<div class="container-fluid">

    <div class="row-fluid">
        <div class="span12">
            <span id="journalPageButtons">
                <button type="button" class="btn btn-small" id="showPreviousJournalPage"
                        title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}><img
                        src="${resource(dir: 'images', file: 'left_arrow.png')}"> show previous journal page</button>
                <button type="button" class="btn btn-small" id="showNextJournalPage"
                        title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>show next journal page <img
                        src="${resource(dir: 'images', file: 'right_arrow.png')}"></button>
                <button type="button" class="btn btn-small" id="rotateImage"
                        title="Rotate the page 180 degrees">Rotate&nbsp;<img
                        style="vertical-align: middle; margin: 0 !important;"
                        src="${resource(dir: 'images', file: 'rotate.png')}"></button>
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
            This template view (journalTranscribe) requires the <strong>individualCount</strong> field to be configured.
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
                <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${allTextField?.label ?: "Transcribe All Text"}</span>
                <a href="#" class="btn btn-default btn-xs fieldHelp" tooltipPosition="bottomLeft"
                   title='${allTextField?.helpText ?: "Transcribe all text as it appears on the page"}'><i
                        class="fa fa-question help-container"></i></a>
                <a style="float:right" class="closeSectionLink" href="#">Shrink</a>
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
                <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}.  For each entry on the field note, please transcribe information into the following fields.</span>
                <a style="float:right" class="closeSectionLink" href="#">Shrink</a>
            </div>
        </div>

        <div class="transcribeSectionBody">
            <g:render template="/transcribe/dynamicDatasetRows"
                      model="${[recordValues: recordValues, fieldList: fieldList, entriesField: entriesField]}"/>
        </div>
    </div>

</div>
