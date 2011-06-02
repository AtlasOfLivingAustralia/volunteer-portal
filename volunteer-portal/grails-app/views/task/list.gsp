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

    <div class="xxxbody">
      <h1>Task list <g:if test="${projectInstance}"> for ${projectInstance.name} </g:if></h1>
      <div class="CCCClist">
        <g:if test="${taskInstanceList}">
        <table style="width:100%; border: none;">
          <thead>
            <th>&nbsp;</th>
            <th>&nbsp;</th>
          </thead>
          <tbody>
            <tr>
            <g:each in="${taskInstanceList}" status="i" var="taskInstance">
              <g:if test="${(i % 4) == 0 && i != 0}">
                </tr>
                <tr>
              </g:if>
              <td width="220px;" class="thumb">
                  <g:link controller="transcribe" action="task" id="${taskInstance.id}">
                  <img src="${ConfigurationHolder.config.server.url}/${taskInstance?.multimedia?.filePathToThumbnail?.iterator().next()}" width="150px"/>
                  </g:link>
                  <p>ID: ${fieldValue(bean: taskInstance, field: "id")}
                  <g:if test="${taskInstance.fullyTranscribedBy}">
                    <br/><span>
                      Transcriber: ${fieldValue(bean: taskInstance, field: "fullyTranscribedBy")}
                    </span>
                  </g:if>
                  <g:else>
                    <span style="padding: 0; margin: 0;"><g:link controller="transcribe" action="task" id="${taskInstance.id}"> Transcribe</g:link></span>
                  </g:else>
                  <g:if test="${taskInstance.fullyTranscribedBy != null && taskInstance.fullyValidatedBy == null}">
                    <!--<span style="padding: 0; margin: 0;"><g:link controller="validate" action="validate" id="${taskInstance.id}">Validate</g:link></span>-->
                  </g:if>
                  </p>
              </td>
            </g:each>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="searchNavBar">
        <g:paginate total="${taskInstanceTotal}" id="${projectInstance?.id}" />
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
