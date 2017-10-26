<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <g:if test="${project}">
        <title><cl:pageTitle title="${message(code: 'user.notebook.titleProject', args: [userInstance?.displayName, project?.i18nName ?: message(code: 'user.show.unknown_project')])}"/></title>
    </g:if>
    <g:else>
        <title><cl:pageTitle title="${message(code: 'user.notebook.title', args: [userInstance?.displayName])}"/></title>
    </g:else>
    <cl:googleChartsScript />
    <cl:googleMapsScript callback="onGmapsReady"/>
</head>

<body data-ng-app="notebook">
<cl:headerContent hideTitle="true"
        title="${cl.displayNameForUserId(id: userInstance.userId)} ${userInstance.userId == currentUser ? message(code: 'user.show.thats_you') : ''}"
        crumbLabel="${cl.displayNameForUserId(id: userInstance.userId)}" selectedNavItem="userDashboard">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'user', action: 'list'), label: message(code: 'user.show.volunteers')]
        ]
    %>
    <div class="container">
        <div class="row">

            <div class="col-sm-2">
                <div class="avatar-holder">
                    <g:if test="${userInstance.userId == currentUser}">
                        <a href="//en.gravatar.com/" class="external" target="_blank" id="gravatarLink" title="${message(code: 'user.show.to_customize_your_avatar')}">
                            <img src="//www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=150" alt="" class="center-block img-circle img-responsive">
                        </a>
                    </g:if>
                    <g:else>
                        <img src="//www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=150" alt="" class="center-block img-circle img-responsive">
                    </g:else>
                </div>
            </div>
            <div class="col-sm-6">
                <span class="pre-header"><g:message code="user.show.volunteer_profile"/></span>
                <h1>${cl.displayNameForUserId(id: userInstance.userId)} ${userInstance.userId == currentUser ? message(code: 'user.show.thats_you') : ''}</h1>
                <g:if test="${project}"><h2>${project?.i18nName}</h2></g:if>
                <div class="row">
                    <div class="col-xs-4">
                        <h2><strong>${score}</strong></h2>
                        <p><g:message code="user.show.total_contribution"/></p>
                    </div><!--/col-->
                    <div class="col-xs-4">
                        <h2><strong>${totalTranscribedTasks}</strong></h2>
                        <p><g:message code="user.show.transcribed"/></p>
                    </div><!--/col-->
                    <div class="col-xs-4">
                    <g:if test="${userInstance.validatedCount > 0}">
                        <h2><strong>${userInstance.validatedCount}</strong></h2>
                        <p><g:message code="user.show.validated"/></p>
                    </g:if>
                    </div><!--/col-->
                </div>

                <div class="achievements">
                    <div class="row">
                        <div class="col-sm-8">
                            <span class="pre-header"><g:message code="user.show.achievements"/></span>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-12 badges">
                            <g:each in="${achievements}" var="ach" status="i">
                                <img src='<cl:achievementBadgeUrl achievement="${ach.achievement}"/>'
                                     width="50px" alt="${ach.achievement.name}"
                                     title="${ach.achievement.description}"/>
                            </g:each>
                        </div>
                    </div>
                </div>


            </div>

            <div class="col-sm-4">
                <div class="contribution-chart">
                    <h2><g:message code="user.show.contributions_to_research"/></h2>
                    <ul>
                        <g:if test="${totalSpeciesCount > 0}">
                            <li>
                                <span><g:message code="user.notebookMain.you_have_added_species" args="${[totalSpeciesCount]}"/></span>

                                <div id="piechart"></div>
                                <gvisualization:pieCoreChart
                                        name="totalSpecies"
                                        dynamicLoading="${true}"
                                        elementId="piechart"
                                        title=""
                                        columns="${[['string', 'Scientific Name'], ['number', 'Transcriptions']]}"
                                        data="${speciesList}"
                                        is3D="${true}"
                                        pieSliceText="label" chartArea="${[width: '100%', height: '100%']}"
                                        pieSliceTextStyle="${[fontSize: '12']}"
                                        backgroundColor="${[fill: 'transparent']}"/>
                            </li>
                        </g:if>
                        <g:if test="${fieldObservationCount > 0}">
                            <li>
                                <span><g:message code="user.notebookMain.you_have_contributed" args="${[fieldObservationCount]}"/></span>
                            </li>
                        </g:if>
                        <g:if test="${expeditionCount > 0}">
                            <li>
                                <span><g:message code="user.notebookMain.you_have_participated_expeditions" args="${[expeditionCount]}"/></span>
                            </li>
                        </g:if>
                        <g:if test="${userPercent != '0.00'}">
                            <li>
                                <span><g:message code="user.notebookMain.you_have_transcribed" args="${[userPercent]}"/></span>
                            </li>
                        </g:if>
                    </ul>
                </div>
                <div class="row">
                    <div class="col-sm-12">
                        <p>
                            <i><g:message code="user.show.first_contributed_in" args="${[formatDate(date: userInstance?.created, format: "MMM yyyy")]}"/></i>
                        </p>
                    </div>
                    <a id="profileTabs"></a>
                </div>
            </div>

        </div>

    </div>

</cl:headerContent>

<section id="user-progress" class="in-body" ng-controller="notebookTabsController as nbtCtrl" ng-cloak>
    <uib-tabset active="nbtCtrl.selectedTab" template-url="notebookTabSet.html">
        %{--<uib-tab ng-if="nbtCtrl.isCurrentUser" index="0" select="nbtCtrl.selectTab(0)">--}%
            %{--<uib-tab-heading>--}%
                %{--<g:message code="notebook.tabs.notifications.heading" /> <i ng-show="unreadCount > 0" class="fa fa-bell text-danger"></i>--}%
            %{--</uib-tab-heading>--}%
            %{--<task-list selected-tab="nbtCtrl.selectedTab" tab-index="0" max="nbtCtrl.tabs[0].max" offset="nbtCtrl.tabs[0].offset" sort="nbtCtrl.tabs[0].sort" order="nbtCtrl.tabs[0].order" query="nbtCtrl.tabs[0].query"></task-list>--}%
        %{--</uib-tab>--}%
        <uib-tab heading="${message(code:"notebook.tabs.transcribed.heading")}" index="1" select="nbtCtrl.selectTab(1)">
            <task-list selected-tab="nbtCtrl.selectedTab" tab-index="1" max="nbtCtrl.tabs[1].max" offset="nbtCtrl.tabs[1].offset" sort="nbtCtrl.tabs[1].sort" order="nbtCtrl.tabs[1].order" query="nbtCtrl.tabs[1].query"></task-list>
        </uib-tab>
        <uib-tab heading="${message(code:"notebook.tabs.saved.heading")}" index="2" select="nbtCtrl.selectTab(2)">
            <task-list selected-tab="nbtCtrl.selectedTab" tab-index="2" max="nbtCtrl.tabs[2].max" offset="nbtCtrl.tabs[2].offset" sort="nbtCtrl.tabs[2].sort" order="nbtCtrl.tabs[2].order" query="nbtCtrl.tabs[2].query"></task-list>
        </uib-tab>
        <uib-tab ng-if="nbtCtrl.isValidator" heading="${message(code:"notebook.tabs.validated.heading")}" index="3" select="nbtCtrl.selectTab(3)">
            <task-list selected-tab="nbtCtrl.selectedTab" tab-index="3" max="nbtCtrl.tabs[3].max" offset="nbtCtrl.tabs[3].offset" sort="nbtCtrl.tabs[3].sort" order="nbtCtrl.tabs[3].order" query="nbtCtrl.tabs[3].query"></task-list>
        </uib-tab>
        <uib-tab heading="${message(code:"notebook.tabs.forum.heading")}" index="4" select="nbtCtrl.selectTab(4)">
            <forum-posts selected-tab="nbtCtrl.selectedTab" tab-index="4"max="nbtCtrl.tabs[4].max" offset="nbtCtrl.tabs[4].offset" sort="nbtCtrl.tabs[4].sort" order="nbtCtrl.tabs[4].order"></forum-posts>
        </uib-tab>
        <uib-tab ng-if="nbtCtrl.isAdmin" heading="${message(code:"notebook.tabs.user.heading")}" index="5">
            <div class="tab-pane-header">
                <div class="row">
                    <div class="col-md-12">
                        <div class="alert alert-info" style="margin-bottom: 0px">
                            <%-- TODO Pull this from user details service --%>
                            &nbsp;<g:message code="user.email.label" />:&nbsp;<a href="mailto:${userInstance.email}">${userInstance.email}</a>
                        </div>
                        <br/>
                        <g:link class="btn btn-success" controller="user" action="editRoles"
                                id="${userInstance.id}"><g:message code="user.roles.manage.label" /></g:link>
                        <g:link class="btn btn-success" controller="user" action="edit"
                                id="${userInstance.id}"><g:message code="user.details.edit.label" /></g:link>
                    </div>
                </div>
            </div>
        </uib-tab>
    </uib-tabset>

</section>

<section id="record-locations">
    <div class="container">
        <div class="row">
            <div class="col-sm-4">
                <div class="map-header">
                    <h2 class="heading"><g:message code="user.show.record_locations"/></h2>
                    <p>${cl.displayNameForUserId(id: userInstance.userId)} ${userInstance.userId == currentUser ? message(code: 'user.show.you_have_transcribed_records') : message(code: 'user.show.user_has_transcribed_records')}</p>
                </div>
            </div>
        </div>
    </div>

    <div id="map"
         markers-url="${createLink(controller: "user", action: 'ajaxGetPoints', id: userInstance.id)}"
         infowindow-url="${createLink(controller: 'task', action: 'details')}">
    </div>
</section>

<g:render template="/common/angularBootstrapTabSet" />

<script id="taskList.html" type="text/ng-template">
<a id="tasklist-top-{{ $ctrl.tabIndex }}"></a>
<div class="tab-pane-header" ng-show="$ctrl.firstLoad" >
    <div class="row">
        <div class="col-sm-8 search-results-count">
            <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> <g:message code="loading.label" /></strong></p>
        </div>
    </div>
</div>
<div class="ng-cloak" ng-show="!$ctrl.firstLoad" ng-class="{ 'tab-content-loading': $ctrl.cancelPromise }">
<div class="tab-pane-header">
    <div class="row">
        <div class="col-sm-8 search-results-count">
            <p>
                <span ng-show="$ctrl.tabIndex > 0"><strong>{{$ctrl.data.totalMatchingTasks }} <g:message code="notebook.taskList.heading" /></strong> <span ng-show="$ctrl.project"><g:message code="notebook.tasklist.heading.projectSuffix" /></span></span>
                <span ng-show="$ctrl.tabIndex == 0 && $ctrl.data.recentValidatedCount > 0"><strong><g:message code="notebook.taskList.reviewedHeading" /></strong> <g:message code="notebook.taskList.reviewHeading.suffix" /></span>
                <span ng-show="$ctrl.tabIndex == 0 && $ctrl.data.recentValidatedCount == 0"><strong><g:message code="notebook.taskList.emptyReviewedHeading" /></strong></span>
                <span ng-show="$ctrl.cancelPromise"><i class="fa fa-cog fa-spin fa-2x"></i></span>
            </p>
        </div>
        <div class="col-sm-4 text-right">
            <div class="custom-search-input body">
                <div class="input-group">
                    <input type="text" id="searchbox" ng-model="$ctrl.query" name="searchbox" class="form-control input-lg" placeholder="${message(code:"default.search.label")}" />
                    <span class="input-group-btn">
                        <button class="btn btn-info btn-lg" type="button" ng-click="$ctrl.load()">
                            <i class="glyphicon glyphicon-search"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="pull-right search-help">
                <button class="btn btn-info pull-right"
                        uib-tooltip="${message(code:"notebook.taskList.searchHelp").replaceAll("\"","\\\"")}"><span
                        class="help-container"><i class="fa fa-question"></i></span>
                </button>
            </div>
        </div>
    </div>
</div>
<div class="table-responsive">
    <table class="table table-striped table-hover">
        <thead>
            <tr class="sorting-header">

                <th ng-if="$ctrl.tabIndex == 0"></th>

                <th class="sortable" ng-class="$ctrl.sortedClasses('id')">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'id', sorting: true})" class="btn"><g:message code="task.id.label" /></a>
                </th>

                <th class="sortable" ng-class="$ctrl.sortedClasses('externalIdentifier')">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'externalIdentifier', sorting: true})" class="btn"><g:message code="task.externalIdentifier.label" /></a>
                </th>

                <th class="sortable" ng-class="$ctrl.sortedClasses('catalogNumber')">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'catalogNumber', sorting: true})" class="btn"><g:message code="task.catalogNumber.label" /></a>
                </th>

                <th class="sortable" ng-class="$ctrl.sortedClasses('projectName')">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'projectName', sorting: true})" class="btn"><g:message code="project.name.label" /></a>
                </th>

                <th class="sortable" ng-class="$ctrl.sortedClasses('dateTranscribed')">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'dateTranscribed', sorting: true})" class="btn"><g:message code="task.dateFullyTranscribed.label" /></a>
                </th>

                <th class="sortable" ng-class="$ctrl.sortedClasses('dateValidated')">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'dateValidated', sorting: true})" class="btn"><g:message code="task.dateFullyValidated.label" /></a>
                </th>

                <th class="sortable" ng-class="$ctrl.sortedClasses('validator')"
                    ng-show="$ctrl.selectedTab == 0">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'validator', sorting: true})" class="btn"><g:message code="task.validator.label" /></a>
                </th>

                <th class="sortable" ng-class="$ctrl.sortedClasses('status')">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'status', sorting: true})" class="btn"><g:message code="task.isValid.label" /></a>
                </th>

                <th style="text-align: center; vertical-align: middle;"><g:message code="notebook.tasklist.tableAction.label" /></th>

            </tr>
        </thead>
        <tbody>
            <tr ng-repeat="taskInstance in $ctrl.data.viewList track by taskInstance.id">

                <td ng-if="$ctrl.tabIndex == 0">
                    <span ng-show="taskInstance.unread" class="glyphicon glyphicon-envelope" style="color:#000192"></span>
                    <span ng-hide="taskInstance.unread" class="glyphicon glyphicon-ok"></span>
                </td>

                <td>
                    <a ng-href="${createLink(controller: 'task', action: 'show')}/{{ taskInstance.id }}" class="listLink">{{ taskInstance.id }}</a>
                </td>
                <td>
                    <a ng-if="taskInstance.isValidator" ng-href="${createLink(controller: 'task', action: 'showDetails')}/{{ taskInstance.id }}" title="${g.message(code: 'task.details.button.label')}"><i class="glyphicon glyphicon-list-alt"></i></a>
                    {{taskInstance.externalIdentifier}}
                </td>

                <td>{{taskInstance.catalogNumber}}</td>

                <td>
                    <a ng-href="${createLink(controller: 'project', action: 'index')}/{{ taskInstance.projectId }}" class="listLink">{{ taskInstance.projectName }}</a>
                </td>

                <td>
                    {{ taskInstance.dateTranscribed | date : 'medium' }}
                </td>

                <td>
                    {{ taskInstance.dateValidated | date : 'medium' }}
                </td>

                <td style="text-align: center;" ng-show="$ctrl.tabIndex == 0">
                    {{ taskInstance.fullyValidatedBy }}
                </td>


                <td style="text-align: center;">
                    {{ taskInstance.status }}
                </td>

                <td style="text-align: center; width: 120px;">
                    <span ng-show="$ctrl.tabIndex > 0"> <!-- notebook.tasklist.tableAction.label -->
                        <a ng-show="taskInstance.fullyTranscribedBy" class="btn btn-default btn-xs"
                           ng-href="${createLink(controller: 'task', action:'show')}/{{taskInstance.id}}">
                            <g:message code="action.view.label" />
                        </a>
                        <a ng-show="taskInstance.fullyTranscribedBy && taskInstance.isValidator" class="btn btn-default btn-xs"
                           ng-href="${createLink(controller: 'validate', action:'task')}/{{taskInstance.id}}">
                            <span ng-show="taskInstance.status == 'Validated'"><g:message code="action.review.label" /></span>
                            <span ng-hide="taskInstance.status == 'Validated'"><g:message code="action.validate.label" /></span>
                        </a>
                        <a ng-hide="taskInstance.fullyTranscribedBy" class="btn btn-default btn-small"
                           ng-href="${createLink(controller:'transcribe', action:'task')}/{{taskInstance.id}}">
                            <g:message code="action.transcribe.label" />
                        </a>
                    </span>
                    <span ng-hide="$ctrl.tabIndex > 0">
                        <button class="btn btn-default btn-xs btnViewNotificationTask"
                                ng-click="$ctrl.viewNotifications(taskInstance)"
                                data-taskId="{{taskInstance.id}}" data-externalIdentifier="{{taskInstance.externalIdentifier}}">
                            <g:message code="action.view.label" />
                        </button>
                    </span>
                </td>

            </tr>
        </tbody>
    </table>
</div>
<div class="pagination">
    <uib-pagination total-items="$ctrl.data.totalMatchingTasks" items-per-page="$ctrl.max" max-size="$ctrl.maxSize" boundary-link-numbers="true"
                    ng-model="$ctrl.page" ng-change="$ctrl.pageChanged()"
                    previous-text="&laquo;" next-text="&raquo;"></uib-pagination>
</div>
</div>
</script>

<script id="forumPosts.html" type="text/ng-template">
    <a id="forumlist-top"></a>
    <div>
        <div ng-show="$ctrl.cancelPromise != null">
            <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> <g:message code="loading.label" /></strong></p>
        </div>
        <table ng-show="$ctrl.data.messages" class="forum-table table table-striped table-condensed table-bordered" style="width:100%">
            <tbody>
                <tr ng-repeat-start="mt in $ctrl.data.messages track by mt.topic.id" style="background-color: #f0f0e8; color: black; height: 15px;">
                    <th colspan="2">
                        <h4 style="padding-bottom: 10px">
                            <g:message code="forumTopic.label" />: <a ng-href="${createLink(controller: 'forum', action: 'viewForumTopic')}/{{ mt.topic.id }}">{{ mt.topic.title }} </a>
                            <span ng-show="mt.topicProject"><g:message code="project.label" />: <a ng-href="${createLink(controller: 'project', action: 'index')}/{{ mt.topicProject.id }}">{{ mt.topicProject.id }}</a></span>
                            <span ng-show="mt.topicTask"><g:message code="task.label" />: <a ng-href="${createLink(controller: 'project', action: 'show')}/{{ mt.topicTask.id }}">{{ mt.topicTask.externalIdentifier }}</a></span>
                        </h4>
                    </th>
                </tr>
                <tr ng-repeat="m in mt.messages track by m.message.id" ng-class="{ 'author-is-moderator-row': m.isUserForumModerator }" ng-repeat-end>
                    <td class="forumNameColumn">
                        <a ng-hide="$ctrl.hideUsername" ng-href="${link(controller: 'user', action: 'show')}/{{ m.message.user.id}}">{{ m.userProps.displayName }}</a>
                        <br />
                        <span class="forumMessageDate">{{ m.message.date | date : 'medium' }}</span>
                        <br ng-show="m.isUserForumModerator" />
                        <span ng-show="m.isUserForumModerator" class="moderator-label"><g:message code="moderator.label" /></span>
                    </td>
                    <td style="vertical-align: middle" marked="m.message.text"></td>
                </tr>
            </tbody>
        </table>
        <div class="pagination">
            <uib-pagination total-items="$ctrl.data.totalCount" items-per-page="$ctrl.max" max-size="$ctrl.maxSize" boundary-link-numbers="true"
                            ng-model="$ctrl.page" ng-change="$ctrl.pageChanged()"
                            previous-text="&laquo;" next-text="&raquo;"></uib-pagination>
        </div>
    </div>
</script>

<script id="viewNotifications.html" type="text/ng-template">
<div class="modal-header">
    <button type="button" class="close" aria-label="Close" ng-click="$ctrl.close()"><span aria-hidden="true">&times;</span></button>
    <h3 class="modal-title">Changes for {{ $ctrl.taskInstance.externalIdentifier }}</h3>
</div>
<div ng-show="$ctrl.loading" class="modal-body">
    <p>
        <g:message code="loading.label" /> <i class="fa fa-2x fa-cog fa-spin"></i>
    </p>
</div>
<div ng-show="$ctrl.error" class="modal-body">
    <p>
        <g:message code="error.generic.label" /> <i class="fa fa-2x fa-frown-o"></i>
    </p>
</div>
<div ng-hide="$ctrl.loading || $ctrl.error" class="modal-body">
    <div class="row" >
        <div class="col-sm-12">
            <p><i><g:message code="task.validatedBy.label" args="${[$ctrl?.validatorDisplayName]}" /></i> </p>
        </div>
    </div>

    <div class="row" ng-show="$ctrl.validatorNotes">
        <div class="col-sm-3">
            <strong><g:message code="field.validatorNotes.label" /></strong>
        </div>
        <div class="col-sm-9" marked="$ctrl.validatorNotes">
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-striped table-hover">
            <thead>
            <tr>
                <td style="color:#307991"><g:message code="modal.notifications.changed" /></td>
                <td style="color:#307991"><g:message code="modal.notifications.previous" /></td>
                <td style="color:#307991"><g:message code="modal.notifications.changes" /></td>
            </tr>
            </thead>
            <tbody ng-repeat="(recordIdx, recordValues) in $ctrl.recordValues">
                <tr ng-repeat="recordValue in recordValues">
                    <td>
                        {{ recordValue.label }}
                    </td>
                    <td marked="recordValue.oldValue"></td>
                    <td marked="recordValue.newValue"></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>
<div class="modal-footer">
    <button class="btn btn-primary" type="button" ng-click="$ctrl.close()">OK</button>
</div>
</script>
<asset:javascript src="digivol-notebook" asset-defer=""/>
<asset:script type="text/javascript">
    var json = <cl:json value="${[
        selectedTab: selectedTab,
        defaultLatitude: grailsApplication.config.location.default.latitude,
        defaultLongitude: grailsApplication.config.location.default.longitude,
        userInstance: userInstance,
        project: project,
        isValidator: isValidator,
        isAdmin: isAdmin,
        isCurrentUser: userInstance?.userId == currentUser,
        max: params.max,
        offset: params.offset,
        sort: params.sort,
        order: params.order,
        query: params.q,
        taskListUrl: createLink(controller: 'user', action: 'taskListFragment', id: userInstance.id),
        forumPostsUrl: createLink(controller: 'forum', action: 'userComments', id: userInstance.id),
        changedFieldsUrl: createLink(controller: 'task', action: 'showChangedFields'),
        auditViewUrl: createLink(controller: 'task', action: 'viewTask')
]}" />
    digivolNotebooksTabs(json);
</asset:script>

</body>
</html>
