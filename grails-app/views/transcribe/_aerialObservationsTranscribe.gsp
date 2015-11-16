<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>

<style type="text/css">

#image-container {
    height: 100px;
}

</style>

<div class="row">
    <div class="col-md-12">
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

<div class="row">
    <div class="col-md-12">
        <div class="panel panel-default">
            <div class="panel-body">
                <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                    <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                        <g:imageViewer multimedia="${multimedia}" hideControls="${true}"/>
                    </g:if>
                </g:each>
            </div>
        </div>
    </div>
</div>

<div class="panel panel-default transcribeSection">
    <div class="panel-body">
        <div class="flightDetails row">
            <div class="col-md-2">
                <strong>Date</strong>
            </div>

            <div class="col-md-1"></div>

            <div class="col-md-2">
                <strong>Aircraft</strong>
            </div>

            <div class="col-md-7">
                <strong>All text verbatim</strong>
            </div>
        </div>

        <div class="flightDetails row">
            <div class="col-md-2">
                <g:renderFieldBootstrap fieldType="${DarwinCoreField.eventDate}" recordValues="${recordValues}"
                                        task="${taskInstance}" hideLabel="${true}" valueClass="col-md-12"
                                        helpTooltipPosition="bottomLeft"/>
            </div>

            <div class="col-md-1"></div>

            <div class="col-md-2">
                <g:renderFieldBootstrap fieldType="${DarwinCoreField.fieldNumber}" recordValues="${recordValues}"
                                        task="${taskInstance}" hideLabel="${true}" valueClass="col-md-12"/>
            </div>

            <div class="col-md-7">
                <g:renderFieldBootstrap fieldType="${DarwinCoreField.occurrenceRemarks}" recordValues="${recordValues}"
                                        task="${taskInstance}" hideLabel="${true}" valueClass="col-md-12" rows="2"/>
            </div>
        </div>
    </div>
</div>

<g:set var="entriesField"
       value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.sightingCount, template)}"/>
<g:set var="fieldList"
       value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort: 'displayOrder'])}"/>
<div class="panel panel-default transcribeSection">
    <div class="panel-body">
        <g:render template="/transcribe/dynamicDatasetRows"
                  model="${[recordValues: recordValues, fieldList: fieldList, entriesField: entriesField]}"/>
    </div>
</div>

