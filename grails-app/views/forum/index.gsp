<%@ page import="au.org.ala.volunteer.ForumController; au.org.ala.volunteer.DateConstants; au.org.ala.volunteer.User; au.org.ala.volunteer.ForumTopicType; au.org.ala.volunteer.ForumTopic" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <content tag="pageType">forum</content>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="Forum"/></title>
    <link href="https://cdn.jsdelivr.net/npm/tom-select@2.6.2/dist/css/tom-select.css" rel="stylesheet">
</head>

<body class="forum">
<cl:headerContent selectedNavItem="forum">
    <g:if test="${params.projectId || params.watched}">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'forum', action: 'index'), label: message(code: 'default.forum.label', default: 'DigiVol Forum')]
            ]
        %>
    </g:if>

    <div class="d-flex justify-content-between align-items-center">
        <h1 class="h2 fw-bold mb-0 text-dark">${listPageTitle}</h1>
        <g:set var="addNewTopicLink" value="${createLink(controller: 'forum', action: 'addForumTopic')}"/>
        <g:if test="${params.projectId}">
            <g:set var="addNewTopicLink" value="${createLink(controller: 'forum', action: 'addForumTopic', params: [projectId: params.projectId])}"/>
        </g:if>
        <a href="${addNewTopicLink}" class="btn btn-primary px-4 py-2 fw-semibold shadow-sm">
            <i class="fa fa-plus me-2"></i>Create New Topic
        </a>
    </div>
</cl:headerContent>

<main>
    <div class="container">
        <!-- SECONDARY TAB NAVIGATION -->
        <ul class="nav nav-tabs border-bottom mb-4">
            <li class="nav-item">
                <a class="nav-link ${params.watched == null || params.watched == 'false' ? 'active fw-semibold' : 'text-secondary'}" ${params.watched == 'false' ? 'aria-current="page"' : ''}
                   href="${createLink(controller: 'forum', action: 'index', params: [watched: false])}">All forum topics</a>
            </li>
            <li class="nav-item">
                <a class="nav-link ${params.watched == 'true' ? 'active fw-semibold' : 'text-secondary'}" ${params.watched == 'true' ? 'aria-current="page"' : ''}
                   href="${createLink(controller: 'forum', action: 'index', params: [watched: true])}">My watched topics</a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-secondary" href="${createLink(controller: 'forum', action: 'expeditions')}">My watched expeditions</a>
            </li>
        </ul>

        <!-- FILTER & SEARCH PANEL DECK -->
        <div class="card card-body border-0 shadow-sm bg-light p-4 mb-4">
            <div class="row g-3 align-items-center">
                <!-- Keyword Input with Floating Label -->
                <div class="col-md-5">
                    <div class="form-floating">
                        <input type="text" class="form-control bg-white border-0 shadow-sm" id="searchKeyword" placeholder="Search by keyword...">
                        <label for="searchKeyword" class="text-muted">Search by keyword...</label>
                    </div>
                </div>
                <!-- Expedition Dropdown Selector -->
                <div class="col-md-5">
                    <div class="form-floating bootstrap-ts-floating">

                        <select id="projectFilter" name="projectFilter" class="form-select bg-white border-0 shadow-sm" data-live-search="true">
                        <vpf:projectSelectOptions projectFilterList="${projectFilterList}" currentSelectedProject="${params.projectId}"/>
                        </select>
                        <label for="projectFilter" class="text-muted">Search by Expedition</label>
                    </div>
                </div>
                <!-- Search Button Action -->
                <div class="col-md-2">
                    <button class="btn btn-secondary w-100 py-3 fw-semibold shadow-sm" id="forumSearchBtn" type="button">
                        <i class="fa fa-search me-2"></i>Filter
                    </button>
                </div>
            </div>
        </div>

        <!-- CONTROL BAR (FILTER BY TYPE + PAGINATION) -->
        <div class="d-flex flex-col flex-md-row flex-wrap justify-content-between align-items-md-baseline gap-3 py-2">
            <!-- Inline Filter Pill Navigation Bar -->
            <div class="d-flex align-items-center flex-wrap gap-2">
                <span class="text-muted fs-7 me-1">Filter by:</span>
                <div class="btn-group btn-group-sm" role="group" aria-label="Task history filters">

                    <a href="#" data-topic-type="all"
                       class="btn btn-sm px-3 filter-topic-link ${!params.filter || params.filter == 'all' ? 'btn-primary active' : 'btn-outline-primary'}"
                        ${!params.filter || params.filter == 'all' ? raw('aria-current="page"') : ''}>All types</a>
                    <a href="#" data-topic-type="question"
                       class="btn btn-sm px-3 filter-topic-link ${params.filter?.equalsIgnoreCase('question') ? 'btn-primary active' : 'btn-outline-primary'}"
                        ${params.filter?.equalsIgnoreCase('question') ? raw('aria-current="page"') : ''}>Question</a>
                    <a href="#" data-topic-type="answered"
                       class="btn btn-sm px-3 filter-topic-link ${params.filter?.equalsIgnoreCase('answered') ? 'btn-primary active' : 'btn-outline-primary'}"
                        ${params.filter?.equalsIgnoreCase('answered') ? raw('aria-current="page"') : ''}>Answered</a>
                    <a href="#" data-topic-type="announcement"
                       class="btn btn-sm px-3 filter-topic-link ${params.filter?.equalsIgnoreCase('announcement') ? 'btn-primary active' : 'btn-outline-primary'}"
                        ${params.filter?.equalsIgnoreCase('announcement') ? raw('aria-current="page"') : ''}>Announcement</a>
                    <a href="#" data-topic-type="discussion"
                       class="btn btn-sm px-3 filter-topic-link ${params.filter?.equalsIgnoreCase('discussion') ? 'btn-primary active' : 'btn-outline-primary'}"
                        ${params.filter?.equalsIgnoreCase('discussion') ? raw('aria-current="page"') : ''}>Discussion</a>
                </div>
            </div>

            <!-- Clean Consolidated Pagination Component -->
            <cl:paginate total="${topicCount ?: 0}" action="index" params="${params}" class="pagination-end" max="30" ariaLabel="Topics, top"/>
        </div>

        <div class="d-flex flex-col flex-md-row flex-wrap justify-content-between align-items-md-end align-items-end gap-3 py-2">
        <!-- METADATA RESULTS COUNT -->
            <div>
                <p class="small text-muted mb-0 fw-medium">Showing matching topics:
                    <span id="projectForumBadge" class="badge badge-project border-primary ms-2" aria-label="Expedition Filter">
                        <i class="fa fa-times-circle pointer delete-project-filter me-1" title="Remove Expedition Filter"></i><span id="projectForumBadgeText"></span>
                    </span>
                    <span id="searchKeywordBadge" class="badge badge-keyword border-red" aria-label="Search Keyword">
                        <i class="fa fa-times-circle pointer delete-search-keyword me-1" title="Remove Keyword Filter"></i><span id="searchKeywordBadgeText"></span>
                    </span>
                    <br/>
                    <span class="badge bg-secondary me-1">${formatNumber(number: topicCount, format: '###,###')} forum topics found</span>

                </p>
            </div>
            <div class="d-flex align-items-center gap-2 w-50">
                <g:if test="${params.projectId}">
                <button type="button" class="btn btn-sm btn-outline-warning ms-auto me-1" id="toggleWatchProject" data-watch="${watchingProjectForum}" data-project-id="${params.projectId}">
                    <i class="projectWatchIcon fa fa-star${watchingProjectForum ? '' : '-o'}"></i>
                    <span id="watchProjectText">${watchingProjectForum ? 'Unwatch' : 'Watch'} this Expedition Forum</span>
                </button>
                </g:if>

                <label class="d-none" for="selectSortOrder" aria-label="Sort Order">Sort Order</label>
                <select id="selectSortOrder" class="form-select form-select-sm bg-white border-0 shadow-sm w-auto ${!params.projectId ? 'ms-auto' : ''}">
                    <option value="lastReply|desc" selected>Sort by: Newest</option>
                    <option value="lastReply|asc">Sort by: Oldest</option>
                    <option value="topic|asc">Sort by: Topic Name (A to Z)</option>
                    <option value="topic|desc">Sort by: Topic Name (Z to A)</option>
                    <option value="topicType|asc">Sort by: Topic Type</option>
                    <option value="postedBy|asc">Sort by: Author</option>
                    <option value="replies|desc">Sort by: Most Replies</option>
                    <option value="replies|asc">Sort by: Least Replies</option>
                    <option value="views|desc">Sort by: Most Views</option>
                    <option value="views|asc">Sort by: Least Views</option>
                </select>
            </div>
        </div>

        <!-- FORUM STREAM LIST CONTAINER -->
        <div class="list-group shadow-sm rounded-3 overflow-hidden border">
            <g:each in="${topicList}" var="topic">
            <!-- TOPIC ITEM -->
            <div class="list-group-item list-group-item-action p-3 bg-white">
                <div class="row align-items-center g-3">
                    <!-- Title & Collection Source -->
                    <div class="col-md-7">
                        <div class="d-flex align-items-start gap-2 flex-wrap flex-md-nowrap">
                            <h5 class="text-truncate mb-1 fw-bold text-dark fs-6 flex-grow-1" title="${topic.title}">
                                <g:link controller="forum" action="viewForumTopic" params="${[id: topic.id]}">${topic.title}</g:link>
                            </h5>
                            <g:if test="${topic.locked}">
                            <span class="btn btn-sm btn-outline-secondary py-1 d-inline-flex align-items-center gap-1 me-auto">
                                <i class="fa fa-lock" title="Topic is locked" aria-label="Topic is locked"></i>
                            </span>
                            </g:if>
                        </div>
                        <g:if test="${topic.projectName}">
                        <div class="text-muted small">
                            <span><i class="fa fa-folder me-1 text-secondary"></i> from: <a href="${createLink(controller: 'forum', action: 'index', params: [projectId: topic.projectId])}">${topic.projectName}</a></span>
                        </div>
                        </g:if>
                    </div>

                    <!-- Dedicated Status Badge Column -->
                    <div class="col-md-2 text-md-center">
                        <g:set var="topicTypeStyle" value="${topic.style}" />
                        <g:if test="${topic.topicType == ForumTopicType.Question && topic.isAnswered}">
                        <span class="badge badge--answered border-answered rounded px-2.5 py-1.5 text-uppercase font-monospace flex-grow-1">
                            Answered
                        </span>
                        </g:if>
                        <g:else>
                        <span class="badge badge--${topicTypeStyle} border-${topicTypeStyle} rounded px-2.5 py-1.5 text-uppercase font-monospace flex-grow-1">
                            ${topic.topicType.name()}
                        </span>
                        </g:else>
                        <div class="text-muted pt-1 small">
                            <span><i class="fa fa-reply me-1 text-secondary"></i>Replies: ${topic.replies}</span>
                            <span><i class="fa fa-eye ms-2 me-1 text-secondary"></i>Views: ${topic.views}</span>
                        </div>
                    </div>

                    <!-- Author & Date Stamps -->
                    <div class="col-md-2 text-md-end text-muted small">
                        <strong class="d-block text-dark">${topic.creator.displayName}</strong>
                        <span class="d-block font-monospace"><g:formatDate date="${topic.dateCreated}"
                                                                   format="${DateConstants.DATE_TIME_FORMAT}"/></span>
                        <g:if test="${topic.lastReply}">
                        <span class="text-muted small">Last reply: <g:formatDate date="${topic.lastReply}" format="${DateConstants.DATE_TIME_FORMAT}"/></span>
                        </g:if>
                    </div>

                    <div class="col-md-1 text-md-end text-muted small">
                        <div class="btn-group btn-group-sm" role="group">
                        <g:if test="${watchingProjectForum}">
                            <span class="d-inline-block" tabindex="0" data-bs-toggle="tooltip" data-bs-title="You are watching this expedition forum, you cannot watch individual topics.">
                                <button type="button" class="toggleWatch btn btn-sm btn-light border disabled"
                                        aria-disabled="true" style="pointer-events: none;">
                                    <i class="watchIcon fa fa-bell" title="Watch topic" aria-label="Watch topic"></i>
                                </button>
                            </span>
                        </g:if>
                        <g:else>
                            <button type="button" class="toggleWatch btn ${watchingProjectForum ? 'disabled' : ''} btn-sm btn-light border"
                                    aria-disabled="${watchingProjectForum}" data-topic-id="${topic.id}" data-watched="${topic.isWatched}">
                                <g:if test="${topic.isWatched}">
                                <i class="watchIcon fa fa-bell-slash" title="Unwatch topic" aria-label="Unwatch topic"></i>
                                </g:if>
                                <g:else>
                                <i class="watchIcon fa fa-bell" title="Watch topic" aria-label="Watch topic"></i>
                                </g:else>
                            </button>
                        </g:else>
                        </div>
                    </div>
                </div>
            </div>
            </g:each>
        </div>

    </div>
</main>
<asset:javascript src="bvp-select.js" asset-defer="" />
<script src="https://cdn.jsdelivr.net/npm/tom-select@2.6.2/dist/js/tom-select.complete.min.js"></script>
<asset:script type="text/javascript">
    $(document).ready(function() {
        const BASE_URL = "${createLink(controller: 'forum', action: 'index')}";
        const PARAMS = ['filter', 'sort', 'order', 'projectId', 'q', 'watched'];

        $('.toggleWatch').on('click', function() {
            let button = $(this);
            let topicId = button.attr("data-topic-id");
            let isWatched = button.attr("data-watched") === "true";
            console.log("Toggle watch for topic with ID: " + topicId);

            if (topicId && !button.hasClass('disabled')) {
                isWatched = !isWatched; // Toggle the watch state
                $.ajax("${createLink(controller: 'forum', action:'ajaxWatchTopic')}?watch=" + isWatched + "&topicId=" + topicId)
                    .done(function (results) {
                        console.log("Watch topic result: " + results);
                        button.attr("data-watched", (!isWatched).toString());
                        let icon = button.find(".watchIcon");
                        if (!isWatched) {
                            icon.removeClass("fa-bell").addClass("fa-bell-slash");
                            icon.attr("title", "Unwatch topic");
                            icon.attr("aria-label", "Unwatch topic");
                        } else {
                            icon.removeClass("fa-bell-slash").addClass("fa-bell");
                            icon.attr("title", "Watch topic");
                            icon.attr("aria-label", "Watch topic");
                        }
                        window.location.reload();
                    })
                    .fail(function (error) {
                        console.log("Failed to watch topic. Error: " + error);
                        bvp.alert("Failed to watch topic. Please try again later.");
                    });
            }
        });

        $('#toggleWatchProject').on('click', function() {
            let button = $(this);
            let projectId = button.attr("data-project-id");
            let isWatching = button.attr("data-watch") === "true";
            console.log("Toggle watch for expedition with ID: " + projectId);

            if (projectId) {
                isWatching = !isWatching; // Toggle the watch state
                $.ajax("${createLink(controller: 'forum', action:'ajaxWatchProject')}?watch=" + isWatching + "&projectId=" + projectId)
                    .done(function (results) {
                        console.log("Watch expedition result: " + results);
                        button.attr("data-watch", (!isWatching).toString());
                        if (!isWatching) {
                            button.find(".projectWatchIcon").removeClass("fa-star-o").addClass("fa-star");
                            button.find("#watchProjectText").text("Unwatch this Expedition Forum");
                        } else {
                            button.find(".projectWatchIcon").removeClass("fa-star").addClass("fa-star-o");
                            button.find("#watchProjectText").text("Watch this Expedition Forum");
                        }
                        window.location.reload();
                    })
                    .fail(function (error) {
                        console.log("Failed to watch expedition. Error: " + error);
                        bvp.alert("Failed to watch expedition. Please try again later.");
                    });
            }
        });

        $('.filter-topic-link').on('click', function(e) {
            e.preventDefault();
            let topicFilter = $(this).attr('data-topic-type');
            // const baseUrl = "${createLink(controller: 'forum', action: 'index')}";
            if (topicFilter) window.location = bvp.getNewLink(BASE_URL, window.location.search, PARAMS, {filter: topicFilter});
        });

        $('#selectSortOrder').on('change', function() {
            const currentQueryString = window.location.search;
            let sortValue = $(this).val();

            // Select value is 'column|direction' e.g. 'lastReply|desc' or 'topic|asc'
            let sortParts = sortValue.split('|');
            if (sortParts.length === 2) {
                let sortColumn = sortParts[0];
                let sortDirection = sortParts[1];
                console.log("queryString: " + currentQueryString);

                let newLink = bvp.getNewLink(BASE_URL, currentQueryString, PARAMS, {
                    sort: sortColumn,
                    order: sortDirection
                });

                console.log('New link for sort order change: ' + newLink);
                window.location.href = newLink;
            }
        });

        $("#searchKeyword").keydown(function(e) {
            if (e.keyCode === 13) {
                doSearch();
            }
        });

        $('.delete-search-keyword').on('click', function() {
            $('#searchKeywordBadgeText').text('');
            $('#searchKeywordBadge').hide();
            window.location = bvp.getNewLink(BASE_URL, window.location.search, PARAMS, {q: ''});
        });

        $('.delete-project-filter').on('click', function() {
            $('#projectForumBadgeText').text('');
            $('#projectForumBadge').hide();
            window.location = bvp.getNewLink(BASE_URL, window.location.search, PARAMS, {projectId: ''});
        });

        $('#forumSearchBtn').on('click', function() {
            doSearch();
        });

        function doSearch() {
            const urlParams = new URLSearchParams(window.location.search);
            const queryQ = urlParams.get('q');
            const queryProjectId = urlParams.get('projectId');
            let q = encodeURIComponent($('#searchKeyword').val());
            if (!q && queryQ) {
                q = queryQ;
            }

            let projectId = $('#projectFilter').val();
            if (!projectId && queryProjectId) {
                projectId = queryProjectId;
            }
            let searchParams = {q: q};
            if (projectId) {
                searchParams.projectId = projectId;
            }
            window.location = bvp.getNewLink(BASE_URL, window.location.search, PARAMS, searchParams);
        }

        function hydrateSortOrderSelect() {
            const urlParams = new URLSearchParams(window.location.search);
            const sortParam = urlParams.get('sort');
            const orderParam = urlParams.get('order');
            console.log('Current URL sort param: ' + sortParam + ', order param: ' + orderParam);

            if (sortParam && orderParam) {
                const combinedValue = sortParam + '|' + orderParam;
                console.log('Hydrating sort order select with value: [' + combinedValue + ']');
                $('#selectSortOrder').val(combinedValue);
            }
        }

        function hydrateSearchFilterKeyword() {
            const urlParams = new URLSearchParams(window.location.search);
            const searchParam = urlParams.get('q');
            const projectIdParam = urlParams.get('projectId');
            console.log('Current URL search param: ' + searchParam);

            if (searchParam) {
                $('#searchKeywordBadgeText').text("Keyword: " + decodeURIComponent(searchParam));
                $('#searchKeywordBadge').show();
                console.log('Hydrated search keyword input with value: [' + decodeURIComponent(searchParam) + ']');
            } else {
                $('#searchKeywordBadgeText').text('');
                $('#searchKeywordBadge').hide();
            }

            if (projectIdParam) {
                const projectName = $('#projectFilter option:selected').text();
                $('#projectForumBadgeText').text("Expedition: " + projectName);
                $('#projectForumBadge').show();
            } else {
                $('#projectForumBadgeText').text('');
                $('#projectForumBadge').hide();
            }
        }

        function hydrateProjectFilterSelect() {
            return {
                create: false,
                persist: false,
                allowEmptyOption: true,
                searchField: ['text'],
                plugins: ['dropdown_input'],
                copyClassesToDropdown: false,
                placeholder: 'Type or select an Expedition name...',
                maxOptions: null
            };
        }

        function hydrateTooltips() {
            const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
            const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
        }

        hydrateSortOrderSelect();
        bvpSelect.init('#projectFilter', hydrateProjectFilterSelect());
        hydrateSearchFilterKeyword();
        hydrateTooltips();
    });
</asset:script>

</body>
</html>