<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>
        <title><cl:pageTitle title="${(validator) ? 'Validate' : 'Expedition'} ${taskInstance?.project?.name}" /></title>
    </head>
    <content tag="templateView">
<div class="row">
    <div class="col-md-12">
        <span id="journalPageButtons">
            <button type="button" class="btn btn-small" id="showPreviousJournalPage"
                    title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}><asset:image
                    src="left_arrow.png" /> show previous journal page</button>
            <button type="button" class="btn btn-small" id="showNextJournalPage"
                    title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>show next journal page
                    <asset:image src="right_arrow.png" /></button>
            <button type="button" class="btn btn-small" id="rotateImage"
                    title="Rotate the page 180 degrees">Rotate&nbsp;<asset:image
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
        This template view requires that you configure 'sightingCount' as a defined field for this template - it can be hidden.
    </div>
</g:if>
<g:set var="fieldList"
       value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort: 'displayOrder'])}"/>
<g:set var="viewParams" value="${taskInstance.project.template?.viewParams}"/>

<g:if test="${isPreview && !fieldList}">
    <div class="alert alert-danger">
        This template view requires at least one field configured in the <strong>dataset</strong> category!
    </div>
</g:if>

<g:if test="${viewParams?.showMonth}">
    <div class="well well-small transcribeSection">
        <div class="row transcribeSectionHeader">
            <div class="col-md-12">
                <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. Enter the month from the top of the page</span>
                <a style="float:right" class="closeSectionLink" href="#">Shrink</a>
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
            <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. Transcribe each record as follows: Enter the number into the “CatalogNumber “ field. Enter the text into the “Transcribe All text” field.
                <a style="float:right" class="closeSectionLink" href="#">Shrink</a>
        </div>
    </div>

    <div class="transcribeSectionBody">
        <g:render template="/transcribe/dynamicDatasetRows"
                  model="${[recordValues: recordValues, fieldList: fieldList, entriesField: entriesField]}"/>
    </div>
</div>

<g:renderFieldCategorySection category="${FieldCategory.location}" task="${taskInstance}"
                              recordValues="${recordValues}" title="Interpreted Location"
                              description="Use the mapping tool before attempting to enter values manually">
    <button type="button" class="btn btn-small btn-info" id="btnGeolocate">Mapping tool <i class="fa fa-map-pin"></i></button>
</g:renderFieldCategorySection>

    </content>
</g:applyLayout>