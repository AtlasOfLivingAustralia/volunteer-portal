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
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'forum', action: 'index'), label: message(code: 'default.forum.label', default: 'DigiVol Forum')]
        ]
    %>

    <div class="d-flex justify-content-between align-items-center">
        <h1 class="h2 fw-bold mb-0 text-dark">${message(code: 'forum.watched.expeditions.label')}</h1>
        <g:set var="addNewTopicLink" value="${createLink(controller: 'forum', action: 'addForumTopic')}"/>
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
                <a class="nav-link text-secondary" href="${createLink(controller: 'forum', action: 'index', params: [watched: false])}">All forum topics</a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-secondary" href="${createLink(controller: 'forum', action: 'index', params: [watched: true])}">My watched topics</a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-secondary active fw-semibold" aria-current="page" href="${createLink(controller: 'forum', action: 'expeditions')}">My watched expeditions</a>
            </li>
        </ul>

        <!-- CONTROL BAR (PAGINATION) -->
        <div class="d-flex flex-col flex-md-row flex-wrap justify-content-between align-items-md-baseline gap-3 py-2">
        <!-- METADATA RESULTS COUNT -->
            <div>
                <p class="small text-muted mb-3 fw-medium">Showing watched expeditions:
                    <span class="badge bg-secondary me-1">${formatNumber(number: forumProjectWatched.size(), format: '###,###')} expedition${forumProjectWatched.size() == 1 ? '' : 's'} found</span>

                </p>
            </div>
            <cl:paginate total="${forumProjectWatched.size() ?: 0}" action="expeditions" params="${params}" navClass="ms-auto" max="30" ariaLabel="Expeditions, top"/>
        </div>

        <div class="table-responsive mt-2">
            <table class="table table-hover align-middle border-top">
                <thead class="table-light">
                <tr class="fs-7 text-uppercase text-muted border-bottom">
                    <g:sortableColumn property="projectName"
                                      title="${message(code: 'forumTopic.expedition.label', default: 'Expedition')}" params="${params}"/>
                    <g:sortableColumn property="lastTopic"
                                      title="${message(code: 'forumTopic.lastTopic.label', default: 'Last Topic')}" params="${params}"/>
                    <g:sortableColumn property="topicType"
                                      title="${message(code: 'forumTopic.type.label', default: 'Type')}" params="${params}"/>
                    <s:sortableColumn tag="th" property="author"
                                      title="${message(code: 'forumTopic.creator.label', default: 'Author')}" params="${params}"/>
                    <s:sortableColumn tag="th" property="lastReply"
                                      title="${message(code: 'forumTopic.lastReply.label', default: 'Last reply')}" params="${params}"/>
                    <th scope="col" class="text-end">Action</th>
                </tr>
                </thead>
                <tbody class="fs-7">
                <g:each in="${forumProjectWatched}" var="projectRow">
                    <tr>
                        <td><g:link controller="forum" action="index" params="${[projectId: projectRow.project.id]}">${projectRow.project.name}</g:link></td>
                        <td>
                            <g:if test="${projectRow.lastTopic}">
                                <g:link controller="forum" action="viewForumTopic" params="${[id: projectRow.lastTopic.id]}">${projectRow.lastTopic.title}</g:link>
                            </g:if>
                            <g:else>
                                <span class="forum-table-topic--no-topic">No topics yet</span>
                            </g:else>
                        </td>
                        <td>
                            <g:if test="${projectRow.lastTopic}">
                                <g:set var="topicTypeStyle" value="${projectRow.lastTopic.topicType.name().toLowerCase()}" />
                                <g:if test="${projectRow.lastTopic.topicType == ForumTopicType.Question && projectRow.lastTopic.isAnswered}">
                                    <div class="badge badge--answered">Answered</div>
                                </g:if>
                                <g:else>
                                    <div class="badge badge--${topicTypeStyle}">${projectRow.lastTopic.topicType.name()}</div>
                                </g:else>
                            </g:if>
                            <g:else>
                                -
                            </g:else>
                        </td>
                        <td class="small text-muted text-nowrap">
                            ${(projectRow.lastMessage) ? projectRow.lastMessage.user.displayName : "-"}
                        </td>
                        <td class="small text-muted text-nowrap">
                            <g:if test="${projectRow.lastMessage}">
                                <g:formatDate date="${projectRow.lastMessage.date}" format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/>
                            </g:if>
                            <g:else>
                                -
                            </g:else>
                        </td>
                        <td class="text-end w-auto">
                            <div class="btn-group btn-group-sm" role="group">
                                <button type="button" class="btn btn-light border toggleWatch" data-project-id="${projectRow.project.id}" data-watched="true" href="#">
                                    <i class="fa fa-bell-slash" title="Unwatch expedition" aria-label="Unwatch expedition"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                </g:each>
                </tbody>
            </table>
        </div>

    </div>
</main>
<asset:javascript src="bvp-select.js" asset-defer="" />
<script src="https://cdn.jsdelivr.net/npm/tom-select@2.6.2/dist/js/tom-select.complete.min.js"></script>
<asset:script type="text/javascript">
    $(document).ready(function() {
        $('.toggleWatch').on('click', function() {
            console.log("Unwatch expedition button clicked.");
            let button = $(this);
            let projectId = button.attr("data-project-id");
            console.log("Project ID to unwatch: " + projectId);

            if (projectId) {
                $.ajax("${createLink(controller: 'forum', action:'ajaxWatchProject')}?watch=false&projectId=" + projectId)
                    .done(function (results) {
                        console.log("Unwatch expedition result: " + results);
                        // Remove the row from the table
                        button.closest('tr').remove();
                    })
                    .fail(function (error) {
                        console.log("Failed to unwatch expedition. Error: " + error);
                        bvp.alert("Failed to unwatch expedition. Please try again later.");
                    });
            }
        });

    });
</asset:script>

</body>
</html>