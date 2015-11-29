var bvp = {};

(function(lib) {

    var noop = function() {};

    lib.showModal = function(options) {

        var opts = {
            backdrop: options.backdrop ? options.backdrop : true,
            keyboard: options.keyboard ? options.keyboard: true,
            url: options.url ? options.url : false,
            id: options.id ? options.id : 'myModal',
            height: options.height ? options.height : 500,
            width: options.width ? options.width : 600,
            size: options.size ? options.size : null,
            className: options.className ? options.className : null,
            title: options.title ? options.title : 'Modal Title',
            hideHeader: options.hideHeader ? options.hideHeader : false,
            onClose: options.onClose || noop,
            onShown: options.onShown || noop,
            buttons: options.buttons ? options.buttons : null
        };

        $.get(opts.url, function(html) {
            var dialog = bootbox.dialog({
                message: html,
                title: options.title,
                backdrop: options.backdrop,
                onEscape: true,
                buttons: options.buttons,
                size: opts.size,
                className: opts.className
            });

            //Fixes event handling when using bootbox for dialogs
            dialog.on('hidden.bs.modal', function(e) {
                opts.onClose();
                // Pop this modal off the history stack. Will only work on browsers that support window history
                if (window.history && window.history.pushState) {
                    var current = window.history.state;
                    if (current && current["bvp-modal"]) {
                        window.history.back(1);
                    }
                }
            });

            dialog.on('shown.bs.modal', function(e) {
                if (opts.onShown) {
                    opts.onShown();
                }
            });
        });

        // hook the back button so that it closes the window. Only works on browsers that support window.history and window.history.popstate
        if (window.history && window.history.pushState) {
            window.history.pushState({'bvp-modal':opts.url}, opts.title)
            window.onpopstate = function(event) {
                lib.hideModal();
            };
        }

    };

    lib.hideModal = function() {
        bootbox.hideAll();
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

    lib.escapeIdPart = function(id) {
        return id.replace( /(:|\.|\[|\]|,)/g, "\\$1" );
    };

    lib.bindTooltips = function(selector, width) {

        if (!selector) {
            selector = ".fieldHelp";
        }
        if (!width) {
            width = '500px';
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
                width = elemWidth.toString() + 'px';
            }

            var styleClasses = ['qtip-bootstrap'];
            var customClass = $(this).attr("customClass");
            if (customClass) {
                styleClasses.push(customClass);
            }

            $(this).qtip({
                tip: true,
                position: {
                    my: tooltipPosition,
                    at: targetPosition
                },
                hide: {
                  fixed: true
                },
                style: {
                    width: width,
                    classes: styleClasses.join(' '),
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



