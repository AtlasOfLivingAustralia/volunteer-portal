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
            <button class="btn btn-small pull-right">Tutorial</button>
            <vpf:taskTopicButton task="${taskInstance}" class="btn-small pull-right" style="margin-right: 6px" />
        </div>

    </div>

    <div class="well well-small transcribeSection">
        <div class="row-fluid">
            <div class="span3">
                <div class="row-fluid">
                    <div class="span12">
                        <div class="control-group">
                            <g:set var="allTextField" value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}" />
                            <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${allTextField?.label ?: "Transcribe All Text"}</span>
                            <g:textArea class="span12" validationRule="${allTextField?.validationRule}" name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks" rows="6" cols="42"/>
                        </div>
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

</r:script>