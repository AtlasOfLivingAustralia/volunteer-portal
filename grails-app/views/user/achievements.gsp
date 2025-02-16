<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="au.org.ala.volunteer.WebUtils" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="${message(code: 'user.notebook.title', args: [currentUser?.displayName])}"/></title>

    <asset:stylesheet src="notebook-2.css"/>
</head>
<body>
<cl:headerContent crumbLabel="${message(code: 'achievement.page.title', default: 'Name')}"
                  title="${message(code: 'achievement.page.title', default: 'Name')}"
                  hideTitle="true"
                  selectedNavItem="userDashboard">

    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'user', action: 'notebook'), label: message(code: 'action.notebook', default: 'My Notebook')]
        ]
    %>

    <h1 class="notebook-user-name">
        <span class="user-icon">
            <g:if test="${currentUser.userId == currentUser}">
                <a href="//en.gravatar.com/" class="external" target="_blank" id="gravatarLink" title="To customise your avatar, register your email address at gravatar.com...">
                    <img src="//www.gravatar.com/avatar/${currentUser.email.toLowerCase().encodeAsMD5()}?s=53&d=https%3A%2F%2Fi.imgur.com%2FzY6A8tI.png" width="53" alt="" class="center-block img-circle img-responsive">
                </a>
            </g:if>
            <g:else>
                <img src="//www.gravatar.com/avatar/${currentUser.email.toLowerCase().encodeAsMD5()}?s=53&d=https%3A%2F%2Fi.imgur.com%2FzY6A8tI.png" width="53" alt="" class="center-block img-circle img-responsive">
            </g:else>
        </span>
        ${cl.displayNameForUserId(id: currentUser.userId)}
    </h1>

</cl:headerContent>

<main>
    <section>
        <h2 class="badge-list-heading">${message(code: 'achievement.page.title', default: 'Name')}</h2>

        <table class="badge-list-table">
            <thead>
            <th class="td--5/12">Badge</th>
            <th class="td--2/12">Status</th>
            <th class="td--3/12 td--text-right">Percentage of volunteers achieved</th>
            <th class="td--2/12 td--text-right">Tasks remaining till achievement</th>
            </thead>
            <tbody>
            <g:each in="${achievementList}" status="i" var="achievementRow">
                <g:set var="achievement" value="${achievementRow.achievement}" />
                <g:set var="achievementAwarded" value="${achievementRow.awarded}" />
                <g:set var="achievementStatus" value="${(achievementRow.status ? achievementRow.status : "-")}" />
            <tr>
                <th class="badge-list-table__cell-head">
                    <div class="badge-list-table-badge-cell">
                        <img src="${cl.achievementBadgeUrl(achievement: achievement)}" class="badge-list-table__badge" />
                        ${fieldValue(bean: achievement, field: "description")}
                    </div>
                </th>
                <td data-key="status">
                <g:if test="${achievementAwarded}">
                    <div><button class="pill pill--bg-green">Achieved</button> <span class="badge-list-table__rarity-description">Awarded ${achievementAwarded.format("dd-MM-yyyy")}</span></div>
                </g:if>
                <g:else>
                    <button class="pill pill--bg-orange">Not Achieved</button>
                </g:else>

                </td>
                <td class="td--text-right" data-key="percentage-achieved">
                    <div>${achievementRow.awardedPercentage}% <span class="badge-list-table__rarity-description">${WebUtils.getAchievementPopularity(achievementRow.awardedPercentage)}</span></div>
                </td>

                <td class="td--text-right" data-key="tasks-remaining">${achievementStatus}</td>
            </tr>
            </g:each>
            </tbody>
        </table>
    </section>
</main>



</body>
</html>
