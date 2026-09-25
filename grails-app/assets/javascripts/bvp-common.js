let bvp = {};

(function(lib) {

    const noop = function() {};

    const MODAL_SIZE_CLASSES = {
        'small': 'modal-sm',
        'large': 'modal-lg',
        'extra-large': 'modal-xl'
    };

    let openModals = [];

    /* Focus management for every Bootstrap modal in the app — helper-built and
     * page-owned alike.
     *
     * Bootstrap 5.0.2 sets aria-hidden="true" on the modal root while a control
     * inside it still holds focus, which assistive technology blocks outright:
     * "Blocked aria-hidden on an element because its descendant retained focus."
     * Bootstrap 5.3 fixes this upstream with `inert`; until we upgrade, we move
     * focus out ourselves on hide and put it back on the opener on hidden.
     *
     * Delegated on `document` because Bootstrap's modal events bubble, so a modal
     * built in a GSP with `new bootstrap.Modal(...)` is covered without that page
     * needing to know anything about this.
     */
    const modalOpeners = new WeakMap();

    // Safari and Firefox do not focus a <button> on click, so document.activeElement
    // is often <body> by the time a modal opens. Remember what was actually clicked.
    let lastPointerDownTarget = null;
    document.addEventListener('mousedown', function (e) {
        lastPointerDownTarget = e.target;
    }, true);

    function findOpener(modal, explicitOpener) {
        if (explicitOpener) {
            return explicitOpener;
        }
        const active = document.activeElement;
        if (active && active !== document.body && !modal.contains(active)) {
            return active;
        }
        const clicked = lastPointerDownTarget && lastPointerDownTarget.closest
            ? lastPointerDownTarget.closest('a, button, [tabindex]')
            : null;
        if (clicked && !modal.contains(clicked)) {
            return clicked;
        }
        // Opened with no user interaction, e.g. on page load. A trigger declared in
        // markup is only usable if it is unambiguous — repeated row actions are not.
        const declared = modal.id ? document.querySelectorAll('[data-bs-target="#' + modal.id + '"]') : [];
        return declared.length === 1 ? declared[0] : null;
    }

    document.addEventListener('show.bs.modal', function (e) {
        modalOpeners.set(e.target, findOpener(e.target, e.relatedTarget));
    });

    document.addEventListener('hide.bs.modal', function (e) {
        const modal = e.target;
        if (modal.contains(document.activeElement)) {
            // Must happen before Bootstrap sets aria-hidden.
            document.activeElement.blur();
        }
    });

    /* Focus is restored on `hidden`, not `hide`.
     *
     * Bootstrap 5.0.2 removes its focusin trap inside hide(), *after* it has
     * dispatched hide.bs.modal. Focusing the opener from a hide.bs.modal handler
     * therefore fires focusin while the trap is still armed, and the trap pulls
     * focus straight back onto the modal root — leaving `div.modal` itself focused
     * when aria-hidden lands, which is the exact violation this code exists to
     * prevent. By hidden.bs.modal the trap is gone and the modal is display:none.
     */
    document.addEventListener('hidden.bs.modal', function (e) {
        const opener = modalOpeners.get(e.target);
        modalOpeners.delete(e.target);
        if (opener && document.body.contains(opener) && typeof opener.focus === 'function') {
            opener.focus();
        }
        // With no opener, focus rests on <body>: no violation, and the next Tab
        // starts from the top of the document.
    });

    function buildModalElement(opts, bodyHtml) {
        const titleId = opts.id + '-title';

        const root = document.createElement('div');
        root.className = 'modal' + (opts.animate ? ' fade' : '') + (opts.className ? ' ' + opts.className : '');
        root.id = opts.id;
        root.tabIndex = -1;
        root.setAttribute('aria-labelledby', titleId);

        const dialog = document.createElement('div');
        dialog.className = 'modal-dialog' +
            (opts.centerVertical ? ' modal-dialog-centered' : '') +
            (MODAL_SIZE_CLASSES[opts.size] ? ' ' + MODAL_SIZE_CLASSES[opts.size] : '');

        const content = document.createElement('div');
        content.className = 'modal-content';

        const header = document.createElement('div');
        header.className = 'modal-header';
        const title = document.createElement('h5');
        title.className = 'modal-title';
        title.id = titleId;
        title.textContent = opts.title;
        const dismiss = document.createElement('button');
        dismiss.type = 'button';
        dismiss.className = 'btn-close';
        dismiss.setAttribute('data-bs-dismiss', 'modal');
        dismiss.setAttribute('aria-label', 'Close');
        header.appendChild(title);
        header.appendChild(dismiss);

        const body = document.createElement('div');
        body.className = 'modal-body';
        body.innerHTML = bodyHtml;

        content.appendChild(header);
        content.appendChild(body);

        if (opts.buttons) {
            const footer = document.createElement('div');
            footer.className = 'modal-footer';
            Object.keys(opts.buttons).forEach(function (key) {
                const spec = opts.buttons[key];
                const button = document.createElement('button');
                button.type = 'button';
                button.className = 'btn ' + (spec.className || 'btn-outline-secondary');
                // Labels carry markup at some call sites, e.g. a trailing icon.
                button.innerHTML = spec.label || key;
                button.addEventListener('click', function () {
                    // Returning false from a callback keeps the modal open, as the previous library did.
                    if (spec.callback && spec.callback() === false) {
                        return;
                    }
                    bootstrap.Modal.getInstance(root).hide();
                });
                footer.appendChild(button);
            });
            content.appendChild(footer);
        }

        dialog.appendChild(content);
        root.appendChild(dialog);
        return root;
    }

    function openModal(opts, bodyHtml) {
        const element = buildModalElement(opts, bodyHtml);
        document.body.appendChild(element);
        openModals.push(element);

        element.addEventListener('show.bs.modal', function () { opts.onShowing(); });
        element.addEventListener('shown.bs.modal', function () { opts.onShown(); });
        element.addEventListener('hide.bs.modal', function () { opts.onClosing(); });
        element.addEventListener('hidden.bs.modal', function () {
            opts.onClose();
            if (window.history && window.history.pushState) {
                const current = window.history.state;
                if (current && current["bvp-modal"]) {
                    window.history.back();
                }
            }
            openModals = openModals.filter(function (open) { return open !== element; });
            bootstrap.Modal.getInstance(element).dispose();
            element.remove();
        });

        new bootstrap.Modal(element, {
            backdrop: opts.backdrop,
            keyboard: true
        }).show();
    }

    /**
     * Opens a Bootstrap 5 modal, either from a fragment URL or from inline markup.
     * @param options Any custom properties for the modal dialog.
     */
    lib.showModal = function(options) {

        let opts = {
            backdrop: options.backdrop !== undefined ? options.backdrop : 'static',
            animate: options.animate !== undefined ? options.animate : true,
            centerVertical: options.centerVertical !== undefined ? options.centerVertical : true,
            url: options.url !== undefined ? options.url : false,
            message: options.message !== undefined ? options.message : null,
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

        if (opts.url) {
            $.get(opts.url, function (html) {
                openModal(opts, html);
            });

            // hook the back button so that it closes the window. Only works on browsers that support window.history and window.history.popstate
            if (window.history && window.history.pushState) {
                window.history.pushState({'bvp-modal': opts.url}, opts.title);
                window.onpopstate = function (event) {
                    lib.hideModal();
                };
            }
        } else if (opts.message !== null) {
            openModal(opts, opts.message);
        }
    };

    lib.hideModal = function() {
        // Only modals this helper opened; pages with their own markup manage their own.
        openModals.slice().forEach(function (element) {
            const instance = bootstrap.Modal.getInstance(element);
            if (instance) {
                instance.hide();
            }
        });
    };

    /**
     * Confirmation dialog. onConfirm runs only when the user confirms.
     */
    lib.confirm = function(message, onConfirm) {
        lib.showModal({
            id: 'bvp-confirm',
            title: 'Please confirm',
            message: message,
            buttons: {
                cancel: { label: 'Cancel', className: 'btn-outline-secondary' },
                confirm: { label: 'OK', className: 'btn-danger', callback: onConfirm }
            }
        });
    };

    /**
     * Message dialog with a single dismiss button.
     */
    lib.alert = function(message) {
        lib.showModal({
            id: 'bvp-alert',
            title: 'Attention!',
            message: message,
            buttons: {
                ok: { label: 'OK', className: 'btn-outline-secondary' }
            }
        });
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

    const TOOLTIP_WIDTH_CLASSES = [
        { maxLength: 120, className: 'tooltip-w-sm' },
        { maxLength: 300, className: 'tooltip-w-md' },
        { maxLength: 600, className: 'tooltip-w-lg' }
    ];

    function tooltipWidthClass(html) {
        const text = new DOMParser().parseFromString(html, 'text/html').body.textContent || '';
        const bucket = TOOLTIP_WIDTH_CLASSES.find(function (b) { return text.length <= b.maxLength; });
        return bucket ? bucket.className : 'tooltip-w-xl';
    }

    lib.bindTooltips = function (selector) {
        document.querySelectorAll(selector || '.fieldHelp').forEach(function (el) {
            if (bootstrap.Tooltip.getInstance(el)) {
                return;
            }
            const title = el.getAttribute('title') || '';
            const widthClass = tooltipWidthClass(title);
            let customClass = [widthClass, el.getAttribute('customClass')]
            // If width is lg or xl, add customClass left align.
            if (widthClass === 'tooltip-w-lg' || widthClass === 'tooltip-w-xl') {
                customClass.push('tooltip-custom-text-left');
            }
            new bootstrap.Tooltip(el, {
                html: true,
                placement: el.getAttribute('placement') || 'auto',
                customClass: customClass.filter(Boolean).join(' '),
                sanitize: true
            });
            el.addEventListener('click', function (e) { e.preventDefault(); });
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



