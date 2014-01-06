var transcribeWidgets = {};

(function(lib) {

    lib.initializeTranscribeWidgets = function() {
        initLatLongWidgets();
    }

    var renderLatLongFormat = function(widget, format) {
        var dd = $(widget).find(".latLongWidget_DD");
        var dms = $(widget).find(".latLongWidget_DMS");

        if (format == "DD") {
            $(dd).css("display", "block");
            $(dms).css("display", "none");
        } else {
            $(dd).css("display", "none");
            $(dms).css("display", "block");
        }
    }

    var switchLatLongFormat = function(format) {
        $(".latLongWidget").each(function(index, widget) {
            var selector = $(widget).find(".latLongFormatSelector");
            $(selector).val(format);
            renderLatLongFormat(widget, format);
        });
    }

    var initLatLongWidgets = function () {

        $(".latLongWidget").each(function(index, widget) {

            var latLongFormat = $(this).attr("latLongFormat");

            if (latLongFormat == 'DD') {
                switchLatLongFormat("DD");
            }

            var selector = $(widget).find(".latLongFormatSelector").first();
            if (selector) {
                $(selector).change(function(e) {
                    var newLatLongFormat = $(this).val();
                    switchLatLongFormat(newLatLongFormat);
                });
            }

        });

    }

})(transcribeWidgets);

function prepareFieldWidgetsForSubmission() {
    preSubmitDateWidgets();
    preSubmitLatLongWidgets();
    preSubmitSheetNumberWidgets();
    preSubmitUnitRangeWidgets();
}

function preSubmitUnitRangeWidgets() {

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


function preSubmitSheetNumberWidgets() {
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

function preSubmitDateWidgets() {

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

function preSubmitLatLongWidgets() {

    $(".latLongWidget").each(function() {

        var targetField = $(this).attr("targetField");
        if (!targetField) {
            return;
        }

        var finalValue = '';
        var latLongFormat = $(this).find(".latLongFormatSelector").val();
        var decimalDegrees = $(this).find(".decimalDegrees").val();

        if (!latLongFormat) {
            if (decimalDegrees) {
                latLongFormat = "DD";
            } else {
                latLongFormat = "DMS";
            }
        }

        if (latLongFormat == "DD") {
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
