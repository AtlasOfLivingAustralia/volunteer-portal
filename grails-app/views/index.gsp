<%@ page import="au.org.ala.volunteer.FrontPage" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="digivol-main"/>
    <meta name="section" content="home"/>
    <title><cl:pageTitle title="Home"/></title>
    <content tag="disableBreadcrumbs">true</content>
    <content tag="selectedNavItem">bvp</content>
    <asset:stylesheet src="digivol-image-resize.css" />
    <g:set var="frontPage" value="${FrontPage.instance()}" />
    <asset:script type="text/javascript">

        $(document).ready(function () {
            $('#parent').readmore({
              speed: 75,
              lessLink: '<a href="#">Read less</a>',
              moreLink: '<a href="#">Read More...</a>'

            });
        });
    </asset:script>
    <style>
        .news-image {
            float: right;
            margin-left: 20px;
        }

        .news-item-more {
            margin-top: 0.8rem;
        }
    </style>
</head>
<body>
<div class="a-feature home"
     style="${frontPage.heroImage ? "background-image: url('${grailsApplication.config.getProperty('server.url', String)}/${grailsApplication.config.getProperty('images.urlPrefix', String)}/hero/${frontPage.heroImage}');" : ''}">
    <div class="container">
        <h1><g:message code="index.heading.line1" /><br/><g:message code="index.heading.line2"/><br/><g:message code="index.heading.line3"/></h1>

        <h2><g:message code="index.subheading" /></h2>

        <div class="cta-primary">
            <a class="btn btn-primary btn-lg" href="#expeditionList" role="button"><g:message code="index.cta.getInvolved" /> <span
                    class="glyphicon glyphicon-arrow-down"></span></a>  <a class="btn btn-lg btn-hollow"
                                                                           href="#learnMore"><g:message code="index.cta.learnMore" /></a>
        </div>

        <div class="row">
            <div class="col-sm-12 image-origin">
                <p><g:message code="image.attribution.prefix" /> <g:if test="${frontPage.heroImageAttribution}">${frontPage.heroImageAttribution}</g:if><g:else><g:message code="index.hero.attribution" /></g:else></p>
            </div>
        </div>
    </div>

</div>
<a name="expeditionList" class="expeditionListAnchor"></a>
<section id="what-you-do" class="dark">
    <div class="container">
        <h2 class="heading"><g:message code="index.whatyoudo.title" /></h2>

        <div class="row">
            <div class="col-sm-1 col-xs-4">
                <asset:image src="iconLabels.png" class="img-responsive"/>
            </div>

            <div class="col-sm-3 col-xs-8">
                <h3><g:message code="index.whatyoudo.specimens.title" /></h3>

                <p><g:message code="index.whatyoudo.specimens.body" /></p>
                <g:link controller="project" action="list" params="[mode: params.mode, tag: 'specimens']"><g:message code="index.whatyoudo.specimens.linkLabel" /></g:link>
            </div>

            <div class="col-sm-1 col-xs-4">
                <asset:image src="iconNotes.png" class="img-responsive"/>
            </div>

            <div class="col-sm-3 col-xs-8">
                <h3><g:message code="index.whatyoudo.fieldjournals.title" /></h3>

                <p><g:message code="index.whatyoudo.fieldjournals.body" /></p>
                <g:link controller="project" action="list" params="[mode: params.mode, tag: 'fieldnotes']"><g:message code="index.whatyoudo.fieldjournals.linkLabel" /></g:link>
            </div>

            <div class="col-sm-1 col-xs-4">
                <asset:image src="iconWild.png" class="img-responsive"/>
            </div>

            <div class="col-sm-3 col-xs-8">
                <h3><g:message code="index.whatyoudo.cameratraps.title" /></h3>

                <p><g:message code="index.whatyoudo.cameratraps.body" /></p>
                <g:link mapping='landingPage' params="[shortUrl: 'wildlife-spotter']"><g:message code="index.whatyoudo.cameratraps.linkLabel" /></g:link>

            </div>

        </div>

    </div>
</section>

<g:if test="${newsItem}">
<section id="latest-news-item">
    <div class="container">
        <h2 class="heading"><g:message code="index.news.heading" /></h2>

        <div class="row">
            <div class="col-md-12">
                <h3><g:link controller="newsItem" action="show" id="${newsItem.id}">${newsItem.title}</g:link></h3>
                <div id="news-parent">
                    <cl:ifNewsItemHasThumb newsItemId="${newsItem.id}">
                        <g:link controller="newsItem" action="show" id="${newsItem.id}">
                            <img src="<cl:newsItemThumbUrl newsItemId="${newsItem.id}"/>" class="img-responsive news-image"
                                 alt="News Item Thumbnail" style="max-width: 200px; max-height: 200px;"/>
                        </g:link>
                    </cl:ifNewsItemHasThumb>
                    <g:set var="newsItemUrl" value="${createLink(controller: 'newsItem', action: 'show', id: newsItem.id)}"/>
                    ${raw(newsItem.truncateContent(200).replace('[linktag]', "<br /><a href='${newsItemUrl}' class='btn btn-hollow grey btn-sm news-item-more'>Read more...</a>"))}
                </div>
                <div class="index-news-nav">
                    <div class="index-news__archive-link">
                        <g:link controller="newsItem" action="index">View other DigiVol news</g:link>
                    </div>
                    <div class="index-news__discuss-link">
                        <g:if test="${newsItem.topic}">
                            <g:link controller="forum" action="viewForumTopic" id="${newsItem.topic.id}">
                                <g:message code="index.news.topic.linkLabel" />
                            </g:link>
                        </g:if>
                        <g:else>
                            <g:link controller="forum" action="addForumTopic" params='[title: "${newsItem.title}", linkToNewsItem: newsItem.id]'>
                                <g:message code="index.news.topic.linkLabel" />
                            </g:link>
                        </g:else>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
</g:if>

<section id="expedition-feature">
    <div class="container">
        <h2 class="heading"><g:message code="index.feature.heading" /></h2>

        <div class="row">
            <div class="col-md-6">
                <g:link controller="project" action="index" id="${frontPage.projectOfTheDay?.id}">
                    <cl:featuredImage project="${frontPage.projectOfTheDay}"
                                      preLoad="true"
                                      class="img-responsive cropme featured-exp-img"
                                      style="width:100%;height:312px;"
                                      dataErrorUrl="${resource(file: '/banners/default-expedition-large.jpg')}" />

                </g:link>
            </div>

            <div class="col-md-6">
                <h3><g:link controller="project" action="index"
                            id="${frontPage.projectOfTheDay?.id}">${frontPage.projectOfTheDay?.featuredLabel}</g:link>
                </h3>
                <g:link controller="project" action="list" params="[mode: params.mode, tag: potdSummary.iconLabel]"
                        class="not-a-badge"><span
                        class="glyphicon glyphicon-tag icon-flipped"></span>${potdSummary.iconLabel}</g:link><g:link
                    controller="institution" action="index" id="${frontPage.projectOfTheDay?.institutionId}"
                    class="not-a-badge"><span
                        class="glyphicon glyphicon glyphicon-bookmark icon-flipped"></span>${frontPage.projectOfTheDay?.institutionName}</g:link>

                <div id="parent">
                    ${raw(frontPage.projectOfTheDay?.description)}
                </div>

                <div style="margin-top: 10px">
                    <g:render template="/project/projectSummaryProgressBar" model="[projectSummary: potdSummary]" />
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
                            <g:message code="index.more.heading" />
                        </h2>
                    </div>

                    <div class="col-sm-4">
                    </div>
                </div>

                <div class="row">
                    <g:render template="/project/projectListThumbnailView" model="[projects: featuredProjects, disablePagination: true]" />
                </div>
            </div>

            <div class="col-sm-4">
                <g:render template="/leaderBoard/stats" model="[maxContributors: frontPage.numberOfContributors ]"/>
            </div>
        </div>
    </div>
</section>
<a name="learnMore"></a>
<asset:javascript src="digivol-image-resize.js" asset-defer="" />
<asset:javascript src="readmore.js" asset-defer=""/>
</body>
</html>