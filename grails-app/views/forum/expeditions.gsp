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
            <li class="forum-nav__list-item">|</li>
            <li class="forum-nav__list-item"><g:link controller="forum" action="expeditions">My watched expeditions</g:link></li>
        </ul>
    </nav>

</cl:headerContent>

<main>
    <section class="forum-table-section">
        <div class="forum-nav-header">
            <a href="${createLink(controller: 'forum', action: 'addForumTopic')}">
                <span class="pill pill--bg-new-post">${message(code: 'forum.newpost.create.label', default: 'Create New Post')}</span>
            </a>
        </div>
        <p class="forum-topic-count">
            ${forumProjectWatched?.size()} expeditions found.
        </p>
        <table class="forum-posts-table">
            <thead>
            <tr>
                <th class="td--5/12">${message(code: 'forumTopic.expedition.label', default: 'Expedition')}</th>
                <th class="td--5/12">${message(code: 'forumTopic.lastTopic.label', default: 'Last Topic')}</th>
                <th class="td--1/12">${message(code: 'forumTopic.type.label', default: 'Type')}</th>
                <th class="td--1/12">${message(code: 'forumTopic.creator.label', default: 'Author')}</th>
                <th class="td--1/12">${message(code: 'forumTopic.lastReply.label', default: 'Last reply')}</th>
                <th class="td--1/12">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <g:if test="${forumProjectWatched.size() > 0}">
            <g:each in="${forumProjectWatched}" var="projectRow">
            <tr>
                <th class="td--order-1 forum-table-topic">
                    <g:link controller="forum" action="index" params="${[projectId: projectRow.project.id]}">${projectRow.project.name}</g:link>
                </th>
                <td class="td--order-2 forum-table-topic">
                    <g:if test="${projectRow.lastTopic}">
                        <g:link controller="forum" action="viewForumTopic" params="${[id: projectRow.lastTopic.id]}">${projectRow.lastTopic.title}</g:link>
                    </g:if>
                    <g:else>
                        <span class="forum-table-topic--no-topic">No topics yet</span>
                    </g:else>
                </td>
                <td class="forum-posts-table__status">
                    <g:if test="${projectRow.lastTopic}">
                        <g:set var="topicTypeStyle" value="${projectRow.lastTopic.topicType.name().toLowerCase()}" />
                        <g:if test="${projectRow.lastTopic.topicType == ForumTopicType.Question && projectRow.lastTopic.isAnswered}">
                            <div class="pill pill--bg-answered">Answered</div>
                        </g:if>
                        <g:else>
                            <div class="pill pill--bg-${topicTypeStyle}">${projectRow.lastTopic.topicType.name()}</div>
                        </g:else>
                    </g:if>
                    <g:else>
                        -
                    </g:else>
                </td>
                <td class="td--order-3 text-nowrap">${(projectRow.lastMessage) ? projectRow.lastMessage.user.displayName : "-"}</td>
                <td class="td--order-4 lg:td--text-right">
                    <g:if test="${projectRow.lastMessage}">
                        <g:formatDate date="${projectRow.lastMessage.date}" format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/>
                    </g:if>
                    <g:else>
                        -
                    </g:else>
                </td>

                <td class="forum-table-watched td--order-5 lg:td--text-right">
                    <div data-project-id="${projectRow.project.id}" data-watched="true" class="toggleWatch">
                        <span class="fa fa-star forum-table-topic-watched" title="${message(code: 'forumTopic.expedition.watched.stopwatching', default: 'Click to stop watching')}"></span>
                    </div>
                </td>
            </tr>
            </g:each>
            </g:if>
            <g:else>
            <tr>
                <th colspan="5" class="forum-table-topic">
                    ${message(code: 'forumTopic.expedition.noTopics', default: 'No expeditions are being watched')}
                </th>
                <td>&nbsp;</td>
            </tr>
            </g:else>
            </tbody>
        </table>
    </section>
</main>

<asset:script type="text/javascript">
    $(document).ready(function() {

        $('.toggleWatch').click(function() {
            let iconSpan = $(this).find('span');
            let div = $(this);
            let watched = $(this).attr("data-watched") === "true";
            let projectId = $(this).attr("data-project-id");

            if (projectId) {
                // Toggle watched flag
                watched = !watched;

                $.ajax("${createLink(controller: 'forum', action:'ajaxWatchProject')}?watch="+ watched +"&projectId=" + projectId).done(function (results) {
                    $(div).attr('data-watched', watched);
                    if (watched) {
                        $(iconSpan).removeClass('fa-star-o').removeClass('forum-table-topic-not-watched')
                            .addClass('fa-star')
                            .attr('title', "${message(code: 'forumTopic.expedition.watched.stopwatching', default: 'Click to unwatch')}");
                    } else {
                        $(iconSpan).removeClass('fa-star')
                            .addClass('fa-star-o').addClass('forum-table-topic-not-watched')
                            .attr('title', "${message(code: 'forumTopic.expedition.watched.watch', default: 'Click to watch')}");
                    }
                });
            }
        });

    });
</asset:script>

</body>
</html>