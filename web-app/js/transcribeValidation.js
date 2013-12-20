var transcribeValidation = {};

(function(vlib) {

    vlib.options = {
        errorClass: 'error',
        warningClass: 'warning',
        alertErrorClass: 'alert-error',
        alertWarningClass: 'alert-warning',
        validationMessageClass: 'validationMessage',
        ruleAttribute: 'validationRule',
        defaultErrorMessage: 'Invalid field value'
    };

    vlib.rules = { };  // will hold a bunch of rule objects, each with a 'test' closure, 'message' and 'type'

    vlib.clearMessages = function() {
        $("." + vlib.options.warningClass).each(function(index, element) {
            $(element).removeClass(vlib.options.warningClass);
        });

        $("." + vlib.options.validationMessageClass).each(function(index, element) {
            $(element).remove();
        });
    };

    vlib.validateFields = function() {

        // first clear any error visualisations...
        vlib.clearMessages();

        // The error list will hold a reference to each element in error, along with a message
        var errorList = [];
        // test each input element that has a validation rule attached to it...
        $('[' + vlib.options.ruleAttribute + ']').each(function(index, element) {
            var ruleName = $(element).attr(vlib.options.ruleAttribute);
            if (ruleName) {
                var ruleObject = vlib.rules[ruleName];
                if (ruleObject) {
                    var value = $.trim($(element).val());
                    if (!ruleObject.test(value, element)) {
                        var message;
                        var messageSource = ruleObject.message;
                        if (messageSource) {
                            if (typeof(messageSource) === 'string') {
                                message = messageSource;
                            } else if (typeof(messageSource) === 'function') {
                                message = messageSource(element);
                            }
                        }

                        if (!message) {
                            message = vlib.defaultErrorMessage;
                        }
                        errorList.push({element: element, message: message, type: ruleObject.type});
                    }
                }
            }
        });

        // now validate special widgets
        vlib.validateTranscribeWidgets(errorList);
        var hasErrors = false;
        var hasWarnings = false;

        $.each(errorList, function(index, error) {
            if (error.type == 'Error') {
                hasErrors = true;
            } else {
                hasWarnings = true;
            }
        });

        $.each(errorList, function(index, error) {
            vlib.markFieldInvalid(error.element, error.message, error.type);
        });

        return { hasWarnings : hasWarnings, hasErrors: hasErrors, errorList: errorList }
    };

    vlib.validateTranscribeWidgets = function(messages) {
        vlib.validateLatLongWidgets(messages);
        vlib.validateDateWidgets(messages);
        vlib.validateUnitRangeWidgets(messages);
    };

    vlib.validateUnitRangeWidgets = function(messages) {
        $(".unitRangeWidget").each(function(index,element) {
            var minElement = $(element).find(":input.rangeMinValue");
            var maxElement = $(element).find(":input.rangeMaxValue");
            var unitElement = $(element).find(".rangeUnits");
            vlib.validateUnitRangeElements(messages, minElement, maxElement, unitElement);
        });
    }

    vlib.validateDateWidgets = function(messages) {
        $(".dateWidget").each(function(index, element) {
            var yearElement = $(element).find(":input.startYear");
            var monthElement = $(element).find(":input.startMonth");
            var dayElement = $(element).find(":input.startDay");
            if (vlib.validateDateElements(messages, yearElement, monthElement, dayElement)) {
                yearElement = $(element).find(":input.endYear");
                monthElement = $(element).find(":input.endMonth");
                dayElement = $(element).find(":input.endDay");
                return vlib.validateDateElements(messages, yearElement, monthElement, dayElement)
            } else {
                return false;
            }
        });
        return true;
    };

    vlib.validateUnitRangeElements = function(messages, minElement, maxElement, unitsElement) {
        var minVal = minElement.val();
        var maxVal = maxElement.val();
        var units = unitsElement.val();
        if (maxVal && !minVal) {
            messages.push({element: maxElement, message: "You cannot enter a 'to' value without a 'from' value", type:'Error'});
        }
        if (!minVal && !maxVal && units) {
            messages.push({element: maxElement, message: "You cannot specify units without a 'from' value", type:'Error'});
        }
    }

    vlib.validateDateElements = function(messages, yearElement, monthElement, dayElement) {

        var yearVal = yearElement.val();
        var monthVal = monthElement.val();
        var dayVal = dayElement.val();

        if (!yearVal && !monthVal && !dayVal) {
            return true;
        }

        if (!vlib.validateIsInteger(yearElement) || !vlib.validateIsInteger(dayElement)) {
            messages.push({element: yearElement, message: "Date components must be integers"});
            return false;
        }

        if (!yearVal) {
            messages.push({element: yearElement, message: "You must supply a year value"});
            return false;
        }

        if (!monthVal && dayVal) {
            messages.push({element: yearElement, message: "You must also supply a month if a day is supplied"});
            return false;
        }

        if (monthVal && vlib.isInt(monthVal)) {
            if (!vlib.validateInNumberRange(monthElement, 1, 12)) {
                messages.push({element: monthElement, message: "Month values must be between 1 and 12"});
                return false;
            }
        }

        if (dayVal && !vlib.validateInNumberRange(dayElement, 1, 31)) {
            messages.push({element: dayElement, message: "Day values must be between 1 and 31"});
            return false;
        }

        return true;
    }

    vlib.validateLatLongWidgets = function(messages) {
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
                vlib.markFieldInvalid(minutesElement, "Degrees must be supplied if minutes or seconds are specified");
                return false;
            }

            if (!degreesElement.val() && !minutesElement.val() && secondsElement.val()) {
                vlib.markFieldInvalid(minutesElement, "Degrees and minutes must be supplied if seconds are specified");
                return false;
            }


            if (!vlib.validateIsInteger(degreesElement) || !vlib.validateIsInteger(minutesElement) || !vlib.validateIsInteger(secondsElement)) {
                messages.push("Invalid value");
                return false;
            }

            if (!vlib.validateInNumberRange(degreesElement, -360, 360)) {
                messages.push("Invalid degrees value.")
                return;
            }

            if (!vlib.validateInNumberRange(minutesElement, 0, 60) || !vlib.validateInNumberRange(secondsElement, 0, 60)) {
                messages.push("Invalid value. Must be between 0 and 60")
                return;
            }

        });

        return true;
    };

    vlib.markFieldInvalid = function(element, message, type) {
        var parent = $(element).closest(".row-fluid");
        var clazz = vlib.options.warningClass;
        if (type == 'Error') {
            clazz = vlib.options.errorClass;
        }

        parent.addClass(clazz);
        parent.append(validationMessageContent(message, type));
    };

    vlib.validateIsInteger = function(element) {
        var value = element.val();
        if (value) {
            if (!vlib.isInt(value)) {
                return false;
            }
        }
        return true;
    };

    vlib.isInt = function(n) {
        return $.isNumeric(n) && parseFloat(n) == parseInt(n, 10);
    };

    vlib.validateInNumberRange = function(element, min, max) {
        var val = element.val();
        if (val) {
            if (!$.isNumeric(val)) {
                return false;
            }
            var fltValue = parseFloat(val);
            if (fltValue < min || fltValue > max) {
                return false;
            }
        }
        return true;
    };

    /**********************************************************/
    var validationMessageContent = function(message, messageType) {
        var alertClass = vlib.options.alertWarningClass;
        if (messageType == 'Error') {
            alertClass = vlib.options.alertErrorClass;
        }
        var buf = '<div class="row-fluid">';
        buf += '<div class="span12 alert ' + vlib.options.validationMessageClass + ' ' + alertClass + '">' + message + '</div>';
        return buf;
    };

})(transcribeValidation);