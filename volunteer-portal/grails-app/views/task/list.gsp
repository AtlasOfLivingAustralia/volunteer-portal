<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
  <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>
<body class="two-column-right">
<div id="content">
  <div class="section">
    <div class="nav">
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]"/></g:link></span>
    </div>
    <div class="body">
      <h1><g:message code="default.list.label" args="[entityName]"/></h1>
      <g:if test="${flash.message}">
        <div class="message">${flash.message}</div>
      </g:if>
      <div class="list">
        <table>
          <thead>
          <tr>

            <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'Id')}"/>

            <g:sortableColumn property="created" title="${message(code: 'task.created.label', default: 'Created')}"/>

            <g:sortableColumn property="externalIdentifier" title="${message(code: 'task.externalIdentifier.label', default: 'External Identifier')}"/>

            <g:sortableColumn property="externalUrl" title="${message(code: 'task.externalUrl.label', default: 'External Url')}"/>

            <g:sortableColumn property="fullyTranscribed" title="${message(code: 'task.fullyTranscribed.label', default: 'Fully Transcribed')}"/>

            <g:sortableColumn property="fullyValidated" title="${message(code: 'task.fullyValidated.label', default: 'Fully Validated')}"/>

          </tr>
          </thead>
          <tbody>
          <g:each in="${taskInstanceList}" status="i" var="taskInstance">
            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

              <td><g:link controller="transcribe" action="task" id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link></td>

              <td><g:formatDate date="${taskInstance.created}"/></td>

              <td>${fieldValue(bean: taskInstance, field: "externalIdentifier")}</td>

              <td>${fieldValue(bean: taskInstance, field: "externalUrl")}</td>

              <td><g:formatBoolean boolean="${taskInstance.fullyTranscribed}"/></td>

              <td><g:formatBoolean boolean="${taskInstance.fullyValidated}"/></td>

            </tr>
          </g:each>
          </tbody>
        </table>
      </div>
      <div class="paginateButtons">
        <g:paginate total="${taskInstanceTotal}"/>
      </div>
    </div>
  </div>
</div>
</body>
</html>
