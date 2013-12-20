function prepareFieldWidgetsForSubmission() {
    prepareDateWidgets();
    prepareLatLongWidgets();
    prepareSheetNumberWidgets();
    prepareUnitRangeWidgets();
}

function prepareUnitRangeWidgets() {

    $(".unitRangeWidget").each(function() {
        var targetField = $(this).attr("targetField");
        if (!targetField) {
            return;
        }

        var min = $.trim($(this).find(".rangeMinValue").val());
        var max = $.trim($(this).find(".rangeMaxValue").val());
        var units = $.trim($(this).find(".rangeUnits").val());

        var finalValue = "";

        if (min) {
            finalValue = min;
            if (max) {
                finalValue += ":" + max;
            }
            if (units) {
                finalValue += ' ' + units;
            }

        }

        var selector = "#recordValues\\.0\\." + targetField;
        $(selector).val(finalValue);
    });
}


function prepareSheetNumberWidgets() {
    $(".sheetNumberWidget").each(function() {

        var targetField = $(this).attr("targetField");
        if (!targetField) {
            return;
        }

        var sheet = $(this).find(".sheetNumber").val();
        var of = $(this).find(".sheetNumberOf").val();

        var finalValue = sheet;
        if (of) {
            finalValue += '/' + of;
        }

        var selector = "#recordValues\\.0\\." + targetField;
        $(selector).val(finalValue);

    });
}

function prepareDateWidgets() {

    $(".dateWidget").each(function() {
        var targetField = $(this).attr("targetField");
        if (!targetField) {
            return;
        }

        var year = $(this).find(".startYear").val();
        var month = $(this).find(".startMonth").val();
        var day = $(this).find(".startDay").val();
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

        var endYear = $(this).find(".endYear").val();
        var endMonth = $(this).find(".endMonth").val();
        var endDay = $(this).find(".endDay").val();

        if (endYear) {
            finalValue += '/' + endYear;
            if (endMonth) {
                finalValue += "-" + endMonth;
                if (endDay) {
                    finalValue += '-' + endDay;
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
            var direction = $(this).find(".direction").val();
            if (degrees) {
                finalValue = degrees + "°";
                if (minutes) {
                    finalValue += minutes + "'";
                    if (seconds) {
                        finalValue += seconds + '"';
                    }
                }
                if (direction) {
                    finalValue += direction;
                }
            }
        }

        var selector = "#recordValues\\.0\\." + targetField;
        $(selector).val(finalValue);
    });
}
