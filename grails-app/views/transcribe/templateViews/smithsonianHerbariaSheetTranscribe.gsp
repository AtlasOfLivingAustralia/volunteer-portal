<%@ page contentType="text/html; charset=UTF-8" %>
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
                <g:imageViewer multimedia="${multimedia}" preserveWidthWhenPinned="true" height="330"/>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="row" id="taskMetadata" >
            <div class="col-md-12">
                <div class="panel panel-default">
                    <div class="panel-body">
                        <table style="width: 100%">
                            <tr>
                                <td>
                                    <span class="metaDataLabel"><g:message code="transcribe.templateViews.all.catalogue_no"/></span> ${recordValues?.get(0)?.catalogNumber}
                                    <br/>
                                    <span class="metaDataLabel"><g:message code="transcribe.templateViews.all.taxa"/></span> ${recordValues?.get(0)?.scientificName}
                                </td>
                                <td style="text-align: right" class="copyFromPreviousTask" >
                                    <div class="col-md-10">
                                        <button type="button" class="btn btn-info btnCopyFromPreviousTask"
                                                href="#task_selector"
                                                style=""><g:message code="transcribe.templateViews.all.copy_values_from_a_previous_task"/></button>
                                    </div>

                                    <div class="col-md-2">
                                        <a href="#" class="btn btn-default btn-xs fieldHelp"
                                           title="${message(code: 'transcribe.templateViews.all.clicking_this_button.description')}"><i
                                                class="fa fa-question help-container"></i></a>
                                    </div>
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
        </div>

        <g:renderFieldCategorySection columns="1" category="${FieldCategory.miscellaneous}" task="${taskInstance}"
                                      recordValues="${recordValues}" title="${message(code: 'transcribe.templateViews.smithsonian.museum_details')}" description=""/>

    </div>
</div>

<div class="transcribeSection panel panel-default">
    <div class="panel-body">
        <div class="row">
            <div class="col-md-6">
                <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. <g:message code="transcribe.templateViews.smithsonian.collection_details"/></span>
                <g:renderCategoryFieldsColumn columns="1" category="${FieldCategory.collectionEvent}"
                                              task="${taskInstance}" recordValues="${recordValues}"
                                              title="Collection details"/>
            </div>

            <div class="col-md-6">
                <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. <g:message code="transcribe.templateViews.smithsonian.location_details"/></span>
                <g:renderCategoryFieldsColumn columns="1" category="${FieldCategory.location}" task="${taskInstance}"
                                              recordValues="${recordValues}" title="Location details"/>
            </div>
        </div>
    </div>
</div>

<g:renderFieldCategorySection category="${FieldCategory.identification}" task="${taskInstance}"
                              recordValues="${recordValues}" title="${message(code: 'transcribe.templateViews.smithsonian.identification')}"
                              description="${message(code: 'transcribe.templateViews.smithsonian.identification.description')}"/>

    </content>
</g:applyLayout>