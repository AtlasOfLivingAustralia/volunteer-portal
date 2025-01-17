<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="${message(code: 'user.notebook.title', args: [userInstance?.displayName])}"/></title>

    <asset:stylesheet src="notebook-2.css"/>
</head>
<body>
<cl:headerContent crumbLabel="${message(code: 'achievement.page.title', default: 'Name')}"
                  title="${message(code: 'achievement.page.title', default: 'Name')}"
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
    <h2 class="badge-list-heading">${message(code: 'achievement.page.title', default: 'Name')}</h2>

    <table class="badge-list-table">
        <thead>
        <th class="td--5/12">Badge</th>
        <th class="td--2/12">Status</th>
        <th class="td--3/12 td--text-right">Percentage of volunteers achieved</th>
        <th class="td--2/12 td--text-right">Tasks remaining till achievement</th>
        </thead>
        <tbody>
        <tr>
            <th class="badge-list-table__cell-head">
                <img src="/static/images/badge-roo.png" alt="" class="badge-list-table__badge">
                Complete 1000 insect tasks
            </th>
            <td data-key="status">
                <button class="pill pill--bg-green">Achieved</button>
            </td>
            <td class="td--text-right" data-key="percentage-achieved">
                <div>90% <span class="badge-list-table__rarity-description">Very common</span>
            </td>
        </div>
            <td class="td--text-right" data-key="tasks-remaining">238</td>
        </tr>
        <tr>
            <th class="badge-list-table__cell-head">
                <img src="/static/images/badge-roo.png" alt="" class="badge-list-table__badge">
                Complete 1000 insect tasks
            </th>
            <td data-key="status">
                <button class="pill pill--bg-green">Achieved</button>
            </td>
            <td class="td--text-right" data-key="percentage-achieved">
                <div>90% <span class="badge-list-table__rarity-description">Very common</span>
            </td>
        </div>
            <td class="td--text-right" data-key="tasks-remaining">238</td>
        </tr>
        <tr>
            <th class="badge-list-table__cell-head">
                <img src="/static/images/badge-roo.png" alt="" class="badge-list-table__badge">
                Complete 1000 insect tasks
            </th>
            <td data-key="status">
                <button class="pill pill--bg-green">Achieved</button>
            </td>
            <td class="td--text-right" data-key="percentage-achieved">
                <div>90% <span class="badge-list-table__rarity-description">Very common</span>
            </td>
        </div>
            <td class="td--text-right" data-key="tasks-remaining">238</td>
        </tr>
        <tr>
            <th class="badge-list-table__cell-head">
                <img src="/static/images/badge-roo.png" alt="" class="badge-list-table__badge">
                Complete 1000 insect tasks
            </th>
            <td data-key="status">
                <button class="pill pill--bg-green">Achieved</button>
            </td>
            <td class="td--text-right" data-key="percentage-achieved">
                <div>90% <span class="badge-list-table__rarity-description">Very common</span>
            </td>
        </div>
            <td class="td--text-right" data-key="tasks-remaining">238</td>
        </tr>
        <tr>
            <th class="badge-list-table__cell-head">
                <img src="/static/images/badge-roo.png" alt="" class="badge-list-table__badge">
                Complete 1000 insect tasks
            </th>
            <td data-key="status">
                <button class="pill pill--bg-green">Achieved</button>
            </td>
            <td class="td--text-right" data-key="percentage-achieved">
                <div>90% <span class="badge-list-table__rarity-description">Very common</span>
            </td>
        </div>
            <td class="td--text-right" data-key="tasks-remaining">238</td>
        </tr>
        <tr>
            <th class="badge-list-table__cell-head">
                <img src="/static/images/badge-roo.png" alt="" class="badge-list-table__badge">
                Complete 1000 insect tasks
            </th>
            <td data-key="status">
                <button class="pill pill--bg-green">Achieved</button>
            </td>
            <td class="td--text-right" data-key="percentage-achieved">
                <div>90% <span class="badge-list-table__rarity-description">Very common</span>
            </td>
        </div>
            <td class="td--text-right" data-key="tasks-remaining">238</td>
        </tr>
        <tr>
            <th class="badge-list-table__cell-head">
                <img src="/static/images/badge-roo.png" alt="" class="badge-list-table__badge">
                Complete 1000 insect tasks
            </th>
            <td data-key="status">
                <button class="pill pill--bg-green">Achieved</button>
            </td>
            <td class="td--text-right" data-key="percentage-achieved">
                <div>90% <span class="badge-list-table__rarity-description">Very common</span>
            </td>
        </div>
            <td class="td--text-right" data-key="tasks-remaining">238</td>
        </tr>
        </tbody>
    </table>

</main>



</body>
</html>
