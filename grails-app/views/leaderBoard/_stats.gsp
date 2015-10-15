<r:require modules="digivol, digivol-stats, livestamp"/>
<g:set var="instName" value="${institutionName ?: institutionInstance?.name ?: message(code: 'default.application.name')}"/>
<g:set var="institutionId" value="${institutionInstance?.id}"/>
<section id="digivol-stats">
    <div class="panel panel-default volunteer-stats">
        <!-- Default panel contents -->
        <h2 class="heading">${instName} Stats<i class="fa fa-users fa-sm pull-right"></i></h2>

        <h3>
            <g:link controller="user" action="list">
                <!-- ko if: loading --><cl:spinner/><!-- /ko -->
                <!-- ko ifNot: loading, text: transcriberCount --><!-- /ko -->
                Volunteers
            </g:link>
        </h3>

        <p>
            <!-- ko if: loading --><cl:spinner/><!-- /ko -->
            <!-- ko ifNot: loading, text: completedTasks --><!-- /ko -->
            tasks of
            <!-- ko if: loading --><cl:spinner/><!-- /ko -->
            <!-- ko ifNot: loading, text: totalTasks --><!-- /ko -->
            completed
        </p>

    </div><!-- Volunteer Stats Ends Here -->

    <div class="panel panel-default leaderboard">
        <!-- Default panel contents -->
        <h2 class="heading">Leaderboard <i class="fa fa-trophy fa-sm pull-right"></i></h2>
        <!-- Table -->
        <table class="table">
            <thead>
            <tr>
                <th colspan="2">Day Tripper</th>
                <th class="view-more"><g:link controller="leaderBoard" action="topList"
                                              params="[category: 'daily', institutionId: institutionId]">View Top 20</g:link></th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <th scope="row">
                    <a id="day-tripper-image" data-bind="attr: { href: daily.userProfileUrl }">
                        <img data-bind="attr: { src: daily.src }" class="avatar img-circle">
                    </a>
                </th>
                <th>
                    <!-- ko if: loading --><cl:spinner/><!-- /ko -->
                    <!-- ko ifNot: loading -->
                    <a id="day-tripper-name" data-bind="attr: { href: daily.userProfileUrl }, text: daily.name"></a>
                    <!-- /ko -->
                </th>
                <td id="day-tripper-amount" class="transcribed-amount" data-bind="text: daily.score"></td>
            </tr>
            </tbody>
            <thead>
            <tr>
                <th colspan="2">Weekly Wonder</th>
                <th class="view-more"><g:link controller="leaderBoard" action="topList"
                                              params="[category: 'weekly', institutionId: institutionId]">View Top 20</g:link></th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <th scope="row">
                    <a id="weekly-wonder-image" data-bind="attr: { href: weekly.userProfileUrl }">
                        <img data-bind="attr: { src: weekly.src }" class="avatar img-circle">
                    </a>
                </th>
                <th>
                    <!-- ko if: loading --><cl:spinner/><!-- /ko -->
                    <!-- ko ifNot: loading -->
                    <a id="weekly-wonder-name" data-bind="attr: { href: weekly.userProfileUrl }, text: weekly.name"></a>
                    <!-- /ko -->
                </th>
                <td id="weekly-wonder-amount" class="transcribed-amount" data-bind="text: weekly.score"></td>
            </tr>
            </tbody>
            <thead>
            <tr>
                <th colspan="2">Monthly Maestro</th>
                <th class="view-more"><g:link controller="leaderBoard" action="topList"
                                              params="[category: 'monthly', institutionId: institutionId]">View Top 20</g:link></th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <th scope="row">
                    <a id="monthly-maestro-image" data-bind="attr: { href: monthly.userProfileUrl }">
                        <img data-bind="attr: { src: monthly.src }" class="avatar img-circle">
                    </a>
                </th>
                <th>
                    <!-- ko if: loading --><cl:spinner/><!-- /ko -->
                    <!-- ko ifNot: loading -->
                    <a id="monthly-maestro-name"
                       data-bind="attr: { href: monthly.userProfileUrl }, text: monthly.name"></a>
                    <!-- /ko -->
                </th>
                <td id="monthly-maestro-amount" class="transcribed-amount" data-bind="text: monthly.score"></td>
            </tr>
            </tbody>
            <thead>
            <tr>
                <th colspan="2">${instName} Legend</th>
                <th class="view-more"><g:link controller="leaderBoard" action="topList"
                                              params="[category: 'alltime', institutionId: institutionId]">View Top 20</g:link></th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <th scope="row">
                    <a id="digivol-legend-image" data-bind="attr: { href: alltime.userProfileUrl }">
                        <img data-bind="attr: { src: alltime.src }" class="avatar img-circle">
                    </a>
                </th>
                <th>
                    <!-- ko if: loading -->
                    <cl:spinner/>
                    <!-- /ko -->
                    <!-- ko ifNot: loading -->
                    <a id="digivol-legend-name"
                       data-bind="attr: { href: alltime.userProfileUrl }, text: alltime.name"></a>
                    <!-- /ko -->
                </th>
                <td id="digivol-legend-amount" class="transcribed-amount" data-bind="text: alltime.score"></td>
            </tr>
            </tbody>
        </table>
    </div><!-- Leaderboard Ends Here -->


    <h2 class="heading">
        Latest Contributions<!-- ko if: loading --> <cl:spinner/><!-- /ko -->
    </h2>
    <ul class="media-list" data-bind="template: { name: 'contribution-template', foreach: contributors }">
    </ul>
    <g:link controller="user" action="list">View all contributors »</g:link>
</section>
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
institutionId: ${institutionId ?: -1}
    });
</r:script>