%{-- include CSS and JS assets in calling page --}%
<g:set var="instName" value="${institutionName ?: institutionInstance?.name ?: message(code: 'default.application.name')}"/>
<g:set var="institutionId" value="${institutionInstance?.id}"/>


<section id="digivol-stats" ng-app="stats" ng-controller="StatsCtrl" class="ng-cloak">
<g:if test="${!disableStats}">
    <div class="panel panel-default volunteer-stats">
        <!-- Default panel contents -->
        <h2 class="heading">${instName} Stats
            <cl:ifSiteAdmin><g:link controller="user" action="adminList" class="pull-right"><i class="fa fa-users fa-sm"></i></g:link></cl:ifSiteAdmin>
        </h2>

        <h3>
            <span data-ng-if="lbLoading"><cl:spinner/></span>
            <span data-ng-if="!lbLoading">{{transcriberCount | number}}</span>
            Volunteers
        </h3>

        <p>
            <span data-ng-if="lbLoading"><cl:spinner/></span>
            <span data-ng-if="!lbLoading">{{completedTasks | number}}</span>
            tasks of
            <span data-ng-if="lbLoading"><cl:spinner/></span>
            <span data-ng-if="!lbLoading">{{totalTasks | number}}</span>
            completed
        </p>

    </div><!-- Volunteer Stats Ends Here -->
</g:if>
<g:if test="${!disableHonourBoard}">
    <div class="panel panel-default leaderboard">
        <!-- Default panel contents -->
        <h2 class="heading"><g:message code="honour.board.label" /> <g:link controller="leaderBoard" action="describeBadges" class="pull-right"><i class="fa fa-trophy fa-sm"></i></g:link></h2>
        <!-- Table -->
        <table class="table">
            <thead>
            <tr>
                <th colspan="2"><g:message code="daily.leader.label" /></th>
                <th class="view-more"><g:link controller="leaderBoard" action="topList"
                                              params="[category: 'daily', institutionId: institutionId]"><g:message code="leaderboard.viewTop20.label" /></g:link></th>
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
                    <span data-ng-if="lbLoading"><cl:spinner/></span>
                    <span data-ng-if="!lbLoading">
                    <a id="day-tripper-name" data-ng-href="{{userProfileUrl(daily)}}">{{daily.name}}</a>
                    </span>
                </th>
                <td id="day-tripper-amount" class="transcribed-amount">{{daily.score | number}}</td>
            </tr>
            </tbody>
            <thead>
            <tr>
                <th colspan="2"><g:message code="weekly.leader.label" /></th>
                <th class="view-more"><g:link controller="leaderBoard" action="topList"
                                              params="[category: 'weekly', institutionId: institutionId]"><g:message code="leaderboard.viewTop20.label" /></g:link></th>
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
                    <span data-ng-if="lbLoading"><cl:spinner/></span>
                    <span data-ng-if="!lbLoading">
                    <a id="weekly-wonder-name" data-ng-href="{{userProfileUrl(weekly)}}">{{weekly.name}}</a>
                    </span>
                </th>
                <td id="weekly-wonder-amount" class="transcribed-amount">{{weekly.score | number}}</td>
            </tr>
            </tbody>
            <thead>
            <tr>
                <th colspan="2"><g:message code="monthly.leader.label" /></th>
                <th class="view-more"><g:link controller="leaderBoard" action="topList"
                                              params="[category: 'monthly', institutionId: institutionId]"><g:message code="leaderboard.viewTop20.label" /></g:link></th>
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
                    <span data-ng-if="lbLoading"><cl:spinner/></span>
                    <span data-ng-if="!lbLoading">
                    <a id="monthly-maestro-name"
                       data-ng-href="{{userProfileUrl(monthly)}}">{{monthly.name}}</a>
                    </span>
                </th>
                <td id="monthly-maestro-amount" class="transcribed-amount">{{monthly.score | number}}</td>
            </tr>
            </tbody>
            <thead>
            <tr>
                <th colspan="2">${instName} <g:message code="alltime.leader.label" /></th>
                <th class="view-more"><g:link controller="leaderBoard" action="topList"
                                              params="[category: 'alltime', institutionId: institutionId]"><g:message code="leaderboard.viewTop20.label" /></g:link></th>
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
                    <span data-ng-if="lbLoading"><cl:spinner/></span>
                    <span data-ng-if="!lbLoading">
                    <a id="digivol-legend-name"
                       data-ng-href="{{userProfileUrl(alltime)}}">{{alltime.name}}</a>
                    </span>
                </th>
                <td id="digivol-legend-amount" class="transcribed-amount">{{alltime.score | number}}</td>
            </tr>
            </tbody>
        </table>
    </div><!-- Honour Board Ends Here -->
</g:if>

<g:if test="${!disableContribution}">
    <h2 class="heading">
        <g:message code="latest.contributions.label" /><span data-ng-if="conLoading"> <cl:spinner/></span>
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

                <p><g:message code="transcribed.label" /> <span>{{contributor.transcribedItems}}</span> <g:message code="items.from.the" /> <a
                        data-ng-href="{{projectUrl(contributor)}}">{{contributor.projectName}}</a></p>

                <div data-ng-if="contributor.projectType !== 'audio'" class="transcribed-thumbs">
                    <img data-ng-repeat="thumb in contributor.transcribedThumbs" data-ng-src="{{thumb.thumbnailUrl}}">
                    <a data-ng-if="additionalTranscribedThumbs(contributor) > 0" data-ng-href="{{userProfileUrl(contributor)}}"><span>+{{additionalTranscribedThumbs(contributor)}}</span>More</a>
                </div>
                <a class="btn btn-link btn-xs join" role="button"
                   data-ng-href="{{projectUrl(contributor)}}"><g:message code="join.expedition.label" /> »</a>
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
                <a class="btn btn-link btn-xs join" data-ng-href="{{contributor.topicUrl}}" role="button"><g:message code="join.discussion.label" /> »</a>
            </div>
        </li>
    </ul>
</g:if>

<g:if test="${disableContribution && !disableForumActivity}">
    <h2 class="heading">
        <g:message code="latest.forum.activity.label" /><span data-ng-if="conLoading"> <cl:spinner/></span>
    </h2>
    <ul class="media-list"
        data-ng-repeat="contributor in contributors"
        data-ng-switch="contributor.type">
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
                <a class="btn btn-link btn-xs join" data-ng-href="{{contributor.topicUrl}}" role="button"><g:message code="join.discussion.label" /> »</a>
            </div>
        </li>

    </ul>
    <ul class="media-list"
        data-ng-if="contributors.length === 0">
        <li>
            <div class="media-body">
                <p>No topics yet. <a href="${createLink(controller: 'forum', action: 'index', params: [projectId: projectId])}"><g:message code="start.discussion.label" /></a></p>
            </div>
        </li>
    </ul>
</g:if>

</section>

<asset:javascript src="digivol-stats.js" asset-defer=""/>
<asset:script type="text/javascript">
digivolStats({
    statsUrl: "${createLink(controller: 'index', action: 'stats')}",
    contributorsUrl: "${createLink(controller: 'index', action: 'contributors')}",
    forumActivityUrl: "${createLink(controller: 'index', action: 'forumActivity')}",
    projectUrl: "${createLink(controller: 'project', action: 'index', id: -1)}",
    userProfileUrl: "${createLink(controller: 'user', action: 'show', id: -1)}",
    taskSummaryUrl: "${createLink(controller: 'task', action: 'summary', id: -1)}",
    institutionId: ${institutionId ?: -1},
    projectId: ${projectId ?: -1},
    projectType: "${projectType ?: ''}",
    tags: <cl:json value="${tagName}" />,
    maxContributors: ${maxContributors ?: 5},
    maxPosts: ${maxPosts ?: 5},
    disableStats: ${disableStats ? 'true' : 'false' },
    disableHonourBoard: ${disableHonourBoard ? 'true' : 'false' },
    disableContribution: ${disableContribution ? 'true' : 'false' },
    disableForumActivity: ${disableForumActivity ? 'true' : 'false' }
});
</asset:script>