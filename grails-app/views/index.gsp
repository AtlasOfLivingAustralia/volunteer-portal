<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-main"/>
    <meta name="section" content="home"/>
    <title><cl:pageTitle title="Home"/></title>
    <content tag="disableBreadcrumbs">true</content>
    %{--<content tag="primaryColour">#0097d4</content>--}%
</head>

<body>
<!-- Main jumbotron for a primary marketing message or call to action -->

<div class="a-feature home">
    <div class="container">
        <h1>Build knowledge &amp; <br/>communities through <br/>digitising collections</h1>

        <h2>Join our community of 1,000+ volunteers</h2>

        <div class="cta-primary">
            <a class="btn btn-primary btn-lg" href="#expeditionList" role="button">Get involved <span
                    class="glyphicon glyphicon-arrow-down"></span></a>  <a class="btn btn-lg btn-hollow"
                                                                           href="#learnMore">Learn more</a>
        </div>

        <div class="row">
            <div class="col-sm-12 image-origin">
                <p>Image by [Name] from Flickr</p>
            </div>
        </div>
    </div>

</div>
<a name="expeditionList" class="expeditionListAnchor"></a>
<section id="what-you-do" class="dark">
    <div class="container">
        <h2 class="heading">Volunteer by</h2>

        <div class="row">
            <div class="col-sm-1 col-xs-4">
                <r:img dir="images/2.0" file="iconLabels.png" class="img-responsive"/>
            </div>

            <div class="col-sm-3 col-xs-8">
                <h3>Transcribe specimen labels</h3>

                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla cursus sem nec consequat accumsan. Sed vel justo odio.</p>
                <a href="#">See all labels</a>
            </div>

            <div class="col-sm-1 col-xs-4">
                <r:img dir="images/2.0" file="iconNotes.png" class="img-responsive"/>
            </div>

            <div class="col-sm-3 col-xs-8">
                <h3>Transcribe field journals</h3>

                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla cursus sem nec consequat accumsan. Sed vel justo odio.</p>
                <a href="#">See all field journals</a>
            </div>

            <div class="col-sm-1 col-xs-4">
                <r:img dir="images/2.0" file="iconWild.png" class="img-responsive"/>
            </div>

            <div class="col-sm-3 col-xs-8">
                <h3>Identify Animals</h3>

                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla cursus sem nec consequat accumsan. Sed vel justo odio.</p>
                <a href="#">See all camera traps</a>

            </div>

        </div>

    </div>
</section>

<section id="expedition-feature">
    <div class="container">
        <h2 class="heading">Feature Expedition</h2>

        <div class="row">
            <div class="col-md-6">
                <a class="btn btn-info btn-xs label">${frontPage.projectOfTheDay?.institutionName}</a>
                <g:link controller="project" action="index" id="${frontPage.projectOfTheDay?.id}"><img
                        src="${frontPage.projectOfTheDay?.featuredImage}" class="img-responsive"></g:link>
            </div>

            <div class="col-md-6">
                <h3><g:link controller="project" action="index"
                            id="${frontPage.projectOfTheDay?.id}">${frontPage.projectOfTheDay?.featuredLabel}</g:link>
                </h3>
                <a class="badge"><span class="glyphicon glyphicon-tag icon-flipped"></span>Field notes</a><g:link
                    controller="institution" action="index" id="${frontPage.projectOfTheDay?.institutionId}"
                    class="badge"><span
                        class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${frontPage.projectOfTheDay?.institutionName}
            </g:link>

                <p>
                    ${raw(frontPage.projectOfTheDay?.description)}
                </p>

                <div class="expedition-progress">
                    <div class="progress">
                        <div class="progress-bar progress-bar-success" style="width: ${potdSummary.percentValidated}%">
                            <span class="sr-only">${potdSummary.percentValidated}% Validated (success)</span>
                        </div>

                        <div class="progress-bar progress-bar-transcribed"
                             style="width: ${potdSummary.percentTranscribed}%">
                            <span class="sr-only">${potdSummary.percentTranscribed}% Transcribed</span>
                        </div>
                    </div>

                    <div class="progress-legend">
                        <div class="row">
                            <div class="col-xs-4">
                                <b>${potdSummary.percentValidated}%</b> Validated
                            </div>

                            <div class="col-xs-4">
                                <b>${potdSummary.percentTranscribed}%</b> Transcribed
                            </div>

                            <div class="col-xs-4">
                                <b>${potdSummary.taskCount}</b> Tasks
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
                        <span class="label label-default">Default</span>
                    </div>

                    <div class="col-sm-4">
                    </div>
                </div>

                <div class="row">
                    <g:each in="${featuredProjects}" var="featuredProject">
                        <div class="col-sm-12 col-md-6">
                            <div class="thumbnail">
                                <a class="btn btn-info btn-xs label">${featuredProject.project?.institutionName}</a>
                                <g:link controller="project" action="index" id="${featuredProject.project?.id}">
                                    <img src="${featuredProject.project?.featuredImage}" class="img-responsive">
                                </g:link>

                                <div class="caption">
                                    <h4><g:link controller="project" action="index"
                                                id="${featuredProject.project?.id}">${featuredProject.project?.featuredLabel}</g:link></h4>

                                    <a class="badge"><span class="glyphicon glyphicon-tag icon-flipped"></span>Speciman
                                    </a><g:link controller="institution" action="index"
                                                id="${featuredProject.project?.institutionId}" class="badge"><span
                                            class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${featuredProject.project?.institutionName}
                                </g:link>

                                    <p>${featuredProject.project?.shortDescription}</p>

                                    <div class="expedition-progress">
                                        <div class="progress">
                                            <div class="progress-bar progress-bar-success"
                                                 style="width: ${featuredProject.percentValidated}%">
                                                <span class="sr-only">${featuredProject.percentValidated}% Validated (success)</span>
                                            </div>

                                            <div class="progress-bar progress-bar-transcribed"
                                                 style="width: ${featuredProject.percentTranscribed}%">
                                                <span class="sr-only">${featuredProject.percentTranscribed}% Transcribed</span>
                                            </div>
                                        </div>

                                        <div class="progress-legend">
                                            <div class="row">

                                                <div class="col-xs-4">
                                                    <b>${featuredProject.percentValidated}%</b> Validated
                                                </div>

                                                <div class="col-xs-4">
                                                    <b>${featuredProject.percentTranscribed}%</b> Transcribed
                                                </div>

                                                <div class="col-xs-4">
                                                    <b>${featuredProject.transcriberCount}</b> Volunteers
                                                </div>

                                            </div>
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </g:each>
                </div><!--/row-->
            </div>

            <div class="col-sm-4">

                <g:render template="/leaderBoard/stats"/>

            </div>
        </div>
    </div>
</section>
<a name="learnMore"></a>

</body>
</html>