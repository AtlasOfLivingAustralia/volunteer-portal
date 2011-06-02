<%@ page import="au.org.ala.volunteer.User" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}"/>
  <title>Volunteers</title>
</head>
<body class="two-column-right">
  <div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
    <span class="menuButton">Volunteer list</span>
  </div>
  <div class="body">
  <h1>Volunteer list</h1>
  <div class="list">
    <table style="border: none;">
      <thead>
      <tr>
        <th></th>
        <g:sortableColumn property="displayName" title="${message(code: 'user.user.label', default: 'Name')}"/>
        <g:sortableColumn property="transcribedCount" title="${message(code: 'user.recordsTranscribedCount.label', default: 'Tasks completed')}"/>
        <g:sortableColumn property="validatedCount" title="${message(code: 'user.transcribedValidatedCount.label', default: 'Tasks validated')}"/>
        <g:sortableColumn property="created" title="${message(code: 'user.created.label', default: 'A transcriber since')}"/>
      </tr>
      </thead>
      <tbody>
      <g:each in="${userInstanceList}" status="i" var="userInstance">
        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
          <td><img src="http://www.gravatar.com/avatar/${userInstance.userId.toLowerCase().encodeAsMD5()}?s=80"/> </td>
          <td style="width:300px;">
              <g:link controller="user" action="show" id="${userInstance.id}">${fieldValue(bean: userInstance, field: "displayName")}</g:link>
              <g:if test="${userInstance.userId == currentUser}">(thats you!)</g:if>
          </td>
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
