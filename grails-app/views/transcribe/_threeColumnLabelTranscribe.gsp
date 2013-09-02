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
                        <g:set var="allTextField" value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}" />
                        <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${allTextField?.label ?: "Transcribe All Text"}</span>
                        <g:textArea class="span12" name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks" rows="6" cols="42"/>
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

    function transcribeBeforeSubmit() {
        prepareLatLongWidgets();
        prepareDateWidgets();
    }

    function prepareDateWidgets() {

        $(".dateWidget").each(function() {
            var targetField = $(this).attr("targetField");
            if (!targetField) {
                return;
            }

            var year = $(this).find(".year").val();
            var month = $(this).find(".month").val();
            var day = $(this).find(".day").val();
            var finalValue = "";

            if (year) {
                finalValue = year;
                if (month) {
                    finalValue += "-" + month;
                    if (day) {
                        finalValue += '-' + day;
                    }
                }
            }

            var selector = "#recordValues\\.0\\." + targetField;
            $(selector).val(finalValue);

        });
    }

    function prepareLatLongWidgets() {
        $(".latLongWidget").each(function() {

            var targetField = $(this).attr("targetField");
            if (!targetField) {
                return;
            }

            var finalValue = '';
            var decimalDegrees = $(this).find(".decimalDegrees").val();

            if (decimalDegrees) {
                finalValue = decimalDegrees;
            } else {
                var degrees = $(this).find(".degrees").val();
                var minutes = $(this).find(".minutes").val();
                var seconds = $(this).find(".seconds").val();
                if (degrees) {
                    finalValue = degrees + "°";
                    if (minutes) {
                        finalValue += minutes + "'";
                        if (seconds) {
                            finalValue += seconds + '"';
                        }
                    }
                }
            }

            var selector = "#recordValues\\.0\\." + targetField;
            $(selector).val(finalValue);
        });
    }

</r:script>