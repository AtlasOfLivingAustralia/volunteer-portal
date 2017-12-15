<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>
        <title><cl:pageTitle title="${(validator) ? 'Validate' : 'Expedition'} ${taskInstance?.project?.name}" /></title>
        <style type="text/css">
        #image-container {
            height: 100px;
        }
        </style>
    </head>
    <content tag="templateView">
        <div class="container-fluid">
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

            <g:renderFieldCategorySection category="${FieldCategory.identification}" task="${taskInstance}"
                                              recordValues="${recordValues}" renderHeaderTitle="false" title="Identification"
                                              description="Observations Transcribe Identification"/>

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

        </div>
    </content>
</g:applyLayout>