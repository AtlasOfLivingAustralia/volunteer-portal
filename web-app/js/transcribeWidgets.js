var transcribeWidgets = {};

(function(lib) {

    // Exports
    lib.initializeTranscribeWidgets = function() {
        initLatLongWidgets();
        initUnitRangeWidgets();
        initDateWidgets();
        initSheetNumberWidgets();
        initImageSelectWidgets();
    };

    lib.prepareFieldWidgetsForSubmission = function() {
        preSubmitDateWidgets();
        preSubmitLatLongWidgets();
        preSubmitSheetNumberWidgets();
        preSubmitUnitRangeWidgets();
    };

    lib.evaluateBeforeSubmitHooks = function(e) {
        try {
            return _.every(beforeSubmitHooks, function(f) {
                return !(typeof(f) === 'function') || f(e);
            });
        } catch(e) {
            if (window.console) console.error("error running before submit hooks",e);
            return false;
        }
    };

    lib.addBeforeSubmitHook = function(f) {
        beforeSubmitHooks.push(f);
    };

    var beforeSubmitHooks = [];

    // REGEX patterns
    var YEAR_PATTERN = /^(\d{2,4})$/;
    var YEAR_MONTH_PATTERN = /^(\d{2,4})-(\d{1,2})$/;
    var YEAR_MONTH_DAY_PATTERN = /^(\d{2,4})-(\d{1,2})-(\d{1,2})$/
    var YEAR_MONTHNAME_PATTERN = /^(\d{2,4})-(\w+)$/;
    var YEAR_MONTHNAME_DAY_PATTERN = /^(\d{2,4})-(\w+)-(\d{1,2})$/;

    var DECIMAL_DEGREE_PATTERN = /^\d+[.]\d+$/;
    var DEGREE_DECIMAL_MINUTES_PATTERN = /^(\d+)[°](\d+[.]\d+)[']{0,1}([NnEeWwSs]?)$/;
    var DEGREE_PATTERN = /^(\d+)[°]([NnEeWwSs]?)$/
    var DEGREE_MINUTES_PATTERN = /^(\d+)[°](\d+(?:[.]\d+)?)[']([NnEeWwSs]?)$/;
    var DEGREE_MINUTES_SECONDS_PATTERN = /^(\d+)[°](\d+)['](\d+(?:[.]\d+)?)["]([NnEeWwSs]?)$/;

    var UNIT_RANGE_PATTERN = /^\s*([^\s:]+)(?::([^\s]+))*(?:\s+([^\s]+))*\s*$/;


    // private init methods ********************************
    function hookTargetFieldChangeEvent(widget, callback) {

        if (callback && widget) {
            callback(widget);
        }

        var targetField = $(widget).attr("targetField");
        if (targetField && callback) {
            var hiddenField = $("#recordValues\\.0\\." + targetField);
            if (hiddenField) {
                hiddenField.change(function(e) {
                    callback(widget);
                });
            }
        }
    }

    var initSheetNumberWidgets = function() {
        $(".sheetNumberWidget").each(function(index, widget) {
            hookTargetFieldChangeEvent(widget, renderSheetNumberWidgetFromTargetField);
        });
    };

    var renderSheetNumberWidgetFromTargetField = function(widget) {
        var targetField = $(widget).attr("targetField");
        var hiddenField = $("#recordValues\\.0\\." + targetField);
        var value = hiddenField.val();
        var sheet = '';
        var of = '';
        if (value.indexOf("/") != -1) {
            var bits = value.split('/');
            sheet = bits[0];
            of = bits[1];
        } else {
            sheet = value;
        }
        $(widget).find(".sheetNumber").val(sheet);
        $(widget).find(".sheetNumberOf").val(of);
    };

    var initDateWidgets = function() {
        $(".dateWidget").each(function(index, widget) {
            hookTargetFieldChangeEvent(widget, renderDateWidgetFromTargetField);
        });
    };

    function parseDateRangeString(value) {
        if (value) {
            if (value.indexOf('/') != -1) {
                var bits = value.split('/')
                var startDate = parseDate(bits[0]);
                var endDate = parseDate(bits[1]);
                return { startDate: startDate, endDate: endDate };
            } else {
                return { startDate: parseDate(value) };
            }
        }
        return { startDate: parseDate(value) };
    }

    function parseDate(value) {

        if (value) {
            var results = YEAR_MONTH_DAY_PATTERN.exec(value);
            if (results) {
                return { year: results[1], month: results[2], day: results[3] };
            }
            results = YEAR_MONTH_PATTERN.exec(value);
            if (results) {
                return { year: results[1], month: results[2] };
            }
            results = YEAR_PATTERN.exec(value);
            if (results) {
                return { year: results[1] };
            }
            results = YEAR_MONTHNAME_PATTERN.exec(value);
            if (results) {
                return { year: results[1], month: results[2] };
            }
            results = YEAR_MONTHNAME_DAY_PATTERN.exec(value);
            if (results) {
                return { year: results[1], month: results[2], day: results[3] };
            }
        }

        return { year: value };
    }

    var initUnitRangeWidgets = function() {
        $(".unitRangeWidget").each(function(index, widget) {
            hookTargetFieldChangeEvent(widget, renderUnitRangeFromTargetField);
        });
    };

    var renderDateWidgetFromTargetField = function(widget) {
        var targetField = $(widget).attr("targetField");
        var hiddenField = $("#recordValues\\.0\\." + targetField);
        var values = parseDateRangeString(hiddenField.val());
        if (values) {
            if (values.startDate) {
                $(widget).find(".startYear").val(values.startDate.year);
                $(widget).find(".startMonth").val(values.startDate.month);
                $(widget).find(".startDay").val(values.startDate.day);
            }

            if (values.endDate) {
                $(widget).find(".endYear").val(values.endDate.year);
                $(widget).find(".endMonth").val(values.endDate.month);
                $(widget).find(".endDay").val(values.endDate.day);
            }
        }
    };


    var initImageSelectWidgets = function() {

        var widgets = $(".imageSelectWidget");

        widgets.filter('.imageSelect').each(function(index, widget) {
            var jw = $(widget);
            jw.on('click', 'a.thumbnail', function(e) {
                var ct = $(e.currentTarget);
                if (ct.hasClass('selected')) {
                    ct.removeClass('selected');
                    syncInputField(ct,jw);
                } else {
                    jw.find('a.thumbnail.selected').removeClass('selected');
                    selectThumbnail(ct,jw);
                }
                //ct.addClass('selected');
                //$('[id=\''+jw.attr('targetField')+'\']').val(ct.attr('data-image-select-value')).trigger('change');
            });
        });

        widgets.filter('.imageMultiSelect').each(function(index, widget) {
            var jw = $(widget);
            jw.on('click', 'a.thumbnail', function(e) {
                var ct = $(e.currentTarget);
                if (ct.hasClass('selected')) {
                    ct.removeClass('selected');
                    syncInputField(ct,jw);
                } else {
                    selectThumbnail(ct, jw);
                }
            });
        });

        function selectThumbnail(ct, jw) {
            ct.addClass('selected');
            syncInputField(ct,jw);
        }

        function syncInputField(ct, jw) {
            var val = ct.parent().siblings().addBack().find('.selected').map(function() { return $(this).attr('data-image-select-value') }).toArray().join(',');
            $('[id=\''+jw.attr('targetField')+'\']').val(val).trigger('change');
        }
    };

    var renderUnitRangeFromTargetField = function(widget) {
        var targetField = $(widget).attr("targetField");
        var hiddenField = $("#recordValues\\.0\\." + targetField);
        var values = parseUnitRangeString(hiddenField.val());
        if (values) {
            $(widget).find(".rangeMinValue").val(values.minValue);
            $(widget).find(".rangeMaxValue").val(values.maxValue);
            $(widget).find(".rangeUnits").val(values.units);
        }
    };

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
    };

    var switchLatLongFormat = function(format) {
        $(".latLongWidget").each(function(index, widget) {
            var selector = $(widget).find(".latLongFormatSelector");
            $(selector).val(format);
            renderLatLongFormat(widget, format);
        });
    };

    var initLatLongWidgets = function () {
        $(".latLongWidget").each(function(index, widget) {
            var values = getLatLongStringFromWidget(widget);

            if (values && values.isDefined) {
                if (values.decimalDegrees) {
                    switchLatLongFormat("DD");
                } else {
                    switchLatLongFormat("DMS");
                }
            }

            hookTargetFieldChangeEvent(widget, renderLatLongFromTargetValue);
            var selector = $(widget).find(".latLongFormatSelector").first();
            if (selector) {
                $(selector).change(function(e) {
                    var newLatLongFormat = $(this).val();
                    switchLatLongFormat(newLatLongFormat);
                });
            }
        });

    };

    function getLatLongStringFromWidget(widget) {
        var targetField = $(widget).attr("targetField");
        var hiddenField = $("#recordValues\\.0\\." + targetField);
        return parseLatLongString(hiddenField.val());
    }

    function renderLatLongFromTargetValue(widget) {
        var values = getLatLongStringFromWidget(widget);
        if (values && values.isDefined) {
            if (values.decimalDegrees) {
                //switchLatLongFormat("DD");
                $(widget).find(".decimalDegrees").val(values.decimalDegrees);
            } else {
                //switchLatLongFormat("DMS");
                $(widget).find(".degrees").val(values.degrees);
                $(widget).find(".minutes").val(values.minutes);
                $(widget).find(".seconds").val(values.seconds);
                $(widget).find(".direction").val(values.direction);
            }
        }
    }

    // Parse out a lat/long string value into component parts. Will detect decimal degrees, and variations of DMS.
    var parseLatLongString = function(value) {

        if (!value) return { isDefined: false, decimalDegrees: "" };

        var results = DECIMAL_DEGREE_PATTERN.exec(value);
        if (results) {
            return { isDefined: true, decimalDegrees: value };
        }
        results = DEGREE_DECIMAL_MINUTES_PATTERN.exec(value)
        if (results) {
            return { isDefined: true, degrees: results[1], minutes: results[2], direction: results[3] };
        }
        results = DEGREE_MINUTES_SECONDS_PATTERN.exec(value);
        if (results) {
            return { isDefined: true, degrees:results[1], minutes: results[2], seconds: results[3], direction: results[4], decimalDegrees: "" };
        }
        results = DEGREE_MINUTES_PATTERN.exec(value);
        if (results) {
            return { isDefined: true, degrees:results[1], minutes: results[2], seconds: "", direction: results[3], decimalDegrees: "" };
        }
        results = DEGREE_PATTERN.exec(value);
        if (results) {
            return { isDefined: true, degrees:results[1], minutes: "", seconds: "", direction: results[2], decimalDegrees: "" };
        }

        return { isDefined: true, decimalDegrees: value };
    }

    function parseUnitRangeString(value) {
        var results = UNIT_RANGE_PATTERN.exec(value);
        if (results) {
            return { minValue: results[1], maxValue: results[2], units: results[3] };
        }

        return { minValue: value }
    }

    // private pre-submit methods ********************************
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

})(transcribeWidgets);

