%{-- include CSS and JS assets in calling page --}%
<g:set var="instName" value="${institutionName ?: institutionInstance?.name ?: message(code: 'default.application.name')}"/>
<g:set var="institutionId" value="${institutionInstance?.id}"/>


<section id="digivol-stats" ng-app="stats" ng-controller="StatsCtrl" class="ng-cloak">
    <g:if test="${!disableStats}">
%{--        <div class="card border-0 shadow-sm mb-3">--}%
%{--            <div class="card-header bg-black text-white d-flex justify-content-between align-items-center py-3 border-bottom border-secondary">--}%
%{--                <h5 class="card-title mb-0 text-uppercase fw-bold fs-6 tracking-wide">--}%
%{--                    ${instName} Stats--}%
%{--                </h5>--}%
%{--                <cl:ifSiteAdmin>--}%
%{--                    <g:link controller="user" action="adminList" class="text-white">--}%
%{--                        <i class="fa fa-users fa-sm" aria-hidden="true"></i>--}%
%{--                    </g:link>--}%
%{--                </cl:ifSiteAdmin>--}%
%{--            </div>--}%

%{--            <div class="card-body bg-black text-white py-3">--}%
%{--                <h3 class="h5 mb-2 fs-4">--}%
%{--                    <span data-ng-if="lbLoading"><cl:spinner/></span>--}%
%{--                    <span data-ng-if="!lbLoading">{{transcriberCount | number}}</span>--}%
%{--                    Volunteers--}%
%{--                </h3>--}%

%{--                <p class="mb-0">--}%
%{--                    <span data-ng-if="lbLoading"><cl:spinner/></span>--}%
%{--                    <span data-ng-if="!lbLoading">{{completedTasks | number}}</span>--}%
%{--                    tasks of--}%
%{--                    <span data-ng-if="lbLoading"><cl:spinner/></span>--}%
%{--                    <span data-ng-if="!lbLoading">{{totalTasks | number}}</span>--}%
%{--                    completed--}%
%{--                </p>--}%
%{--            </div>--}%
%{--        </div>--}%

        <div class="card bg-dark text-white border-0 rounded-4 shadow-lg p-3 mb-3" style="max-width: 420px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #121824 !important;">
            <div class="card-body p-2">
                <!-- Header -->
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div>
                        <h5 class="card-title mb-0 fw-bold fs-5">DigiVol Stats</h5>
                        <g:if test="${institutionInstance}">
                        <small class="text-white">${instName}</small>
                        </g:if>
                        <small class="text-secondary mt-1 d-block">Platform Impact Overview</small>
                    </div>
                    <i class="bi bi-three-dots-vertical text-secondary cursor-pointer"></i>
                </div>

                <hr class="border-secondary opacity-25 my-3">

                <!-- Hero Stat -->
                <div class="mb-4">
                    <div class="text-uppercase text-secondary fw-semibold fs-7 tracking-wider" style="font-size: 0.75rem; letter-spacing: 0.05em;">VOLUNTEERS</div>
                    <div class="display-6 fw-bold text-white mt-1">
                        <span data-ng-if="lbLoading"><cl:spinner/></span>
                        <span data-ng-if="!lbLoading">{{transcriberCount | number}}</span>
                    </div>
                </div>

                <!-- Secondary Stats Grid Row 1 -->
                <div class="row g-3 mb-3">
                    <div class="col-6">
                        <div class="text-uppercase text-secondary fw-semibold" style="font-size: 0.75rem; letter-spacing: 0.05em;">INSTITUTIONS</div>
                        <div class="fs-4 fw-semibold text-light">{{institutionCount | number}} <span class="text-uppercase text-secondary fs-7">/ {{projectCount | number}} projects</span></div>
                    </div>
                    <div class="col-6">
                        <div class="text-uppercase text-secondary fw-semibold" style="font-size: 0.75rem; letter-spacing: 0.05em;">TEMPLATES</div>
                        <div class="fs-4 fw-semibold text-light">{{templates | number}}</div>
                    </div>
                </div>

                <!-- Secondary Stats Grid Row 2 -->
                <div class="row g-3 mb-3">
                    <div class="col-6">
                        <div class="text-uppercase text-secondary fw-semibold" style="font-size: 0.75rem; letter-spacing: 0.05em;">TRANSCRIPTIONS</div>
                        <div class="fs-5 fw-semibold text-light">{{transcriptionCount | number}}</div>
                    </div>
                    <div class="col-6">
                        <div class="text-uppercase text-secondary fw-semibold" style="font-size: 0.75rem; letter-spacing: 0.05em;">SPECIES TRANSCRIBED</div>
                        <div class="fs-5 fw-semibold text-light">{{speciesTranscribed | number}}</div>
                    </div>
                </div>

                <hr class="border-secondary opacity-25 my-3">

                <!-- Progress Stat: Tasks Completed (95.1%) -->
                <div class="mb-3">
                    <div class="d-flex justify-content-between align-items-baseline mb-1">
                        <span class="text-uppercase text-secondary fw-semibold" style="font-size: 0.75rem; letter-spacing: 0.05em;">TASKS COMPLETED</span>
                        <span class="fs-7 text-light fw-medium">{{completedTasks | number}} <span class="text-secondary fs-7">/ {{totalTasks | number}}</span></span>
                    </div>
                    <div class="progress bg-secondary bg-opacity-25" style="height: 6px; border-radius: 3px;">
                        <div class="progress-bar bg-success" role="progressbar" style="width: {{percentageComplete}}%;" aria-valuenow="{{percentageComplete}}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>

                <!-- Progress Stat: Average Speed -->
                <div class="mb-1">
                    <div class="d-flex justify-content-between align-items-baseline mb-1">
                        <span class="text-uppercase text-secondary fw-semibold" style="font-size: 0.75rem; letter-spacing: 0.05em;">AVG TRANSCRIPTION TIME</span>
                        <span class="fs-7 text-light fw-medium">{{avgTranscriptionTimeString}} <span class="text-secondary fs-7">({{avgTranscriptionTime | number}}s)</span></span>
                    </div>
                    <div class="d-flex gap-1 mt-2">
                        <div ng-repeat="i in [1, 2, 3, 4, 5]"
                             class="flex-fill"
                             ng-class="i <= avgTimeAsPercentOfMax ? 'bg-info opacity-75' : 'bg-secondary opacity-25'"
                             style="height: 6px; border-radius: 2px;">
                        </div>
                    </div>
                </div>

            </div>
        </div>


    </g:if>
<g:if test="${!disableHonourBoard}">
    <div class="card border-0 shadow-sm mb-3">
        <!-- Card Header -->
        <div class="card-header bg-white d-flex justify-content-between align-items-center py-3 border-bottom">
            <h5 class="card-title mb-0 text-uppercase fw-bold text-secondary fs-6 tracking-wide">
                <g:message code="honour.board.label" />
            </h5>
            <g:link controller="leaderBoard" action="describeBadges" class="float-end"><i class="fa fa-trophy text-warning fs-5" aria-hidden="true"></i></g:link>
        </div>

        <!-- Leaderboard Categories -->
        <ul class="list-group list-group-flush">
            <!-- Day Tripper -->
            <li class="list-group-item py-3">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="fw-bold text-dark"><g:message code="daily.leader.label" default="Day Tripper"/></span>
                    <g:link controller="leaderBoard" action="topList" class="text-decoration-none small text-muted"
                            params="[category: 'daily', institutionId: institutionId]"><g:message code="leaderboard.viewTop20.label" default="View Top 20" />  &raquo;</g:link>
                </div>
                <div class="d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center">
                        <img id="day-tripper-image" data-ng-src="{{avatarUrl(daily)}}" alt="Day Tripper leader" class="rounded-circle me-3" width="40" height="40">
                        <span data-ng-if="lbLoading"><cl:spinner/></span>
                        <span data-ng-if="!lbLoading">
                            <a id="day-tripper-name" class="fw-semibold text-dark text-truncate" data-ng-href="{{userProfileUrl(daily)}}">{{daily.name}}</a>
                        </span>
                    </div>
                    <span id="day-tripper-amount" class="fw-bold text-dark">{{daily.score | number}}</span>
                </div>
            </li>

            <!-- Weekly Wonder -->
            <li class="list-group-item py-3">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="fw-bold text-dark"><g:message code="weekly.leader.label" default="Weekly Wonder"/></span>
                    <g:link controller="leaderBoard" action="topList" class="text-decoration-none small text-muted"
                            params="[category: 'weekly', institutionId: institutionId]"><g:message code="leaderboard.viewTop20.label" default="View Top 20" />  &raquo;</g:link>
                </div>
                <div class="d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center me-2">
                        <img id="weekly-wonder-image" data-ng-src="{{avatarUrl(weekly)}}" alt="Day Tripper leader" class="rounded-circle me-3" width="40" height="40">
                        <span data-ng-if="lbLoading"><cl:spinner/></span>
                        <span data-ng-if="!lbLoading">
                            <a id="weekly-wonder-name" class="fw-semibold text-dark text-truncate" data-ng-href="{{userProfileUrl(weekly)}}">{{weekly.name}}</a>
                        </span>
                    </div>
                    <span id="weekly-wonder-score" class="fw-bold text-dark">{{weekly.score | number}}</span>
                </div>
            </li>

            <!-- Monthly Maestro -->
            <li class="list-group-item py-3">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="fw-bold text-dark"><g:message code="monthly.leader.label" default="Monthly Maestro"/></span>
                    <g:link controller="leaderBoard" action="topList" class="text-decoration-none small text-muted"
                            params="[category: 'monthly', institutionId: institutionId]"><g:message code="leaderboard.viewTop20.label" default="View Top 20" />  &raquo;</g:link>
                </div>
                <div class="d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center me-2">
                        <img id="monthly-maestro-image" data-ng-src="{{avatarUrl(monthly)}}" alt="Monthly Maestro leader" class="rounded-circle me-3" width="40" height="40">
                        <span data-ng-if="lbLoading"><cl:spinner/></span>
                        <span data-ng-if="!lbLoading">
                            <a id="monthly-maestro-name" class="fw-semibold text-dark text-truncate" data-ng-href="{{userProfileUrl(monthly)}}">{{monthly.name}}</a>
                        </span>
                    </div>
                    <span id="monthly-maestro-score" class="fw-bold text-dark">{{monthly.score | number}}</span>
                </div>
            </li>

            <!-- DigiVol Legend -->
            <li class="list-group-item py-3">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="fw-bold text-dark">${instName} <g:message code="alltime.leader.label" default="All-time Leader"/></span>
                    <g:link controller="leaderBoard" action="topList" class="text-decoration-none small text-muted"
                            params="[category: 'alltime', institutionId: institutionId]"><g:message code="leaderboard.viewTop20.label" default="View Top 20" />  &raquo;</g:link>
                </div>
                <div class="d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center me-2">
                        <img id="alltime-leader-image" data-ng-src="{{avatarUrl(alltime)}}" alt="All-time Leader" class="rounded-circle me-3" width="40" height="40">
                        <span data-ng-if="lbLoading"><cl:spinner/></span>
                        <span data-ng-if="!lbLoading">
                            <a id="alltime-leader-name" class="fw-semibold text-dark text-truncate" data-ng-href="{{userProfileUrl(alltime)}}">{{alltime.name}}</a>
                        </span>
                    </div>
                    <span id="alltime-leader-score" class="fw-bold text-dark">{{alltime.score | number}}</span>
                </div>
            </li>
        </ul>
    </div>
</g:if>

<g:if test="${!disableContribution}">

    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3 border-bottom">
            <h5 class="card-title mb-0 text-uppercase fw-bold text-secondary fs-6 tracking-wide">
                <g:message code="latest.contributions.label" />
                <span data-ng-if="conLoading"> <cl:spinner/></span>
            </h5>
        </div>

        <div class="card-body p-0">
            <div class="list-group list-group-flush" data-ng-repeat="contributor in contributors"
                 data-ng-switch="contributor.type">

                %{-- Begin template for task transcription contribution --}%
                <!-- Contribution Item -->
                <div data-ng-switch-when="task" class="list-group-item p-3">
                    <div class="d-flex align-items-start">
                        <img data-ng-src="{{avatarUrl(contributor)}}" alt="{{contributor.displayName}}" class="rounded-circle me-3 flex-shrink-0" width="44" height="44">
                        <div class="w-100">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <h6 class="mb-0 fw-bold text-dark"><a data-ng-href="{{userProfileUrl(contributor)}}">{{contributor.displayName}}</a></h6>
                                <small class="text-muted" data-livestamp="{{contributor.timestamp}}"></small>
                            </div>
                            <p class="mb-2 text-secondary small">
                                <g:message code="transcribed.label" /> {{contributor.transcribedItems}} <g:message code="items.from.the" />
                                <a data-ng-href="{{projectUrl(contributor)}}" class="text-decoration-none fw-semibold">{{contributor.projectName}}</a>
                            </p>
                            <div data-ng-if="contributor.projectType !== 'audio'" class="mt-2">
                                <div class="d-flex align-items-center gap-3">
                                    <img data-ng-repeat="thumb in contributor.transcribedThumbs" data-ng-src="{{thumb.thumbnailUrl}}"
                                         alt="Expedition Thumbnail" class="rounded border" width="48" height="48" style="object-fit: cover;">
                                </div>
                                <a data-ng-href="{{userProfileUrl(contributor)}}" class="btn btn-sm btn-outline-primary px-3 mt-2">
                                    <g:message code="join.expedition.label" /> &raquo;
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Contribution Item 2 (Forum Post) -->
                <div data-ng-switch-when="forum" class="list-group-item p-3">
                    <div class="d-flex align-items-start">
                        <img data-ng-src="{{avatarUrl(contributor)}}" alt="{{contributor.displayName}}" class="rounded-circle me-3 flex-shrink-0" width="44" height="44">
                        <div class="w-100" style="min-width: 0;">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <h6 class="mb-0 fw-bold text-dark">{{contributor.displayName}}</h6>
                                <small class="text-muted" data-livestamp="{{contributor.timestamp}}"></small>
                            </div>
                            <p class="mb-2 text-secondary small">
                                Has posted in the forum topic:
                            </p>

                            <div style="min-width: 0;">
                                <a data-ng-href="{{contributor.topicUrl}}"
                                   class="text-decoration-none fw-semibold text-truncate d-block"
                                   style="min-width: 0;" target="_blank">
                                    {{contributor.topicTitle}}
                                </a>
                                <span class="badge badge--{{contributor.topicType.toLowerCase()}} mt-1 d-inline-block">
                                    {{contributor.topicType}}
                                </span>
                            </div>

                            <div class="mt-2">
                                <img data-ng-src="{{contributor.thumbnailUrl}}" class="rounded border" width="48" height="48" style="object-fit: cover;">
                                <div class="mt-2">
                                    <a data-ng-href="{{contributor.topicUrl}}" class="btn btn-sm btn-outline-primary px-3">
                                        <g:message code="join.discussion.label" /> &raquo;
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
            <div class="list-group list-group-flush" data-ng-if="contributors.length === 0">
                <div class="list-group-item p-3">
                    <p class="mb-0 text-secondary small">No contributors yet.
                        <a class="btn btn-sm btn-outline-primary"
                           href="${createLink(controller: 'forum', action: 'index', params: [projectId: projectId])}">\
                        <g:message code="start.discussion.label" />
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</g:if>

<g:if test="${disableContribution && !disableForumActivity}">

    <div class="card border-0 shadow-sm mt-3">
        <div class="card-header bg-white py-3 border-bottom">
            <h5 class="card-title mb-0 text-uppercase fw-bold text-secondary fs-6 tracking-wide">
                <g:message code="latest.forum.activity.label" />
                <span data-ng-if="conLoading"> <cl:spinner/></span>
            </h5>
        </div>

        <div class="card-body p-0">
            <div class="list-group list-group-flush" data-ng-repeat="contributor in contributors"
                 data-ng-switch="contributor.type">

                <!-- Contribution Item 2 (Forum Post) -->
                <div data-ng-switch-when="forum" class="list-group-item p-3">
                    <div class="d-flex align-items-start">
                        <img data-ng-src="{{avatarUrl(contributor)}}" alt="{{contributor.displayName}}" class="rounded-circle me-3 flex-shrink-0" width="44" height="44">
                        <div class="w-100" style="min-width: 0;">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <h6 class="mb-0 fw-bold text-dark">{{contributor.displayName}}</h6>
                                <small class="text-muted" data-livestamp="{{contributor.timestamp}}"></small>
                            </div>
                            <p class="mb-2 text-secondary small">
                                Has posted in the forum topic:
                            </p>

                            <div style="min-width: 0;">
                                <a data-ng-href="{{contributor.topicUrl}}"
                                   class="text-decoration-none fw-semibold text-truncate d-block"
                                   style="min-width: 0;" target="_blank">
                                    {{contributor.topicTitle}}
                                </a>
                                <span class="badge badge--{{contributor.topicType.toLowerCase()}} mt-1 d-inline-block">
                                    {{contributor.topicType}}
                                </span>
                            </div>

                            <div class="mt-2">
                                <img data-ng-src="{{contributor.thumbnailUrl}}" class="rounded border" width="48" height="48" style="object-fit: cover;">
                                <div class="mt-2">
                                    <a data-ng-href="{{contributor.topicUrl}}" class="btn btn-sm btn-outline-primary px-3">
                                        <g:message code="join.discussion.label" /> &raquo;
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="list-group list-group-flush" data-ng-if="contributors.length === 0">
                <div class="list-group-item p-3">
                    <p class="mb-0 text-secondary small">No contributors yet.
                        <a class="btn btn-sm btn-outline-primary"
                           href="${createLink(controller: 'forum', action: 'index', params: [projectId: projectId])}">
                            <g:message code="start.discussion.label" />
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </div>

</g:if>

</section>

<asset:javascript src="digivol-stats.js" asset-defer=""/>
<asset:script type="text/javascript">
digivolStats({
    statsUrl: bvp.getNewLink("${createLink(controller: 'index', action: 'stats')}", ['q', 'tag', 'tags'], '', ''),
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