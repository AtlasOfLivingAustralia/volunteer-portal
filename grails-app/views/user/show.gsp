<%@ page import="au.org.ala.volunteer.DateConstants; au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <g:if test="${project}">
        <title><cl:pageTitle title="${message(code: 'user.notebook.titleProject', args: [cl.displayNameForUserId(id: userInstance.userId), project?.name ?: 'Unknown project'])}"/></title>
    </g:if>
    <g:else>
        <title><cl:pageTitle title="${message(code: 'user.notebook.title', args: [cl.displayNameForUserId(id: userInstance.userId)])}"/></title>
    </g:else>

    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="notebook-2.css"/>

    <style>
        .btn {
            border-radius: 3px !important;
            margin-left: 0.5rem;
            margin-right: 4.5rem;
        }
    </style>
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
                    <img src="//www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=53&d=https%3A%2F%2Fi.imgur.com%2FzY6A8tI.png" width="53" alt="" class="center-block img-circle img-fluid">
                </a>
            </g:if>
            <g:else>
                <img src="//www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=53&d=https%3A%2F%2Fi.imgur.com%2FzY6A8tI.png" width="53" alt="" class="center-block img-circle img-fluid">
            </g:else>
        </span>
        ${cl.displayNameForUserId(id: userInstance.userId)}
        <cl:ifSiteAdmin>
         <span class="notebook-user-name__admin-link">
            <cl:externalLinkIcon href="${createLink(controller: "user", action: "edit", id: userInstance.id)}" title="Administrator: Edit User"/>
        </span>
        </cl:ifSiteAdmin>
    </h1>

</cl:headerContent>

<main>
    %{--  Info Cards  --}%
    <section class="achievement-list-section">
        <dl class="achievement-list">
            <div class="achievement-list__card">
                <dt>Total Contribution</dt>
                <dd class="achievement-list__definition">
                    <span class="achievement-list__leaderboard-breakdown">Transcribed: ${transcribedScore} / Validated: ${validatedScore}</span><br />
                    ${score} <span class="achievement-list__leaderboard-total">tasks</span>
                </dd>
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
                <g:if test="${userRank == "0"}">
                    <dd class="achievement-list__leaderboard-total">Not ranked</dd>
                </g:if>
                <g:else>
                    <dd class="achievement-list__definition">${userRank} <span class="achievement-list__leaderboard-total">/ ${totalUsers}</span></dd>
                </g:else>
            </div>
        </dl>
    </section>

    %{--  Achievement Badges  --}%
    <section class="badge-list-section ">
        <header class="badge-list-header">
            <h2>Badges</h2>
            <p><g:link controller="user" action="achievements">View all available badges and your progress</g:link></p>
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

    %{--  Nav  --}%
    <section class="task-list-nav-section">
        <h2>Task history</h2>
        <p>${totalMatchingTasks} tasks found.</p>
        <nav class="task-history-nav">
            <div class="filter-nav filter-nav--mt-3">
                <div class="filter-nav__label task-history-nav__filter-label">
                    Filter by:
                    <cl:helpText>
                        Select a filter to view your tasks. Transcribed and Validated tasks will appear in the full list (All tasks). Saved tasks is a separate list. 'All tasks' will also clear filters.
                    </cl:helpText>
                </div>
                <ul class="task-history-nav__list nav nav-pills">
                    <g:if test="${userInstance.userId == currentUser}">
                        <g:set var="perspective" value="by me"/>
                    </g:if>
                    <g:else>
                        <g:set var="perspective" value="by ${cl.displayNameForUserId(id: userInstance.userId)}"/>
                    </g:else>
                    <li class="nav-item"><g:link class="nav-link ${!params.filter ? 'active' : ''}" controller="user" action="show" id="${userInstance.id}">All tasks</g:link></li>
                    <li class="nav-item"><g:link class="nav-link ${params.filter?.equalsIgnoreCase('transcribed') ? 'active' : ''}" controller="user" action="show" id="${userInstance.id}" params="${[filter: 'transcribed']}">Transcribed ${perspective}</g:link></li>
                    <li class="nav-item"><g:link class="nav-link ${params.filter?.equalsIgnoreCase('validated') ? 'active' : ''}" controller="user" action="show" id="${userInstance.id}" params="${[filter: 'validated']}">Validated ${perspective}</g:link></li>
                <g:if test="${userInstance.userId == currentUser}">
                    <li class="nav-item"><g:link class="nav-link ${params.filter?.equalsIgnoreCase('saved') ? 'active' : ''}" controller="user" action="show" id="${userInstance.id}" params="${[filter: 'saved']}">Saved for later</g:link></li>
                </g:if>
                </ul>
            </div>
            <div class="task-history-pagination-nav">
                <cl:paginate total="${totalMatchingTasks ?: 0}" action="show" params="${params}" class="pagination-end"/>
            </div>
        </nav>
    </section>

    %{--  Task History  --}%
    <section>
        <table class="task-history-table">
            <thead>
            <tr>
                <th class="td--2/12">${message(code: 'task.label', default: 'Task')}</th>
                <g:sortableColumn property="id" class="td--1/12"
                                  title="${message(code: 'task.id.label', default: 'Task ID')}" params="${[filter: params.filter]}"/>
                <g:sortableColumn property="projectName" class="td--5/12"
                                  title="${message(code: 'project.name.label', default: 'Expedition')}" params="${[filter: params.filter]}"/>
                <g:sortableColumn property="dateTranscribed" class="td--2/12"
                                  title="${message(code: 'task.dateFullyTranscribed.label', default: 'Transcribed')}" params="${[filter: params.filter]}"/>
                <s:sortableColumn tag="th" property="status" class="td--2/12"
                                  title="${message(code: 'task.isValid.label', default: 'Status')}" params="${[filter: params.filter]}">
                    <cl:helpText>
                        The current status of the task. Shows 'Transcribed by me' or 'Validated by me' if you were the last to action the task, otherwise just the current status.
                    </cl:helpText>
                </s:sortableColumn>
                <th class="td--1/12">${message(code: 'notebook.tasklist.tableAction.label', default: 'Action')}</th>
            </tr>
            </thead>
            <tbody>
            <g:if test="${viewTaskList.size() == 0}">
                <tr>
                    <td colspan="5" class="task-history-table__no-results">
                        <p>No tasks found.</p>
                    </td>
                    <td>&nbsp;</td>
                </tr>
            </g:if>
            <g:else>
            <g:each in="${viewTaskList}" var="row">
            <tr>
                <th class="task-history-table__thumbnail" data-key="task">
                    <cl:taskThumbnail taskId="${row.task_id}"/>
                </th>
                <td data-key="id"><g:link controller="task" action="showDetails" id="${row.task_id}">${row.task_id}</g:link></td>
                <td data-key="expedition"><a href="${createLink(controller: 'project', action: 'index', id: row.projectId)}">${row.projectName}</a></td>
                <td data-key="transcribed">
                    <g:formatDate date="${row.dateTranscribed}"
                                  format="${DateConstants.DATE_TIME_FORMAT}"/>
                </td>
                <td data-key="status">
                    <g:set var="statusPerspective" value="" />
                    <g:if test="${currentUser == row.fullyTranscribedBy && row.status == message(code: 'status.transcribed')}">
                        <g:set var="statusPerspective" value=" by me" />
                    </g:if>
                    <g:if test="${currentUser == row.fullyValidatedBy && row.status == message(code: 'status.validated')}">
                        <g:set var="statusPerspective" value=" by me" />
                    </g:if>
                    <span class="badge badge--${row.status.replace(" ", "-").toLowerCase()}">${row.status}${statusPerspective}</span>
                </td>
                <td data-key="action" class="task-history__action-buttons">
%{--                    // If task is fully transcribed and (the user is the transcriber or the user is a validator)--}%
%{--                    // display show task button--}%
                    <g:if test="${row.isFullyTranscribed && (row.fullyTranscribedBy == currentUser || row.isValidator)}">
                        <!-- show task -->
                        <a class="btn btn-sm btn-outline-secondary" href="${createLink(controller: 'task', action: 'show', id: row.task_id)}">
                            <i class="fa fa-eye task-action-icon" title="View task"></i>
                        </a>
                    </g:if>

%{--                    // If task is fully transcribed and the user is a validator--}%
%{--                    // display validate button--}%
                    <g:if test="${row.isFullyTranscribed && row.isValidator}">
%{--                    // If task status is validated, label = review--}%
%{--                    // else label = validate--}%
                        <g:if test="${row.status == message(code: 'status.validated')}">
                            <g:set var="validateButtonLabel" value="Review" />
                        </g:if>
                        <g:else>
                            <g:set var="validateButtonLabel" value="Validate" />
                        </g:else>
                        <!-- validate task -->
                        <a class="btn btn-sm btn-outline-secondary" href="${createLink(controller: 'validate', action: 'task', id: row.task_id)}">
                            <i class="fa fa-check-square-o task-action-icon" title="${validateButtonLabel}"></i>
                        </a>
                    </g:if>

%{--                    // If task is not fully transcribed--}%
%{--                    // display transcribe button--}%
                    <g:if test="${!row.isFullyTranscribed}">
                        <a class="btn btn-sm btn-outline-secondary" href="${createLink(controller: 'transcribe', action: 'task', id: row.task_id)}">
                            <i class="fa fa-pencil-square-o task-action-icon" title="Transcribe"></i>
                        </a>
                    </g:if>
                </td>
            </tr>
            </g:each>
            </g:else>
            </tbody>
        </table>
    </section>

    <g:if test="${totalMatchingTasks > 10}">
    <section class="task-list-nav-section">
        <nav class="task-history-nav">
            <div class="task-history-pagination-nav">
                <cl:paginate total="${totalMatchingTasks ?: 0}" action="show" params="${params}" class="pagination-end"/>
            </div>
        </nav>
    </section>
    </g:if>
</main>

<asset:script type="text/javascript">
    $(document).ready(function () {
        // Initialise tooltips
        bvp.bindTooltips("");
    });
</asset:script>
</body>
</html>
