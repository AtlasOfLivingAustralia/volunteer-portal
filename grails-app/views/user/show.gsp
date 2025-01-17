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
                    <li class="filter-nav__list-item"><button class="pill pill--bg-black">All</button></li>
                    <li class="filter-nav__list-item"><button class="pill pill--bg-orange">Saved</button></li>
                    <li class="filter-nav__list-item"><button class="pill pill--bg-purple">Transcribed</button></li>
                    <li class="filter-nav__list-item"><button class="pill pill--bg-green">Validated</button></li>
                </ul>
            </div>

            <div class="task-history-nav-col task-history-nav-col__pagination">
                <ol class="pagination-list">
                    <li class="pagination-list__item"><a href="">Prev</a></li>
                    <li class="pagination-list__item"><a href="">1</a></li>
                    <li class="pagination-list__item pagination-list__item--highlight"><a href="">2</a></li>
                    <li class="pagination-list__item"><a href="">3</a></li>
                    <li class="pagination-list__item"><a href="">4</a></li>
                    <li class="pagination-list__item"><a href="">...</a></li>
                    <li class="pagination-list__item"><a href="">325</a></li>
                    <li class="pagination-list__item"><a href="">Next</a></li>
                </ol>
            </div>

            <div class="task-history-nav-col task-history-nav-col__mode">
                <ol class="pagination-list">
                    <li class="pagination-list__item pagination-list__item--highlight">
                        <a href="">
                            <i class="glyphicon glyphicon-th-large "></i>
                        </a>
                    </li>
                    <li class="pagination-list__item">
                        <a href="">
                            <i class="glyphicon glyphicon-th-list "></i>
                        </a>
                    </li>
                </ol>
            </div>
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
            <tr>
                <th class="task-history-table__thumbnail" data-key="task"><a href="post.html"><img src="https://dummyimage.com/600x400/009994/00f492" alt=""></a></th>
                <td data-key="id">39209380</td>
                <td data-key="expedition">Bush Heritage Australia Bon Bon Core 47 (1 of 12)</td>
                <td data-key="transcribed">29 May 2024</td>
                <td data-key="status">
                    <span class="pill pill--bg-purple">Transcribed</span>
                </td>
                <td data-key="action"><a href="">Edit</a></td>
            </tr>
            <tr>
                <th class="task-history-table__thumbnail" data-key="task"><a href="post.html"><img src="https://dummyimage.com/600x400/009994/00f492" alt=""></a></th>
                <td data-key="id">39209380</td>
                <td data-key="expedition">Bush Heritage Australia Bon Bon Core 47 (1 of 12)</td>
                <td data-key="transcribed">29 May 2024</td>
                <td data-key="status">
                    <span class="pill pill--bg-orange">Saved</span>
                </td>
                <td data-key="action"><a href="">View</a></td>
            </tr>
            <tr>
                <th class="task-history-table__thumbnail" data-key="task"><a href="post.html"><img src="https://dummyimage.com/600x400/009994/00f492" alt=""></a></th>
                <td data-key="id">39209380</td>
                <td data-key="expedition">Bush Heritage Australia Bon Bon Core 47 (1 of 12)</td>
                <td data-key="transcribed">29 May 2024</td>
                <td data-key="status">
                    <span class="pill pill--bg-orange">Saved</span>
                </td>
                <td data-key="action"><a href="">View</a></td>
            </tr>
            <tr>
                <th class="task-history-table__thumbnail" data-key="task"><a href="post.html"><img src="https://dummyimage.com/600x400/009994/00f492" alt=""></a></th>
                <td data-key="id">39209380</td>
                <td data-key="expedition">Bush Heritage Australia Bon Bon Core 47 (1 of 12)</td>
                <td data-key="transcribed">29 May 2024</td>
                <td data-key="status">
                    <span class="pill pill--bg-orange">Saved</span>
                </td>
                <td data-key="action"><a href="">View</a></td>
            </tr>
            <tr>
                <th class="task-history-table__thumbnail" data-key="task"><a href="post.html"><img src="https://dummyimage.com/600x400/009994/00f492" alt=""></a></th>
                <td data-key="id">39209380</td>
                <td data-key="expedition">Bush Heritage Australia Bon Bon Core 47 (1 of 12)</td>
                <td data-key="transcribed">29 May 2024</td>
                <td data-key="status">
                    <span class="pill pill--bg-orange">Saved</span>
                </td>
                <td data-key="action"><a href="">View</a></td>
            </tr>
            </tbody>
        </table>


    </section>

</main>



</body>
</html>
