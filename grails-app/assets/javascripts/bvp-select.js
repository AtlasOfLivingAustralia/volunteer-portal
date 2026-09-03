//= encoding UTF-8
(function (window, document) {
    "use strict";

    function resolveElements(selectorOrElement) {
        if (!selectorOrElement) return [];
        if (typeof selectorOrElement === "string") {
            return Array.prototype.slice.call(document.querySelectorAll(selectorOrElement));
        }
        if (selectorOrElement instanceof Element) {
            return [selectorOrElement];
        }
        if (selectorOrElement.length !== undefined) {
            return Array.prototype.slice.call(selectorOrElement);
        }
        return [];
    }

    function hasTomSelect(el) {
        return !!(el && el.tomselect);
    }

    function initOne(el, options) {
        if (!el) return null;
        if (hasTomSelect(el)) return el.tomselect;

        let opts = options || {};
        return new TomSelect(el, opts);
    }

    function destroyOne(el) {
        if (hasTomSelect(el)) {
            el.tomselect.destroy();
        }
    }

    function refreshOne(el, options) {
        // Tom Select has no direct "refresh" equivalent for external DOM mutations.
        // Safest drop-in behavior: destroy + re-init.
        destroyOne(el);
        return initOne(el, options);
    }

    window.bvpSelect = {
        init: function (selectorOrElement, options) {
            const elements = resolveElements(selectorOrElement);
            let instances = [];
            elements.forEach(function (el) {
                instances.push(initOne(el, options));
            });
            return instances;
        },
        destroy: function (selectorOrElement) {
            resolveElements(selectorOrElement).forEach(destroyOne);
        },
        refresh: function (selectorOrElement, options) {
            const elements = resolveElements(selectorOrElement);
            let instances = [];
            elements.forEach(function (el) {
                instances.push(refreshOne(el, options));
            });
            return instances;
        }
    };
})(window, document);