//= require mustache
//= require_self
function loadProgress(config) {
    var first = true;
    var lastChange = null;
    var lastRemaining = -1;
    var endTime = null;
    (function poll() {
        setTimeout(function() {

            $.ajax({ url: config.loadProgressUrl, success: function(data) {
                    if (lastRemaining != data.count) {
                        var now = new Date();
                        if (lastChange != null) {
                            var ms = now.getTime() - lastChange.getTime();

                            // var seconds = dif;
                            var msRemaining = (ms / (lastRemaining - data.count)) * data.count;
                            endTime = new Date(now.getTime() + msRemaining);
                        }

                        lastChange = now;
                    }

                    lastRemaining = data.count;

                    data.finishEstimate = endTime ? endTime.toLocaleString() : null;
                    mu.updateTemplate(document.getElementById('load-progress'), 'load-progress-template', data);
                }, dataType: "json", complete: poll });

        }, first ? 0 : 30000);
        first = false;
    })();
}
