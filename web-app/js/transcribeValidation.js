var transcribeValidation = {};

(function(vlib) {

    vlib.options = {
        warningClass: 'error',
        alertClass: 'alert-error',
        validationMessageClass: 'validationMessage',
        ruleAttribute: 'validationRule'
    };

    vlib.messages = {
        generic: 'Invalid field value',
        mandatory: 'This field is mandatory',
        integer: 'This field must be an integer',
        numeric: 'This field must be a number',
        positiveInteger: 'This field must be a positive integer'
    };

    vlib.rules = {
        // --- MANDATORY
        mandatory: function(value, element) {
            return value;
        },

        // --- INTEGER
        integer: function(value, element) {
            if (value) {
                return vlib.isInt(value);
            }
            return true;
        },

        // --- NUMERIC
        numeric: function(value, element) {
            if (value) {
                return $.isNumeric(value);
            }
            return true;
        },
        // --- POSITIVE INTEGER
        positiveInteger: function(value, element) {
            if (value) {
                if (!vlib.isInt(value)) {
                    return false;
                }
                var intVal = parseInt(value);
                return intVal >= 0;
            }

            return true;
        }

    };

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
                var ruleClosure = vlib.rules[ruleName];
                if (ruleClosure) {
                    var value = $.trim($(element).val());
                    if (!ruleClosure(value, element)) {
                        var message;
                        var messageSource = vlib.messages[ruleName];
                        if (messageSource) {
                            if (typeof(messageSource) === 'string') {
                                message = messageSource;
                            } else if (typeof(messageSource) === 'function') {
                                message = messageSource(element);
                            }
                        }

                        if (!message) {
                            message = vlib.messages.generic;
                        }

                        vlib.markFieldInvalid(element, message);
                        errorList.push({element: element, message: message});
                    }
                }
            }
        });

        // now validate special widgets
        vlib.validateTranscribeWidgets(errorList);

        return errorList.length == 0;
    };

    vlib.validateTranscribeWidgets = function(messages) {
        vlib.validateLatLongWidgets(messages);
        vlib.validateDateWidgets(messages);
    };

    vlib.validateDateWidgets = function(messages) {
        $(".dateWidget").each(function(index, element) {
            var yearElement = $(element).find(":input.year");
            var monthElement = $(element).find(":input.month");
            var dayElement = $(element).find(":input.day");

            if (!yearElement.val() && !monthElement.val() && !dayElement.val()) {
                return true;
            }

            if (!vlib.validateIsInteger(yearElement) || !vlib.validateIsInteger(monthElement) || !vlib.validateIsInteger(dayElement)) {
                messages.push({element: yearElement, message: "Date values must be integers"});
                return false;
            }

        });
        return true;
    };

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

    vlib.markFieldInvalid = function(element, message) {
        var parent = $(element).closest(".control-group");
        parent.addClass(vlib.options.warningClass);
        parent.append(validationMessageContent(message));
    };

    vlib.validateIsInteger = function(element) {
        var value = element.val();
        if (value) {
            if (!vlib.isInt(value)) {
                vlib.markFieldInvalid(element, "Value is not numeric");
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
    };

    /**********************************************************/
    var validationMessageContent = function(message) {
        var buf = '<div class="row-fluid">';
        buf += '<div class="span12 alert ' + vlib.options.validationMessageClass + ' ' + vlib.options.alertClass + '">' + message + '</div>';
        return buf;
    };

})(transcribeValidation);