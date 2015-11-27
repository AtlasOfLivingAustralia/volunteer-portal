<r:require modules="digivol, digivol-stats, livestamp"/>
<g:set var="instName" value="${institutionName ?: institutionInstance?.name ?: message(code: 'default.application.name')}"/>
<g:set var="institutionId" value="${institutionInstance?.id}"/>
<section id="digivol-stats" ng-app="stats" ng-controller="StatsCtrl" class="ng-cloak">
    <g:if test="${!disableStats}">
    <div class="panel panel-default volunteer-stats">
        <!-- Default panel contents -->
        <h2 class="heading">${instName} Stats<g:link controller="user" action="list" class="pull-right"><i class="fa fa-users fa-sm"></i></g:link></h2>

        <h3>
            <g:link controller="user" action="list">
                <span data-ng-if="loading"><cl:spinner/></span>
                <span data-ng-if="!loading">{{transcriberCount}}</span>
                Volunteers
            </g:link>
        </h3>

        <p>
            <span data-ng-if="loading"><cl:spinner/></span>
            <span data-ng-if="!loading">{{completedTasks}}</span>
            tasks of
            <span data-ng-if="loading"><cl:spinner/></span>
            <span data-ng-if="!loading">{{totalTasks}}</span>
            completed
        </p>

    </div><!-- Volunteer Stats Ends Here -->
    </g:if>
    <g:if test="${!disableHonourBoard}">
    <div class="panel panel-default leaderboard">
        <!-- Default panel contents -->
        <h2 class="heading">Honour Board <g:link controller="leaderBoard" action="describeBadges" class="pull-right"><i class="fa fa-trophy fa-sm"></i></g:link></h2>
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
                    <a id="day-tripper-image" data-ng-href="{{userProfileUrl(daily)}}">
                        <img data-ng-src="{{avatarUrl(daily)}}" class="avatar img-circle">
                    </a>
                </th>
                <th>
                    <span data-ng-if="loading"><cl:spinner/></span>
                    <span data-ng-if="!loading">
                    <a id="day-tripper-name" data-ng-href="{{userProfileUrl(daily)}}">{{daily.name}}</a>
                    </span>
                </th>
                <td id="day-tripper-amount" class="transcribed-amount">{{daily.score}}</td>
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
                    <a id="weekly-wonder-image" data-ng-href="{{userProfileUrl(weekly)}}">
                        <img data-ng-src="{{avatarUrl(weekly)}}" class="avatar img-circle">
                    </a>
                </th>
                <th>
                    <span data-ng-if="loading"><cl:spinner/></span>
                    <span data-ng-if="!loading">
                    <a id="weekly-wonder-name" data-ng-href="{{userProfileUrl(weekly)}}">{{weekly.name}}</a>
                    </span>
                </th>
                <td id="weekly-wonder-amount" class="transcribed-amount">{{weekly.score}}</td>
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
                    <a id="monthly-maestro-image" data-ng-href="{{userProfileUrl(monthly)}}">
                        <img data-ng-src="{{avatarUrl(monthly)}}" class="avatar img-circle">
                    </a>
                </th>
                <th>
                    <span data-ng-if="loading"><cl:spinner/></span>
                    <span data-ng-if="!loading">
                    <a id="monthly-maestro-name"
                       data-ng-href="{{userProfileUrl(monthly)}}">{{monthly.name}}</a>
                    </span>
                </th>
                <td id="monthly-maestro-amount" class="transcribed-amount">{{monthly.score}}</td>
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
                    <a id="digivol-legend-image" data-ng-href="{{userProfileUrl(alltime)}}">
                        <img data-ng-src="{{avatarUrl(alltime)}}" class="avatar img-circle">
                    </a>
                </th>
                <th>
                    <span data-ng-if="loading"><cl:spinner/></span>
                    <span data-ng-if="!loading">
                    <a id="digivol-legend-name"
                       data-ng-href="{{userProfileUrl(alltime)}}">{{alltime.name}}</a>
                    </span>
                </th>
                <td id="digivol-legend-amount" class="transcribed-amount">{{alltime.score}}</td>
            </tr>
            </tbody>
        </table>
    </div><!-- Honour Board Ends Here -->
    </g:if>

    <h2 class="heading">
        Latest Contributions<span data-ng-if="loading"> <cl:spinner/></span>
    </h2>
    <ul class="media-list"
        data-ng-repeat="contributor in contributors"
        data-ng-switch="contributor.type">
        %{-- Begin template for task transcription contribution --}%
        <li data-ng-switch-when="task" class="media">
            <div class="media-left">
                <a data-ng-href="{{userProfileUrl(contributor)}}">
                    <img data-ng-src="{{avatarUrl(contributor)}}" class="avatar img-circle">
                </a>
            </div>

            <div class="media-body">
                <span class="time" data-livestamp="{{contributor.timestamp}}"></span>
                <h4 class="media-heading"><a data-ng-href="{{userProfileUrl(contributor)}}">{{contributor.displayName}}</a></h4>

                <p>Transcribed <span>{{contributor.transcribedItems}}</span> items from the <a
                        data-ng-href="{{projectUrl(contributor)}}">{{contributor.projectName}}</a></p>

                <div class="transcribed-thumbs">
                    <img data-ng-repeat="thumb in contributor.transcribedThumbs" data-ng-src="{{thumb.thumbnailUrl}}">
                    <a data-ng-if="additionalTranscribedThumbs(contributor) > 0" data-ng-href="{{userProfileUrl(contributor)}}"><span>+{{additionalTranscribedThumbs(contributor)}}</span>More</a>
                </div>
                <a class="btn btn-link btn-xs join" role="button"
                   data-ng-href="{{projectUrl(contributor)}}">Join expedition »</a>
            </div>
        </li>
        %{-- Begin template for forum message contribution --}%
        <li data-ng-switch-when="forum" class="media">
            <div class="media-left">
                <a data-ng-href="{{userProfileUrl(contributor)}}">
                    <img data-ng-src="{{avatarUrl(contributor)}}" class="avatar img-circle">
                </a>
            </div>
            <div class="media-body">
                <span class="time" data-livestamp="{{contributor.timestamp}}"></span>
                <h4 class="media-heading"><a data-ng-href="{{userProfileUrl(contributor)}}">{{contributor.displayName}}</a></h4>
                <p>Has posted in the forum: <a data-ng-href="{{contributor.forumUrl}}">{{contributor.forumName}}</a></p>
                <div class="transcribed-thumbs">
                    <img data-ng-src="{{contributor.thumbnailUrl}}">
                </div>
                <a class="btn btn-link btn-xs join" data-ng-href="{{contributor.topicUrl}}" role="button">Join discussion »</a>
            </div>
        </li>
    </ul>
    <g:link controller="user" action="list">View all contributors »</g:link>
</section>
<r:script>
digivolStats({
statsUrl: "${createLink(controller: 'index', action: 'stats')}",
projectUrl: "${createLink(controller: 'project', action: 'index', id: -1)}",
userProfileUrl: "${createLink(controller: 'user', action: 'show', id: -1)}",
institutionId: ${institutionId ?: -1},
projectId: ${projectId ?: -1},
maxContributors: ${maxContributors ?: 5},
disableStats: ${disableStats ? 'true' : 'false' },
disableHonourBoard: ${disableHonourBoard ? 'true' : 'false' },
    });
</r:script>