<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'user.label', default: 'Volunteer')}"/>
  <title><g:message code="default.show.label" args="[entityName]"/></title>
  <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.qtip-1.0.0-rc3.min.js')}"></script>
  <script type="text/javascript">
    $(document).ready(function() {
        // Context sensitive help popups
        $("a#gravitarLink").qtip({
            tip: true,
            position: {
                corner: {
                    target: 'bottomRight',
                    tooltip: 'topLeft'
                }
            },
            style: {
                //width: 450,
                padding: 8,
                background: 'white', //'#f0f0f0',
                color: 'black',
                textAlign: 'left',
                border: {
                    width: 4,
                    radius: 5,
                    color: '#E66542'// '#E66542' '#DD3102'
                },
                tip: 'topLeft',
                name: 'light' // Inherit the rest of the attributes from the preset light style
            }
        });

    });
  </script>
</head>
<body>
<div class="nav">
  <span class="menuButton"><a class="crumb" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
  <span class="menuButton"><g:link class="crumb" action="list"><g:message code="default.userlist.label" default="Volunteers"/></g:link></span>
  <span class="menuButton">${fieldValue(bean: userInstance, field: "displayName")}</span>
</div>
<div class="body">
  <h1>Volunteer: ${fieldValue(bean: userInstance, field: "displayName")} <g:if test="${userInstance.userId == currentUser}">(thats you!)</g:if></h1>
  <g:if test="${flash.message}">
    <div class="message">${flash.message}</div>
  </g:if>
  <div class="dialog">
    <table style="border:  none;">
       <tr>
        <td style="padding-top:18px; width:150px;">
          <img src="http://www.gravatar.com/avatar/${userInstance.userId.toLowerCase().encodeAsMD5()}?s=150" style="width:150px;" class="avatar"/>
          <g:if test="${userInstance.userId == currentUser}">
          <p>
            %{--<img src="http://www.gravatar.com/favicon.ico"/>&nbsp;--}%<a href="http://en.gravatar.com/" class="external" target="_blank"
                id="gravitarLink" title="To customise this avatar, register your email address at gravatar.com...">Change avatar</a>
          </p>
          </g:if>
        </td>
        <td>
        <table style="border: none; margin-top: 8px;">
          <tbody>
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.recordsTranscribedCount.label" default="Tasks edited"/></td>
            <td valign="top" class="value">${numberOfTasksEdited}</td>
          </tr>
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.recordsTranscribedCount.label" default="Tasks Completed"/></td>
            <td valign="top" class="value">${fieldValue(bean: userInstance, field: "transcribedCount")}</td>
          </tr>
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.transcribedValidatedCount.label" default="Tasks Validated"/></td>
            <td valign="top" class="value">${fieldValue(bean: userInstance, field: "validatedCount")}</td>
          </tr>
          <!--<tr class="prop">
            <td valign="top" class="name"><g:message code="user.userId.points.tally.label" default="Points"/></td>
            <td valign="top" class="value">${pointsTotal}</td>
          </tr>-->
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.created.label" default="First contribution"/></td>
            <td valign="top" class="value">
              <prettytime:display date="${userInstance?.created}"/>
            </td>
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
    </g:else> (${numberOfTasksEdited} tasks found)
    </h2>
    <div class="list">
        <table style="border: none; width: 100%">
          <tbody>
          <tr>
          <g:each in="${taskInstanceList}" status="i" var="taskInstance">
            <g:if test="${(i % 4) == 0 && i != 0}">
              </tr>
              <tr>
            </g:if>
              <td style="width:220px">
                <g:link controller="transcribe" action="task" id="${taskInstance.id}">
                <img src="${ConfigurationHolder.config.server.url}/${taskInstance?.multimedia?.filePathToThumbnail?.iterator().next()}" width="150px"/>
                </g:link>
                <p><g:link controller="transcribe" action="task" id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link><br/>
                    Status: ${(taskInstance.fullyTranscribedBy) ? 'submitted' : 'saved'}</p>
              </td>
          </g:each>
          <!-- pad it out -->
          <g:each in="${1.. taskInstanceList.size() % 4 }" var="test">
              <td style="width:220px">&nbsp;</td>
          </g:each>
          </tr>
          </tbody>
        </table>
    </div>
    <div class="paginateButtons">
      <g:paginate total="${numberOfTasksEdited}" id="${userInstance?.id}" />
    </div>
%{--
    <div class="list">
      <g:renderTaskList taskInstanceList="${allTasks}" noOfColumns="4"/>
    </div>
    <div class="paginateButtons">
      <g:paginate total="${allTasksTotal}"/>
    </div>--}%
  </g:if>
</div>
</body>
</html>
