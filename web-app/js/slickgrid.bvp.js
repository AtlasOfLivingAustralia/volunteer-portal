(function ($) {

    // register namespace
    $.extend(true, window, {
        "BVP": {
            "SlickGrid": {
                "Date": DateEditor,
                "Autocomplete": function(taskId, fieldName) {
                    // return a partially applied function, baking in the necessary parameters to perform the autocomplete lookup
                    return AutoCompleteEditor.bind(this, taskId, fieldName)
                },
                "Select": function(options) {
                    return SelectEditor.bind(this, options)
                }
            }
        }
    });

    function SelectEditor(options, args) {

        var $input;
        var defaultValue;

        this.init = function () {
            var widget = "<select class='editor-text'><option value=''></option>";
            for (var i = 0; i < options.length; ++i) {
                var value = options[i];
                widget += "<option value='" + value + "'>" + value + "</option>";
            }
            widget += "</select>";

            $input = $(widget);
            $input.appendTo(args.container);
            $input.focus().select();
        };

        this.destroy = function () {
            $input.autocomplete("destroy");
        };

        this.focus = function () {
            $input.focus();
        };

        this.loadValue = function (item) {
            defaultValue = item[args.column.field];
            $input.val(defaultValue);
            $input[0].defaultValue = defaultValue;
            $input.select();
        };

        this.serializeValue = function () {
            return $input.val();
        };

        this.applyValue = function (item, state) {
            item[args.column.field] = state;
        };

        this.isValueChanged = function () {
            return (!($input.val() == "" && defaultValue == null)) && ($input.val() != defaultValue);
        };

        this.validate = function () {
            return {
                valid: true,
                msg: null
            };
        };

        this.init();
    }


    function AutoCompleteEditor(taskId, fieldName, args) {

        var $input;
        var defaultValue;

        // This function performs the lookup for the autocomplete
        this.autocompleteSource = function(request, response) {
            var url = BVP_JS_URLS.picklistAutocompleteUrl + "?taskId=" + taskId + "&picklist=" + fieldName + "&q=" + request.term;
            $.ajax(url).done(function(data) {
                var rows = new Array();
                if (data.autoCompleteList) {
                    var list = data.autoCompleteList;
                    for (var i = 0; i < list.length; i++) {
                        rows[i] = {
                            value: list[i].name,
                            label: list[i].name,
                            data: list[i]
                        };
                    }
                }
                if (response) {
                    response(rows);
                }
            });
        };

        this.init = function () {
            $input = $("<INPUT id='tags' class='editor-text' type='text' />");
            $input.appendTo(args.container);
            $input.focus().select();

            $input.bind("keydown.nav", function(e) {
                if ((e.keyCode == $.ui.keyCode.DOWN || e.keyCode == $.ui.keyCode.UP ||
                    e.keyCode == $.ui.keyCode.ENTER)
                    && $('ul.ui-autocomplete').is(':visible')) e.stopPropagation();

                if (e.keyCode == $.ui.keyCode.LEFT || e.keyCode == $.ui.keyCode.RIGHT)
                    e.stopImmediatePropagation();
            });

            $input.autocomplete({
                source: this.autocompleteSource
            });
        };

        this.destroy = function () {
            $input.autocomplete("destroy");
        };

        this.focus = function () {
            $input.focus();
        };

        this.loadValue = function (item) {
            defaultValue = item[args.column.field];
            $input.val(defaultValue);
            $input[0].defaultValue = defaultValue;
            $input.select();
        };

        this.serializeValue = function () {
            return $input.val();
        };

        this.applyValue = function (item, state) {
            item[args.column.field] = state;
        };

        this.isValueChanged = function () {
            return (!($input.val() == "" && defaultValue == null)) && ($input.val() != defaultValue);
        };

        this.validate = function () {
            return {
                valid: true,
                msg: null
            };
        };

        this.init();
    }

    function DateEditor(args) {
        var $input;
        var defaultValue;
        var scope = this;
        var calendarOpen = false;

        this.init = function () {
            $input = $("<INPUT type=text class='editor-text' />");
            $input.appendTo(args.container);
            $input.focus().select();
            $input.datepicker({
                showOn: "button",
                buttonImageOnly: true,
                buttonImage: BVP_JS_URLS.webappRoot + "js/slickgrid/images/calendar.gif",
                dateFormat: 'yy-mm-dd',
                beforeShow: function () {
                    calendarOpen = true
                },
                onClose: function () {
                    calendarOpen = false
                }
            });
            $input.width($input.width() - 20);
        };

        this.destroy = function () {
            $.datepicker.dpDiv.stop(true, true);
            $input.datepicker("hide");
            $input.datepicker("destroy");
            $input.remove();
        };

        this.show = function () {
            if (calendarOpen) {
                $.datepicker.dpDiv.stop(true, true).show();
            }
        };

        this.hide = function () {
            if (calendarOpen) {
                $.datepicker.dpDiv.stop(true, true).hide();
            }
        };

        this.position = function (position) {
            if (!calendarOpen) {
                return;
            }
            $.datepicker.dpDiv.css("top", position.top + 30).css("left", position.left);
        };

        this.focus = function () {
            $input.focus();
        };

        this.loadValue = function (item) {
            defaultValue = item[args.column.field];
            $input.val(defaultValue);
            $input[0].defaultValue = defaultValue;
            $input.select();
        };

        this.serializeValue = function () {
            return $input.val();
        };

        this.applyValue = function (item, state) {
            item[args.column.field] = state;
        };

        this.isValueChanged = function () {
            return (!($input.val() == "" && defaultValue == null)) && ($input.val() != defaultValue);
        };

        this.validate = function () {
            return {
                valid: true,
                msg: null
            };
        };

        this.init();
    }
})($);
