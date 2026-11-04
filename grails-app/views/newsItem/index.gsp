<%@ page import="au.org.ala.volunteer.DateConstants" contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <title><cl:pageTitle title="${message(code: 'newsItem.list.title')}"/></title>
    <content tag="pageType">news</content>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.2/font/bootstrap-icons.min.css">
    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="news.scss"/>
</head>
<body class="news">
<cl:headerContent title="${message(code: 'newsItem.list.title')}" hideTitle="true" selectedNavItem="bvp">

    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4 gap-3">
        <h1 class="h2 mb-0 fw-bold">${message(code: 'newsItem.list.title')}</h1>
        <form class="d-flex gap-2 col-12 col-md-5">
            <div class="input-group">
                <span class="input-group-text bg-white border-end-0">
                    <i class="bi bi-search text-muted"></i>
                </span>
                <input type="text" id="searchbox" class="form-control border-start-0 ps-0" placeholder="Search by keyword...">
                <label class="visually-hidden" for="searchbox">Search by keyword</label>
            </div>
            <button type="reset" id="reset-button" class="btn btn-outline-secondary">Reset</button>
        </form>
    </div>

</cl:headerContent>

<main>
    <div class="container">

        <!-- Featured News Hero Banner -->
        <g:if test="${featuredNewsItem && !params.q}">
        <div class="card border-0 bg-primary-subtle text-primary-emphasis mb-5 shadow-sm overflow-hidden">
            <div class="card-body p-4 p-md-5">
                <div class="d-flex align-items-center gap-2 mb-2">
                    <span class="badge bg-primary rounded-pill">Latest News</span>
                    <small class="text-secondary fw-semibold">${featuredNewsItem.dateCreated.format('dd/MM/yyyy')}</small>
                </div>
                <div class="position-absolute top-0 end-0 m-2">
                    <img src="<cl:newsItemThumbUrl newsItemId="${featuredNewsItem.id}"/>" class="img-thumbnail img-fluid shadow-sm" alt="News Item Thumbnail" style="max-width: 200px; max-height: 200px;"/>
                </div>
                <h2 class="card-title h3 fw-bold mb-3">
                    <g:link controller="newsItem" action="show" params="${[id: featuredNewsItem.id]}" class="text-decoration-none text-reset stretched-link">${featuredNewsItem.title}</g:link>
                </h2>
                <p class="card-text lead fs-6 text-secondary mb-4 col-lg-9">
                    <g:set var="sanitisedContent" value="${featuredNewsItem.content.replaceAll("<[^>]*>", "")}"/>
                    ${sanitisedContent.length() > 100 ? sanitisedContent.substring(0, 100) : sanitisedContent}...
                </p>
                <div class="d-flex align-items-center gap-2 text-muted small">
                    <i class="bi bi-person-circle"></i>
                    <span>${featuredNewsItem.createdBy.displayName}</span>
                </div>
            </div>
        </div>
        </g:if>

        <!-- News List Feed -->
        <div id="newsfeed" class="d-flex justify-content-between align-items-center mb-3">
            <h3 class="h5 fw-bold mb-0 col-8">Previous Updates</h3>
            <!-- Optional Sort / Filter -->
            <select id="news-sort" name="news-sort" class="form-select form-select-sm col-3 w-auto" aria-label="Sort news items">
                <option value="dateCreated|desc" selected>Date posted (newest first)</option>
                <option value="dateCreated|asc">Date posted (oldest first)</option>
                <option value="title|asc">Title (A-Z)</option>
                <option value="title|desc">Title (Z-A)</option>
                <option value="author|asc">Author (A-Z)</option>
                <option value="author|desc">Author (Z-A)</option>
            </select>
        </div>

        <div class="list-group list-group-flush border-top border-bottom mb-4">
            <g:each in="${newsItemList}" var="newsItem">
            <a href="${createLink(controller: 'newsItem', action: 'show', params: [id: newsItem.id])}"
               class="list-group-item list-group-item-action py-3 px-2 d-flex justify-content-between align-items-center gap-3">
                <div class="me-auto col-8">
                    <h6 class="mb-1 fw-semibold text-body">${newsItem.title}</h6>
                    <p class="mb-0 text-muted small text-truncate" style="max-width: 500px;">
                        <g:set var="itemSanitisedContent" value="${newsItem.content.replaceAll("<[^>]*>", "")}"/>
                        ${itemSanitisedContent.length() > 100 ? itemSanitisedContent.substring(0, 100) : itemSanitisedContent}...
                    </p>
                </div>
                <div class="text-end text-nowrap text-muted small col-3">
                    <div>${newsItem.createdBy.displayName}</div>
                    <div class="text-secondary opacity-75">${newsItem.dateCreated.format('dd/MM/yyyy')}</div>
                </div>
            </a>
            </g:each>
        </div>

        <cl:paginate total="${newsItemCount ?: 0}" action="index" params="${params}" max="15"/>
    </div>
</main>

<asset:script type="text/javascript">
    document.addEventListener('DOMContentLoaded', function () {
        const persistParams = ['q', 'sort', 'order'];
        const searchBox = document.getElementById('searchbox');
        const sortSelect = document.getElementById('news-sort');
        const resetButton = document.getElementById('reset-button');

        searchBox.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                doSearch();
            }
        });

        sortSelect.addEventListener('change', function () {
            const [sort, order] = sortSelect.value.split('|');
            window.location = bvp.getNewLink("${createLink(controller: 'newsItem', action: 'index')}", window.location.search, persistParams, {sort: sort, order: order});
        });

        resetButton.addEventListener('click', function () {
            window.location = bvp.getNewLink("${createLink(controller: 'newsItem', action: 'index')}", window.location.search, persistParams, {q: ''});
        });

        function doSearch() {
            const q = encodeURIComponent(searchBox.value);
            window.location = bvp.getNewLink("${createLink(controller: 'newsItem', action: 'index')}", window.location.search, persistParams, {q: q});
        }

        function hydrateSortSelect() {
            const urlParams = new URLSearchParams(window.location.search);
            const sortParam = urlParams.get('sort');
            const orderParam = urlParams.get('order');

            if (sortParam && orderParam) {
                sortSelect.value = sortParam + "|" + orderParam;
            }
        }

        hydrateSortSelect();
    });
</asset:script>

</body>
</html>