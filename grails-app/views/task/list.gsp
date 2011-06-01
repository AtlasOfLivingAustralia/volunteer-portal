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
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
    </div>
    <div class="body">
      <h1>Task list
        <g:if test="${projectInstance}"> for
          <g:link controller="project" action="show" id="${projectInstance.id}">${projectInstance.name}</g:link>
        </g:if>
      </h1>
      <g:if test="${flash.message}">
        <div class="message">${flash.message}</div>
      </g:if>
      <div class="list">
        <table>
          <thead>
          <tr>
            <td>&nbsp;</td>

            <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'Task id')}"/>

            <g:sortableColumn property="externalIdentifier" title="${message(code: 'task.externalIdentifier.label', default: 'External Identifier')}"/>

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

              <td>${fieldValue(bean: taskInstance, field: "externalIdentifier")}</td>

              <td>${fieldValue(bean: taskInstance, field: "fullyTranscribedBy")}</td>

              <td>${fieldValue(bean: taskInstance, field: "fullyValidatedBy")}</td>

              <td>
                  <ul>
                    <li><g:link controller="transcribe" action="task" id="${taskInstance.id}"> Transcribe</g:link></li>
                    <g:if test="${taskInstance.fullyTranscribedBy != null && taskInstance.fullyValidatedBy == null }"><li>Validate</li></g:if>
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
    </div>
</body>
</html>
