<%@ page import="au.org.ala.volunteer.DateConstants; au.org.ala.volunteer.User" %>
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
    %{--  Info Cards  --}%
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
                <div class="filter-nav__label">Filter by:</div>
                <ul class="task-history-nav__list">
                    <g:if test="${userInstance.userId == currentUser}">
                        <g:set var="perspective" value="by you"/>
                    </g:if>
                    <g:else>
                        <g:set var="perspective" value="by ${userInstance.displayName}"/>
                    </g:else>
                    <li class="filter-nav__list-item"><g:link controller="user" action="show" id="${userInstance.id}"><span class="pill pill--bg-${(!params.filter) ? "black" : "grey"}">All</span></g:link></li>
                    <li class="filter-nav__list-item"><g:link controller="user" action="show" id="${userInstance.id}" params="${[filter: 'transcribed']}"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('transcribed')) ? "black" : "grey"}" title="Tasks transcribed ${perspective}">Transcribed</span></g:link></li>
                    <li class="filter-nav__list-item"><g:link controller="user" action="show" id="${userInstance.id}" params="${[filter: 'validated']}"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('validated')) ? "black" : "grey"}" title="Tasks validated ${perspective}">Validated</span></g:link></li>
                    <li class="filter-nav__list-item">|</li>
                    <li class="filter-nav__list-item"><g:link controller="user" action="show" id="${userInstance.id}" params="${[filter: 'saved']}"><span class="pill pill--bg-${(params.filter?.equalsIgnoreCase('saved')) ? "black" : "grey"}" title="Tasks saved for later ${perspective}">Saved</span></g:link></li>
                </ul>
            </div>
            <div class="task-history-pagination-nav">
                <g:paginate total="${totalMatchingTasks ?: 0}" action="show" params="${params}" class="pagination-list"/>
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
                <g:sortableColumn property="status" class="td--1/12"
                                  title="${message(code: 'task.isValid.label', default: 'Status')}" params="${[filter: params.filter]}"/>
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
                    <span class="pill pill--bg-${row.status.replace(" ", "-").toLowerCase()}">${row.status}</span>
                </td>
                <td data-key="action">
                <!-- Already Validated. Allow view or continue validation -->
                    <g:if test="${row.fullyValidatedBy}">
                        <g:if test="${row.isValid}">
                            <!-- show task -->
                            <a class="btn btn-small" href="${createLink(controller: 'task', action: 'show', id: row.task_id)}">
                                <i class="fa fa-eye task-action-icon" title="View task"></i>
                            </a>
                        </g:if>
                        <g:else>
                            <g:if test="${row.fullyValidatedBy == currentUser}">
                                <!-- validate task -->
                                <a class="btn btn-small" href="${createLink(controller: 'validate', action: 'task', id: row.task_id)}">
                                    <i class="fa fa-check-square-o task-action-icon" title="Continue Validation"></i>
                                </a>
                            </g:if>
                            <g:else>
                                <!-- show task -->
                                <a class="btn btn-small" href="${createLink(controller: 'task', action: 'show', id: row.task_id)}">
                                    <i class="fa fa-eye task-action-icon" title="View task"></i>
                                </a>
                            </g:else>
                        </g:else>
                    </g:if>
                    <g:elseif test="${row.isFullyTranscribed}">
                        <!-- Task has been transcribed but not validated -->
                        <g:if test="${isValidator}">
                            <!-- validate task -->
                            <a class="btn btn-small" href="${createLink(controller: 'validate', action: 'task', id: row.task_id)}">
                                <i class="fa fa-check-square-o task-action-icon" title="Validate"></i>
                            </a>
                        </g:if>
                        <g:else>
                            <!-- show task -->
                            <a class="btn btn-small" href="${createLink(controller: 'task', action: 'show', id: row.task_id)}">
                                <i class="fa fa-eye task-action-icon" title="View task"></i>
                            </a>
                        </g:else>
                    </g:elseif>
                    <g:else>
                        <!-- Task has not been completely transcribed yet -->
                        <!-- transcribe task -->
                        <a class="btn btn-small" href="${createLink(controller: 'transcribe', action: 'task', id: row.task_id)}">
                            <i class="fa fa-pencil-square-o task-action-icon" title="Transcribe"></i>
                        </a>
                    </g:else>

                </td>
            </tr>
            </g:each>
            </g:else>
            </tbody>
        </table>


    </section>

</main>



</body>
</html>
