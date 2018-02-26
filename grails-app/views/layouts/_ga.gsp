<%@ page import="grails.util.Environment" %>
<!-- Google Analytics -->
<script>
    window.ga=window.ga||function(){(ga.q=ga.q||[]).push(arguments)};ga.l=+new Date;
    var trackers = <cl:analyticsTrackers />;
    for (var i = 0, l = trackers.length; i < l; ++i) {
        if (i == 0) {
            ga('create', trackers[i], 'auto');
            ga('send', 'pageview');
        } else {
            var is = i.toString();
            ga('create', trackers[i], 'auto', is);
            ga(is+'.send', 'pageview');
        }
    }
</script>
<g:if test="${grailsApplication.config.getProperty('digivol.trackJsErrors', Boolean, false)}">
<script>
    (function (window) {
        // Retain a reference to the previous global error handler, in case it has been set:
        var originalWindowErrorCallback = window.onerror;
        window.onerror = function customErrorHandler (errorMessage, url, lineNumber, columnNumber, errorObject) {
            // Send error details to Google Analytics, if the library is already available:
            if (typeof ga === 'function') {
                try {
                    // In case the "errorObject" is available, use its data, else fallback
                    // on the default "errorMessage" provided:
                    var exceptionDescription = errorMessage;
                    if (typeof errorObject !== 'undefined' && typeof errorObject.message !== 'undefined') {
                        exceptionDescription = errorObject.message;
                    }
                    // Format the message to log to Analytics (might also use "errorObject.stack" if defined):
                    exceptionDescription += ' @ ' + url + ':' + lineNumber + ':' + columnNumber;
                    var trackers = <cl:analyticsTrackers />;
                    for (var i = 0, l = trackers.length; i < l; ++i) {
                        if (i == 0) {
                            ga('send', 'exception', {
                                'exDescription': exceptionDescription,
                                'exFatal': false, // Some Error types might be considered as fatal.
                                'appName': '${grailsApplication.config.info.app.name}',
                                'appVersion': '${grailsApplication.config.info.app.version}'
                            });

                        } else {
                            var is = i.toString();
                            ga(is+'.send', 'exception', {
                                'exDescription': exceptionDescription,
                                'exFatal': false, // Some Error types might be considered as fatal.
                                'appName': '${grailsApplication.config.info.app.name}',
                                'appVersion': '${grailsApplication.config.info.app.version}'
                            });

                        }
                    }
                } catch (e) {
                    // consume error here to prevent a loop
                    console.log(e)
                }
            }
            // If the previous "window.onerror" callback can be called, pass it the data:
            if (typeof originalWindowErrorCallback === 'function') {
                return originalWindowErrorCallback(errorMessage, url, lineNumber, columnNumber, errorObject);
            }
            // Otherwise, Let the default handler run:
            return false;
        };
    })(window);
</script>
</g:if>
<script async src='//www.google-analytics.com/analytics.js'></script>
<!-- End Google Analytics -->