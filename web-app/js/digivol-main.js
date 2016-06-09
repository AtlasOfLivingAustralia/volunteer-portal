jQuery(function($) {
  var unreadCount = 0;
  if (BVP_JS_URLS && BVP_JS_URLS.unreadValidatedCount) {
    $.getJSON(BVP_JS_URLS.unreadValidatedCount).done(function(data) {
      unreadCount = data.count;
      updateUnreadCount();
    }).fail(function() {
      console.warn("couldn't retrieve unread validated count", error);
    });
  } else {
    console.warn("Unread validated count URL is not defined!");
  }
  function updateUnreadCount() {
    if (unreadCount > 0) {
      var text = unreadCount > 50 ? '50+' : unreadCount.toString();
      $('.unread-count').text(text).removeClass('hidden');
    } else {
      $('.unread-count').addClass('hidden');
    }
  }
  $(document).on('unreadValidationViewed', function(e, p) {
    if (unreadCount > 0) {
      unreadCount--;
      updateUnreadCount();
    } else {
      console.warn("unread validation viewed when there are no unread validations to view?!");
    }
  });
});