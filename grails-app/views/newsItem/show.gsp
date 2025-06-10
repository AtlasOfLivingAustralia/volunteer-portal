<%@ page import="au.org.ala.volunteer.DateConstants" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
        <title><cl:pageTitle title="${message(code: 'newsItem.item.title', args: [newsItem?.title])}"/></title>

        <asset:stylesheet src="notebook-reset.css"/>
        <asset:stylesheet src="news.scss"/>
        <style>
        <cl:ifNewsItemHasThumb newsItemId="${newsItem.id}">
            .newsItem__item {
                min-height: 200px;
            }
        </cl:ifNewsItemHasThumb>
        </style>
    </head>
    <body>
    <cl:headerContent title="${newsItem?.title}" selectedNavItem="bvp" hideTitle="${true}">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'newsItem', action: 'index'), label: message(code: 'newsItem.list.title', default: 'News')],
            ]
        %>
        <h1>${newsItem?.title}</h1>
    </cl:headerContent>
    <main>
        <section class="news-item-section">
            <ol>
                <li class="newsItem__item">
                    <article>
                        <div class="news-item__header">
                            <h2 class="news-item__heading">${newsItem?.createdBy?.displayName}</h2>
                            <time class="news-item__date-time"><g:formatDate date="${newsItem?.dateCreated}" format="${DateConstants.DATE_FORMAT_SHORT}" /></time>
                        </div>
                        <div class="news-item__text">
                            <cl:ifNewsItemHasThumb newsItemId="${newsItem.id}">
                                <img src="<cl:newsItemThumbUrl newsItemId="${newsItem.id}"/>" class="img-responsive news-image" alt="News Item Thumbnail" style="max-width: 200px; max-height: 200px;"/>
                            </cl:ifNewsItemHasThumb>
                            ${raw(newsItem?.content)}
                        </div>
                        <div class="news-item__footer">
                            <g:if test="${newsItem?.topic}">
                                <g:link controller="forum" action="viewForumTopic" id="${newsItem?.topic.id}">
                                    <g:message code="index.news.topic.linkLabel" />
                                </g:link>
                            </g:if>
                            <g:else>
                                <g:link controller="forum" action="addForumTopic" params='[title: "${newsItem?.title}", linkToNewsItem: newsItem?.id]'>
                                    <g:message code="index.news.topic.linkLabel" />
                                </g:link>
                            </g:else>
                        </div>
                    </article>
                </li>
            </ol>
        </section>

        <section class="other-news-section">
            <h2 class="heading">Other news</h2>
        </section>
        <section class="featured-news-section">
            <dl class="featured-news-list">
                <g:if test="${featuredNewsItems}">
                    <g:each in="${featuredNewsItems}" var="featuredNewsItem">
                        <div class="featured-news-list__card news-item-other__card">
                            <dt><g:link controller="newsItem" action="show" params="${[id: featuredNewsItem.id]}">${featuredNewsItem.title}</g:link></dt>
                            <dd class="featured-news-list__news-excerpt">
                                <g:link controller="newsItem" action="show" params="${[id: featuredNewsItem.id]}">
                                    <g:set var="sanitisedContent" value="${featuredNewsItem.content.replaceAll("<[^>]*>", "")}"/>

                                    <p>${sanitisedContent.length() > 100 ? sanitisedContent.substring(0, 100) : sanitisedContent}...</p>
                                    <span class="featured-news-list__author-label">
                                        ${featuredNewsItem.createdBy.displayName}<br />
                                        <g:formatDate date="${featuredNewsItem.dateCreated}" format="${DateConstants.DATE_FORMAT_SHORT}" />
                                    </span>
                                </g:link>
                            </dd>
                        </div>
                    </g:each>
                </g:if>
            </dl>
        </section>
    </main>
<asset:script type="text/javascript">
jQuery(function($) {

    $('.news-image').on('click', function(e) {
        e.preventDefault();

        bvp.showModal({
            url:"${createLink(action: 'viewNewsItemImageFragment', id: newsItem?.id)}"
        });
    });

});
</asset:script>
    </body>
</html>
