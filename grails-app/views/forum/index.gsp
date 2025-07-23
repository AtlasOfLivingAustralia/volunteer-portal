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

<cl:headerContent title="${listPageTitle}" selectedNavItem="forum">
    <g:if test="${params.projectId || params.watched}">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'forum', action: 'index'), label: message(code: 'default.forum.label', default: 'DigiVol Forum')]
            ]
        %>
    </g:if>

    <nav class="forum-nav">
        <ul class="forum-nav__list">
            <li class="forum-nav__list-item"><g:link controller="forum" action="index">All forum topics</g:link></li>
            <li class="forum-nav__list-item">|</li>
            <g:if test="${!params.watched}">
            <li class="forum-nav__list-item"><g:link controller="forum" action="index" params="[watched: 'true']">My watched topics</g:link></li>
            <li class="forum-nav__list-item">|</li>
            </g:if>
            <li class="forum-nav__list-item"><g:link controller="forum" action="expeditions">My watched expeditions</g:link></li>
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
                        </li>
                        <li class="filter-nav__list-item">
                            <a href="#" data-topic-type="question" class="filter-topic-link"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('question')) ? "black" : "question"}" title="Question Topics">Question</span></a>
                        </li>
                        <li class="filter-nav__list-item">
                            <a href="#" data-topic-type="answered" class="filter-topic-link"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('answered')) ? "black" : "answered"}" title="Answered Topics">Answered</span></a>
                        </li>
                        <li class="filter-nav__list-item">
                            <a href="#" data-topic-type="announcement" class="filter-topic-link"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('announcement')) ? "black" : "announcement"}" title="Announcement Topics">Announcement</span></a>
                        </li>
                        <li class="filter-nav__list-item">
                            <a href="#" data-topic-type="discussion" class="filter-topic-link"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('discussion')) ? "black" : "discussion"}" title="Discussion Topics">Discussion</span></a>
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
                    <div class="filter-nav__label">Search by Expedition:</div>
                    <select name="projectFilter" id="projectFilter" class="nav-dropdown filter-nav__list-item">
                        <vpf:projectSelectOptions projectFilterList="${projectFilterList}" currentSelectedProject="${params.projectId}"/>
                    </select>
                </div>
            </nav>
        </div>
    </section>
    <section class="forum-table-section">
        <div class="forum-nav-header">
            <g:if test="${params.projectId}" >
            <a href="${createLink(controller: 'forum', action: 'addForumTopic', params: [projectId: params.projectId])}">
            </g:if>
            <g:else>
            <a href="${createLink(controller: 'forum', action: 'addForumTopic')}">
            </g:else>
                <span class="pill pill--bg-new-post">${message(code: 'forum.newpost.create.label', default: 'Create New Topic')}</span>
            </a>
            <g:if test="${params.projectId}">
                <div data-project-id="${params.projectId}" data-project-watched="${watchingProjectForum ? 'true' : 'false'}" class="forum-post-buttons--justify-left toggleExpeditionWatch">
                    <g:if test="${watchingProjectForum}">
                        <span class="fa fa-star forum-post--watch-icon forum-post-watched" title="${message(code: 'forumTopic.expedition.watched.stopwatching', default: 'Click to stop watching')}"></span>
                    </g:if>
                    <g:else>
                        <span class="fa fa-star-o forum-post--watch-icon forum-post-watched forum-post-not-watched" title="${message(code: 'forumTopic.expedition.watched.watch', default: 'Click to watch')}"></span>
                    </g:else>
                    <span class="forum--watch-label">Watch this expedition forum</span>
                </div>
            </g:if>
        </a>
        </div>
        <p class="forum-topic-count">
            ${topicCount} forum topics found<g:if test="${project}"> for ${project.name}</g:if>.
        </p>
        <table class="forum-posts-table">
            <thead>
            <tr>
                <g:sortableColumn property="topic" class="td--5/12"
                                  title="${message(code: 'forumTopic.label', default: 'Topic')}" params="${params}"/>
                <g:sortableColumn property="type" class="td--1/12"
                                  title="${message(code: 'forumTopic.type.label', default: 'Type')}" params="${params}"/>
                <g:sortableColumn property="postedBy" class="td--1/12"
                                  title="${message(code: 'forumTopic.creator.label', default: 'Author')}" params="${params}"/>
                <g:sortableColumn property="posted" class="td--1/12 lg:td--text-right"
                                  title="${message(code: 'forumTopic.posted.label', default: 'Posted')}" params="${params}"/>
                <g:sortableColumn property="lastReply" class="td--1/12 lg:td--text-right"
                                  title="${message(code: 'forumTopic.lastReply.label', default: 'Last reply')}" params="${params}"/>
                <g:sortableColumn property="views" class="td--1/12 td--text-right"
                                  title="${message(code: 'forumTopic.views.label', default: 'Views')}" params="${params}"/>
                <g:sortableColumn property="replies" class="td--1/12 td--text-right"
                                  title="${message(code: 'forumTopic.replies.label', default: 'Replies')}" params="${params}"/>
                <th class="td--1/12">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <g:if test="${topicCount == 0}">
                <tr>
                    <td colspan="7" class="forum-table-topic--no-topic">No topics found</td>
                    <td>&nbsp;</td>
                </tr>
            </g:if>
            <g:else>
            <g:each in="${topicList}" var="topic">
            <tr>
                <th class="td--order-1 forum-table-topic"><g:link controller="forum" action="viewForumTopic" params="${[id: topic.id]}">${topic.title}</g:link>
                <g:if test="${topic.projectName}">
                    <br>
                    <span class="forum-table-topic-project">from: <g:link controller="forum" action="index" params="${[projectId: topic.projectId]}">${(topic.projectName ? topic.projectName : '-')}</g:link></span>
                </g:if>
                </th>
                <td class="forum-posts-table__status">
                    <g:set var="topicTypeStyle" value="${topic.style}" />
                    <g:if test="${topic.topicType == ForumTopicType.Question && topic.isAnswered}">
                        <div class="pill pill--bg-answered">Answered</div>
                    </g:if>
                    <g:else>
                        <div class="pill pill--bg-${topicTypeStyle}">${topic.topicType.name()}</div>
                    </g:else>
                </td>
                <td class="td--order-3 text-nowrap">${topic.creator.displayName}</td>
                <td class="td--order-4 lg:td--text-right"><g:formatDate date="${topic.dateCreated}"
                                                                        format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/></td>
                <td class="td--order-5 lg:td--text-right">
                <g:if test="${topic.lastReply}">
                    <g:formatDate date="${topic.lastReply}" format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/>
                </g:if>
                <g:else>
                    -
                </g:else>
                </td>
                <td class="td--order-6 lg:td--text-right">${topic.views}</td>
                <td class="td--order-7 lg:td--text-right">${topic.replies}</td>

                <td class="forum-table-watched td--order-8 lg:td--text-right">
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
            </g:else>
            </tbody>
        </table>
    </section>

    <section class="forum-nav-section">

        <div class="forum-nav-row">
            <g:if test="${topicCount > 10}">
            <nav class="forum-filter-nav filter-nav--mt-6">
                <div class="forum-nav-header">
                <g:if test="${params.projectId}" >
                    <a href="${createLink(controller: 'forum', action: 'addForumTopic', params: [projectId: params.projectId])}">
                </g:if>
                <g:else>
                    <a href="${createLink(controller: 'forum', action: 'addForumTopic')}">
                </g:else>
                <span class="pill pill--bg-new-post">${message(code: 'forum.newpost.create.label', default: 'Create New Topic')}</span>
                </a>
                </div>
            </nav>
            </g:if>

            <div class="forum-pagination-nav">
                <div class="forum-nav-header forum-nav-pagination">
                    <g:paginate total="${topicCount ?: 0}" action="index" params="${params}" class="pagination-list" max="30"/>
                </div>
            </div>

        </div>
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

        $('.toggleExpeditionWatch').click(function() {
            let iconSpan = $(this).find('.forum-post--watch-icon');
            let div = $(this);
            let watched = $(this).attr("data-project-watched") === "true";
            let projectId = $(this).attr("data-project-id");

            if (projectId) {
                // Toggle watched flag
                watched = !watched;

                $.ajax("${createLink(controller: 'forum', action:'ajaxWatchProject')}?watch="+ watched +"&projectId=" + projectId).done(function (results) {
                    $(div).attr('data-project-watched', watched);
                    if (watched) {
                        $(iconSpan).removeClass('fa-star-o').removeClass('forum-post-not-watched')
                            .addClass('fa-star')
                            .attr('title', "${message(code: 'forumTopic.expedition.watched.stopwatching', default: 'Click to unwatch')}");
                    } else {
                        $(iconSpan).removeClass('fa-star')
                            .addClass('fa-star-o').addClass('forum-post-not-watched')
                            .attr('title', "${message(code: 'forumTopic.expedition.watched.watch', default: 'Click to watch')}");
                    }
                });
            }
        });

    });
</asset:script>

</body>
</html>