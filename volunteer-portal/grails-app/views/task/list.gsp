<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
  <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>
<body class="two-column-right">
    <div class="nav">
      <span class="menuButton"><a class="crumb" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <g:if test="${projectInstance}">
        <span class="menuButton">${projectInstance.name}</span>
      </g:if>
      <g:else>
        <span class="menuButton">Tasks</span>
      </g:else>
    </div>
    <div class="body">
      <h1>Task list
        <g:if test="${projectInstance}"> for ${projectInstance.name} </g:if>
      </h1>
      <g:if test="${flash.message}">
        <div class="message">${flash.message}</div>
      </g:if>
      <div class="list">
        <g:if test="${taskInstanceList}">
        <table style="border:  none;">
          <thead>
          <tr>
            <td>&nbsp;</td>
            <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'Task id')}"/>
            <g:sortableColumn property="fullyTranscribedBy" title="${message(code: 'task.fullyTranscribed.label', default: 'Transcribed by')}"/>
            <g:sortableColumn property="fullyValidatedBy" title="${message(code: 'task.fullyValidated.label', default: 'Validated by')}"/>
            <th>Actions</th>
          </tr>
          </thead>
          <tbody>
          <g:each in="${taskInstanceList}" status="i" var="taskInstance">
            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
              <td>
                <g:link controller="transcribe" action="task" id="${taskInstance.id}">
                <img src="${ConfigurationHolder.config.server.url}/${taskInstance?.multimedia?.filePathToThumbnail?.iterator().next()}" width="150px"/>
                </g:link>
              </td>
              <td><g:link controller="transcribe" action="task" id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link></td>
              <td>${fieldValue(bean: taskInstance, field: "fullyTranscribedBy")}</td>
              <td>${fieldValue(bean: taskInstance, field: "fullyValidatedBy")}</td>
              <td>
                  <ul style="list-style-type: circle; padding: 0; margin-left: 10px;">
                    <li><g:link controller="transcribe" action="task" id="${taskInstance.id}"> Transcribe</g:link></li>
                    <g:if test="${taskInstance.fullyTranscribedBy != null && taskInstance.fullyValidatedBy == null}"><li>Validate</li></g:if>
                  </ul>
              </td>
            </tr>
          </g:each>
          </tbody>
        </table>
      </div>
      <div class="paginateButtons">
        <g:paginate total="${taskInstanceTotal}"/>
      </div>
      </g:if>
      <g:else>
        <div>
          <p>No tasks currently loaded for this project.</p>
        </div>
      </g:else>
    </div>
</body>
</html>
