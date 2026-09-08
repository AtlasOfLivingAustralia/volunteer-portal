let bvp = {};

(function(lib) {

    const noop = function() {};

    /**
     * Wrapper function for Bootbox Modals.
     * THIS STILL DEPENDS ON jQuery and Bootbox being loaded in the page.
     * TODO: Replace with Bootstrap 5 native modals
     * @param options Any custom properties for the modal dialog.
     */
    lib.showModal = function(options) {

        let opts = {
            backdrop: options.backdrop !== undefined ? options.backdrop : 'static',
            animate: options.animate !== undefined ? options.animate : true,
            centerVertical: options.centerVertical !== undefined ? options.centerVertical : true,
            url: options.url !== undefined ? options.url : false,
            id: options.id !== undefined ? options.id : 'myModal',
            size: options.size !== undefined ? options.size : null,
            className: options.className !== undefined ? options.className : null,
            title: options.title !== undefined ? options.title : 'Modal Title',
            onClosing: options.onClosing || noop,
            onClose: options.onClose || noop,
            onShowing: options.onShowing || noop,
            onShown: options.onShown || noop,
            buttons: options.buttons !== undefined ? options.buttons : null
        };

        if (opts.url !== undefined && opts.url !== false) {
            $.get(opts.url, function (html) {
                let dialog = bootbox.dialog({
                    id: opts.id,
                    animate: opts.animate,
                    message: html,
                    title: opts.title,
                    backdrop: opts.backdrop,
                    centerVertical: opts.centerVertical,
                    onEscape: true,
                    buttons: opts.buttons,
                    size: opts.size,
                    className: opts.className,
                    show: false
                });

                // Fixes event handling when using bootbox for dialogs
                dialog.on('show.bs.modal', function () {
                    opts.onShowing();
                });
                dialog.on('shown.bs.modal', function () {
                    opts.onShown();
                });
                dialog.on('hide.bs.modal', function () {
                    opts.onClosing();
                });
                dialog.on('hidden.bs.modal', function () {
                    opts.onClose();
                    if (window.history && window.history.pushState) {
                        const current = window.history.state;
                        if (current && current["bvp-modal"]) {
                            window.history.back();
                        }
                    }
                });

                dialog.modal('show');
            });

            // hook the back button so that it closes the window. Only works on browsers that support window.history and window.history.popstate
            if (window.history && window.history.pushState) {
                window.history.pushState({'bvp-modal': opts.url}, opts.title);
                window.onpopstate = function (event) {
                    lib.hideModal();
                };
            }
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
    
    lib.round = function(n, places) {
        let factor = 10 ^ places;
        return Math.round(n * factor) / factor;
    };

    lib.bindTooltips = function(selector, width) {

        if (!selector) {
            selector = ".fieldHelp";
        }
        if (!width) {
            width = '500px';
        }
        // Context-sensitive help popups
        $(selector).each(function() {
            let tooltipPosition = $(this).attr("tooltipPosition");
            if (!tooltipPosition) {
                tooltipPosition = "bottomRight";
            }

            let targetPosition = $(this).attr("targetPosition");
            if (!targetPosition) {
                targetPosition = "topMiddle";
            }
            let tipPosition = $(this).attr("tipPosition");
            if (!tipPosition) {
                tipPosition = true;  // auto position the speech bubble marker
            }

            let elemWidth = $(this).attr("width");
            if (elemWidth) {
                width = elemWidth.toString() + 'px';
            }

            let styleClasses = ['qtip-bootstrap'];
            let customClass = $(this).attr("customClass");
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
                    classes: styleClasses.join(' ')
                }
            }).on('click', function(e){ e.preventDefault(); return false; });
        });
    };

    lib.submitWithWebflowEvent = function(jqButton, event) {

        if (event == null) {
            event = $(jqButton).attr("event");
        }

        let form = $(jqButton).closest("form");
        if (form.length && event) {
            // Remove any event field that might exist first
            const eventInputName = "_eventId_" + event;
            let existingEventInput = $(form).find('input[name="' + eventInputName + '"]');
            if (existingEventInput) {
                existingEventInput.remove();
            }

            // Replace this with DOM jquery
            let eventInput = document.createElement("input");
            eventInput.type = "hidden";
            eventInput.name = eventInputName;
            form[0].appendChild(eventInput);
            form[0].submit();
        }
    };

    lib.suppressEnterSubmit = function() {
        $("input[type=text]").keypress(function(e) {
            if (e.keyCode === 13) {
                e.preventDefault();
            }
        });
    };

    lib.disableBackspace = function() {
        $(document).keydown(function(e) {
            let isTextInputOrTextarea = $(document.activeElement).is('input[type=text], textarea');
            if (e.keyCode === 8 && !isTextInputOrTextarea) {
                e.preventDefault();
                return false;
            }
        });
    };

    lib.selectProjectId = function(callback) {
        let options = {
            title: "Find an Expedition",
            url: BVP_JS_URLS.selectProjectFragment,
            size: 'large',
            onClosing: function() {
                if (callback) {
                    let projectId = $("#selectedProjectId").val();
                    if (projectId) {
                        callback(projectId);
                    }
                }
            }
        };

        lib.showModal(options);
    };
})(bvp);



