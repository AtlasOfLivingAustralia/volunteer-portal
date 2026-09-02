//= encoding UTF-8
//= require compile/eventsource/polyfill.js
//= require_self

function digivolNotify(config, self) {
  "use strict";

  let source = new EventSource(config.eventSourceUrl);

  // Notification containers
  let alertContainer = ensureContainer("bvp-alert-container", {top: 70, right: 20});
  let toastContainer = ensureContainer("bvp-toast-container", {top: 70, right: 20});

  // Keep parity with old behavior/state
  let alertNotify = null;
  let achievementsNotifications = {};

  function ensureContainer(id, offset) {
    let el = document.getElementById(id);
    if (!el) {
      el = document.createElement("div");
      el.id = id;
      el.style.position = "fixed";
      el.style.zIndex = "1080";
      el.style.top = offset.top + "px";
      el.style.right = offset.right + "px";
      el.style.maxWidth = "720px";
      el.style.width = "auto";
      el.style.display = "flex";
      el.style.flexDirection = "column";
      el.style.gap = "8px";
      document.body.appendChild(el);
    }
    return el;
  }

  function createAlertHandle(options) {
    let wrapper = document.createElement("div");
    wrapper.className = "alert alert-" + (options.type || "info") + " alert-dismissible fade show mb-0";
    wrapper.setAttribute("role", "alert");

    let iconHtml = options.iconClass ? '<i class="' + options.iconClass + '"></i> ' : "";
    wrapper.innerHTML =
        '<div class="d-flex align-items-start">' +
        '  <div class="me-2">' + iconHtml + "</div>" +
        '  <div class="flex-grow-1 bvp-alert-message"></div>' +
        '  <button type="button" class="btn-close" aria-label="Close"></button>' +
        "</div>";

    let messageNode = wrapper.querySelector(".bvp-alert-message");
    let closeBtn = wrapper.querySelector(".btn-close");
    messageNode.textContent = options.message || "";

    closeBtn.addEventListener("click", function () {
      close();
    });

    alertContainer.appendChild(wrapper);

    function updateMessage(msg) {
      messageNode.textContent = msg || "";
    }

    function close() {
      if (!wrapper.parentNode) return;
      wrapper.parentNode.removeChild(wrapper);
      if (typeof options.onClose === "function") options.onClose();
    }

    return {
      updateMessage: updateMessage,
      close: close
    };
  }

  function createAchievementToastHandle(options) {
    let toastEl = document.createElement("div");
    toastEl.className = "toast text-bg-" + (options.type || "info") + " border-0";
    toastEl.setAttribute("role", "alert");
    toastEl.setAttribute("aria-live", "assertive");
    toastEl.setAttribute("aria-atomic", "true");

    // Sticky until user closes, matching old behavior
    toastEl.setAttribute("data-bs-autohide", "false");

    let iconHtml = options.iconUrl
        ? '<img src="' + options.iconUrl + '" alt="" style="width:40px; height:40px;">'
        : "";

    let titleHtml = options.title ? "<strong>" + options.title + "</strong>" : "";
    let messageHtml = options.message ? "<div class=\"small mt-1\">" + options.message + "</div>" : "";
    let linkHtml = options.url
        ? '<a href="' + options.url + '" class="stretched-link bvp-ach-link mt-2" target="_blank" rel="noopener">View <i class="fa fa-external-link"></i></a>'
        : "";

    toastEl.innerHTML =
        '<div class="toast-header">' +
        '  <span class="me-2">' + iconHtml + "</span>" +
        '  <div class="me-auto">' + titleHtml + "</div>" +
        '  <button type="button" class="btn-close" aria-label="Close"></button>' +
        "</div>" +
        '<div class="toast-body position-relative">' +
        messageHtml +
        linkHtml +
        "</div>";

    toastContainer.appendChild(toastEl);

    const bsToast = bootstrap.Toast.getOrCreateInstance(toastEl, {autohide: false});
    let closeBtn = toastEl.querySelector(".btn-close");
    let linkEl = toastEl.querySelector(".bvp-ach-link");

    function close() {
      bsToast.hide();
      if (toastEl.parentNode) toastEl.parentNode.removeChild(toastEl);
      if (typeof options.onClose === "function") options.onClose();
    }

    closeBtn.addEventListener("click", function () {
      close();
    });

    if (linkEl) {
      linkEl.addEventListener("click", function () {
        close();
      });
    }

    bsToast.show();

    return {
      close: close
    };
  }

  // ---- Existing wiring preserved ----
  let unloadHandler = function(e) {
    if (source) source.close();
  };

  $( window ).on('unload', unloadHandler);

  source.addEventListener('error', function(e) {
    if (e.readyState === EventSource.CLOSED) {
      //console.debug("Eventsource closed", e);
    } else {
      console.debug("Eventsource error", e);
    }
  }, false);

  source.addEventListener('open', function(e) {
    //console.debug("eventsource opened!");
  }, false);

  source.addEventListener(config.alertMessageType, function(event) {
    //console.log("Got Alert Message", event.data);
    alertMessage(event.data);
  }, false);

  source.addEventListener(config.achievmentAwardedMessageType, function(event) {
    let data = JSON.parse(event.data);
    //console.log("Got Achievement Awarded Message", data);
    achievement(data);
  }, false);

  source.addEventListener(config.achievmentViewedMessageType, function(event) {
    let data = JSON.parse(event.data);
    //console.log("Got Achievement Viewed Message", data);
    achievementViewed(data);
  }, false);

  source.addEventListener('message', function(e) {
    console.warn("Unexpected SSE", e.data);
  }, false);

  function alertMessage(data) {
    var isClosed = amplify.store.sessionStorage("bvp_notify_close");
    if (alertNotify !== null) {
      if (data) {
        alertNotify.updateMessage(data);
      } else {
        alertNotify.close();
      }
    } else if (data && !isClosed) {
      alertNotify = createAlertHandle({
        iconClass: config.alertIconClass,
        message: data,
        type: config.alertType,
        onClose: function () {
          alertNotify = null;
          amplify.store.sessionStorage("bvp_notify_close", true);
        }
      });
    }
  }

  function achievement(data) {
    var existing = achievementsNotifications[data.id];
    if (!existing) {
      var achNot = createAchievementToastHandle({
        iconUrl: data.badgeUrl,
        title: data.title,
        message: data.message,
        url: data.profileUrl,
        type: config.achievementType || "info",
        onClose: function () {
          $.ajax(config.acceptAchievementsUrl, {
            type: "post",
            data: { ids: [data.id] },
            dataType: "json"
          });
          achievementsNotifications[data.id] = null;
        }
      });
      achievementsNotifications[data.id] = achNot;
    }
  }

  function achievementViewed(data) {
    const n = achievementsNotifications[data.id];
    if (n) n.close();
  }

  self.digivolNotifications = {
    addMessageListener: function(message, handler) {
      source.addEventListener(message, handler);
    },
    removeMessageListener: function(message, handler) {
      source.removeEventListener(message, handler);
    }
  }
}

