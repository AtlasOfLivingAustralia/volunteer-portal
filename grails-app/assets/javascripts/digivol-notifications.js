//= encoding UTF-8
//= require compile/eventsource/polyfill.js
//= require compile/bootstrap-notify/3.1.3/bootstrap-notify.js
//= require_self
function digivolNotify(config, self) {
  "use strict";
  var source = new EventSource(config.eventSourceUrl);

  var unloadHandler = function(e) {
    if (source) source.close();
  };

  $( window ).on('unload', unloadHandler);

  source.addEventListener('error', function(e) {
    if (e.readyState == EventSource.CLOSED) {
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
    var data = JSON.parse(event.data);
    //console.log("Got Achievement Awarded Message", data);
    achievement(data);
  }, false);

  source.addEventListener(config.achievmentViewedMessageType, function(event) {
    var data = JSON.parse(event.data);
    //console.log("Got Achievement Viewed Message", data);
    achievementViewed(data);
  }, false);

  source.addEventListener('message', function(e) {
    console.warn("Unexpected SSE", e.data);
  }, false);

  $.notifyDefaults({
    allow_duplicates: false,
    delay: 0,
    offset: {
      x: 20,
      y: 70
    }
  });

  var alertNotify = null;

  function alertMessage(data) {
    var isClosed = amplify.store.sessionStorage("bvp_notify_close");
    if (alertNotify != null) {
      if (data) {
        alertNotify.update('message', data);
      } else {
        alertNotify.close();
      }
    } else if (data && (!isClosed)) {
      alertNotify = $.notify({
        icon: config.alertIconClass,
        message: data
      },{
        type: config.alertType,
        onClose: function() {
          alertNotify = null;
          amplify.store.sessionStorage("bvp_notify_close", true);
        }
      });
    }
  }

  var achievementsNotifications = {};

  function achievement(data) {
    var existing = achievementsNotifications[data.id];
    if (!existing) {
      var achNot = $.notify({
        icon: data.badgeUrl,
        title: data.title,
        message: data.message,
        url: data.profileUrl
      },{
        animate: {
          enter: 'animated pulse',
          exit: 'animated fadeOutUp'
        },
        icon_type: 'img',
        type: config.achievementType,
        onClose: function() {
          $.ajax(config.acceptAchievementsUrl, {
            type: 'post',
            data: { ids : [data.id] },
            dataType: 'json'
          });
          achievementsNotifications[data.id] = null;
        }
      });
      achievementsNotifications[data.id] = achNot;
      // hack to close the notification on click
      achNot.$ele.find('[data-notify="url"]').click(function() {
        achNot.close();
      });
    }

  }

  function achievementViewed(data) {
    var n = achievementsNotifications[data.id];
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

