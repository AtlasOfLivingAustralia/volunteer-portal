
<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="${grailsApplication.config.ala.skin}">
		<g:set var="entityName" value="${message(code: 'achievementDescription.label', default: 'AchievementDescription')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<a href="#list-achievementDescription" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>
		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
				<li><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></li>
			</ul>
		</div>
		<div id="list-achievementDescription" class="content scaffold-list" role="main">
			<h1><g:message code="default.list.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
				<div class="message" role="status">${flash.message}</div>
			</g:if>
			<table>
			<thead>
					<tr>
					
						<g:sortableColumn property="badge" title="${message(code: 'achievementDescription.badge.label', default: 'Badge')}" />
					
						<g:sortableColumn property="dateCreated" title="${message(code: 'achievementDescription.dateCreated.label', default: 'Date Created')}" />
					
						<g:sortableColumn property="lastUpdated" title="${message(code: 'achievementDescription.lastUpdated.label', default: 'Last Updated')}" />
					
						<g:sortableColumn property="name" title="${message(code: 'achievementDescription.name.label', default: 'Name')}" />
					
					</tr>
				</thead>
				<tbody>
				<g:each in="${achievementDescriptionInstanceList}" status="i" var="achievementDescriptionInstance">
					<tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
					
						<td><g:link action="show" id="${achievementDescriptionInstance.id}">${fieldValue(bean: achievementDescriptionInstance, field: "badge")}</g:link></td>
					
						<td><g:formatDate date="${achievementDescriptionInstance.dateCreated}" /></td>
					
						<td><g:formatDate date="${achievementDescriptionInstance.lastUpdated}" /></td>
					
						<td>${fieldValue(bean: achievementDescriptionInstance, field: "name")}</td>
					
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
