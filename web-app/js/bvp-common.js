var bvp = {};

(function(lib) {

    lib.showModal = function(options) {

        var opts = {
            backdrop: options.backdrop ? options.backdrop : true,
            keyboard: options.keyboard ? options.keyboard: true,
            url: options.url ? options.url : false,
            id: options.id ? options.id : 'modal_element_id',
            height: options.height ? options.height : 500,
            width: options.width ? options.width : 600,
            title: options.title ? options.title : 'Modal Title',
            hideHeader: options.hideHeader ? options.hideHeader : false,
            onClose: options.onClose ? options.onClose : null,
            onShown: options.onShown ? options.onShown : null
        };

        var html = "<div id='" + opts.id + "' class='modal hide' role='dialog' aria-labelledby='modal_label_" + opts.id + "' aria-hidden='true' style='width: " + opts.width + "px; margin-left: -" + opts.width / 2 + "px;overflow: hidden'>";
        if (!opts.hideHeader) {
            html += "<div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>x</button><h3 id='modal_label_" + opts.id + "'>" + opts.title + "</h3></div>";
        }
        html += "<div class='modal-body' style='max-height: " + opts.height + "px'>Loading...</div></div>";

        $("body").append(html);

        var selector = "#" + opts.id;

        $(selector).on("hidden", function() {
            if (opts.onClose) {
                opts.onClose();
            }
            $(selector).remove();

            // Pop this modal off the history stack. Will only work on browsers that support window history
            if (window.history && window.history.pushState) {
                var current = window.history.state;
                if (current && current["bvp-modal"]) {
                    window.history.back(1);
                }
            }

        });

        $(selector).on("shown", function() {
            if (opts.onShown) {
                opts.onShown();
            }
        });

        // hook the back button so that it closes the window. Only works on browsers that support window.history and window.history.popstate
        if (window.history && window.history.pushState) {
            window.history.pushState({'bvp-modal':opts.url}, opts.title)
            window.onpopstate = function(event) {
                lib.hideModal();
            };
        }

        $(selector).modal({
            remote: opts.url,
            keyboard: opts.keyboard,
            backdrop: opts.backdrop
        });

    };

    lib.hideModal = function() {
        $("#modal_element_id").modal('hide');
    };

    lib.htmlEscape = function(str) {
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
    };

    lib.htmlUnescape = function(value) {
        return String(value)
            .replace(/&quot;/g, '"')
            .replace(/&#39;/g, "'")
            .replace(/&lt;/g, '<')
            .replace(/&gt;/g, '>')
            .replace(/&amp;/g, '&');
    };

    lib.escapeId = function(id) {
        return "#" + id.replace( /(:|\.|\[|\]|,)/g, "\\$1" );
    };

    lib.bindTooltips = function(selector, width) {

        if (!selector) {
            selector = "a.fieldHelp";
        }
        if (!width) {
            width = 300;
        }
        // Context sensitive help popups
        $(selector).each(function() {


            var tooltipPosition = $(this).attr("tooltipPosition");
            if (!tooltipPosition) {
                tooltipPosition = "bottomRight";
            }

            var targetPosition = $(this).attr("targetPosition");
            if (!targetPosition) {
                targetPosition = "topMiddle";
            }
            var tipPosition = $(this).attr("tipPosition");
            if (!tipPosition) {
                tipPosition = true;  // auto position the speech bubble marker
            }

            var elemWidth = $(this).attr("width");
            if (elemWidth) {
                width = elemWidth;
            }

            $(this).qtip({
                tip: true,
                position: {
                    corner: {
                        target: targetPosition,
                        tooltip: tooltipPosition
                    }
                },
                style: {
                    width: width,
                    padding: 8,
                    background: 'white', //'#f0f0f0',
                    color: 'black',
                    textAlign: 'left',
                    border: {
                        width: 4,
                        radius: 5,
                        color: '#E66542'// '#E66542' '#DD3102'
                    },
                    tip: tipPosition,
                    name: 'light' // Inherit the rest of the attributes from the preset light style
                }
            }).bind('click', function(e){ e.preventDefault(); return false; });

        });
    }

    lib.submitWithWebflowEvent = function(jqButton, event) {

        if (event == null) {
            event = $(jqButton).attr("event");
        }

        var form = $(jqButton).closest("form");
        if (form.length && event) {
            form.append("<input type='hidden' name='_eventId_" + event + "' />");
            form.submit();
        }
    };

    lib.suppressEnterSubmit = function() {
        $("input[type=text]").keypress(function(e) {
            if (e.keyCode == 13) {
                e.preventDefault();
            }
        });
    };

    lib.disableBackspace = function() {
        $(document).keydown(function(e) {
            var elid = $(document.activeElement).is('input[type=text], textarea');
            if (e.keyCode === 8 && !elid) {
                e.preventDefault();
                return false;
            }
        });
    };

    lib.selectProjectId = function(callback) {
        var options = {
            title: "Find an Expedition",
            url: BVP_JS_URLS.selectProjectFragment,
            width: 800,
            onClose: function() {
                if (callback) {
                    var projectId = $("#selectedProjectId").val();
                    if (projectId) {
                        callback(projectId);
                    }
                }
            }
        };

        lib.showModal(options);
    }


})(bvp);



