
<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="${grailsApplication.config.ala.skin}">
		<g:set var="entityName" value="${message(code: 'achievementDescription.label', default: 'AchievementDescription')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
        <cl:headerContent title="${message(code:'default.achievementDescription.label', default:'Manage Achievements')}">
            <%
                pageScope.crumbs = [
                        [link:createLink(controller:'admin'),label:message(code:'default.admin.label', default:'Admin')]
                ]

            %>

            <a class="btn btn-success" href="${createLink(action:"create")}"><i class="icon-plus icon-white"></i>&nbsp;Add Achievement</a>
        </cl:headerContent>
		<div id="list-achievementDescription" class="content scaffold-list" role="main">
			<h1><g:message code="default.list.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
				<div class="message" role="status">${flash.message}</div>
			</g:if>
			<table>
			<thead>
					<tr>
                        <g:sortableColumn property="name" title="${message(code: 'achievementDescription.name.label', default: 'Name')}" />

                        <g:sortableColumn width="10%" property="enabled" title="${message(code: 'achievementDescription.enabled.label', default: 'Enabled')}" />

                        <g:sortableColumn width="15%" property="badge" title="${message(code: 'achievementDescription.badge.label', default: 'Badge')}" />

                        <g:sortableColumn width="15%" property="dateCreated" title="${message(code: 'achievementDescription.dateCreated.label', default: 'Date Created')}" />

                        <g:sortableColumn width="15%" property="lastUpdated" title="${message(code: 'achievementDescription.lastUpdated.label', default: 'Last Updated')}" />

					</tr>
				</thead>
				<tbody>
				<g:each in="${achievementDescriptionInstanceList}" status="i" var="achievementDescriptionInstance">
					<tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
                        <td style="vertical-align: middle;">
                            <h3><g:link action="edit" id="${achievementDescriptionInstance.id}">${fieldValue(bean: achievementDescriptionInstance, field: "name")}</g:link></h3>
                            <div class="well-small">
                                <p>${fieldValue(bean: achievementDescriptionInstance, field: "description")}</p>
                            </div>
                        </td>

                        <td style="vertical-align: middle;">${fieldValue(bean: achievementDescriptionInstance, field: "enabled")}</td>

                        <td><img src="${cl.achievementBadgeUrl(achievement:achievementDescriptionInstance)}" height="140px" width="140px" /></td>

                        <td style="vertical-align: middle;"><g:formatDate date="${achievementDescriptionInstance.dateCreated}" /></td>

                        <td style="vertical-align: middle;"><g:formatDate date="${achievementDescriptionInstance.lastUpdated}" /></td>

					</tr>
				</g:each>
				</tbody>
			</table>
			<div class="pagination">
				<g:paginate total="${achievementDescriptionInstanceCount ?: 0}" />
			</div>
		</div>
	</body>
</html>
