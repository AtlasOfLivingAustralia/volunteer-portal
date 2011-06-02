<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}"/>
  <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>
<body>
<div class="nav">
  <span class="menuButton"><a class="crumb" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
  <span class="menuButton"><g:link class="crumb" action="list"><g:message code="default.userlist.label" default="Users"/></g:link></span>
  <span class="menuButton">${fieldValue(bean: userInstance, field: "displayName")}</span>
</div>
<div class="body">
  <h1>User: ${fieldValue(bean: userInstance, field: "displayName")} <g:if test="${userInstance.userId == currentUser}">(thats you!)</g:if></h1>
  <g:if test="${flash.message}">
    <div class="message">${flash.message}</div>
  </g:if>
  <div class="dialog">
    <table style="border:  none;">
       <tr>
        <td style="padding-top:18px; width:150px;">
          <img src="http://www.gravatar.com/avatar/${userInstance.userId.toLowerCase().encodeAsMD5()}?s=150" style="width:150px;"/>

          <g:if test="">
          <p>
            To update your avatar, you can register your email and picture with
            <a href="http://en.gravatar.com/">Gravatar</a>
          </p>
          </g:if>
        </td>
        <td>
        <table style="border:  none;">
          <tbody>
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.created.label" default="First contribution"/></td>
            <td valign="top" class="value"><g:formatDate date="${userInstance?.created}"/></td>
          </tr>
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.recordsTranscribedCount.label" default="Tasks Completed"/></td>
            <td valign="top" class="value">${fieldValue(bean: userInstance, field: "transcribedCount")}</td>
          </tr>
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.transcribedValidatedCount.label" default="Tasks Validated"/></td>
            <td valign="top" class="value">${fieldValue(bean: userInstance, field: "validatedCount")}</td>
          </tr>
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.userId.label" default="User Id"/></td>
            <td valign="top" class="value">${fieldValue(bean: userInstance, field: "userId")}</td>
          </tr>
          </tbody>
        </table>
        </td>
       </tr>
    </table>
  </div>

  <g:if test="${taskInstanceList}">
  <h2>Recently Transcribed Tasks by
    <g:if test="${userInstance.userId == currentUser}">
      you
    </g:if>
    <g:else>
      ${fieldValue(bean: userInstance, field: "displayName")}
    </g:else>
  </h2>
  <div class="list">
    <table style="border:  none;">
      <tbody>
      <g:each in="${taskInstanceList}" status="i" var="taskInstance">
        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
          <td>
            <g:link controller="transcribe" action="task" id="${taskInstance.id}">
            <img src="${ConfigurationHolder.config.server.url}/${taskInstance?.multimedia?.filePathToThumbnail?.iterator().next()}" width="150px"/>
            </g:link>
          </td>
          <td><g:link controller="transcribe" action="task" id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link></td>
          <td><g:if test="${taskInstance.fullyValidatedBy}">Validated by: ${fieldValue(bean: taskInstance, field: "fullyValidatedBy")}</g:if></td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  </g:if>
</div>
</body>
</html>
