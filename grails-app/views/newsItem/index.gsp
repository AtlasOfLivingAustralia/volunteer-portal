<%@ page import="au.org.ala.volunteer.DateConstants" contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <title><cl:pageTitle title="${message(code: 'newsItem.list.title')}"/></title>

    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="news.scss"/>
</head>
<body>
<cl:headerContent title="${message(code: 'newsItem.list.title')}" selectedNavItem="bvp">

</cl:headerContent>
<main>
    <section class="news-nav-section">
        <div class="news-nav-row">
            <nav class="news-filter-nav filter-nav--mt-6">
                <div class="news-nav-header">
                    <div class="filter-nav__label">Search by keyword:</div>
                    <input type="text" name="searchbox" id="searchbox" value="${params.q}" class="nav-dropdown" />
                </div>
            </nav>
            <nav class="news-filter-nav filter-nav--mt-6">
                <div class="news-nav-header">
                    <a class="pill pill--reset"
                       href="${createLink(controller: 'newsItem', action: 'index')}">Reset</a>
                </div>
            </nav>
        </div>
    </section>
    <section class="featured-news-section">
        <dl class="featured-news-list">
        <g:if test="${featuredNewsItems && !params.q}">
            <g:each in="${featuredNewsItems}" var="featuredNewsItem">
            <div class="featured-news-list__card">
                <dt><a href="#">${featuredNewsItem.title}</a></dt>
                <dd class="featured-news-list__news-excerpt">
                    <a href="#">
                        <p>${featuredNewsItem.content.substring(0, 100).replaceAll("<[^>]*>", "")}...</p>
                        <span class="featured-news-list__author-label">
                            ${featuredNewsItem.createdBy.displayName}<br />
                            <g:formatDate date="${featuredNewsItem.dateCreated}" format="${DateConstants.DATE_FORMAT_SHORT}" />
                        </span>
                    </a>
                </dd>
            </div>
            </g:each>
        </g:if>
        </dl>
    </section>
    <section class="news-nav-section">
        <div class="news-nav-row">
            <div class="news-pagination-nav">
                <div class="news-nav-header news-nav-pagination">
                    <g:paginate total="${newsItemCount ?: 0}" action="index" params="${params}" class="pagination-list" max="15"/>
                </div>
            </div>
        </div>
    </section>
    <section class="news-table-section">
        <table class="news-item-table">
            <thead>
            <tr>
                <g:sortableColumn property="title" class="td--5/12"
                                  title="${message(code: 'newsItem.title.label', default: 'Title')}" params="${params}"/>
                <g:sortableColumn property="createdBy" class="td--1/12"
                                  title="${message(code: 'newsItem.createdBy.label', default: 'Posted by')}" params="${params}"/>
                <g:sortableColumn property="dateCreated" class="td--1/12 lg:td--text-right"
                                  title="${message(code: 'newsItem.dateCreated.label', default: 'Date posted')}" params="${params}"/>
            </tr>
            </thead>
            <tbody>
            <g:each in="${newsItemList}" var="newsItem">
            <tr>
                <th class="td--order-1 news-item-title"><g:link controller="newsItem" action="show" params="${[id: newsItem.id]}">${newsItem.title}</g:link></th>
                <td class="td--order-2">${newsItem.createdBy.displayName}</td>
                <td class="td--order-3 lg:td--text-right"><g:formatDate date="${newsItem.dateCreated}" format="${DateConstants.DATE_FORMAT_SHORT}" /></td>
            </tr>
            </g:each>
            </tbody>
        </table>
    </section>
</main>

<asset:script type="text/javascript">
    $(document).ready(function() {
        $("#searchbox").keydown(function(e) {
            if (e.keyCode === 13) {
                doSearch();
            }
        });

        function doSearch() {
            let q = encodeURIComponent($('#searchbox').val());
            window.location = getLink("${createLink(controller: 'newsItem', action: 'index')}", "q", q);
        }

        function getLink(url, replaceParam, replaceVar) {
            const params = new URLSearchParams(window.location.search);
            let searchQuery = params.get('q');

            let goUrl = "";

            if (searchQuery || replaceParam === 'q') {
                goUrl += (goUrl.length === 0) ? "?" : "&";
                if (replaceParam === 'q') goUrl += "q=" + replaceVar;
                else goUrl += "q=" + searchQuery;
            }

            return url + goUrl;
        }

    });

</asset:script>

</body>
</html>