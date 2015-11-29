<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>

<style>
</style>

<div class="form-condensed">
    <div class="row">
        <div class="col-md-12">
            <div>
                <g:set var="multimedia" value="${taskInstance.multimedia.first()}"/>
                <g:imageViewer multimedia="${multimedia}"/>
            </div>
        </div>
    </div>

    <div class="row" style="margin-top: 10px">

        <div class="col-md-9">
            <table style="width:100%">
                <tr>
                    <td>
                        <strong>Institution:</strong>
                        <span class="institutionName">${taskInstance?.project?.featuredOwner}</span>
                    </td>
                    <td>
                        <strong>Project:</strong>
                        <span class="institutionName">${taskInstance?.project?.name}</span>
                    </td>
                    <td>
                        <strong>Catalog Number:</strong>
                        <span class="institutionName">${recordValues?.get(0)?.catalogNumber}</span>
                    </td>
                    <td>
                        <strong>Taxa:</strong>
                        <span class="institutionName">${recordValues?.get(0)?.scientificName}</span>
                    </td>
                </tr>
            </table>
        </div>

        <div class="col-md-3">
            <g:if test="${taskInstance?.project?.tutorialLinks}">
                <div class="tutorialLinks" style="text-align: right">
                    ${raw(taskInstance?.project?.tutorialLinks)}
                </div>
            </g:if>
        </div>

    </div>

    <div class="panel panel-default transcribeSection">
        <div class="panel-body">
            <div class="row">
            <div class="col-md-3">
                <div class="row">
                    <div class="col-md-12">
                        <div class="form-group">
                            <g:set var="allTextField"
                                   value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}"/>
                            <span class="pull-right">
                                <g:fieldHelp field="${allTextField}" tooltipPosition="bottomLeft"/>
                            </span>
                            <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${allTextField?.label ?: "Transcribe All Text"}</span>
                            <g:textArea class="form-control" validationRule="${allTextField?.validationRule}"
                                        name="recordValues.0.occurrenceRemarks"
                                        value="${recordValues?.get(0)?.occurrenceRemarks}"
                                        id="recordValues.0.occurrenceRemarks" rows="12" cols="42"/>
                            <div>
                                <button type="button" class="insert-symbol-button btn btn-primary btn-sm" symbol="&deg;"
                                        title="Insert a degree symbol"></button>
                                <button type="button" class="insert-symbol-button btn btn-primary btn-sm" symbol="&#39;"
                                        title="Insert an apostrophe (minutes) symbol"></button>
                                <button type="button" class="insert-symbol-button btn btn-primary btn-sm" symbol="&quot;"
                                        title="Insert a quote (minutes) symbol"></button>
                                <button type="button" class="insert-symbol-button btn btn-primary btn-sm" symbol="&#x2642;"
                                        title="Insert the male gender symbol"></button>
                                <button type="button" class="insert-symbol-button btn btn-primary btn-sm" symbol="&#x2640;"
                                        title="Insert the female gender symbol"></button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-10">
                        <button type="button" class="btn btn-info btnCopyFromPreviousTask" href="#task_selector"
                                style="">Copy values from a previous task</button>
                    </div>

                    <div class="col-md-2">
                        <a href="#" class="btn btn-default btn-xs fieldHelp" tooltipPosition="bottomLeft"
                           title="Clicking this button will allow you to select a previously transcribed task to copy values from"><i
                                class="fa fa-question help-container"></i></a>
                    </div>
                </div>
            </div>

            <div class="col-md-9">
                <div class="row">
                    <div class="col-md-6">
                        <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Collection Location</span>
                        <g:renderCategoryFieldsColumn category="${FieldCategory.location}" task="${taskInstance}"
                                                      recordValues="${recordValues}" title="Collection Location"/>
                    </div>

                    <div class="col-md-6">
                        <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Miscellaneous</span>
                        <g:renderCategoryFieldsColumn category="${FieldCategory.miscellaneous}" task="${taskInstance}"
                                                      recordValues="${recordValues}" title="Miscellaneous Event"/>
                    </div>
                </div>
            </div>
        </div>
        </div>
    </div>

</div>


<r:script>

    $(document).ready(function () {
        $(".tutorialLinks a").each(function (index, element) {
            $(this).addClass("btn btn-default").attr("target", "tutorialWindow");
        });
    });

</r:script>