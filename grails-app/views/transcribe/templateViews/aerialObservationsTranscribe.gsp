<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>

        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title><cl:pageTitle title="${(validator) ? message(code: 'transcribe.templateViews.all.validate') : message(code: 'transcribe.templateViews.all.expedition')} ${taskInstance?.project?.i18nName}" /></title>
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
                                title="${message(code: 'transcribe.templateViews.all.display_in_new_window')}" ${prevTask ? '' : 'disabled="true"'}><asset:image
                                src="left_arrow.png" /> <g:message code="transcribe.templateViews.all.show_previous_journal"/></button>
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
                                              recordValues="${recordValues}" renderHeaderTitle="false" title="${message(code: 'transcribe.templateViews.aerialObservationsTranscribe.identification')}"
                                              description="${message(code: 'transcribe.templateViews.aerialObservationsTranscribe.observations_transcribe_identification')}"/>

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