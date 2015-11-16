<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>

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
        <div class="row" id="taskMetadata">
            <div class="col-md-12">
                <div class="panel panel-default">
                    <div class="panel-body">
                        <table style="width: 100%">
                            <tr>
                                <td>
                                    <span class="metaDataLabel">Catalogue No.:</span> ${recordValues?.get(0)?.catalogNumber}
                                    <br/>
                                    <span class="metaDataLabel">Taxa:</span> ${recordValues?.get(0)?.scientificName}
                                </td>
                                <td style="text-align: right">
                                    <div class="col-md-10">
                                        <button type="button" class="btn btn-info btnCopyFromPreviousTask"
                                                href="#task_selector"
                                                style="">Copy from previous task</button>
                                    </div>

                                    <div class="col-md-2">
                                        <a href="#" class="btn btn-default btn-xs fieldHelp"
                                           title="Clicking this button will allow you to select a previously transcribed task to copy values from"><i
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
                                      recordValues="${recordValues}" title="Museum details" description=""/>

    </div>
</div>

<div class="transcribeSection panel panel-default">
    <div class="panel-body">
        <div class="row">
            <div class="col-md-6">
                <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Collection details</span>
                <g:renderCategoryFieldsColumn columns="1" category="${FieldCategory.collectionEvent}"
                                              task="${taskInstance}" recordValues="${recordValues}"
                                              title="Collection details"/>
            </div>

            <div class="col-md-6">
                <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Location details</span>
                <g:renderCategoryFieldsColumn columns="1" category="${FieldCategory.location}" task="${taskInstance}"
                                              recordValues="${recordValues}" title="Location details"/>
            </div>
        </div>
    </div>
</div>

<g:renderFieldCategorySection category="${FieldCategory.identification}" task="${taskInstance}"
                              recordValues="${recordValues}" title="Identification"
                              description="If a label contains information on the name of the organism then record the name and associated information in this section"/>

