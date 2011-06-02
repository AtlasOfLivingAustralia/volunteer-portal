<%@ page import="au.org.ala.volunteer.User" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}"/>
  <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>
<body>

<body class="two-column-right">
<div class="nav">
  <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
  <span class="menuButton">Users</span>
</div>
  <h1><g:message code="default.list.label" args="[entityName]"/></h1>
  <g:if test="${flash.message}">
    <div class="message">${flash.message}</div>
  </g:if>
  <div class="list">
    <table style="border: none;">
      <thead>
      <tr>
        <th></th>
        <g:sortableColumn property="displayName" title="${message(code: 'user.user.label', default: 'User')}"/>
        <g:sortableColumn property="recordsTranscribedCount" title="${message(code: 'user.recordsTranscribedCount.label', default: 'Tasks completed')}"/>
        <g:sortableColumn property="transcribedValidatedCount" title="${message(code: 'user.transcribedValidatedCount.label', default: 'Tasks validated')}"/>
        <g:sortableColumn property="created" title="${message(code: 'user.created.label', default: 'First contribution')}"/>
      </tr>
      </thead>
      <tbody>
      <g:each in="${userInstanceList}" status="i" var="userInstance">
        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
          <td><img src="http://www.gravatar.com/avatar/${userInstance.userId.toLowerCase().encodeAsMD5()}?s=80"/> </td>
          <td><g:link controller="user" action="show" id="${userInstance.id}">${fieldValue(bean: userInstance, field: "displayName")}</g:link> </td>
          <td>${fieldValue(bean: userInstance, field: "transcribedCount")}</td>
          <td>${fieldValue(bean: userInstance, field: "validatedCount")}</td>
          <td><g:formatDate date="${userInstance.created}"/></td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div class="paginateButtons">
    <g:paginate total="${userInstanceTotal}"/>
  </div>
</div>
</body>
</html>
