<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-main"/>
    <meta name="section" content="home"/>
    <title><cl:pageTitle title="Home"/></title>
    <content tag="disableBreadcrumbs">true</content>
    %{--<content tag="primaryColour">#0097d4</content>--}%
    <content tag="selectedNavItem">bvp</content>
</head>

<body>
<!-- Main jumbotron for a primary marketing message or call to action -->

<div class="a-feature home">
    <div class="container">
        <h1><g:message code="index.heading.line1" default="Decipher our collections,"/><br/><g:message code="index.heading.line2" default="discover hidden archives"/><br/><g:message code="index.heading.line3" default="and contribute to knowledge"/></h1>

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
        <h2 class="heading"><g:message code="index.whatyoudo.title" default="Join a virtual expedition of…"/></h2>

        <div class="row">
            <div class="col-sm-1 col-xs-4">
                <r:img dir="images/2.0" file="iconLabels.png" class="img-responsive"/>
            </div>

            <div class="col-sm-3 col-xs-8">
                <h3><g:message code="index.whatyoudo.specimens.title" default="Collection labels"/></h3>

                <p><g:message code="index.whatyoudo.specimens.body" default="Capture data from specimen and object labels to make it accessible for scientific and cultural research."/></p>
                <g:link controller="project" action="list" params="[mode: params.mode, q: 'tag:Specimens']">See all labels</g:link>
            </div>

            <div class="col-sm-1 col-xs-4">
                <r:img dir="images/2.0" file="iconNotes.png" class="img-responsive"/>
            </div>

            <div class="col-sm-3 col-xs-8">
                <h3><g:message code="index.whatyoudo.fieldjournals.title" default="Historical documents"/></h3>

                <p><g:message code="index.whatyoudo.fieldjournals.body" default="Transcribe text and capture data from historical documents to make them digitally accessible."/></p>
                <g:link controller="project" action="list" params="[mode: params.mode, q: 'tag:Field notes']">See all field journals</g:link>
            </div>

            <div class="col-sm-1 col-xs-4">
                <r:img dir="images/2.0" file="iconWild.png" class="img-responsive"/>
            </div>

            <div class="col-sm-3 col-xs-8">
                <h3><g:message code="index.whatyoudo.cameratraps.title" default="Images"/></h3>

                <p><g:message code="index.whatyoudo.cameratraps.title" default="Identify and tag images of animals and collection objects to support information discovery and research."/></p>
                <g:link controller="project" action="list" params="[mode: params.mode, q: 'tag:Camera traps']">See all camera traps</g:link>

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
                <g:link controller="project" action="list" params="[mode: params.mode, q: 'tag:' + potdSummary.iconLabel]"
                        class="badge"><span
                        class="glyphicon glyphicon-tag icon-flipped"></span>${potdSummary.iconLabel}</g:link><g:link
                    controller="institution" action="index" id="${frontPage.projectOfTheDay?.institutionId}"
                    class="badge"><span
                        class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${frontPage.projectOfTheDay?.institutionName}</g:link>

                <p>
                    ${raw(frontPage.projectOfTheDay?.description)}
                </p>

                <g:render template="/project/projectSummaryProgressBar" model="[projectSummary: potdSummary]" />

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
                    <g:render template="/project/projectListThumbnailView" model="[projects: featuredProjects, includeWeirdAnchorLabel: true, disablePagination: true]" />
                </div>
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