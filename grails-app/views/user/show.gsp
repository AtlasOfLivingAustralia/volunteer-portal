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
    <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery-ui-1.8.23.custom.min.js')}"></script>
    <style type="text/css">
      .ui-widget {
        font:1em Arial, Helvetica, sans-serif;
        line-height: 1.2em;
      }

      .ui-widget button {
        font: bold 1em Arial, Helvetica, sans-serif;
        margin: 5px;
      }

      .ui-widget-content .listLink {
        color: #3A5C83;
        margin-top: 20px;
      }

      #taskTabs .ui-state-active {
        background: #FFFEF7;
        font-weight: bold;
      }

      .ui-tabs .ui-tabs-panel {
        background-color: #FFFEF7;
        padding-bottom: 25px;
      }

    </style>
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

        $("#taskTabs").tabs({selected: ${params.selectedTab ?: 0}, show: function(e) {
          var $tabs = $('#taskTabs').tabs();
          var newIndex = $tabs.tabs('option', 'selected');

          if (newIndex != ${params.selectedTab ?: 0}) {
            var url = "${createLink(action:'show', id:userInstance.id)}?selectedTab=" + newIndex + "&projectId=${project?.id ?: ''}";
            window.location.href = url;
          }

        } });

      });

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
        <h1>Volunteer: ${fieldValue(bean: userInstance, field: "displayName")} <g:if test="${userInstance.userId == currentUser}">(that's you!)</g:if></h1>
      </div><!--inner-->
    </header>

<div class="inner">

  <cl:messages />

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
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.score.label" default="Volunteer score"/></td>
            <td valign="top" class="value">${score}</td>
          </tr>
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.recordsTranscribedCount.label" default="Tasks Completed"/></td>
            <td valign="top" class="value">${totalTranscribedTasks} (${userInstance.validatedCount} validated)</td>
          </tr>
          <tr class="prop">
            <td valign="top" class="name"><g:message code="user.transcribedValidatedCount.label" default="Tasks validated"/></td>
            <td valign="top" class="value">${validatedCount}</td>
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
         <td style="vertical-align: top" align="right">
           <g:if test="${achievements.size() > 0}">
             <table class="bvp-expeditions" style="margin:10px; border: 1px solid #d3d3d3;text-align: center; border-collapse: separate;" width="400px">
               <thead>
                <tr><td colspan="5" style="border:none"><h3>Achievements</h3></td></tr>
               </thead>
               <tbody>
                  <tr>
                    <td>
                   <g:each in="${achievements}" var="ach" status="i">
                      <div style="float:left;margin: 10px">
                        <img src='<g:resource file="${ach.icon}"/>' width="50px" alt="${ach.label}" title="${ach.description}"/>
                        %{--<div style="font:0.6em">${ach.label}</div>--}%
                      </div>
                   </g:each>
                  </td>
                  </tr>
               </tbody>
             </table>
           </g:if>
         </td>
       </tr>
       <tr>
         <td colspan="3">
           <cl:ifGranted role="ROLE_VP_ADMIN">
             <g:link controller="user" action="editRoles" id="${userInstance.id}">Manage user roles</g:link>
             &nbsp;Email:&nbsp;<a href="mailto:${userInstance.userId}">${userInstance.userId}</a>
           </cl:ifGranted>

         </td>
       </tr>
    </table>
  </div>

  <div id="taskTabs">

      <ul>
          <li><a href="#tabs-1">Transcribed Tasks</a></li>
          <li><a href="#tabs-2">Saved Tasks</a></li>
          <cl:ifValidator>
            <li><a href="#tabs-3">Validated Tasks</a></li>
          </cl:ifValidator>
      </ul>
      <g:set var="includeParams" value="${params.findAll { it.key != 'selectedTab' }}" />
      <div id="tabs-1" class="tabContent">
        <g:if test="${selectedTab == 0}">
          <g:include action="taskListFragment" params="${includeParams + [projectId:project?.id]}" />
        </g:if>
        <g:else>
          <span>Loading...</span>
        </g:else>
      </div>
      <div id="tabs-2" class="tabContent">
        <g:if test="${selectedTab == 1}">
          <g:include action="taskListFragment" params="${includeParams  + [projectId:project?.id]}" />
        </g:if>
        <g:else>
          <span>Loading...</span>
        </g:else>
      </div>
      <cl:ifValidator>
        <div id="tabs-3" class="tabContent">
          <g:if test="${selectedTab == 2}">
            <g:include action="taskListFragment" params="${includeParams  + [projectId:project?.id]}" />
          </g:if>
          <g:else>
            <span>Loading...</span>
          </g:else>
        </div>
      </cl:ifValidator>
  </div>


  </div>
    <script type="text/javascript">
      $("th > a").addClass("button")
      $("th.sorted > a").addClass("current")
    </script>
  </body>
</html>
