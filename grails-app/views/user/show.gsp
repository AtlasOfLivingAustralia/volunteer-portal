<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
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
  <body class="sublevel sub-site volunteerportal">
  <nav id="nav-site">
    <ul class="sf sf-js-enabled">
      <li class="nav-bvp"><a href="${createLink(uri: '/')}">Biodiversity Volunteer Portal</a></li>
      <li class="nav-expeditions"><a href="${createLink(controller: 'project', action:'list')}">Expeditions</a></li>
      <li class="nav-tutorials"><a href="${createLink(uri: '/tutorials.gsp')}">Tutorials</a></li>
      <li class="nav-submitexpedition"><a href="${createLink(uri:'/submitAnExpedition.gsp')}">Submit an Expedition</a></li>
      <li class="nav-aboutbvp"><a href="${createLink(uri: '/about.gsp')}">About the Portal</a></li></ul>
  </nav>
  <header id="page-header">
    <div class="inner">
      <nav id="breadcrumb">
        <ol>
          <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
          <li><a href="${createLink(controller: 'user', action:'list')}">Volunteers</a></li>
          <li class="last">${fieldValue(bean: userInstance, field: "displayName")}</li>
        </ol>
      </nav>
      <h1>Volunteer: ${fieldValue(bean: userInstance, field: "displayName")} <g:if test="${userInstance.userId == currentUser}">(thats you!)</g:if></h1>
    </div><!--inner-->
  </header>

<div class="inner">
  <g:if test="${flash.message}">
    <div class="message">${flash.message}</div>
  </g:if>
  <div class="list">
    <table class="bvp-expeditions">
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
          <g:if test="${project}">
               <tr class="prop">
                   <td valign="top" class="name"><g:message code="project.label" default="Project"/></td>
                   <td valign="top" class="value">${project} (<a href="${createLink(controller:'user', action:'show', id:userInstance.id)}">View tasks from all projects</a> )</td>
              </tr>
          </g:if>
          %{--<tr class="prop">--}%
            %{--<td valign="top" class="name"><g:message code="user.recordsTranscribedCount.label" default="Tasks edited"/></td>--}%
            %{--<td valign="top" class="value">${numberOfTasksEdited}</td>--}%
          %{--</tr>--}%
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.recordsTranscribedCount.label" default="Tasks Completed"/></td>
            <td valign="top" class="value">${totalTranscribedTasks}</td>
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

  <g:if test="${savedTasks}">
    <h2>&quot;Saved Unfinished&quot; Tasks by
    <g:if test="${userInstance.userId == currentUser}">
      you
    </g:if>
    <g:else>
      ${fieldValue(bean: userInstance, field: "displayName")}
    </g:else>
    <g:if test="${project}">
        - for ${project}
    </g:if>
    (${totalSavedTasks} tasks found)
    </h2>
    <div class="list">
            <table class="bvp-expeditions">
                <thead>
                    <tr>

                        <g:sortableColumn style="text-align: left" property="id" title="${message(code: 'task.id.label', default: 'Id')}" params="${[q:params.q]}"/>

                        <g:sortableColumn style="text-align: left" property="externalIdentifier" title="${message(code: 'task.externalIdentifier.label', default: 'Image ID')}" params="${[q:params.q]}"/>

                        <th style="text-align: left">Catalog Number</th>

                        <g:sortableColumn style="text-align: left" property="project" title="${message(code: 'task.project.name', default: 'Project')}" params="${[q:params.q]}"/>

                        <g:sortableColumn property="isValid" title="${message(code: 'task.isValid.label', default: 'Status')}" params="${[q:params.q]}" style="text-align: center;"/>

                        <th style="text-align: center;">Action</th>

                    </tr>
                </thead>
                <tbody>
                <g:each in="${savedTasks}" status="i" var="taskInstance">
                    <tr>

                        <td><g:link controller="transcribe" action="task" id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link></td>

                        <td>${fieldValue(bean: taskInstance, field: "externalIdentifier")}</td>

                        <td>${fieldsInTask?.get(taskInstance.id)?.get(0)?.catalogNumber}</td>

                        <td>${fieldValue(bean: taskInstance, field: "project")}</td>

                        <td style="text-align: center;">
                            <g:if test="${taskInstance.isValid == true}">validated</g:if>
                            <g:elseif test="${taskInstance.isValid == false}">invalidated</g:elseif>
                            <g:elseif test="${taskInstance.fullyTranscribedBy}">submitted</g:elseif>
                            <g:else>saved</g:else>
                        </td>

                        <td style="text-align: center;">
                            <g:if test="${taskInstance.fullyTranscribedBy}">
                                <g:link controller="transcribe" action="task" id="${taskInstance.id}">view</g:link>
                            </g:if>
                            <g:else>
                                <button onclick="location.href='${createLink(controller:'transcribe', action:'task', id:taskInstance.id)}'">transcribe</button>
                            </g:else>
                        </td>

                    </tr>
                </g:each>
                </tbody>
            </table>
    </div>
    <div class="paginateButtons">
      <g:paginate total="${totalSavedTasks}" id="${userInstance?.id}" params="${params}"/>
    </div>
  </g:if>

  <g:if test="${taskInstanceList}">
    <h2>Transcribed Tasks by
    <g:if test="${userInstance.userId == currentUser}">
      you
    </g:if>
    <g:else>
      ${fieldValue(bean: userInstance, field: "displayName")}
    </g:else>
    <g:if test="${project}">
        - for ${project}
    </g:if>
    (${totalTranscribedTasks} tasks found)
    </h2>
    <div class="list">
            <table class="bvp-expeditions">
                <thead>
                    <tr>

                        <g:sortableColumn style="text-align: left" property="id" title="${message(code: 'task.id.label', default: 'Id')}" params="${[q:params.q]}"/>

                        <g:sortableColumn style="text-align: left" property="externalIdentifier" title="${message(code: 'task.externalIdentifier.label', default: 'Image ID')}" params="${[q:params.q]}"/>

                        <th style="text-align: left">Catalog Number</th>

                        <g:sortableColumn style="text-align: left" property="project" title="${message(code: 'task.project.name', default: 'Project')}" params="${[q:params.q]}"/>

                        <g:sortableColumn property="isValid" title="${message(code: 'task.isValid.label', default: 'Status')}" params="${[q:params.q]}" style="text-align: center;"/>

                        <th style="text-align: center;">Action</th>

                    </tr>
                </thead>
                <tbody>
                <g:each in="${taskInstanceList}" status="i" var="taskInstance">
                    <tr>

                        <td><g:link controller="transcribe" action="task" id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link></td>

                        <td>${fieldValue(bean: taskInstance, field: "externalIdentifier")}</td>

                        <td>${fieldsInTask?.get(taskInstance.id)?.get(0)?.catalogNumber}</td>

                        <td>${fieldValue(bean: taskInstance, field: "project")}</td>

                        <td style="text-align: center;">
                            <g:if test="${taskInstance.isValid == true}">validated</g:if>
                            <g:elseif test="${taskInstance.isValid == false}">invalidated</g:elseif>
                            <g:elseif test="${taskInstance.fullyTranscribedBy}">submitted</g:elseif>
                            <g:else>saved</g:else>
                        </td>

                        <td style="text-align: center;">
                            <g:if test="${taskInstance.fullyTranscribedBy}">
                                <g:link controller="transcribe" action="task" id="${taskInstance.id}">view</g:link>
                            </g:if>
                            <g:else>
                                <button onclick="location.href='${createLink(controller:'transcribe', action:'task', id:taskInstance.id)}'">transcribe</button>
                            </g:else>
                        </td>

                    </tr>
                </g:each>
                </tbody>
            </table>
    </div>
    <div class="paginateButtons">
      <g:paginate total="${totalTranscribedTasks}" id="${userInstance?.id}" params="${params}"/>
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
  <script type="text/javascript">
    $("th > a").addClass("button")
    $("th.sorted > a").addClass("current")
  </script>
</body>
</html>
