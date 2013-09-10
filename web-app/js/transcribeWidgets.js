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

function validateTranscribeWidgets(messages) {
    validateLatLongWidgets(messages);
    validateDateWidgets(messages);
}

function validateDateWidgets() {
    $(".dateWidget").each(function(index, element) {
        var yearElement = $(element).find(":input.year");
        var monthElement = $(element).find(":input.month");
        var dayElement = $(element).find(":input.day");

        if (!yearElement.val() && !monthElement.val() && !dayElement.val()) {
            return true;
        }

    });
    return true;
}

function validateLatLongWidgets(messages) {
    $(".latLongWidget").each(function(index, element) {
        var decimalDegreesElement = $(element).find(":input.decimalDegrees");

        if (decimalDegreesElement.val()) {
            // Just let this through?
            return true;
        }

        var degreesElement = $(element).find(":input.degrees");
        var minutesElement = $(element).find(":input.minutes");
        var secondsElement = $(element).find(":input.seconds");

        if (!degreesElement.val() && !minutesElement.val() && !secondsElement.val()) {
            return true;
        }

        if (!degreesElement.val() && minutesElement.val() && secondsElement.val()) {
            markFieldInvalid(minutesElement, "Degrees must be supplied if minutes or seconds are specified");
            return false;
        }

        if (!degreesElement.val() && !minutesElement.val() && secondsElement.val()) {
            markFieldInvalid(minutesElement, "Degrees and minutes must be supplied if seconds are specified");
            return false;
        }


        if (!validateIsInteger(degreesElement) || !validateIsInteger(minutesElement) || !validateIsInteger(secondsElement)) {
            messages.push("Invalid value");
            return false;
        }

        if (!validateInNumberRange(degreesElement, -360, 360)) {
            messages.push("Invalid degrees value.")
            return;
        }

        if (!validateInNumberRange(minutesElement, 0, 60) || !validateInNumberRange(secondsElement, 0, 60)) {
            messages.push("Invalid value. Must be between 0 and 60")
            return;
        }

    });

    return true;
}

function markFieldInvalid(element, message) {
    var parent = $(element).closest(".control-group");
    parent.addClass("warning");
    parent.append(validationMessageContent(message));
}

function validationMessageContent(message) {
    var buf = '<div class="row-fluid">';
    buf += '<div class="span12 alert alert-warning validationMessage">' + message + '</div>';
    return buf;
}

function validateIsInteger(element) {
    var value = element.val();
    if (value) {
        if (!isInt(value)) {
            markFieldInvalid(element, "Value is not numeric");
            return false;
        }
    }
    return true;
}

function isInt(n) {
    return $.isNumeric(n) && parseFloat(n) == parseInt(n, 10);
}

function validateInNumberRange(element, min, max) {
    var val = element.val();
    if (val) {
        if (!$.isNumeric(val)) {
            markFieldInvalid(element, "Value must be a number");
            return false;
        }
        var fltValue = parseFloat(val);
        if (fltValue < min || fltValue > max) {
            markFieldInvalid(element, "Value must be between " + min + " and " + max);
            return false;
        }
    }
    return true;
}
