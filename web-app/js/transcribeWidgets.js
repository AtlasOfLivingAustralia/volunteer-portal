function prepareFieldWidgetsForSubmission() {
    prepareDateWidgets();
    prepareLatLongWidgets();
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
