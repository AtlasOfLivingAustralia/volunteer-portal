<!doctype html>
<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <meta name="section" content="home"/>
        <title><g:message code="default.application.name" /> - Atlas of Living Australia</title>
        <style type="text/css">

           h1.bvp-heading {
                margin-top: 20px;
                margin-bottom: 20px;
                font-size: 90px;
                line-height: 90px
            }

            .bvp-byline {
                font-size: 1.6em;
                font-weight: bold;
            }

            .row-fluid .thumbnails .span4:nth-child(3n+1) {
                margin-left: 0;
            }

            .thumbnail h2 {
                /*float: right;*/
                font-size: 1.2em;
                position: absolute;
                right: 0px;
                bottom: 5px;
               	background-color: #3d464c;
               	background-image: linear-gradient(top, #3d464c, #353d43);
               	padding:6px 12px 8px 12px;
               	color: #fff;
                border-radius: 5px 0 0 5px;
            }

            .thumbnails > li {
                margin-bottom: 10px;
            }

            .thumbnail a img {
                border-radius: 5px;
                max-height: 156px;
            }

            .thumbnail {
                border: 0 none;
                box-shadow: none;
                padding: 0;
            }

            .thumbnail .label {
                position: absolute;
                top: 5px;
                left: 5px;
                background-color: #3d464c;
            }

            .thumbnail a:hover h2 {
                background-color: #df4a21;
            }

            @media (min-width: 1200px) {
                .thumbnail h2 {
                    margin-right: 15px;
                }
            }

            @media (max-width: 979px) and (min-width: 768px) {
                .thumbnail h2 {
                    font-size: 1.0em;
                }
            }

            @media (max-width: 768px) {
                .thumbnail h2 {
                    position: static;
                    top: inherit;
                    text-align: center;
                }

                .thumbnails > li {
                    margin-bottom: 20px;
                }

                .thumbnail {
                    border: 1px solid #ddd;
                    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.055);
                    padding: 4px;
                }

            }

        </style>
    </head>

    <body>
        <cl:headerContent title="${message(code:'default.application.name', default:'DigiVol')}" selectedNavItem="bvp" hideCrumbs="${true}">
            <p class="bvp-byline">Volunteers building knowledge through digitising collections</p>
        </cl:headerContent>

        <div class="container-fluid">
            <div class="row-fluid">
                <div class="span9">
                    <section>
                        <div style="margin-bottom: 10px">
                            <h2 class="orange">Virtual expedition of the day</h2>
                            <div class="row-fluid">
                            <div class="span4" style="position: relative">
                                <div class="thumbnail">
                                    <a href="${createLink(controller: 'project', id: frontPage.projectOfTheDay?.id, action: 'index')}">
                                        <img src="${frontPage.projectOfTheDay?.featuredImage}" />
                                        <h2>${frontPage.projectOfTheDay?.featuredLabel}</h2>
                                    </a>
                                </div>
                            </div>

                            %{--<div class="button-nav"><a href="${grailsApplication.config.grails.serverURL}/project/index/${frontPage.projectOfTheDay?.id}" style="background-image:url(${frontPage.projectOfTheDay?.featuredImage});"><h2>${frontPage.projectOfTheDay?.featuredLabel}</h2>--}%
                            %{--</a></div>--}%

                            <div class="span8">
                                <span class="eyebrow">${frontPage.projectOfTheDay?.featuredOwner}</span>
                                <h2 class="grey"><a href="${grailsApplication.config.grails.serverURL}/project/index/${frontPage.projectOfTheDay?.id}">${frontPage.projectOfTheDay?.name}</a></h2>
                                <p>${frontPage.projectOfTheDay?.shortDescription}</p>
                                <a href="${grailsApplication.config.grails.serverURL}/transcribe/index/${frontPage.projectOfTheDay?.id}" class="btn btn-small">
                                    Start transcribing <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_transcribe.png" width="37" height="18" alt="">
                                </a>
                            </div>
                            </div>
                        </div>
                    </section>

                    <g:if test="${featuredProjects}">
                        <div class="row-fluid">
                            <div class="span12">
                                <hgroup>
                                    <h2 class="alignleft">More expeditions</h2>
                                    <a href="${createLink(controller: 'project', action: 'list')}" class="btn btn-small">View all</a>
                                </hgroup>
                            </div>
                        </div>
                        <div class="row-fluid">
                            <div class="span12">
                                <ul class="thumbnails">
                                    <g:each in="${featuredProjects}" var="featuredProject">
                                        <li class="span4" style="position: relative">
                                            <div class="thumbnail">
                                                <a href="${createLink(controller: 'project', id: featuredProject.project?.id, action: 'index')}">
                                                    <img src="${featuredProject.project?.featuredImage}" />
                                                    <h2>${featuredProject.project?.featuredLabel}</h2>
                                                    <div class="label label-inverse">${featuredProject.percentComplete}%</div>
                                                </a>
                                            </div>
                                        </li>
                                    </g:each>
                                </ul>

                            </div>
                        </div>
                    </g:if>
                </div> <!-- col-wide -->

                <div class="span3">
                    <section id="leaderBoardSection">

                    </section>

                    <cl:isLoggedIn>
                        <scetion id="user-stats">
                            <a class="btn btn-small" href="${createLink(controller:'user', action:'myStats')}">View my tasks</a>
                        </scetion>
                    </cl:isLoggedIn>

                    <section id="expedition-stats">
                        <table>
                            <tr>
                                <td>
                                    <h3>Expedition stats</h3>
                                </td>
                                <td>
                                    <img class="pull-right" src="${resource(dir:"images/vp", file:'compassrose.png')}" />
                                </td>
                            </tr>
                        </table>

                        Calculating statistics...
                    </section>
                    <section>
                        <g:if test="${newsItem}">
                            <h3>News</h3>
                            <article>
                                <g:if test="${newsItem?.created}">
                                    <time datetime="${formatDate(format: "yyyy-MM-dd", date: newsItem.created)}"><g:formatDate format="dd MMM yyyy" date="${newsItem.created}"/></time>
                                </g:if>
                                <h4>
                                    <g:if test="${frontPage.useGlobalNewsItem == false}">
                                        <g:link action="show" controller="newsItem" id="${newsItem?.id}">${newsItem.title}</g:link>
                                    </g:if>
                                    <g:else>
                                        ${newsItem.title}
                                    </g:else>
                                </h4>

                                <p>
                                    ${newsItem?.shortDescription}
                                    <g:if test="${frontPage.useGlobalNewsItem == false}">
                                        <g:link controller="newsItem" action="show" id="${newsItem?.id}">Read more...</g:link>
                                    </g:if>
                                </p>
                            </article>
                        </g:if>
                    </section>
                </div>
            </div>
        </div>


        <r:script type="text/javascript">

            $(document).ready(function (e) {

                $.ajax("${createLink(controller: 'leaderBoard', action:'leaderBoardFragment')}").done(function (content) {
                    $("#leaderBoardSection").html(content);
                });

                $.ajax("${createLink(controller: 'index', action:'statsFragment')}").done(function (content) {
                    $("#expedition-stats").html(content);
                });

                $('#description-panes img.active').click(function () {
                    document.location.href = $(this).next('a').attr('href');
                });

                $('#rollovers img.active').css("cursor", "pointer").click(function () {
                    document.location.href = "${resource(dir:'project/index/')}" + $(this).attr('id');
                });

            });


        </r:script>

    </body>
</html>