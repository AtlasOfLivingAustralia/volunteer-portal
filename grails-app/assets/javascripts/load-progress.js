//= require mustache
//= require_self
function loadProgress(config) {
    var first = true;
    var lastChange = null;
    var lastRemaining = -1;
    var endTime = null;
    (function poll() {
        setTimeout(function() {

            $.ajax(
                {
                    url: config.loadProgressUrl,
                    success: function(data) {
                        if (lastRemaining !== data.count) {
                            var now = new Date();
                            if (lastChange != null) {
                                var ms = now.getTime() - lastChange.getTime();

                                // var seconds = dif;
                                var msRemaining = (ms / (lastRemaining - data.count)) * data.count;
                                endTime = new Date(now.getTime() + msRemaining);
                            }

                            lastChange = now;
                        }

                        lastRemaining = data.count - data.errorCount;

                        data.finishEstimate = lastRemaining === 0 ? ('All tasks loaded' + (data.errorCount > 0 ? ' (with errors)' : '')) : (endTime ? formatTime(endTime) : null);
                        data.timeStartedFormatted = formatTime(data.timeStarted ? new Date(data.timeStarted) : new Date());
                        mu.updateTemplate(document.getElementById('load-progress'), 'load-progress-template', data);
                    },
                    dataType: "json",
                    complete: poll
                });

        }, first ? 0 : 30000);
        first = false;
    })();
}

// Helper function to pad single digits
function pad(n) {
    return n < 10 ? '0' + n : n;
}

function formatTime(date) {
    return date.getFullYear() + '-' +
        pad(date.getMonth() + 1) + '-' + // months are 0-based
        pad(date.getDate()) + ' ' +
        pad(date.getHours()) + ':' +
        pad(date.getMinutes()) + ':' +
        pad(date.getSeconds());
}
