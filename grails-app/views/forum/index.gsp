<%@ page import="au.org.ala.volunteer.DateConstants; au.org.ala.volunteer.User; au.org.ala.volunteer.ForumTopicType; au.org.ala.volunteer.ForumTopic" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="Forum"/></title>

    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="forum-2.scss"/>
</head>
<body>

<cl:headerContent title="${message(code: 'default.forum.label', default: 'DigiVol Forum')}" selectedNavItem="forum">

    <nav class="forum-nav">
        <ul class="forum-nav__list">
            <li class="forum-nav__list-item"><g:link controller="forum" action="index">All forum posts</g:link></li>
            <li class="forum-nav__list-item">|</li>
            <li class="forum-nav__list-item"><g:link controller="forum" action="index" params="[watched: 'true']">My watched topics</g:link></li>
        </ul>
    </nav>

</cl:headerContent>

<main>
    <!-- Nav section -->
    <section class="forum-nav-section">
        <!-- Row 1, Filter and Pagination -->
        <div class="forum-nav-row">

            <nav class="forum-filter-nav filter-nav--mt-6">
                <div class="forum-nav-header">
                    <div class="filter-nav__label">Filter by:</div>
                    <ul>
                        <g:set var="queryString" value="${params}" />
                        <li class="filter-nav__list-item">
                        <a href="#" data-topic-type="all" class="filter-topic-link"><span class="pill pill--bg-${(!params.filter) ? "black" : "grey"}">All types</span></a>
%{--                            <g:link controller="forum" action="index"><span class="pill pill--bg-${(!params.filter) ? "black" : "grey"}">All</span></g:link>--}%
                        </li>
                        <li class="filter-nav__list-item">
                            <a href="#" data-topic-type="question" class="filter-topic-link"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('question')) ? "black" : "question"}" title="Question Topics">Question</span></a>
%{--                            <g:link controller="forum" action="index" params="${[filter: 'question']}"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('question')) ? "black" : "question"}" title="Question Topics">Question</span></g:link>--}%
                        </li>
                        <li class="filter-nav__list-item">
                            <a href="#" data-topic-type="answered" class="filter-topic-link"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('answered')) ? "black" : "answered"}" title="Answered Topics">Answered</span></a>
%{--                            <g:link controller="forum" action="index" params="${[filter: 'answered']}"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('answered')) ? "black" : "answered"}" title="Answered Topics">Answered</span></g:link>--}%
                        </li>
                        <li class="filter-nav__list-item">
                            <a href="#" data-topic-type="announcement" class="filter-topic-link"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('announcement')) ? "black" : "announcement"}" title="Announcement Topics">Announcement</span></a>
%{--                            <g:link controller="forum" action="index" params="${[filter: 'announcement']}"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('announcement')) ? "black" : "announcement"}" title="Announcement Topics">Announcement</span></g:link>--}%
                        </li>
                        <li class="filter-nav__list-item">
                            <a href="#" data-topic-type="discussion" class="filter-topic-link"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('discussion')) ? "black" : "discussion"}" title="Discussion Topics">Discussion</span></a>
%{--                            <g:link controller="forum" action="index" params="${[filter: 'discussion']}"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('discussion')) ? "black" : "discussion"}" title="Discussion Topics">Discussion</span></g:link>--}%
                        </li>
                    </ul>
                </div>
            </nav>

            <div class="forum-pagination-nav">
                <div class="forum-nav-header forum-nav-pagination">
                    <g:paginate total="${topicCount ?: 0}" action="index" params="${params}" class="pagination-list" max="30"/>
                </div>
            </div>

        </div>

        <!-- Row 2, Query search and Project filter -->
        <div class="forum-nav-row">

            <nav class="forum-filter-nav filter-nav--mt-6">
                <div class="forum-nav-header">
                    <div class="filter-nav__label">Search by keyword:</div>
                    <input type="text" name="searchbox" id="searchbox" value="${params.q}" class="nav-dropdown" />
                </div>
            </nav>
            <nav class="forum-filter-nav filter-nav--mt-6">
                <div class="forum-nav-header">
                    <div class="filter-nav__label">Project:</div>
                    <select name="projectFilter" id="projectFilter" class="nav-dropdown filter-nav__list-item">
                        <vpf:projectSelectOptions projectFilterList="${projectFilterList}" currentSelectedProject="${params.projectId}"/>
                    </select>
                </div>
            </nav>
        </div>
    </section>
    <section class="forum-table-section">
        <p class="forum-topic-count">${topicCount} forum topics found.</p>
        <table class="forum-posts-table">
            <thead>
            <tr>
                <g:sortableColumn property="topic" class="td--5/12"
                                  title="${message(code: 'forumTopic.label', default: 'Topic')}" params="${params}"/>
%{--                <th class="td--2/12">Expedition</th>--}%
                <g:sortableColumn property="type" class="td--1/12"
                                  title="${message(code: 'forumTopic.type.label', default: 'Type')}" params="${params}"/>
                <g:sortableColumn property="postedBy" class="td--1/12"
                                  title="${message(code: 'forumTopic.creator.label', default: 'Author')}" params="${params}"/>
                <g:sortableColumn property="posted" class="td--1/12"
                                  title="${message(code: 'forumTopic.posted.label', default: 'Posted')}" params="${params}"/>
                <g:sortableColumn property="lastReply" class="td--1/12"
                                  title="${message(code: 'forumTopic.lastReply.label', default: 'Last reply')}" params="${params}"/>
                <g:sortableColumn property="views" class="td--1/12"
                                  title="${message(code: 'forumTopic.views.label', default: 'Views')}" params="${params}"/>
                <g:sortableColumn property="replies" class="td--1/12"
                                  title="${message(code: 'forumTopic.replies.label', default: 'Replies')}" params="${params}"/>
                <th class="td--1/12">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${topicList}" var="topic">
            <tr>
                <th class="td--order-1 forum-table-topic"><g:link controller="forum" action="viewForumTopic" params="${[id: topic.id]}">${topic.title}</g:link>
                <g:if test="${topic.projectName}">
                    <br>
                    <span class="forum-table-topic-project">from: <g:link controller="forum" action="index" params="${[projectId: topic.projectId]}">${(topic.projectName ? topic.projectName : '-')}</g:link></span>
                </g:if>
                </th>
%{--                <td class="forum-posts-table__expedition"><span class="fa forum-table-info fa-info-circle" title="${(topic.projectName ? topic.projectName : '-')}"></span></td>--}%
                <td class="forum-posts-table__status">
                    <g:set var="topicTypeStyle" value="${topic.style}" />
                    <g:if test="${topic.topicType == ForumTopicType.Question && topic.isAnswered}">
                        <div class="pill pill--bg-answered">Answered</div>
                    </g:if>
                    <g:else>
                        <div class="pill pill--bg-${topicTypeStyle}">${topic.topicType.name()}</div>
                    </g:else>
                </td>
                <td class="td--order-2">${topic.creator.displayName}</td>
                <td class="td--order-3 lg:td--text-right"><g:formatDate date="${topic.dateCreated}"
                                                                        format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/></td>
                <td class="td--order-4 lg:td--text-right">
                <g:if test="${topic.lastReply}">
                    <g:formatDate date="${topic.lastReply}" format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/>
                </g:if>
                <g:else>
                    -
                </g:else>
                </td>
                <td class="td--order-5 lg:td--text-right">${topic.views}</td>
                <td class="td--order-6 lg:td--text-right">${topic.replies}</td>

                <td class="forum-table-watched">
                    <g:if test="${topic.isWatched}">
                        <div data-topic-id="${topic.id}" data-watched="true" class="toggleWatch">
                            <span class="fa fa-star forum-table-topic-watched" title="${message(code: 'forumTopic.watched.stopwatching', default: 'Click to stop watching')}"></span>
                        </div>
                    </g:if>
                    <g:else>
                        <div data-topic-id="${topic.id}" data-watched="false" class="toggleWatch">
                            <span class="fa fa-star-o forum-table-topic-watched forum-table-topic-not-watched" title="${message(code: 'forumTopic.watched.watch', default: 'Click to watch')}"></span>
                        </div>
                    </g:else>
                </td>
            </tr>
            </g:each>

            </tbody>
        </table>
    </section>
</main>

<asset:script type="text/javascript">
    $(document).ready(function() {
        $('#projectFilter').change(function() {
            window.location = getLink("${createLink(controller: 'forum', action: 'index')}", "projectId", $(this).val());
        });

        $('.filter-topic-link').click(function(e) {
            e.preventDefault();
            let topicFilter = $(this).attr('data-topic-type');
            if (topicFilter)
                window.location = getLink("${createLink(controller: 'forum', action: 'index')}", "filter", topicFilter);
        });

        function getLink(url, replaceParam, replaceVar) {
            const params = new URLSearchParams(window.location.search);
            let topicFilter = params.get('filter');
            let searchQuery = params.get('q');
            let projectId = params.get('projectId');

            let goUrl = "";

            if (topicFilter || replaceParam === 'filter') {
                goUrl += (goUrl.length === 0) ? "?" : "&";
                if (replaceParam === 'filter') goUrl += "filter=" + replaceVar;
                else goUrl += "filter=" + topicFilter;
            }
            if (searchQuery || replaceParam === 'q') {
                goUrl += (goUrl.length === 0) ? "?" : "&";
                if (replaceParam === 'q') goUrl += "q=" + replaceVar;
                else goUrl += "q=" + searchQuery;
            }
            if (projectId || replaceParam === 'projectId') {
                goUrl += (goUrl.length === 0) ? "?" : "&";
                if (replaceParam === 'projectId') goUrl += "projectId=" + replaceVar;
                else goUrl += "projectId=" + projectId;
            }

            return url + goUrl;
        }

        $("#searchbox").keydown(function(e) {
            if (e.keyCode === 13) {
                doSearch();
            }
        });

        function doSearch() {
            let q = encodeURIComponent($('#searchbox').val());
            window.location = getLink("${createLink(controller: 'forum', action: 'index')}", "q", q);
        }

        $('.toggleWatch').click(function() {
            let iconSpan = $(this).find('span');
            let div = $(this);
            let watched = $(this).attr("data-watched") === "true";
            let topicId = $(this).attr("data-topic-id");

            if (topicId) {
                // Toggle watched flag
                watched = !watched;

                $.ajax("${createLink(controller: 'forum', action:'ajaxWatchTopic')}?watch="+ watched +"&topicId=" + topicId).done(function (results) {
                    $(div).attr('data-watched', watched);
                    if (watched) {
                        $(iconSpan).removeClass('fa-star-o').removeClass('forum-table-topic-not-watched')
                            .addClass('fa-star')
                            .attr('title', "${message(code: 'forumTopic.watched.stopwatching', default: 'Click to unwatch')}");
                    } else {
                        $(iconSpan).removeClass('fa-star')
                            .addClass('fa-star-o').addClass('forum-table-topic-not-watched')
                            .attr('title', "${message(code: 'forumTopic.watched.watch', default: 'Click to watch')}");
                    }
                });
            }
        });

    });
</asset:script>

</body>
</html>