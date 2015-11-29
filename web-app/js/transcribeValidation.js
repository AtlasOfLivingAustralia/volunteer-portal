var transcribeValidation = {};

(function(vlib) {

    vlib.options = {
        errorClass: 'has-error',
        warningClass: 'has-warning',
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

        $("." + vlib.options.errorClass).each(function(index, element) {
            $(element).removeClass(vlib.options.errorClass);
        });

        $("." + vlib.options.validationMessageClass).each(function(index, element) {
            $(element).remove();
        });
    };

    vlib.validateFields = function() {

        // first clear any error visualisations...
        errorClearer();

        var validationResult = vlib.validate();

        errorRenderer(validationResult.errorList);

        return validationResult;
    };

    vlib.validate = function() {
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
        vlib.evaluateCustomValidators(errorList);
        var hasErrors = false;
        var hasWarnings = false;

        $.each(errorList, function(index, error) {
            if (error.type == 'Error') {
                hasErrors = true;
            } else {
                hasWarnings = true;
            }
        });

        return { hasWarnings : hasWarnings, hasErrors: hasErrors, errorList: errorList }
    };

    var defaultErrorRenderer = function(errorList) {
        $.each(errorList, function(index, error) {
            vlib.markFieldInvalid(error.element, error.message, error.type);
        });
    };

    var errorClearer = vlib.clearMessages;
    var errorRenderer = defaultErrorRenderer;

    vlib.setErrorRenderFunctions = function(errorRenderFn, errorClearFn) {
        errorRenderer = errorRenderFn;
        errorClearer = errorClearFn;
    };

    var customValidators = [];

    vlib.evaluateCustomValidators = function(errorList) {
        try {
            return _.each(customValidators, function(f) {
                if (typeof(f) === 'function') {
                    f(errorList);
                } else if (window.console) {
                    console.warn("Got invalid custom validator", f);
                }
            });
        } catch(e) {
            if (window.console) console.error("error running custom validators",e);
            return false;
        }
    };

    vlib.addCustomValidator = function(f) {
        customValidators.push(f);
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

        if (yearVal && !vlib.validateInNumberRange(yearElement, 1000, 3000)) {
            messages.push({element: dayElement, message: "Year values must be between 1000 and 3000"});
            return false;
        }


        return true;
    }

//    vlib.valid_months = [
//        "january","february","march","april","may","june","july","august","september","october","november","december",
//        "i","ii","iii","iv","v","vi","vii","viii", "ix", "x", "xi", "xii"
//
//    ];

    vlib.validateLatLongWidgets = function(messages) {
        $(".latLongWidget").each(function(index, element) {

            var targetField = $(element).attr("targetField");

            var isLatitude = false;
            var typeLabel = "latitude/longitude";
            if (targetField) {

                if (targetField.toLowerCase().indexOf("lat") > 0) {
                    isLatitude = true;
                }
            }

            var decimalDegreesElement = $(element).find(":input.decimalDegrees");

            if (decimalDegreesElement.val()) {
                // Just let this through?
                return;
            }

            var degreesElement = $(element).find(":input.degrees");
            var minutesElement = $(element).find(":input.minutes");
            var secondsElement = $(element).find(":input.seconds");
            var directionElement = $(element).find(":input.direction");

            if (!degreesElement.val() && !minutesElement.val() && !secondsElement.val() && !directionElement.val()) {
                return;
            }

            if (!degreesElement.val() && (minutesElement.val() || secondsElement.val() || directionElement.val())) {
                messages.push({element:degreesElement, message: "Degrees must be supplied if minutes, seconds or a direction are specified", type:'Error'});
                return;
            }

            if (!degreesElement.val() && !minutesElement.val() && secondsElement.val()) {
                messages.push({element:degreesElement, message: "Degrees and minutes must be supplied if seconds are specified", type:'Error'});
                return;
            }

            if (!vlib.validateIsInteger(degreesElement) || !vlib.validateIsNumeric(minutesElement) || !vlib.validateIsInteger(secondsElement)) {
                messages.push({element:degreesElement, message: "Degrees, Minutes and Seconds values must be numeric", type:'Warning'});
                return;
            }

            var typeLabel = "longitude";
            var maxMin = 180;
            if (isLatitude) {
                maxMin = 90;
                typeLabel = "latitude";
            }

            if (!vlib.validateInNumberRange(degreesElement, -maxMin, maxMin)) {
                messages.push({element:degreesElement, message: typeLabel + " degrees should be between " + -maxMin.toString() + " and " + maxMin.toString(), type:'Warning'});
                return;
            }

            if (!vlib.validateInNumberRange(minutesElement, 0, 60) || !vlib.validateInNumberRange(secondsElement, 0, 60)) {
                messages.push({element:minutesElement, message: "Invalid value. Seconds and Minutes must be between 0 and 60", type:'Warning'});
                return;
            }

        });

        return true;
    };

    vlib.markFieldInvalid = function(element, message, type) {
        var parent = $(element).closest(".form-group");
        var clazz = vlib.options.warningClass;
        if (type == 'Error') {
            clazz = vlib.options.errorClass;
        }

        parent.addClass(clazz);
        parent.append(validationMessageContent(message, type));
    };

    vlib.validateIsNumeric = function(element) {
        var value = element.val();
        if (value) {
            return $.isNumeric(value);
        }
        return true;
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
        var buf = '<div class="row">';
        buf += '<div class="col-sm-12 alert ' + vlib.options.validationMessageClass + ' ' + alertClass + '">' + message + '</div></div>';
        return buf;
    };

})(transcribeValidation);