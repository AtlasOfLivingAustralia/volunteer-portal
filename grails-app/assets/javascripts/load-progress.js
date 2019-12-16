//= require mustache
//= require_self
function loadProgress(config) {
    (function poll() {
        setTimeout(function() {

            $.ajax({ url: config.loadProgressUrl, success: function(data) {
                    mu.updateTemplate(document.getElementById('load-progress'), 'load-progress-template', data);
                }, dataType: "json", complete: poll });

        }, 1000);

    })();
}
