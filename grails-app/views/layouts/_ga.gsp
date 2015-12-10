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
<script async src='//www.google-analytics.com/analytics.js'></script>
<!-- End Google Analytics -->