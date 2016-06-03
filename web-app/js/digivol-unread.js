jQuery(function() {
  var $unread = $('.validatedCount');
  if ($unread.length) {
    $.getJSON(BVP_JS_URLS.unreadValidatedCount).done(function(data) {
      if (data.count) {
        var value = data.count > 50 ? '50+' : data.count;
        $unread.text(value).addClass('label label-danger label-as-badge');
      }
    }).error(function() {
      console.log("couldn't retrieve unread validated count");
    });
  }
});