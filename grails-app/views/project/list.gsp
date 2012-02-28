<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
  <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}"/>
  <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>
<body class="two-column-right">
    <div class="nav">
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <span class="menuButton">Projects</span>
    </div>
    <div class="body">
      <h1>Projects</h1>
      <div class="list">
        <table>
          <thead>
          <tr>
            <td>&nbsp;</td>
            <g:sortableColumn property="name" title="${message(code: 'project.name.label', default: 'Name')}"/>
            <g:sortableColumn property="description" title="${message(code: 'project.description.label', default: 'Description')}"/>
            <td>Number of Tasks</td>
            <td>Fully transcribed</td>
            <td>Partially transcribed</td>
            <td>Validated</td>
            <td>Tasks viewed</td>
            <!--<td>Total task views</td>-->
            <td></td>
            <!--<td></td>-->
          </tr>
          </thead>
          <tbody>
          <g:each in="${projectInstanceList}" status="i" var="projectInstance">
            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
              <td>
                <img src="${resource(file: projectInstance.bannerImage)}" style="width:200px;"/>
              </td>
              <td><g:link action="index" controller="project" id="${projectInstance.id}">${fieldValue(bean: projectInstance, field: "name")}</g:link></td>
              <td>${projectInstance?.description}</td>
              <td>${projectTaskCounts.get(projectInstance.id) ? projectTaskCounts.get(projectInstance.id) : 0 }</td>
              <td>${projectFullyTranscribedCounts.get(projectInstance.id) ? projectFullyTranscribedCounts.get(projectInstance.id) : 0}</td>
              <td>${projectTaskTranscribedCounts.get(projectInstance.id) ? projectTaskTranscribedCounts.get(projectInstance.id) - (projectFullyTranscribedCounts.get(projectInstance.id) ? projectFullyTranscribedCounts.get(projectInstance.id) : 0) : 0}</td>
              <td>${projectTaskValidatedCounts.get(projectInstance.id) ? projectTaskValidatedCounts.get(projectInstance.id) : 0}</td>
              <td>${projectTaskViewedCounts.get(projectInstance.id) ? projectTaskViewedCounts.get(projectInstance.id) : 0}</td>
              <!--<td>${viewCountPerProject.get(projectInstance.id) ? viewCountPerProject.get(projectInstance.id) : 0}</td>-->
              <td>
                <g:if test="${projectFullyTranscribedCounts.get(projectInstance.id) < projectTaskCounts.get(projectInstance.id)}">
                  <g:link action="showNextFromProject" controller="transcribe" id="${projectInstance.id}">Transcribe</g:link>
                </g:if>
                <g:else>
                  Transcription complete
                </g:else>
              </td>
              <!--<td><g:link action="showNextFromProject" controller="validate" id="${projectInstance.id}">Validate</g:link></td>-->
            </tr>
          </g:each>
          </tbody>
        </table>
      </div>
      <div class="paginateButtons">
        <g:paginate total="${projectInstanceTotal}"/>
      </div>
</div>
</body>
</html>