//= encoding UTF-8
(function (window, $) {
    "use strict";

    function recipientSelectOptions(mode) {
        var base = {
            create: false,
            persist: false,
            searchField: ["text"],
            placeholder: "Select a recipient"
        };

        if (mode === "project") {
            return Object.assign({}, base, {
                maxItems: null,
                plugins: ["remove_button"],
                placeholder: "Select an expedition"
            });
        }

        if (mode === "institution") {
            return Object.assign({}, base, {
                placeholder: "No recipient selection required"
            });
        }

        return base;
    }

    function setSelectState($recipient, mode, optionHtml, disabled) {
        $recipient.removeAttr("title");
        $recipient.empty();

        if (mode === "project") {
            $recipient.attr("multiple", "multiple");
        } else {
            $recipient.removeAttr("multiple");
        }

        if (optionHtml) {
            $recipient.append(optionHtml);
        }

        $recipient.prop("disabled", !!disabled);
    }

    function buildUserOptions(data, selectedUserId, includeOptOut) {
        var html = "";
        $.each(data || [], function (_, u) {
            var selectedAttr = (u.id === selectedUserId) ? " selected='selected'" : "";
            var disabledAttr = "";
            var suffix = "";

            if (includeOptOut && u.optOut) {
                suffix = " (Opted Out)";
                disabledAttr = " disabled";
            }

            html += "<option value='" + u.id + "'" + selectedAttr + disabledAttr + ">";
            html += (u.lastName || "") + ", " + (u.firstName || "") + suffix;
            html += "</option>";
        });
        return html;
    }

    function buildProjectOptions(data) {
        var html = "";
        $.each(data || [], function (_, p) {
            var id = String(p.id);
            html += "<option value='" + id + "'>" + p.name + "</option>";
        });
        return html;
    }

    function applySelectedProjects($recipient, selectedProjectIds) {
        var ids = (selectedProjectIds || []).map(function (id) { return String(id); });
        ids.forEach(function (id) {
            var $opt = $recipient.find("option[value='" + id + "']");
            if ($opt.length) $opt.prop("selected", true);
        });
    }

    window.InstitutionMessageRecipient = {
        init: function (cfg) {
            var $recipient = $(cfg.recipientSelector);
            var $recipientType = $(cfg.recipientTypeSelector);
            var $institution = $(cfg.institutionSelector);
            var $loading = $(cfg.loadingSelector);

            function refreshTomSelect(mode) {
                //if (mode !== "project") bvpSelect.destroy(cfg.recipientSelector); // Already clean from below
                bvpSelect.init(cfg.recipientSelector, recipientSelectOptions(mode));
            }

            function renderRecipient(type, data) {
                if (type === "user") {
                    var userOptions = buildUserOptions(data, cfg.selectedUserId || 0, !!cfg.includeOptOut);
                    bvpSelect.destroy(cfg.recipientSelector);
                    setSelectState($recipient, "user", userOptions, !!cfg.isApproved);
                    refreshTomSelect("user");
                } else if (type === "project") {
                    var projectOptions = buildProjectOptions(data);
                    bvpSelect.destroy(cfg.recipientSelector);
                    setSelectState($recipient, "project", projectOptions, !!cfg.isApproved);
                    applySelectedProjects($recipient, cfg.selectedProjectIds || []);
                    refreshTomSelect("project");
                } else {
                    bvpSelect.destroy(cfg.recipientSelector);
                    setSelectState($recipient, "institution", "", true);
                    refreshTomSelect("institution");
                }
            }

            function showLoading() {
                $loading.removeClass("d-none hidden");
                $(cfg.recipientContainerSelector).addClass("d-none");
            }

            function hideLoading() {
                $loading.addClass("d-none hidden");
                $(cfg.recipientContainerSelector).removeClass("d-none");
            }

            function fetchAndRender(type) {
                if (type === "user") {
                    showLoading();
                    $.get({ url: cfg.urls.users(), dataType: "json" })
                        .done(function (data) {
                            renderRecipient("user", data);
                        })
                        .always(function() {
                            hideLoading();
                        });
                } else if (type === "project") {
                    showLoading();
                    $.get({ url: cfg.urls.projects(), dataType: "json" })
                        .done(function (data) {
                            renderRecipient("project", data);
                        })
                        .always(function() {
                            hideLoading();
                        });
                } else {
                    showLoading();
                    renderRecipient(type, null);
                    hideLoading();
                }
            }

            $recipientType.on("change", function () {
                $recipient.prop("disabled", false);
                fetchAndRender(this.value);
            });

            $institution.on("change", function () {
                var type = $recipientType.val();
                $recipient.find("option:selected").prop("selected", false);
                fetchAndRender(type);
            });

            // Initial render
            $recipient.prop("disabled", false);
            fetchAndRender(cfg.initialRecipientType);
        }
    };
})(window, jQuery);