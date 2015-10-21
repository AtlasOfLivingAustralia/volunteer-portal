<r:require modules="digivol, digivol-stats, livestamp"/>
<g:set var="instName" value="${institutionName ?: institutionInstance?.name ?: message(code: 'default.application.name')}"/>
<g:set var="institutionId" value="${institutionInstance?.id}"/>

<h2 class="heading">
    Latest Contributions<!-- ko if: loading --> <cl:spinner/><!-- /ko -->
</h2>
<ul class="media-list" data-bind="template: { name: 'contribution-template', foreach: contributors }">
</ul>

<script type="text/html" id="contribution-template">
<li class="media">
    <div class="media-left">
        <a data-bind="attr: { href: userProfileUrl }">
            <img data-bind="attr: { src: avatarUrl }" class="avatar img-circle">
        </a>
    </div>

    <div class="media-body">
        <span class="time" data-bind='attr: { "data-livestamp": timestamp }'></span>
        <h4 class="media-heading"><a data-bind="text: displayName"></a></h4>

        <p>Transcribed <span data-bind="text: transcribedItems"></span> items from the <a
                data-bind="attr: { href: projectUrl }, text: projectName"></a></p>

        <div class="transcribed-thumbs">
            <!-- ko foreach: transcribedThumbs -->
            <img data-bind="attr: { src: thumbnailUrl }">
            <!-- /ko -->
            <!-- ko if: additionalTranscribedThumbs -->
            <a href="#"><span>+<!-- ko text: additionalTranscribedThumbs --><!-- /ko --></span>More</a>
            <!-- /ko -->
        </div>
        <a class="btn btn-default btn-xs join" role="button"
           data-bind="attr: { href: projectUrl }">Join expedition »</a>
    </div>

</li>
</script>
<r:script>
digivolStats({
    statsUrl: "${createLink(controller: 'index', action: 'stats')}",
    projectUrl: "${createLink(controller: 'project', action: 'index', id: -1)}",
    userProfileUrl: "${createLink(controller: 'user', action: 'show', id: -1)}",
    institutionId: ${institutionId ?: -1},
    maxContributors: 2
});
</r:script>