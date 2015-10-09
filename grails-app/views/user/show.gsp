<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'Volunteer')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>

</head>

<body>
<cl:headerContent
        title="${cl.displayNameForUserId(id: userInstance.userId)}${userInstance.userId == currentUser ? "(that's you!)" : ''}"
        crumbLabel="${cl.displayNameForUserId(id: userInstance.userId)}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'user', action: 'list'), label: 'Volunteers']
        ]
    %>
</cl:headerContent>
<div class="a-feature simple-header profile-summary">
    <div class="container">
        <div class="row">

            <div class="col-sm-2">
                <div class="avatar-holder"><img src="img/avatar-male.png" alt="" class="center-block img-circle img-responsive"></div>
            </div>
            <div class="col-sm-6">
                <span class="pre-header">Volunteer Profile</span>
                <h1>Jerry Smith</h1>
                <div class="row">
                    <div class="col-xs-4">
                        <h2><strong>593</strong></h2>
                        <p>Total Contribution</p>
                    </div><!--/col-->
                    <div class="col-xs-4">
                        <h2><strong>744</strong></h2>
                        <p>Transcribed</p>
                    </div><!--/col-->
                    <div class="col-xs-4">
                        <h2><strong>322</strong></h2>
                        <p>Validated</p>
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
                            <img src="img/badges/badgeInsectTasks100.png">
                            <img src="img/badges/badgeFieldNotes100.png">
                            <img src="img/badges/badgeMalacologyTasks100.png">
                            <img src="img/badges/badgeBotanicTasks100.png">
                            <img src="img/badges/badge5Countries100Tasks.png">
                        </div>
                    </div>
                </div>


            </div>

            <div class="col-sm-4">
                <div class="contribution-chart">
                    <h2>Contribution to Research</h2>
                    <p>You have added 40 species to the ALA</p>
                    <div id="canvas-holder">
                        <canvas id="chart-area"/></canvas>
                    </div>

                    <div class="row pie-legend">

                        <div class="col-xs-4">
                            <span class="key" style="background-color: #d5502a;"></span>Acupalpa
                        </div>

                        <div class="col-xs-4">
                            <span class="key" style="background-color: #f5bf56;"></span>Agrius convo
                        </div>

                        <div class="col-xs-4">
                            <span class="key" style="background-color: #717171;"></span>Others
                        </div>

                    </div>
                </div>
                <div class="row">
                    <div class="col-sm-12">
                        <p>
                            <i>First contributed in Jan 2014</i>
                        </p>
                    </div>
                </div>
            </div>

        </div>

    </div>
</div>


<section id="user-progress">
    <div class="container">
        <ul class="nav nav-tabs profile-tabs" role="tablist">
            <li role="presentation" class="active"><a href="#transcribed-tasks" aria-controls="transcribed-tasks" role="tab" data-toggle="tab">Transcribed Tasks</a></li>
            <li role="presentation"><a href="#saved-tasks" aria-controls="saved-tasks" role="tab" data-toggle="tab">Saved Tasks</a></li>
            <li role="presentation"><a href="#validated-tasks" aria-controls="validated-tasks" role="tab" data-toggle="tab">Validated Tasks</a></li>
            <li role="presentation"><a href="#forum-messages" aria-controls="forum-messages" role="tab" data-toggle="tab">Forum Activities</a></li>
            <li role="presentation"><a href="#saved-notes" aria-controls="forum-messages" role="tab" data-toggle="tab">Saved Notes</a></li>
        </ul>
    </div>
    <div class="tab-content-bg">
        <!-- Tab panes -->
        <div class="container">
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="transcribed-tasks">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4">
                                <p><strong>435 Tasks Found</strong></p>
                            </div>
                            <div class="col-sm-8">
                                <div class="custom-search-input body">
                                    <div class="input-group">
                                        <input type="text" class="form-control input-lg" placeholder="Search e.g. Bivalve" />
                                        <span class="input-group-btn">
                                            <button class="btn btn-info btn-lg" type="button">
                                                <i class="glyphicon glyphicon-search"></i>
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <table class="table table-striped">
                        <thead>
                        <tr>
                            <th>Photo</th>
                            <th>Image ID</th>
                            <th>Catalog ID</th>
                            <th>Expedition</th>
                            <th>Transcribed</th>
                            <th>Validated</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        </tbody>
                    </table>
                </div>

                <div role="tabpanel" class="tab-pane" id="saved-tasks">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4">
                                <p><strong>435 Tasks Found</strong></p>
                            </div>
                            <div class="col-sm-8">
                                <div class="custom-search-input body">
                                    <div class="input-group">
                                        <input type="text" class="form-control input-lg" placeholder="Search e.g. Bivalve" />
                                        <span class="input-group-btn">
                                            <button class="btn btn-info btn-lg" type="button">
                                                <i class="glyphicon glyphicon-search"></i>
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <table class="table table-striped">
                        <thead>
                        <tr>
                            <th>Photo</th>
                            <th>Image ID</th>
                            <th>Catalog ID</th>
                            <th>Expedition</th>
                            <th>Transcribed</th>
                            <th>Validated</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        </tbody>
                    </table>


                </div>
                <div role="tabpanel" class="tab-pane" id="validated-tasks">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4">
                                <p><strong>435 Tasks Found</strong></p>
                            </div>
                            <div class="col-sm-8">
                                <div class="custom-search-input body">
                                    <div class="input-group">
                                        <input type="text" class="form-control input-lg" placeholder="Search e.g. Bivalve" />
                                        <span class="input-group-btn">
                                            <button class="btn btn-info btn-lg" type="button">
                                                <i class="glyphicon glyphicon-search"></i>
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <table class="table table-striped">
                        <thead>
                        <tr>
                            <th>Photo</th>
                            <th>Image ID</th>
                            <th>Catalog ID</th>
                            <th>Expedition</th>
                            <th>Transcribed</th>
                            <th>Validated</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        </tbody>
                    </table>

                </div>
                <div role="tabpanel" class="tab-pane" id="forum-messages">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4">
                                <p><strong>435 Messages Found</strong></p>
                            </div>
                            <div class="col-sm-8">
                                <div class="custom-search-input body">
                                    <div class="input-group">
                                        <input type="text" class="form-control input-lg" placeholder="Search e.g. Bivalve" />
                                        <span class="input-group-btn">
                                            <button class="btn btn-info btn-lg" type="button">
                                                <i class="glyphicon glyphicon-search"></i>
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="topicTable">
                        <table class="forum-table table table-striped">
                            <thead>
                            <tr>
                                <th class="button sortable" colspan="2">
                                    <a class="btn" href="/forum/index?selectedTab=0&amp;sort=title&amp;order=asc">Topic</a>
                                </th>

                                <th class="button sortable">
                                    <a class="btn" href="/forum/index?selectedTab=0&amp;sort=replies&amp;order=asc">Replies</a>
                                </th>

                                <th class="button sortable">
                                    <a class="btn" href="/forum/index?selectedTab=0&amp;sort=views&amp;order=asc">Views</a>
                                </th>

                                <th class="button sortable">
                                    <a class="btn" href="/forum/index?selectedTab=0&amp;sort=creator&amp;order=asc">Posted&nbsp;by</a>
                                </th>

                                <th class="button sortable">
                                    <a class="btn" href="/forum/index?selectedTab=0&amp;sort=dateCreated&amp;order=asc">Posted</a>
                                </th>

                                <th class="button sortable">
                                    <a class="btn" href="/forum/index?selectedTab=0&amp;sort=lastReplyDate&amp;order=asc">Last reply</a>
                                </th>

                                <th></th>
                            </tr>
                            </thead>

                            <tbody>
                            <tr class="Normal">
                                <td style="width: 40px; padding: 0px"><img src="http://placehold.it/40x40/ccc" class="forum-thumb"></td>

                                <td>
                                    <a href="/forum/viewForumTopic/9041196">SAMA_D30839_Unidentified.jpg</a>
                                </td>

                                <td>0</td>

                                <td>1</td>

                                <td><span>Rosie Fedorow</span></td>

                                <td>24 Sep 2015 13:19:36</td>

                                <td></td>

                                <td>
                                    <a class="btn btn-small" href="/forum/postMessage?topicId=9041196">Reply</a>
                                </td>
                            </tr>

                            <tr class="Normal">
                                <td style="width: 40px; padding: 0px"><img src="http://placehold.it/40x40/ccc" class="forum-thumb"></td>

                                <td>
                                    <a href="/forum/viewForumTopic/9029875">Wildcount</a>
                                </td>

                                <td>2</td>

                                <td>7</td>

                                <td><span>Teresa Van Der Heul</span></td>

                                <td>23 Sep 2015 21:09:36</td>

                                <td>24 Sep 2015 13:17:09</td>

                                <td>
                                    <a class="btn btn-small" href="/forum/postMessage?topicId=9029875">Reply</a>
                                </td>
                            </tr>

                            <tr class="Normal">
                                <td style="width: 40px; padding: 0px"><img src="http://placehold.it/40x40/ccc" class="forum-thumb"></td>

                                <td>
                                    <a href="/forum/viewForumTopic/9040033">SAMA_D30817_Spirula_spirula.jpg</a>
                                </td>

                                <td>0</td>

                                <td>0</td>

                                <td><span>Rosie Fedorow</span></td>

                                <td>24 Sep 2015 12:33:21</td>

                                <td></td>

                                <td>
                                    <a class="btn btn-small" href="/forum/postMessage?topicId=9040033">Reply</a>
                                </td>
                            </tr>

                            <tr class="Normal">
                                <td style="width: 40px; padding: 0px"><img src="http://placehold.it/40x40/ccc" class="forum-thumb"></td>

                                <td>
                                    <a href="/forum/viewForumTopic/9038378">SAMA_D30853_Octopus_flindersi.jpg</a>
                                </td>

                                <td>1</td>

                                <td>3</td>

                                <td><span>Rosie Fedorow</span></td>

                                <td>24 Sep 2015 11:52:02</td>

                                <td>24 Sep 2015 11:56:36</td>

                                <td>
                                    <a class="btn btn-small" href="/forum/postMessage?topicId=9038378">Reply</a>
                                </td>
                            </tr>

                            <tr class="Normal">
                                <td style="width: 40px; padding: 0px"><img src="http://placehold.it/40x40/ccc" class="forum-thumb"></td>

                                <td>
                                    <a href="/forum/viewForumTopic/9024637">SAMA_D13682_Arctosepia_braggi.jpg</a>
                                </td>

                                <td>3</td>

                                <td>10</td>

                                <td><span>Rosie Fedorow</span></td>

                                <td>23 Sep 2015 13:28:19</td>

                                <td>24 Sep 2015 09:42:36</td>

                                <td>
                                    <a class="btn btn-small" href="/forum/postMessage?topicId=9024637">Reply</a>
                                </td>
                            </tr>

                            <tr class="Normal author-is-moderator-row">
                                <td style="width: 40px; padding: 0px"><img src="http://placehold.it/40x40/ccc" class="forum-thumb"></td>

                                <td>
                                    <a href="/forum/viewForumTopic/8958642">50, 000!!</a>
                                </td>

                                <td>5</td>

                                <td>17</td>

                                <td><span>Rhiannon Stephens <i class="icon-star-empty">&nbsp;</i></span></td>

                                <td>20 Sep 2015 21:16:03</td>

                                <td>23 Sep 2015 21:06:54</td>

                                <td>
                                    <a class="btn btn-small" href="/forum/postMessage?topicId=8958642">Reply</a>
                                </td>
                            </tr>

                            <tr class="Normal">
                                <td style="width: 40px; padding: 0px"><img src="http://placehold.it/40x40/ccc" class="forum-thumb"></td>

                                <td>
                                    <a href="/forum/viewForumTopic/8790230">Gillies_Journal_1_037.jpg</a>
                                </td>

                                <td>5</td>

                                <td>17</td>

                                <td><span>Teresa Van Der Heul</span></td>

                                <td>13 Sep 2015 13:11:33</td>

                                <td>20 Sep 2015 17:58:45</td>

                                <td>
                                    <a class="btn btn-small" href="/forum/postMessage?topicId=8790230">Reply</a>
                                </td>
                            </tr>

                            <tr class="Normal">
                                <td style="width: 40px; padding: 0px"><img src="http://placehold.it/40x40/ccc" class="forum-thumb"></td>

                                <td>
                                    <a href="/forum/viewForumTopic/8882319">SAMA_D22319_Nautilus_stenomphalus.jpg</a>
                                </td>

                                <td>2</td>

                                <td>13</td>

                                <td><span>Helen Robinson</span></td>

                                <td>17 Sep 2015 12:25:56</td>

                                <td>17 Sep 2015 20:12:32</td>

                                <td>
                                    <a class="btn btn-small" href="/forum/postMessage?topicId=8882319">Reply</a>
                                </td>
                            </tr>

                            <tr class="Normal">
                                <td style="width: 40px; padding: 0px"><img src="http://placehold.it/40x40/ccc" class="forum-thumb"></td>

                                <td>
                                    <a href="/forum/viewForumTopic/8824641">Gillies_Journal_1_102.jpg</a>
                                </td>

                                <td>0</td>

                                <td>4</td>

                                <td><span>Teresa Van Der Heul</span></td>

                                <td>15 Sep 2015 10:13:04</td>

                                <td></td>

                                <td>
                                    <a class="btn btn-small" href="/forum/postMessage?topicId=8824641">Reply</a>
                                </td>
                            </tr>

                            <tr class="Normal">
                                <td style="width: 40px; padding: 0px"><img src="http://placehold.it/40x40/ccc" class="forum-thumb"></td>

                                <td>
                                    <a href="/forum/viewForumTopic/8681312">174B_2014_IMG_0034.jpg</a>
                                </td>

                                <td>1</td>

                                <td>13</td>

                                <td><span>J Hitcho</span></td>

                                <td>08 Sep 2015 16:28:23</td>

                                <td>09 Sep 2015 16:46:07</td>

                                <td>
                                    <a class="btn btn-small" href="/forum/postMessage?topicId=8681312">Reply</a>
                                </td>
                            </tr>
                            </tbody>

                        </table>
                    </div>
                </div>
                <div role="tabpanel" class="tab-pane" id="saved-notes">
                    <div class="tab-pane-header">
                        <div class="row">
                            <div class="col-sm-4">
                                <p><strong>435 Tasks Found</strong></p>
                            </div>
                            <div class="col-sm-8">
                                <div class="custom-search-input body">
                                    <div class="input-group">
                                        <input type="text" class="form-control input-lg" placeholder="Search e.g. Bivalve" />
                                        <span class="input-group-btn">
                                            <button class="btn btn-info btn-lg" type="button">
                                                <i class="glyphicon glyphicon-search"></i>
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <table class="table table-striped">
                        <thead>
                        <tr>
                            <th>Photo</th>
                            <th>Image ID</th>
                            <th>Catalog ID</th>
                            <th>Expedition</th>
                            <th>Transcribed</th>
                            <th>Validated</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        <tr>
                            <th scope="row"><img src="http://placehold.it/40x40/ccc"></th>
                            <td>56734</td>
                            <td>UHIM201123212</td>
                            <td>Bivalve Expedition</td>
                            <td>28 May, 2015 08:00</td>
                            <td>21 June, 2015 08:00</td>
                        </tr>
                        </tbody>
                    </table>
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
</body>
</html>
