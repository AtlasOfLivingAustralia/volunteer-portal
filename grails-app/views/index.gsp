<!doctype html>
<html>
    <head>
        <meta name="layout" content="main-digivol-bs3"/>
        <meta name="section" content="home"/>
        <title><cl:pageTitle title="Home" /></title>
        %{--<content tag="primaryColour">#0097d4</content>--}%
    </head>

    <body>
    <!-- Main jumbotron for a primary marketing message or call to action -->

    <div class="a-feature home">
        <div class="container">
            <h1>Build knowledge &amp; <br />communities through <br />digitising collections</h1>
            <h2>Join our community of 1,000+ volunteer citizen scientists</h2>

            <div class="cta-primary">
                <a class="btn btn-primary btn-lg" href="#expeditionList" role="button">Get involved <span class="glyphicon glyphicon-arrow-down"></span></a>  <a class="btn btn-lg btn-hollow" href="#learnMore" >Learn more</a>
            </div>
            <a name="learnMore"></a>
        </div>

    </div>

    <section id="what-you-do" class="dark">
        <div class="container">
            <h2 class="heading">Volunteer by</h2>
            <div class="row">
                <div class="col-sm-1 col-xs-4">
                    <r:img dir="images/2.0" file="iconWild.png" class="img-responsive" />
                </div>
                <div class="col-sm-3 col-xs-8">
                    <h3>Identify Animals</h3>
                    <p>Help identify animals in photos captured by in camera traps.</p>
                    <a href="#">See all camera traps</a>
                </div>
                <div class="col-sm-1 col-xs-4">
                    <r:img dir="images/2.0" file="iconNotes.png" class="img-responsive" />
                </div>
                <div class="col-sm-3 col-xs-8">
                    <h3>Transcribe field journals</h3>
                    <p>Transcribe written text in field journals from various expeditions.</p>
                    <a href="#">See all field journals</a>
                </div>
                <div class="col-sm-1 col-xs-4">
                    <r:img dir="images/2.0" file="iconLabels.png" class="img-responsive" />
                </div>
                <div class="col-sm-3 col-xs-8">
                    <h3>Transcribe speciman labels</h3>
                    <p>Transcribe field labels from expeditions</p>
                    <a href="#">See all labels</a>
                </div>

            </div>

        </div>
    </section>

    <a name="expeditionList"></a>

    <section id="expedition-feature">
        <div class="container">
            <h2 class="heading">Feature Expedition</h2>
            <div class="row">
                <div class="col-md-6">
                    <a class="btn btn-info btn-xs label">${frontPage.projectOfTheDay?.institutionName}</a>
                    <a href="#"><img src="${frontPage.projectOfTheDay?.featuredImage}" class="img-responsive"></a>
                </div>
                <div class="col-md-6">
                    <h3><a href="${createLink(controller: 'project', id: frontPage.projectOfTheDay?.id, action: 'index')}">${frontPage.projectOfTheDay?.featuredLabel}</a></h3>
                    <a class="badge"><span class="glyphicon glyphicon-tag icon-flipped"></span>Field notes</a><a class="badge"><span class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${frontPage.projectOfTheDay?.institutionName}</a>
                    <p>
                        ${raw(frontPage.projectOfTheDay?.description)}
                    </p>

                    <div class="expedition-progress">
                        <div class="progress">
                            <div class="progress-bar progress-bar-success" style="width: ${potdSummary.percentValidated}%">
                                <span class="sr-only">${potdSummary.percentValidated}% Validated (success)</span>
                            </div>
                            <div class="progress-bar progress-bar-transcribed" style="width: ${potdSummary.percentTranscribed}%">
                                <span class="sr-only">${potdSummary.percentTranscribed}% Transcribed</span>
                            </div>
                        </div>

                        <div class="progress-legend">
                            <div class="row">
                                <div class="col-xs-4">
                                    <span class="key validated"></span><b>${potdSummary.percentValidated}%</b> Validated
                                </div>
                                <div class="col-xs-4">
                                    <span class="key transcribed"></span><b>${potdSummary.percentTranscribed}%</b> Transcribed
                                </div>
                                <div class="col-xs-4">
                                    <span class="key volunteers"></span><b>${potdSummary.transcriberCount}</b> Volunteers
                                </div>
                            </div>
                        </div>
                    </div>


                </div>
            </div>
        </div>

    </section>


    <section id="main-content">
        <div class="container">
            <div class="row">
                <div class="col-sm-8">

                    <div class="row">
                        <div class="col-sm-8">
                            <h2 class="heading">
                                More Expeditions
                            </h2>
                        </div>
                        <div class="col-sm-4">
                            <button type="button" class="btn btn-default btn-sm pull-right">See all</button>
                        </div>
                    </div>

                    <div class="row">
                        <g:each in="${featuredProjects}" var="featuredProject">
                            <div class="col-sm-12 col-md-6">
                                <div class="thumbnail">
                                    <a class="btn btn-info btn-xs label">${featuredProject.project?.institutionName}</a>
                                    <a href="${createLink(controller: 'project', id: featuredProject.project?.id, action: 'index')}"><img src="${featuredProject.project?.featuredImage}" class="img-responsive"></a>
                                    <div class="caption">
                                        <h4><a href="#">${featuredProject.project?.featuredLabel}</a></h4>

                                        <a class="badge"><span class="glyphicon glyphicon-tag icon-flipped"></span>Speciman</a><a class="badge"><span class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${featuredProject.project?.institutionName}</a>
                                        <p>${featuredProject.project?.shortDescription}</p>

                                        <div class="expedition-progress">
                                            <div class="progress">
                                                <div class="progress-bar progress-bar-success" style="width: ${featuredProject.percentValidated}%">
                                                    <span class="sr-only">${featuredProject.percentValidated}% Validated (success)</span>
                                                </div>
                                                <div class="progress-bar progress-bar-transcribed" style="width: ${featuredProject.percentTranscribed}%">
                                                    <span class="sr-only">${featuredProject.percentTranscribed}% Transcribed</span>
                                                </div>
                                            </div>

                                            <div class="progress-legend">
                                                <div class="row">

                                                    <div class="col-xs-4">
                                                        <span class="key validated"></span><b>${featuredProject.percentValidated}%</b> Validated
                                                    </div>
                                                    <div class="col-xs-4">
                                                        <span class="key transcribed"></span><b>${featuredProject.percentTranscribed}%</b> Transcribed
                                                    </div>
                                                    <div class="col-xs-4">
                                                        <span class="key volunteers"></span><b>${featuredProject.transcriberCount}</b> Volunteers
                                                    </div>

                                                </div>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </g:each>
                    </div><!--/row-->

                    <div class="row">
                        <div class="col-md-12">
                            <a class="btn btn-default btn-load" href="#" role="button">Load more</a>
                        </div>
                    </div>
                </div>

                <div class="col-sm-4">

                    <div class="panel panel-default leaderboard">
                        <!-- Default panel contents -->
                        <h2 class="heading">Leaderboard <i class="fa fa-trophy fa-sm pull-right"></i></h2>
                        <!-- Table -->
                        <table class="table">
                            <thead>
                            <tr>
                                <th colspan="2">Day Tripper</th>
                                <th class="view-more"><a href="#">View Top 20</a></th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <th scope="row"><a href="#"><img src="https://randomuser.me/api/portraits/med/women/35.jpg" class="img-circle"></a></th>
                                <th><a href="#">Rachel Lee</a></th>
                                <td class="transcribed-amount">3982</td>
                            </tr>
                            </tbody>
                            <thead>
                            <tr>
                                <th colspan="2">Weekly Wonder</th>
                                <th class="view-more"><a href="#">View Top 20</a></th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <th scope="row"><a href="#"><img src="https://randomuser.me/api/portraits/med/women/12.jpg" class="img-circle"></a></th>
                                <th><a href="#">Teresa Van Der Heul</a></th>
                                <td class="transcribed-amount">1223</td>
                            </tr>
                            </tbody>
                            <thead>
                            <tr>
                                <th colspan="2">Digivol Legend</th>
                                <th class="view-more"><a href="#">View Top 20</a></th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <th scope="row"><a href="#"><img src="https://randomuser.me/api/portraits/med/women/19.jpg" class="img-circle"></a></th>
                                <th><a href="#">Megan Ede</a></th>
                                <td class="transcribed-amount">989</td>
                            </tr>
                            </tbody>
                            <thead>
                            <tr>
                                <th colspan="2">Day Tripper</th>
                                <th class="view-more"><a href="#">View Top 20</a></th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <th scope="row"><a href="#"><img src="https://randomuser.me/api/portraits/med/women/22.jpg" class="img-circle"></a></th>
                                <th><a href="#">Rachel Lee</a></th>
                                <td class="transcribed-amount">124</td>
                            </tr>
                            </tbody>
                        </table>
                    </div><!-- Leaderboard Ends Here -->


                    <h2 class="heading">
                        Latest Contributions
                    </h2>
                    <ul class="media-list">


                        <li class="media">
                            <div class="media-left">
                                <a href="#">
                                    <img src="https://randomuser.me/api/portraits/med/women/62.jpg" class="img-circle">
                                </a>
                            </div>
                            <div class="media-body">
                                <span class="time">5 hours ago</span>
                                <h4 class="media-heading"><a href="#">Margret Kin</a></h4>
                                <p>Transcribed 7 items from the <a href="#">Bivalve expedition</a></p>
                                <div class="transcribed-thumbs">
                                    <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc">  <img src="http://placehold.it/40x40/ccc"> <a href="#"><span>+2</span>More</a>
                                </div>
                                <a class="btn btn-default btn-xs join" href="#" role="button">Join expedition »</a>
                            </div>

                        </li>
                        <li class="media">
                            <div class="media-left">
                                <a href="#">
                                    <img src="https://randomuser.me/api/portraits/med/women/62.jpg" class="img-circle">
                                </a>
                            </div>
                            <div class="media-body">
                                <span class="time">5 hours ago</span>
                                <h4 class="media-heading"><a href="#">Margret Kin</a></h4>
                                <p>Transcribed 7 items from the <a href="#">Bivalve expedition</a></p>
                                <div class="transcribed-thumbs">
                                    <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc">  <img src="http://placehold.it/40x40/ccc"> <a href="#"><span>+2</span>More</a>
                                </div>
                                <a class="btn btn-default btn-xs join" href="#" role="button">Join expedition »</a>
                            </div>

                        </li>

                        <li class="media">
                            <div class="media-left">
                                <a href="#">
                                    <img src="https://randomuser.me/api/portraits/med/men/51.jpg" class="img-circle">
                                </a>
                            </div>
                            <div class="media-body">
                                <span class="time">5 hours ago</span>
                                <h4 class="media-heading"><a href="#">Warren Lee</a></h4>
                                <p>Has posted in the forum: <a href="#">Hawaiian Mouthparts expedition</a></p>
                                <div class="transcribed-thumbs">
                                    <img src="http://placehold.it/40x40/ccc">
                                </div>
                                <a class="btn btn-default btn-xs join" href="#" role="button">Join discussion »</a>
                            </div>

                        </li>
                        <li class="media">
                            <div class="media-left">
                                <a href="#">
                                    <img src="https://randomuser.me/api/portraits/med/women/62.jpg" class="img-circle">
                                </a>
                            </div>
                            <div class="media-body">
                                <span class="time">5 hours ago</span>
                                <h4 class="media-heading"><a href="#">Margret Kin</a></h4>
                                <p>Transcribed 3 items from the <a href="#">Bivalve expedition</a></p>
                                <div class="transcribed-thumbs">
                                    <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc">
                                </div>
                                <a class="btn btn-default btn-xs join" href="#" role="button">Join expedition »</a>
                            </div>

                        </li>
                        <li class="media">
                            <div class="media-left">
                                <a href="#">
                                    <img src="https://randomuser.me/api/portraits/med/women/62.jpg" class="img-circle">
                                </a>
                            </div>
                            <div class="media-body">
                                <span class="time">5 hours ago</span>
                                <h4 class="media-heading"><a href="#">Margret Kin</a></h4>
                                <p>Transcribed 2 items from the <a href="#">Bivalve expedition</a></p>
                                <div class="transcribed-thumbs">
                                    <img src="http://placehold.it/40x40/ccc"> <img src="http://placehold.it/40x40/ccc">
                                </div>
                                <a class="btn btn-default btn-xs join" href="#" role="button">Join expedition »</a>
                            </div>

                        </li>
                    </ul>
                    <a href="#">View all contributors »</a>

                </div>
            </div>
        </div>
    </section>
        %{--<cl:headerContent title="${message(code:'default.application.name', default:'DigiVol')}" selectedNavItem="bvp" hideCrumbs="${true}">--}%
            %{--<p class="bvp-byline">Volunteers building knowledge and communities through digitising collections</p>--}%
        %{--</cl:headerContent>--}%

        %{--<div class="container-fluid">--}%
            %{--<div class="row-fluid">--}%
                %{--<div class="span9">--}%
                    %{--<section>--}%
                        %{--<div style="margin-bottom: 10px">--}%
                            %{--<h2 class="orange">Virtual expedition of the day</h2>--}%
                            %{--<div class="row-fluid">--}%
                            %{--<div class="span4" style="position: relative">--}%
                                %{--<div class="thumbnail">--}%
                                    %{--<a href="${createLink(controller: 'project', id: frontPage.projectOfTheDay?.id, action: 'index')}">--}%
                                        %{--<img src="${frontPage.projectOfTheDay?.featuredImage}" />--}%
                                        %{--<h2>${frontPage.projectOfTheDay?.featuredLabel}</h2>--}%
                                    %{--</a>--}%
                                %{--</div>--}%
                            %{--</div>--}%

                            %{--<div class="button-nav"><a href="${grailsApplication.config.grails.serverURL}/project/index/${frontPage.projectOfTheDay?.id}" style="background-image:url(${frontPage.projectOfTheDay?.featuredImage});"><h2>${frontPage.projectOfTheDay?.featuredLabel}</h2>--}%
                            %{--</a></div>--}%

                            %{--<div class="span8">--}%
                                %{--<span class="eyebrow">${frontPage.projectOfTheDay?.featuredOwner}</span>--}%
                                %{--<h2 class="grey"><a href="${grailsApplication.config.grails.serverURL}/project/index/${frontPage.projectOfTheDay?.id}">${frontPage.projectOfTheDay?.name}</a></h2>--}%
                                %{--<p>${frontPage.projectOfTheDay?.shortDescription}</p>--}%
                                %{--<a href="${grailsApplication.config.grails.serverURL}/transcribe/index/${frontPage.projectOfTheDay?.id}" class="btn btn-small">--}%
                                    %{--Start transcribing <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_transcribe.png" width="37" height="18" alt="">--}%
                                %{--</a>--}%
                            %{--</div>--}%
                            %{--</div>--}%
                        %{--</div>--}%
                    %{--</section>--}%

                    %{--<g:if test="${featuredProjects}">--}%
                        %{--<div class="row-fluid">--}%
                            %{--<div class="span12">--}%
                                %{--<hgroup>--}%
                                    %{--<h2 class="alignleft">More expeditions</h2>--}%
                                    %{--<a href="${createLink(controller: 'project', action: 'list')}" class="btn btn-small">View all</a>--}%
                                %{--</hgroup>--}%
                            %{--</div>--}%
                        %{--</div>--}%
                        %{--<div class="row-fluid">--}%
                            %{--<div class="span12">--}%
                                %{--<ul class="thumbnails">--}%
                                    %{--<g:each in="${featuredProjects}" var="featuredProject">--}%
                                        %{--<li class="span4" style="position: relative">--}%
                                            %{--<div class="thumbnail">--}%
                                                %{--<a href="${createLink(controller: 'project', id: featuredProject.project?.id, action: 'index')}">--}%
                                                    %{--<img src="${featuredProject.project?.featuredImage}" />--}%
                                                    %{--<h2>${featuredProject.project?.featuredLabel}</h2>--}%
                                                    %{--<div class="label label-inverse">${featuredProject.percentTranscribed}%</div>--}%
                                                %{--</a>--}%
                                            %{--</div>--}%
                                        %{--</li>--}%
                                    %{--</g:each>--}%
                                %{--</ul>--}%

                            %{--</div>--}%
                        %{--</div>--}%
                    %{--</g:if>--}%
                %{--</div> <!-- col-wide -->--}%

                %{--<div class="span3">--}%
                    %{--<section id="leaderBoardSection">--}%

                    %{--</section>--}%

                    %{--<cl:isLoggedIn>--}%
                        %{--<scetion id="user-stats">--}%
                            %{--<a class="btn btn-small" href="${createLink(controller:'user', action:'notebook')}">View my notebook</a>--}%
                        %{--</scetion>--}%
                    %{--</cl:isLoggedIn>--}%

                    %{--<section id="expedition-stats">--}%
                        %{--<table>--}%
                            %{--<tr>--}%
                                %{--<td>--}%
                                    %{--<h3>Expedition stats</h3>--}%
                                %{--</td>--}%
                                %{--<td>--}%
                                    %{--<img class="pull-right" src="${resource(dir:"images/vp", file:'compassrose.png')}" />--}%
                                %{--</td>--}%
                            %{--</tr>--}%
                        %{--</table>--}%

                        %{--Calculating statistics...--}%
                    %{--</section>--}%
                    %{--<section>--}%
                        %{--<g:if test="${newsItem}">--}%
                            %{--<h3>News</h3>--}%
                            %{--<article>--}%
                                %{--<g:if test="${newsItem?.created}">--}%
                                    %{--<time datetime="${formatDate(format: "yyyy-MM-dd", date: newsItem.created)}"><g:formatDate format="dd MMM yyyy" date="${newsItem.created}"/></time>--}%
                                %{--</g:if>--}%
                                %{--<h4>--}%
                                    %{--<g:if test="${frontPage.useGlobalNewsItem == false}">--}%
                                        %{--<g:link action="show" controller="newsItem" id="${newsItem?.id}">${newsItem.title}</g:link>--}%
                                    %{--</g:if>--}%
                                    %{--<g:else>--}%
                                        %{--${newsItem.title}--}%
                                    %{--</g:else>--}%
                                %{--</h4>--}%

                                %{--<p>--}%
                                    %{--${newsItem?.shortDescription}--}%
                                    %{--<g:if test="${frontPage.useGlobalNewsItem == false}">--}%
                                        %{--<g:link controller="newsItem" action="show" id="${newsItem?.id}">Read more...</g:link>--}%
                                    %{--</g:if>--}%
                                %{--</p>--}%
                            %{--</article>--}%
                        %{--</g:if>--}%
                    %{--</section>--}%
                %{--</div>--}%
            %{--</div>--}%
        %{--</div>--}%


        %{--<r:script type="text/javascript">--}%

            %{--$(document).ready(function (e) {--}%

                %{--$.ajax("${createLink(controller: 'leaderBoard', action:'leaderBoardFragment')}").done(function (content) {--}%
                    %{--$("#leaderBoardSection").html(content);--}%
                %{--});--}%

                %{--$.ajax("${createLink(controller: 'index', action:'statsFragment')}").done(function (content) {--}%
                    %{--$("#expedition-stats").html(content);--}%
                %{--});--}%

                %{--$('#description-panes img.active').click(function () {--}%
                    %{--document.location.href = $(this).next('a').attr('href');--}%
                %{--});--}%

                %{--$('#rollovers img.active').css("cursor", "pointer").click(function () {--}%
                    %{--document.location.href = "${resource(dir:'project/index/')}" + $(this).attr('id');--}%
                %{--});--}%

            %{--});--}%


        %{--</r:script>--}%

    </body>
</html>