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

        $('#searchbox').bind('keypress', function(e) {
            var code = (e.keyCode ? e.keyCode : e.which);
            if(code == 13) {
              doSearch();
            }
        });

    // Context sensitive help popups
    $("a.fieldHelp").qtip({
        tip: true,
        position: {
            corner: {
                target: 'topMiddle',
                tooltip: 'bottomRight'
            }
        },
        style: {
            width: 400,
            padding: 8,
            background: 'white', //'#f0f0f0',
            color: 'black',
            textAlign: 'left',
            border: {
                width: 4,
                radius: 5,
                color: '#E66542'// '#E66542' '#DD3102'
            },
            tip: 'bottomRight',
            name: 'light' // Inherit the rest of the attributes from the preset light style
        }
    }).bind('click', function(e){ e.preventDefault(); return false; });

      });

      doSearch = function() {
        var searchTerm = $('#searchbox').val()
        var link = "${createLink(controller: 'user', action: 'show', id: userInstance.id)}?q=" + searchTerm
        window.location.href = link;
      }
    </script>
  </head>
  <body class="sublevel sub-site volunteerportal">
    <cl:navbar selected="" />
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
                   <td valign="top" class="value">${project.featuredLabel} (<a href="${createLink(controller:'user', action:'show', id:userInstance.id)}">View tasks from all projects</a> )</td>
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
        for ${project.featuredLabel}
    </g:if>
    (${totalSavedTasks} tasks found)
    </h2>
    <div class="list">
            <table class="bvp-expeditions">
                <thead>
                    <tr>

                        <th style="text-align: left">Id</th>

                        <th style="text-align: left">Image ID</th>

                        <th style="text-align: left">Catalog Number</th>

                        <th style="text-align: left">Project</th>

                        <th style="text-align: left">Status</th>

                        %{--<g:sortableColumn style="text-align: left" property="id" title="${message(code: 'task.id.label', default: 'Id')}" params="${[q:params.q]}"/>--}%

                        %{--<g:sortableColumn style="text-align: left" property="externalIdentifier" title="${message(code: 'task.externalIdentifier.label', default: 'Image ID')}" params="${[q:params.q]}"/>--}%




                        %{--<g:sortableColumn style="text-align: left" property="project" title="${message(code: 'task.project.name', default: 'Project')}" params="${[q:params.q]}"/>--}%

                        %{--<g:sortableColumn property="isValid" title="${message(code: 'task.isValid.label', default: 'Status')}" params="${[q:params.q]}" style="text-align: center;"/>--}%

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


  <h2>Transcribed Tasks by
  <g:if test="${userInstance.userId == currentUser}">
    you
  </g:if>
  <g:else>
    ${fieldValue(bean: userInstance, field: "displayName")}
  </g:else>
  <g:if test="${project}">
      for ${project.featuredLabel}
  </g:if>
  <g:if test="${!matchingTasks}">
  <span>(No matching tasks found)</span>
  </g:if>
  <g:else>
    (${totalMatchingTasks} tasks found)
  </g:else>
  </h2>
  <div class="list">
          <table class="bvp-expeditions">
              <thead>
                  <tr>
                    <th colspan="7" style="text-align: right">
                      <span>
                        <a style="vertical-align: middle;" href="#" class="fieldHelp" title="Enter search text here to show only tasks matching values in the ImageID, CatalogNumber, Project and Transcribed columns"><span class="help-container">&nbsp;</span></a>
                      </span>
                      <g:textField id="searchbox" value="${params.q}" name="searchbox" onkeypress=""/>
                      <button onclick="doSearch()">Search</button>
                    </th>
                  </tr>
                  <tr>

                      <g:sortableColumn style="text-align: left" property="t.id" title="${message(code: 'task.id.label', default: 'Id')}" params="${[q:params.q]}"/>

                      <g:sortableColumn style="text-align: left" property="external_identifier" title="${message(code: 'task.externalIdentifier.label', default: 'Image ID')}" params="${[q:params.q]}"/>

                      <g:sortableColumn style="text-align: left" property="value" title="${message(code: 'task.catalogNumber.label', default: 'Catalog Number')}" params="${[q:params.q]}"/>

                      <g:sortableColumn style="text-align: left" property="featured_label" title="${message(code: 'task.project.name', default: 'Project')}" params="${[q:params.q]}"/>

                      <g:sortableColumn property="lastEdit" title="${message(code: 'task.transcribed.label', default: 'Transcribed')}" params="${[q:params.q]}" style="text-align: left;"/>

                      <g:sortableColumn property="is_valid" title="${message(code: 'task.isValid.label', default: 'Status')}" params="${[q:params.q]}" style="text-align: center;"/>

                      <th style="text-align: center;">Action</th>

                  </tr>
              </thead>
              <tbody>
              <g:each in="${matchingTasks}" status="i" var="taskInstance">
                  <tr>

                      <td><g:link controller="transcribe" action="task" id="${taskInstance.id}">${taskInstance.id}</g:link></td>

                      <td>${taskInstance.externalIdentifier}</td>

                      <td>${taskInstance.catalogNumber}</td>

                      <td><g:link controller="project" action="index" id="${taskInstance.projectId}">${taskInstance.project}</g:link></td>

                      <td>
                        <g:formatDate date="${taskInstance.lastEdit}" format="dd MMM, yyyy HH:mm:ss" />

                      </td>

                      <td style="text-align: center;">
                          ${taskInstance.status}
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
    <g:paginate total="${totalMatchingTasks}" id="${userInstance?.id}" params="${params}"/>
  </div>

  </div>
    <script type="text/javascript">
      $("th > a").addClass("button")
      $("th.sorted > a").addClass("current")
    </script>
  </body>
</html>
