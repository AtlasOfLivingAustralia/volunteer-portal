<!doctype html>
<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <meta name="section" content="home"/>
        <title>Volunteer Portal - Atlas of Living Australia</title>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.frontpageheading.label', default:'Biodiversity Volunteer Portal')}" selectedNavItem="bvp">
            <p style="font-size: 1.2em">Helping to understand, manage and conserve biodiversity<br>through community based capture of archival and natural history collections</p>
        </cl:headerContent>

        <div class="container-fluid">
            <div class="row-fluid">
                <div class="span9">
                    <section>
                        <div style="">
                            <h2 class="orange">Virtual expedition of the day</h2>
                            <div class="button-nav"><a href="${grailsApplication.config.grails.serverURL}/project/index/${frontPage.projectOfTheDay?.id}" style="background-image:url(${frontPage.projectOfTheDay?.featuredImage});"><h2>${frontPage.projectOfTheDay?.featuredLabel}</h2>
                            </a></div>

                            <div>
                                <span class="eyebrow">${frontPage.projectOfTheDay?.featuredOwner}</span>

                                <h2 class="grey"><a href="${grailsApplication.config.grails.serverURL}/project/index/${frontPage.projectOfTheDay?.id}">${frontPage.projectOfTheDay?.name}</a></h2>

                                <p>${frontPage.projectOfTheDay?.shortDescription}</p>
                                <a href="${grailsApplication.config.grails.serverURL}/transcribe/index/${frontPage.projectOfTheDay?.id}" class="btn btn-small">
                                    Start transcribing <img src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_transcribe.png" width="37" height="18" alt="">
                                </a>
                            </div>
                        </div>
                    </section>

                    <section class="featuredExpeditions">
                        <div class="row-fluid">
                            <div class="span12">
                                <hgroup>
                                    <h2 class="alignleft">More expeditions</h2>
                                    <a href="${createLink(controller: 'project', action: 'list')}" class="btn btn-small pull-right">View all</a>
                                </hgroup>
                            </div>
                        </div>
                        <div class="row-fluid">
                            <div class="span12">
                                <nav>
                                    <ol>
                                        <li>
                                            <a href="${createLink(controller: 'project', id: frontPage.featuredProject1?.id, action: 'index')}" style="background-image:url(${frontPage.featuredProject1?.featuredImage});">
                                                <h2>${frontPage.featuredProject1?.featuredLabel}</h2>
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${createLink(controller: 'project', id: frontPage.featuredProject2?.id, action: 'index')}" style="background-image:url(${frontPage.featuredProject2?.featuredImage});">
                                                <h2>${frontPage.featuredProject2?.featuredLabel}</h2>
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${createLink(controller: 'project', id: frontPage.featuredProject3?.id, action: 'index')}" style="background-image:url(${frontPage.featuredProject3?.featuredImage});">
                                                <h2>${frontPage.featuredProject3?.featuredLabel}</h2>
                                            </a>
                                        </li>
                                        <g:if test="${frontPage.featuredProject4}">
                                            <li>
                                                <a href="${createLink(controller: 'project', id: frontPage.featuredProject4?.id, action: 'index')}" style="background-image:url(${frontPage.featuredProject4?.featuredImage});">
                                                    <h2>${frontPage.featuredProject4?.featuredLabel}</h2>
                                                </a>
                                            </li>
                                        </g:if>
                                        <g:if test="${frontPage.featuredProject5}">
                                            <li>
                                                <a href="${createLink(controller: 'project', id: frontPage.featuredProject5?.id, action: 'index')}" style="background-image:url(${frontPage.featuredProject5?.featuredImage});">
                                                    <h2>${frontPage.featuredProject5?.featuredLabel}</h2>
                                                </a>
                                            </li>
                                        </g:if>
                                        <g:if test="${frontPage.featuredProject6}">
                                            <li>
                                                <a href="${createLink(controller: 'project', id: frontPage.featuredProject6?.id, action: 'index')}" style="background-image:url(${frontPage.featuredProject6?.featuredImage});">
                                                    <h2>${frontPage.featuredProject6?.featuredLabel}</h2>
                                                </a>
                                            </li>
                                        </g:if>
                                    </ol>
                                </nav>
                            </div>
                        </div>
                    </section>
                </div> <!-- col-wide -->

                <div class="span3">
                    <section id="leaderBoardSection">

                    </section>



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
                            <h2>News</h2>
                            <article>
                                <g:if test="${newsItem?.created}">
                                    <time datetime="${formatDate(format: "yyyy-MM-dd", date: newsItem.created)}"><g:formatDate format="dd MMM yyyy" date="${newsItem.created}"/></time>
                                </g:if>
                                <h3>
                                    <g:if test="${frontPage.useGlobalNewsItem == false}">
                                        <g:link action="show" controller="newsItem" id="${newsItem?.id}">${newsItem.title}</g:link>
                                    </g:if>
                                    <g:else>
                                        ${newsItem.title}
                                    </g:else>
                                </h3>

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
            <cl:isLoggedIn>
                <div class="row-fluid">
                    <div class="span9">
                        <g:link controller="admin" action="index" style="color:#DDDDDD;">Admin</g:link>
                    </div>
                </div>
            </cl:isLoggedIn>
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