<!-- Google Analytics -->
<script>
    window.ga=window.ga||function(){(ga.q=ga.q||[]).push(arguments)};ga.l=+new Date;
    var trackers = <cl:analyticsTrackers />;
    for (var i = 0, l = trackers.length; i < l; ++i) {
        var is = i.toString();
        ga('create', trackers[i], 'auto', is);
        ga('send', 'pageview', is);
    }
</script>
<script async src='//www.google-analytics.com/analytics.js'></script>
<!-- End Google Analytics -->