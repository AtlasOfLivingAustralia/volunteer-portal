<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />

<div class="container-fluid">
    <div class="row-fluid">
        <div class="span12">
            <div>
                <g:set var="multimedia" value="${taskInstance.multimedia.first()}" />
                <g:imageViewer multimedia="${multimedia}" />
            </div>
        </div>
    </div>

    <div class="row-fluid" style="margin-top: 10px">

        <div class="span9">
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
        <div class="span3">
            <g:if test="${taskInstance?.project?.tutorialLinks}">
                <div class="tutorialLinks" style="text-align: right">
                    ${taskInstance?.project?.tutorialLinks}
                </div>
            </g:if>
        </div>

    </div>

    <div class="well well-small transcribeSection">
        <div class="row-fluid">
            <div class="span3">
                <div class="row-fluid">
                    <div class="span12">
                        <div class="control-group">
                            <g:set var="allTextField" value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}" />
                            <span class="pull-right">
                                <g:fieldHelp field="${allTextField}" />
                            </span>
                            <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${allTextField?.label ?: "Transcribe All Text"}</span>
                            <g:textArea class="span12" validationRule="${allTextField?.validationRule}" name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks" rows="12" cols="42"/>
                            <div>
                                <button class="insert-symbol-button" symbol="&deg;" title="Insert a degree symbol"></button>
                                <button class="insert-symbol-button" symbol="&#39;" title="Insert an apostrophe (minutes) symbol"></button>
                                <button class="insert-symbol-button" symbol="&quot;" title="Insert a quote (minutes) symbol"></button>
                                <button class="insert-symbol-button" symbol="&#x2642;" title="Insert the male gender symbol"></button>
                                <button class="insert-symbol-button" symbol="&#x2640;" title="Insert the female gender symbol"></button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row-fluid">
                    <div class="span10">
                        <button class="btn" id="show_task_selector" href="#task_selector" style="">Copy values from a previous task</button>
                    </div>
                    <div class="span2">
                        <a href="#" class="fieldHelp" title="Clicking this button will allow you to select a previously transcribed task to copy values from"><span class="help-container">&nbsp;</span></a>
                    </div>
                </div>
            </div>

            <div class="span9">
                <div class="row-fluid">
                    <div class="span6">
                        <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Collection Location</span>
                        <g:renderCategoryFieldsColumn category="${FieldCategory.location}" task="${taskInstance}" recordValues="${recordValues}" title="Collection Location" />
                    </div>

                    <div class="span6">
                        <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Miscellaneous</span>
                        <g:renderCategoryFieldsColumn category="${FieldCategory.miscellaneous}" task="${taskInstance}" recordValues="${recordValues}" title="Miscellaneous Event" />
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>


<r:script>

    $(document).ready(function() {
        $(".tutorialLinks a").each(function(index, element) {
            $(this).addClass("btn").attr("target", "tutorialWindow");
        });
    });

</r:script>