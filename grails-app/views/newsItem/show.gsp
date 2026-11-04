<%@ page import="au.org.ala.volunteer.DateConstants" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
        <content tag="pageType">news</content>
        <title><cl:pageTitle title="${message(code: 'newsItem.item.title', args: [newsItem?.title])}"/></title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.2/font/bootstrap-icons.min.css">
    </head>
    <body class="news">
    <cl:headerContent title="${message(code: 'newsItem.item.label')}" selectedNavItem="bvp" hideTitle="${true}">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'newsItem', action: 'index'), label: message(code: 'newsItem.list.title', default: 'News')]
            ]
        %>

        <div class="container mt-2 mb-3" style="max-width: 860px;">
            <nav class="mb-4">
                <a href="${createLink(controller: 'newsItem', action: 'index')}" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-2">
                    <i class="bi bi-arrow-left"></i> Back to News
                </a>
            </nav>

            <div class="mb-4 border-bottom pb-4">
                <h1 class="h2 fw-bold text-body-emphasis mb-3">${newsItem?.title}</h1>

                <div class="d-flex align-items-center gap-3 text-muted small">
                    <div class="d-flex align-items-center gap-2">
                        <cl:gravatarImage user="${newsItem?.createdBy}" size="32" alt="Author Gravatar"/>
                        <span class="fw-semibold text-body">${newsItem?.createdBy?.displayName}</span>
                        <span class="text-muted small">•</span>
                        <time class="text-muted small" datetime="<g:formatDate date="${newsItem?.dateCreated}" format="${DateConstants.DATE_FORMAT_SHORT}" />">
                            <g:formatDate date="${newsItem?.dateCreated}" format="${DateConstants.DATE_FORMAT_SHORT}" />
                        </time>
                    </div>
                </div>
            </div>
        </div>
    </cl:headerContent>

    <main>
        <div class="container" style="max-width: 860px;">
            <article class="bg-white">

                <cl:ifNewsItemHasThumb newsItemId="${newsItem.id}">
                <!-- Image Thumbnail / Media Callout -->
                <figure class="figure mb-4 w-100">
                    <div class="card border-0 bg-light overflow-hidden shadow-sm">
                        <div class="row g-0 align-items-center">
                            <div class="col-md-5">
                                <img src="<cl:newsItemThumbUrl newsItemId="${newsItem.id}"/>"
                                     class="img-fluid object-fit-cover rounded-start news-image pointer" alt="${newsItem?.imageCaption}"
                                     aria-label="${newsItem?.imageCaption}">
                                <span class="position-absolute bottom-0 start-0 m-2 badge bg-dark bg-opacity-75 d-flex align-items-center gap-1 pointer news-image">
                                    <i class="bi bi-zoom-in"></i> View Full Image
                                </span>
                            </div>
                            <div class="col-md-7">
                                <div class="card-body">
                                    <figcaption class="figure-caption mb-0">
                                        <strong class="d-block text-body mb-1">Attached Image</strong>
                                        ${newsItem?.imageCaption}
                                    </figcaption>
                                </div>
                            </div>
                        </div>
                    </div>
                </figure>
                </cl:ifNewsItemHasThumb>

                <!-- Main Content Body -->
                <div class="article-body fs-6 text-secondary lh-lg mb-5">
                    <cl:newsItemContentWithLeadText newsItemId="${newsItem.id}" class="fs-5 mb-4"/>
                </div>

                <!-- Forum Link Banner / CTA -->
                <div class="card border-0 bg-body-tertiary shadow-sm mb-5">
                    <div class="card-body p-4 d-flex flex-column flex-sm-row justify-content-between align-items-sm-center gap-3">
                        <div>
                            <h5 class="fw-bold text-body mb-1 d-flex align-items-center gap-2">
                                <i class="bi bi-chat-square-text-fill text-primary"></i> Join the Discussion
                            </h5>
                            <p class="text-muted small mb-0">Have feedback or questions about this update? Share your thoughts on the forum.</p>
                        </div>
                        <g:if test="${newsItem?.topic}">
                            <g:link controller="forum" action="viewForumTopic" id="${newsItem?.topic.id}" class="btn btn-sm btn-primary text-nowrap d-inline-flex align-items-center gap-2">
                                <g:message code="index.news.topic.linkLabel" />
                                <i class="bi bi-box-arrow-up-right small"></i>
                            </g:link>
                        </g:if>
                        <g:else>
                            <g:link controller="forum" action="addForumTopic" params='[title: "${newsItem?.title}", linkToNewsItem: newsItem?.id]' class="btn btn-sm btn-primary text-nowrap d-inline-flex align-items-center gap-2">
                                <g:message code="index.news.topic.linkLabel" />
                                <i class="bi bi-box-arrow-up-right small"></i>
                            </g:link>
                        </g:else>

                    </div>
                </div>

            </article>

            <!-- Article Footer / Navigation -->
            <footer class="d-flex justify-content-between align-items-center border-top pt-4">
                <cl:previousNewsItem newsItemId="${newsItem?.id}" class="btn btn-link text-decoration-none text-secondary p-0">
                    <i class="bi bi-chevron-left me-1"></i> Previous Item
                </cl:previousNewsItem>
                <cl:nextNewsItem newsItemId="${newsItem?.id}" class="btn btn-link text-decoration-none text-secondary p-0">
                    Next Item <i class="bi bi-chevron-right ms-1"></i>
                </cl:nextNewsItem>
            </footer>
        </div>
    </main>

<asset:script type="text/javascript">

document.addEventListener('DOMContentLoaded', function () {
    // Find each element and add a click event listener to it
    const newsImageElements = document.querySelectorAll('.news-image');
    newsImageElements.forEach(function(newsImageElement) {
        newsImageElement.addEventListener('click', function (e) {
            e.preventDefault();
            bvp.showModal({
                url: "${createLink(action: 'viewNewsItemImageFragment', id: newsItem?.id)}",
                title: 'DigiVol News',
                size: 'large'
            });
        });
    });

});


</asset:script>
</body>
</html>
