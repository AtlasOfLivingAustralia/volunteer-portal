<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <g:if test="${project}">
        <title><cl:pageTitle title="${message(code: 'user.notebook.titleProject', args: [userInstance?.displayName, project?.name ?: 'Unknown project'])}"/></title>
    </g:if>
    <g:else>
        <title><cl:pageTitle title="${message(code: 'user.notebook.title', args: [userInstance?.displayName])}"/></title>
    </g:else>

    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="notebook-2.css"/>
</head>
<body>
<cl:headerContent crumbLabel="${cl.displayNameForUserId(id: userInstance.userId)}"
                  title="User Notebook for ${cl.displayNameForUserId(id: userInstance.userId)}"
                  hideTitle="true"
                  selectedNavItem="userDashboard">

    <h1 class="notebook-user-name">
        <span class="user-icon">
            <g:if test="${userInstance.userId == currentUser}">
                <a href="//en.gravatar.com/" class="external" target="_blank" id="gravatarLink" title="To customise your avatar, register your email address at gravatar.com...">
                    <img src="//www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=53&d=https%3A%2F%2Fi.imgur.com%2FzY6A8tI.png" width="53" alt="" class="center-block img-circle img-responsive">
                </a>
            </g:if>
            <g:else>
                <img src="//www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=53&d=https%3A%2F%2Fi.imgur.com%2FzY6A8tI.png" width="53" alt="" class="center-block img-circle img-responsive">
            </g:else>
        </span>
        ${cl.displayNameForUserId(id: userInstance.userId)}
    </h1>

</cl:headerContent>

<main>
    <section class="achievement-list-section">
        <dl class="achievement-list">
            <div class="achievement-list__card">
                <dt>Total Contribution</dt>
                <dd class="achievement-list__definition">${score} <span class="achievement-list__leaderboard-total">tasks</span></dd>
            </div>
            <div class="achievement-list__card">
                <dt>Expeditions contributed to</dt>
                <dd class="achievement-list__definition">${expeditionCount}</dd>
            </div>
            <div class="achievement-list__card">
                <dt>Species added to ALA</dt>
                <dd class="achievement-list__definition">${totalSpeciesCount}</dd>
            </div>
            <div class="achievement-list__card">
                <dt>Leaderboard position</dt>
                <dd class="achievement-list__definition">${userRank} <span class="achievement-list__leaderboard-total">/ ${totalUsers}</span></dd>
            </div>
        </dl>
    </section>

    <section class="badge-list-section ">
        <header class="badge-list-header">
            <h2>Badges</h2>
            <p><g:link controller="user" action="achievements">View all available badges</g:link></p>
        </header>
        <ul class="badges-list">
            <g:each in="${achievements}" var="ach" status="i">
            <li class="badges-list__item">
                <figure>
                    <img src='<cl:achievementBadgeUrl achievement="${ach.achievement}"/>'
                         width="50px" alt="${ach.achievement.name}"
                         title="${ach.achievement.description}"
                         class="badges-list__badge"/>
                    <figcaption>${ach.achievement.name}</figcaption>
                </figure>
            </li>
            </g:each>
        </ul>
    </section>

    <section class="task-list-nav-section">
        <h2>Task history</h2>
        <nav class="task-history-nav">

            <div class="task-history-nav-col task-history-nav-col__filter">
                <div class="filter-nav__label">Filter by:</div>
                <ul class="forum-nav__list">
                    <li class="filter-nav__list-item"><g:link controller="user" action="show" id="${userInstance.id}"><span class="pill pill--bg-${(!params.filter) ? "black" : "grey"}">All</span></g:link></li>
                    <li class="filter-nav__list-item"><g:link controller="user" action="show" id="${userInstance.id}" params="${[filter: 'transcribed']}"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('transcribed')) ? "black" : "grey"}" title="Tasks transcribed by you">Transcribed</span></g:link></li>
                    <li class="filter-nav__list-item"><g:link controller="user" action="show" id="${userInstance.id}" params="${[filter: 'validated']}"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('validated')) ? "black" : "grey"}" title="Tasks validated by you">Validated</span></g:link></li>
                    <li class="filter-nav__list-item">|</li>
                    <li class="filter-nav__list-item"><g:link controller="user" action="show" id="${userInstance.id}" params="${[filter: 'saved']}"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('saved')) ? "black" : "grey"}" title="Tasks you have saved for later">Saved</span></g:link></li>
                </ul>
            </div>

            <div class="task-history-nav-col task-history-nav-col__pagination">
                <g:paginate total="${totalMatchingTasks ?: 0}" action="show" params="${params}" class="pagination-list"/>
            </div>

%{--            <div class="task-history-nav-col task-history-nav-col__mode">--}%
%{--                <ol class="pagination-list">--}%
%{--                    <li class="pagination-list__item pagination-list__item--highlight">--}%
%{--                        <a href="">--}%
%{--                            <i class="glyphicon glyphicon-th-large "></i>--}%
%{--                        </a>--}%
%{--                    </li>--}%
%{--                    <li class="pagination-list__item">--}%
%{--                        <a href="">--}%
%{--                            <i class="glyphicon glyphicon-th-list "></i>--}%
%{--                        </a>--}%
%{--                    </li>--}%
%{--                </ol>--}%
%{--            </div>--}%
        </nav>
    </section>

    <section>
        <table class="task-history-table">
            <thead>
            <tr>
                <th class="td--2/12">Task</th>
                <th class="td--1/12">ID</th>
                <th class="td--4/12">Expedition</th>
                <th class="td--2/12">Transcribed</th>
                <th class="td--2/12">Status</th>
                <th class="td--1/12">Action</th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${viewTaskList}" var="row">
            <tr>
                <th class="task-history-table__thumbnail" data-key="task">
                    <cl:taskThumbnail taskId="${row.task_id}"/>
                </th>
                <td data-key="id"><g:link controller="task" action="showDetails" id="${row.task_id}">${row.task_id}</g:link></td>
                <td data-key="expedition">${row.projectName}</td>
                <td data-key="transcribed">
                    <g:formatDate date="${row.dateTranscribed}"
                                  format="${au.org.ala.volunteer.DateConstants.DATE_TIME_FORMAT}"/>
                </td>
                <td data-key="status">
                    <span class="pill pill--bg-${row.status.replace(" ", "-").toLowerCase()}">${row.status}</span>
                </td>
                <td data-key="action">
                    <g:if test="${row.isFullyTranscribed && (row.fullyTranscribedBy == currentUser || isValidator)}">
                        <!-- show task -->
                        <a class="btn btn-small" href="${createLink(controller: 'task', action: 'show', id: row.task_id)}">
                            <i class="fa fa-2x fa-eye" title="View task"></i>
                        </a>
                    </g:if>
                    <g:if test="${row.isFullyTranscribed && isValidator}">
                        <!-- validate task -->
                        <a class="btn btn-small" href="${createLink(controller: 'validate', action: 'task', id: row.task_id)}">
                            <i class="fa fa-2x fa-check-square-o" title="Validate"></i>
                        </a>
                    </g:if>
                    <g:if test="${!row.isFullyTranscribed}">
                        <!-- transcribe task -->
                        <a class="btn btn-small" href="${createLink(controller: 'transcribe', action: 'task', id: row.task_id)}">
                            <i class="fa fa-2x fa-pencil-square-o" title="Transcribe"></i>
                        </a>
                    </g:if>
                </td>
            </tr>
            </g:each>
            </tbody>
        </table>


    </section>

</main>



</body>
</html>
