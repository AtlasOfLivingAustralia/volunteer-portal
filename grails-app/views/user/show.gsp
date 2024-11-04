<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <g:if test="${project}">
        <title><cl:pageTitle title="${message(code: 'user.notebook.titleProject', args: [userInstance?.displayName, project?.name ?: 'Unknown project'])}"/></title>
    </g:if>
    <g:else>
        <title><cl:pageTitle title="${message(code: 'user.notebook.title', args: [userInstance?.displayName])}"/></title>
    </g:else>
    <cl:googleChartsScript />
    <cl:googleMapsScript callback="onGmapsReady"/>
</head>

<body data-ng-app="notebook">
<cl:headerContent hideTitle="true"
        title="${cl.displayNameForUserId(id: userInstance.userId)}${userInstance.userId == currentUser ? " (that's you!)" : ''}"
        crumbLabel="${cl.displayNameForUserId(id: userInstance.userId)}" selectedNavItem="userDashboard">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'user', action: 'list'), label: 'Volunteers']
        ]
    %>
    <div class="container">
        <div class="row">

            <div class="col-sm-2">
                <div class="avatar-holder">
                    <g:if test="${userInstance.userId == currentUser}">
                        <a href="//en.gravatar.com/" class="external" target="_blank" id="gravatarLink" title="To customise your avatar, register your email address at gravatar.com...">
                            <img src="//www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=150" alt="" class="center-block img-circle img-responsive">
                        </a>
                    </g:if>
                    <g:else>
                        <img src="//www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=150" alt="" class="center-block img-circle img-responsive">
                    </g:else>
                </div>
            </div>
            <div class="col-sm-6">
                <span class="pre-header">Volunteer Profile</span>
                <h1>${cl.displayNameForUserId(id: userInstance.userId)}${userInstance.userId == currentUser ? " (that's you!)" : ''}</h1>
                <g:if test="${project}"><h2>${project.name}</h2></g:if>
                <div class="row">
                    <div class="col-xs-4">
                        <h2><strong>${score}</strong></h2>
                        <p>Total Contribution</p>
                    </div><!--/col-->
                    <div class="col-xs-4">
                        <h2><strong>${totalTranscribedTasks}</strong></h2>
                        <p>Transcribed</p>
                    </div><!--/col-->
                    <div class="col-xs-4">
                    <g:if test="${userInstance.validatedCount > 0}">
                        <h2><strong>${userInstance.validatedCount}</strong></h2>
                        <p>Validated</p>
                    </g:if>
                    </div><!--/col-->
                </div>

                <div class="achievements">
                    <div class="row">
                        <div class="col-sm-8">
                            <span class="pre-header">Achievements</span>
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
                    <h2>Contribution to Research</h2>
                    <g:set var="selectedPronoun" value="${userInstance.userId == currentUser ? 'You have' : userInstance.firstName + ' has'}" />
                    <ul>
                        <g:if test="${totalSpeciesCount > 0}">
                            <li>
                                <span>${selectedPronoun} added ${totalSpeciesCount} species to the ALA:</span>

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
                                <span>${selectedPronoun} contributed to ${fieldObservationCount} new field observations.</span>
                            </li>
                        </g:if>
                        <g:if test="${expeditionCount > 0}">
                            <li>
                                <span>${selectedPronoun} participated in ${expeditionCount} expeditions.</span>
                            </li>
                        </g:if>
                        <g:if test="${userPercent != '0.00'}">
                            <li>
                                <span>${selectedPronoun} transcribed ${userPercent}% of the total transcriptions on DigiVol.</span>
                            </li>
                        </g:if>
                    </ul>
                </div>
                <div class="row">
                    <div class="col-sm-12">
                        <p>
                            <i>First contributed in <g:formatDate date="${userInstance?.created}" format="MMM yyyy"/></i>
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
                        <g:link class="btn btn-success" controller="admin" action="manageUserRoles"
                                params="[userid: userInstance.id]"><g:message code="user.roles.manage.label" /></g:link>
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
                    <h2 class="heading">Record Locations</h2>
                    <p>${cl.displayNameForUserId(id: userInstance.userId)}${userInstance.userId == currentUser ? ', you' : ''} ${userInstance.userId == currentUser ? 'have' : 'has'} transcribed records from all the locations on this map</p>
                </div>
            </div>
        </div>
    </div>

    <g:if test="${isValidator}">
        <g:set var="taskViewUrl" value="${createLink(controller: 'task', action: 'showDetails')}""/>
    </g:if>
    <g:else>
        <g:set var="taskViewUrl" value=""/>
    </g:else>

    <div id="map"
         markers-url="${createLink(controller: "user", action: 'ajaxGetPoints', id: userInstance.id)}"
         infowindow-url="${createLink(controller: 'task', action: 'details')}"
         taskview-url="${taskViewUrl}">
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
                        uib-tooltip="${message(code:"notebook.taskList.searchHelp")}"><span
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

                <th class="sortable" ng-class="$ctrl.sortedClasses('id')">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'id', sorting: true})" class="btn"><g:message code="task.id.label" /></a>
                </th>

                <th class="sortable" ng-class="$ctrl.sortedClasses('externalIdentifier')">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'externalIdentifier', sorting: true})" class="btn"><g:message code="task.externalIdentifier.label" /></a>
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

                <th class="sortable" ng-class="$ctrl.sortedClasses('status')">
                    <a href="javascript:void(0)" ng-click="$ctrl.load({max:10, offset:0, sort: 'status', sorting: true})" class="btn"><g:message code="task.isValid.label" /></a>
                </th>

                <th style="text-align: center; vertical-align: middle;"><g:message code="notebook.tasklist.tableAction.label" /></th>

            </tr>
        </thead>
        <tbody>
            <tr ng-repeat="taskInstance in $ctrl.data.viewList track by taskInstance.id">

                <td>
                    <a ng-href="${createLink(controller: 'task', action: 'show')}/{{ taskInstance.id }}?userId=${userInstance.userId}" class="listLink">{{ taskInstance.id }}</a>
                </td>
                <td>
                    <a ng-if="taskInstance.isValidator" ng-href="${createLink(controller: 'task', action: 'showDetails')}/{{ taskInstance.id }}" title="${g.message(code: 'task.details.button.label')}"><i class="glyphicon glyphicon-list-alt"></i></a>
                    {{taskInstance.externalIdentifier}}
                </td>

                <td>
                    <a ng-href="${createLink(controller: 'project', action: 'index')}/{{ taskInstance.projectId }}" class="listLink">{{ taskInstance.projectName }}</a>
                </td>

                <td>
                    {{ taskInstance.dateTranscribed | date : 'medium' }}
                </td>

                <td>
                    {{ taskInstance.dateValidated | date : 'medium' }}
                </td>

                <td style="text-align: center;">
                    {{ taskInstance.status }}
                </td>

                <td style="text-align: center; width: 120px;">
                    <span ng-show="$ctrl.tabIndex > 0"> <!-- notebook.tasklist.tableAction.label -->
                        <a ng-show="taskInstance.isFullyTranscribed" class="btn btn-default btn-xs"
                           ng-href="${createLink(controller: 'task', action:'show')}/{{taskInstance.id}}?userId=${userInstance.userId}">
                            <g:message code="action.view.label" />
                        </a>
                        <a ng-show="taskInstance.isFullyTranscribed && taskInstance.isValidator" class="btn btn-default btn-xs"
                           ng-href="${createLink(controller: 'validate', action:'task')}/{{taskInstance.id}}">
                            <span ng-show="taskInstance.status == 'Validated'"><g:message code="action.review.label" /></span>
                            <span ng-hide="taskInstance.status == 'Validated'"><g:message code="action.validate.label" /></span>
                        </a>
                        <a ng-hide="taskInstance.isFullyTranscribed" class="btn btn-default btn-xs"
                           ng-href="${createLink(controller:'transcribe', action:'task')}/{{taskInstance.id}}">
                            <g:message code="action.transcribe.label" />
                        </a>
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
                        </h4>
                        <span ng-show="mt.topicProject"><g:message code="project.label" />: <a ng-href="${createLink(controller: 'project', action: 'index')}/{{ mt.topicProject.id }}">{{ mt.topicProject.name }}</a></span><br/>
                        <span ng-show="mt.topicTask"><g:message code="task.label" />: <a ng-href="${createLink(controller: 'task', action: 'show')}/{{ mt.topicTask.id }}">{{ mt.topicTask.externalIdentifier }}</a></span>
                    </th>
                </tr>
                <tr ng-repeat="m in mt.messages track by m.message.id" ng-class="{ 'author-is-moderator-row': m.isUserForumModerator }" ng-repeat-end>
                    <td class="forumNameColumn">
                        <a ng-hide="$ctrl.hideUsername" ng-href="${createLink(controller: 'user', action: 'show')}/{{ m.message.user.id}}">{{ m.userProps.displayName }}</a>
                        <br />
                        <span class="forumMessageDate">{{ m.message.date | date : 'medium' }}</span>
                        <br ng-show="m.isUserForumModerator" />
                        <span ng-show="m.isUserForumModerator" class="moderator-label"><g:message code="moderator.label" /></span>
                    </td>
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

</script>
<asset:javascript src="digivol-notebook" asset-defer=""/>
<asset:script type="text/javascript">
    var json = <cl:json value="${[
        selectedTab: selectedTab,
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
        forumPostsUrl: createLink(controller: 'forum', action: 'userComments', id: userInstance.id)
]}" />
    digivolNotebooksTabs(json);
</asset:script>

</body>
</html>
