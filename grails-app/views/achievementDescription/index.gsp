<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.WebUtils; au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.ala.skin}">
    <g:set var="entityName" value="${message(code: 'achievementDescription.label', default: 'Badge')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.achievementDescription.label', default: 'Manage Badges')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]

    %>

    <a class="btn btn-success" href="${createLink(action: "create")}"><i
            class="icon-plus icon-white"></i>&nbsp;<g:message code="achievementDescription.edit.add_badge"/></a>
</cl:headerContent>
<div class="container" role="main">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn property="i18nName.${WebUtils.getCurrentLocaleAsString()}" mapping="achievementDescription"
                                              title="${message(code: 'achievementDescription.name.label', default: 'Name')}"/>

                            <g:sortableColumn width="10%" property="enabled" mapping="achievementDescription"
                                              title="${message(code: 'achievementDescription.enabled.label', default: 'Enabled')}"/>

                            <g:sortableColumn width="15%" property="badge" mapping="achievementDescription"
                                              title="${message(code: 'achievementDescription.badge.label', default: 'Icon')}"/>

                            <g:sortableColumn width="15%" property="dateCreated" mapping="achievementDescription"
                                              title="${message(code: 'achievementDescription.dateCreated.label', default: 'Date Created')}"/>

                            <g:sortableColumn width="15%" property="lastUpdated" mapping="achievementDescription"
                                              title="${message(code: 'achievementDescription.lastUpdated.label', default: 'Last Updated')}"/>

                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${achievementDescriptionInstanceList}" status="i" var="achievementDescriptionInstance">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
                                <td style="vertical-align: middle;">
                                    <h3><g:link action="edit"
                                                id="${achievementDescriptionInstance.id}">${fieldValue(bean: achievementDescriptionInstance, field: "i18nName")}</g:link></h3>

                                    <div class="well-small">
                                        <p>${raw(achievementDescriptionInstance?.i18nDescription?.toString())}</p>
                                    </div>
                                </td>

                                <td style="vertical-align: middle;">${fieldValue(bean: achievementDescriptionInstance, field: "enabled")}</td>

                                <td><img src="${cl.achievementBadgeUrl(achievement: achievementDescriptionInstance)}" height="140px"
                                         width="140px"/></td>

                                <td style="vertical-align: middle;"><g:formatDate
                                        date="${achievementDescriptionInstance.dateCreated}" format="yyyy-MM-dd HH:mm:ss"/></td>

                                <td style="vertical-align: middle;"><g:formatDate
                                        date="${achievementDescriptionInstance.lastUpdated}" format="yyyy-MM-dd HH:mm:ss"/></td>

                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${achievementDescriptionInstanceCount ?: 0}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
