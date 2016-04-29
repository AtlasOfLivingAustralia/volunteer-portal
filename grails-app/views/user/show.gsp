<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'Volunteer')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
    <script src="https://maps.googleapis.com/maps/api/js"></script>
    <gvisualization:apiImport/>
    <r:require module="digivol-notebook"/>
</head>

<body>
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
                    <ul>
                        <g:if test="${totalSpeciesCount > 0}">
                            <li>
                                <span>You have added ${totalSpeciesCount} species to the ALA:</span>

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
                                <span>You have contributed to ${fieldObservationCount} new field observations.</span>
                            </li>
                        </g:if>
                        <g:if test="${expeditionCount > 0}">
                            <li>
                                <span>You have participated in ${expeditionCount} expeditions.</span>
                            </li>
                        </g:if>
                        <g:if test="${userPercent != '0.00'}">
                            <li>
                                <span>You have transcribed ${userPercent}% of the total transcriptions on DigiVol.</span>
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

<g:set var="includeParams" value="${params.findAll { it.key != 'selectedTab' }}"/>
<section id="user-progress">
    <div class="container" >
        <ul class="nav nav-tabs profile-tabs" role="tablist" id="profileTabsList">
            <g:if test="${userInstance.userId == currentUser}">
                <li role="presentation" class="${selectedTab == 0 || !selectedTab ? 'active' : ''}">
                    <a id="notificationsTab" href="#notifications-tasks" tab-index="0" content-url="${createLink(controller: 'user', action: 'notificationsFragment', params: includeParams + [selectedTab: 0])}" aria-controls="notifications-tasks" role="tab" data-toggle="tab">
                        Notifications
                        <g:if test="${recentValidatedTaskCount > 0}" >
                            <span class="glyphicon glyphicon-bell" style="color:red"></span>
                        </g:if>
                    </a>
                </li>
            </g:if>
            <li role="presentation" class="${selectedTab == 1 ? 'active' : ''}">
                <a href="#transcribed-tasks" tab-index="1" content-url="${createLink(controller: 'user', action: 'transcribedTasksFragment', params: includeParams + [selectedTab: 1])}" aria-controls="transcribed-tasks" role="tab" data-toggle="tab">Transcribed Tasks</a>
            </li>
            <li role="presentation" class="${selectedTab == 2 ? 'active' : ''}">
                <a href="#saved-tasks" tab-index="2" content-url="${createLink(controller: 'user', action: 'savedTasksFragment', params: includeParams + [selectedTab: 2])}" aria-controls="saved-tasks" role="tab" data-toggle="tab">Saved Tasks</a>
            </li>
            <cl:ifValidator>
                <li role="presentation" class="${selectedTab == 3 ? 'active' : ''}">
                    <a href="#validated-tasks" tab-index="3" content-url="${createLink(controller: 'user', action: 'validatedTasksFragment', params: includeParams + [selectedTab: 3])}" aria-controls="validated-tasks" role="tab" data-toggle="tab">Validated Tasks</a>
                </li>
            </cl:ifValidator>
            <li role="presentation" class="${selectedTab == 4 ? 'active' : ''}">
                <a href="#forum-messages" tab-index="4" content-url="${createLink(controller: 'forum', action: 'userCommentsFragment', params: [selectedTab: 4, id: params.id, max: params.max, offset: params.offset])}" aria-controls="forum-messages" role="tab" data-toggle="tab">Forum Activities</a>
            </li>
            <cl:ifAdmin>
                <li role="presentation" class="${selectedTab == 5 ? 'active' : ''}">
                    <a href="#user-settings" tab-index="5" aria-controls="user-settings" role="tab" data-toggle="tab">User Settings</a>
                </li>
            </cl:ifAdmin>
        </ul>
    </div>

    <div class="tab-content-bg">
        <!-- Tab panes -->
        <div class="container">
            <div class="tab-content" id="profileTabsContent">
                <div role="tabpanel" class="tab-pane active" id="notifications-tasks">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4 search-results-count">
                                <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading ...</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div role="tabpanel" class="tab-pane" id="transcribed-tasks">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4 search-results-count">
                                <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading ...</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div role="tabpanel" class="tab-pane" id="saved-tasks">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4 search-results-count">
                                <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading ...</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div role="tabpanel" class="tab-pane" id="validated-tasks">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4 search-results-count">
                                <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading ...</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div role="tabpanel" class="tab-pane" id="forum-messages">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4 search-results-count">
                                <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading ...</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <cl:ifAdmin>
                <div role="tabpanel" class="tab-pane" id="user-settings">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="alert alert-info" style="margin-bottom: 0px">
                                    <%-- TODO Pull this from user details service --%>
                                    &nbsp;Email:&nbsp;<a href="mailto:${userInstance.email}">${userInstance.email}</a>
                                </div>
                                <br/>
                                <g:link class="btn btn-success" controller="user" action="editRoles"
                                        id="${userInstance.id}">Manage user roles</g:link>
                                <g:link class="btn btn-success" controller="user" action="edit"
                                        id="${userInstance.id}">Edit user details</g:link>
                            </div>
                        </div>
                    </div>
                </div>
                </cl:ifAdmin>
            </div>
        </div>
    </div>

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

    <div id="map"
         markers-url="${createLink(controller: "user", action: 'ajaxGetPoints', id: userInstance.id)}"
         infowindow-url="${createLink(controller: 'task', action: 'details')}">
    </div>
</section>

</body>
</html>
