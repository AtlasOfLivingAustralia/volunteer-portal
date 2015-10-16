<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'Volunteer')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
    <gvisualization:apiImport/>
    <r:require modules="qtip"/>
</head>

<body>
<cl:headerContent hideTitle="true"
        title="${cl.displayNameForUserId(id: userInstance.userId)}${userInstance.userId == currentUser ? "(that's you!)" : ''}"
        crumbLabel="${cl.displayNameForUserId(id: userInstance.userId)}" selectedNavItem="userDashboard">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'user', action: 'list'), label: 'Volunteers']
        ]
    %>
    <div class="container">
        <div class="row">

            <div class="col-sm-2">
                <div class="avatar-holder"><img src="http://www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=150" alt="" class="center-block img-circle img-responsive"></div>
            </div>
            <div class="col-sm-6">
                <span class="pre-header">Volunteer Profile</span>
                <h1>${cl.displayNameForUserId(id: userInstance.userId)}${userInstance.userId == currentUser ? "(that's you!)" : ''}</h1>
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
                </div>
            </div>

        </div>

    </div>

</cl:headerContent>

<a id="profileTabs"></a>
<g:set var="includeParams" value="${params.findAll { it.key != 'selectedTab' }}"/>
<section id="user-progress">
    <div class="container" >
        <ul class="nav nav-tabs profile-tabs" role="tablist" id="profileTabsList">
            <li role="presentation" class="${selectedTab == 0 || !selectedTab ? 'active' : ''}">
                <a href="#transcribed-tasks" tab-index="0" content-url="${createLink(controller: 'user', action: 'transcribedTasksFragment', params: includeParams + [selectedTab: 0])}" aria-controls="transcribed-tasks" role="tab" data-toggle="tab">Transcribed Tasks</a>
            </li>
            <li role="presentation" class="${selectedTab == 1 ? 'active' : ''}">
                <a href="#saved-tasks" tab-index="1" content-url="${createLink(controller: 'user', action: 'savedTasksFragment', params: includeParams + [selectedTab: 1])}" aria-controls="saved-tasks" role="tab" data-toggle="tab">Saved Tasks</a>
            </li>
            <cl:ifValidator>
            <li role="presentation" class="${selectedTab == 2 ? 'active' : ''}">
                <a href="#validated-tasks" tab-index="2" content-url="${createLink(controller: 'user', action: 'validatedTasksFragment', params: includeParams + [selectedTab: 2])}" aria-controls="validated-tasks" role="tab" data-toggle="tab">Validated Tasks</a>
            </li>
            </cl:ifValidator>
            <li role="presentation" class="${selectedTab == 3 ? 'active' : ''}">
                <a href="#forum-messages" tab-index="3" content-url="${createLink(controller: 'forum', action: 'userCommentsFragment', params: includeParams + [selectedTab: 3, userId: params.id])}" aria-controls="forum-messages" role="tab" data-toggle="tab">Forum Activities</a>
            </li>
        </ul>
    </div>

    <div class="tab-content-bg">
        <!-- Tab panes -->
        <div class="container">
            <div class="tab-content" id="profileTabsContent">
                <div role="tabpanel" class="tab-pane active" id="transcribed-tasks">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4 search-results-count">
                                <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading...</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div role="tabpanel" class="tab-pane" id="saved-tasks">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4 search-results-count">
                                <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading...</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div role="tabpanel" class="tab-pane" id="validated-tasks">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4 search-results-count">
                                <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading...</strong></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div role="tabpanel" class="tab-pane" id="forum-messages">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4 search-results-count">
                                <p><strong><i class="fa fa-cog fa-spin fa-2x"></i> Loading...</strong></p>
                            </div>
                        </div>
                    </div>
                </div>
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
                    <p>Jerry has transcribed records from all the locations on this map</p>
                </div>
            </div>
        </div>
    </div>

    <div id="map">
    </div>
</section>

<section id="main-content">
    <div class="container">
        <div class="row">
            <div class="col-sm-12">

                <div class="row">
                    <div class="col-sm-8">
                        <h2 class="heading">
                            Jerry's Current Expeditions
                        </h2>
                    </div>
                    <div class="col-sm-4">

                    </div>
                </div>



                <div class="row">
                    <div class="col-sm-12 col-md-4">
                        <div class="thumbnail">
                            <a class="btn btn-info btn-xs label">Australian Museum</a>
                            <a href="#"><img src="img/placeholder/1.jpg"></a>
                            <div class="caption">
                                <h4><a href="#">Thumbnail label</a></h4>
                                <a class="badge"><span class="glyphicon glyphicon-tag icon-flipped"></span>Speciman</a><a class="badge"><span class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>Australian Museum</a>
                                <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit.</p>

                                <div class="expedition-progress">
                                    <div class="progress">
                                        <div class="progress-bar progress-bar-success" style="width: 10%">
                                            <span class="sr-only">10% Validated (success)</span>
                                        </div>
                                        <div class="progress-bar progress-bar-transcribed" style="width: 20%">
                                            <span class="sr-only">20% Transcribed</span>
                                        </div>
                                    </div>

                                    <div class="progress-legend">
                                        <div class="row">
                                            <div class="col-xs-4">
                                                <b>38%</b> Validated
                                            </div>
                                            <div class="col-xs-4">
                                                <b>60%</b> Transcribed
                                            </div>
                                            <div class="col-xs-4">
                                                <b>2000</b> Tasks
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-sm-12 col-md-4">
                        <div class="thumbnail">
                            <a class="btn btn-info btn-xs label">Australian Museum</a>
                            <a href="#"><img src="img/placeholder/1.jpg"></a>
                            <div class="caption">
                                <h4><a href="#">Thumbnail label</a></h4>
                                <a class="badge"><span class="glyphicon glyphicon-tag icon-flipped"></span>Speciman</a><a class="badge"><span class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>Australian Museum</a>
                                <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit.</p>

                                <div class="expedition-progress">
                                    <div class="progress">
                                        <div class="progress-bar progress-bar-success" style="width: 10%">
                                            <span class="sr-only">10% Validated (success)</span>
                                        </div>
                                        <div class="progress-bar progress-bar-transcribed" style="width: 20%">
                                            <span class="sr-only">20% Transcribed</span>
                                        </div>
                                    </div>

                                    <div class="progress-legend">
                                        <div class="row">
                                            <div class="col-xs-4">
                                                <b>38%</b> Validated
                                            </div>
                                            <div class="col-xs-4">
                                                <b>60%</b> Transcribed
                                            </div>
                                            <div class="col-xs-4">
                                                <b>2000</b> Tasks
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-sm-12 col-md-4">
                        <div class="thumbnail">
                            <a class="btn btn-info btn-xs label">Australian Museum</a>
                            <a href="#"><img src="img/placeholder/1.jpg"></a>
                            <div class="caption">
                                <h4><a href="#">Thumbnail label</a></h4>
                                <a class="badge"><span class="glyphicon glyphicon-tag icon-flipped"></span>Speciman</a><a class="badge"><span class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>Australian Museum</a>
                                <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit.</p>

                                <div class="expedition-progress">
                                    <div class="progress">
                                        <div class="progress-bar progress-bar-success" style="width: 10%">
                                            <span class="sr-only">10% Validated (success)</span>
                                        </div>
                                        <div class="progress-bar progress-bar-transcribed" style="width: 20%">
                                            <span class="sr-only">20% Transcribed</span>
                                        </div>
                                    </div>

                                    <div class="progress-legend">
                                        <div class="row">
                                            <div class="col-xs-4">
                                                <b>38%</b> Validated
                                            </div>
                                            <div class="col-xs-4">
                                                <b>60%</b> Transcribed
                                            </div>
                                            <div class="col-xs-4">
                                                <b>2000</b> Tasks
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div><!--/row-->


            </div>

        </div>
    </div>
</section>

<r:script>
    var notebookTabs = {

        loadContent: function () {
            var url = $('#profileTabsList li.active a').attr('content-url');
            console.log('url 1 = ' + url);
            $.ajax(url).done(function(content) {
                $("#profileTabsContent .tab-pane.active").html(content);
            });
        },

        updateQueryStringParameter: function (uri, key, value) {
            var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
            var separator = uri.indexOf('?') !== -1 ? "&" : "?";
            if (uri.match(re)) {
                return uri.replace(re, '$1' + key + "=" + value + '$2');
            }
            else {
                return uri + separator + key + "=" + value;
            }
        }
    };

    $(function() {
        notebookTabs.loadContent();

        $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
            e.preventDefault();
            console.log('shown.bs.tab event fired');
            location.replace(notebookTabs.updateQueryStringParameter(window.location.pathname, 'selectedTab', $(this).attr('tab-index')) + '#profileTabs');
        });
    });
</r:script>
</body>
</html>
