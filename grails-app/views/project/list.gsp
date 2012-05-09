<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
  <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}"/>
  <title><g:message code="default.list.label" args="[entityName]"/></title>
  <style type="text/css">

    .ui-widget-header {
      border: 1px solid #3A5C83;
      background: white url(${resource(dir:'images/vp',file:'progress_1x100b.png')}) 50% 50% repeat-x;
    }

    .ui-widget-content {
      border: 1px solid #3A5C83;
    }
  </style>
</head>
<body class="sublevel sub-site volunteerportal">

    <cl:navbar selected="expeditions" />

    <header id="page-header">
      <div class="inner">
        <cl:messages />
        <nav id="breadcrumb">
          <ol>
            <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
            <li class="last">Expeditions</li>
          </ol>
        </nav>
        <hgroup>
          <h1>Volunteer for a virtual expedition</h1>
        </hgroup>
      </div><!--inner-->
    </header>
    <div class="inner">
      <h2>${numberOfUncompletedProjects} expeditions need your help. Join now!</h2>
      <table class="bvp-expeditions">
        <colgroup>
          <col style="width:165px" />
        </colgroup>
        <thead>
        <tr>
          <th><a href="?sort=name&order=${params.sort == 'name' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0" class="button ${params.sort == 'name' ? 'current' : ''}">Name</a></th>
          <th><a href="?sort=completed&order=${params.sort == 'completed' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0" class="button ${params.sort == 'completed' ? 'current' : ''}">Tasks completed</a></th>
          <th><a href="?sort=volunteers&order=${params.sort == 'volunteers' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0" class="button ${params.sort == 'volunteers' ? 'current' : ''}">Volunteers</a></th>
          <th><a href="?sort=institution&order=${params.sort == 'institution' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0" class="button ${params.sort == 'institution' ? 'current' : ''}">Sponsoring Institution</a></th>
          <th><a href="?sort=type&order=${params.sort == 'type' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0" class="button ${params.sort == 'type' ? 'current' : ''}">Type</a></th>
        </tr>
        </thead>
        <tbody>
        <g:each in="${projects}" status="i" var="projectInstance">
          <tr>
            <th colspan="4">
                <h2><a href="${createLink(controller: 'project', action:'index', id: projectInstance.id)}">${projectInstance['project'].featuredLabel}</a></h2>
            </th>
            <th align="center">
              <cl:ifGranted role="ROLE_VP_ADMIN">
                <g:link style="color: #d3d3d3;" controller="project" action="edit" id="${projectInstance['project'].id}">Edit</g:link>
              </cl:ifGranted>
            </th>
          </tr>
          <tr>
            <%-- Project thumbnail --%>
            <td><a href="${createLink(controller: 'project', action:'index', id: projectInstance['project'].id)}">
                <img src="${projectInstance['project'].featuredImage}" width="147" height="81" />
              </a>
            </td>
            <%-- Progress bar --%>
            <td>
              <div id="recordsChart">
                <strong>${projectInstance['countComplete'] ? projectInstance['countComplete'] : 0}</strong> tasks completed (<strong>${projectInstance['percentComplete']}%</strong>)
              </div>
              <div id="recordsChartWidget${i}" class="ui-progressbar ui-widget ui-widget-content ui-corner-all" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="${projectInstance['percentComplete']}">
                <div class="ui-progressbar-value ui-widget-header ui-corner-left ui-corner-right" style="width: ${projectInstance['percentComplete']}%; "></div>
              </div>
            </td>
            <%-- Volunteer count --%>
            <td class="bold centertext">${projectInstance['volunteerCount']}</td>
            <%-- Institution --%>
            <td>${projectInstance['project'].featuredOwner}</td>
            <%-- Project type --%>
            <td class="type"><img src="http://www.ala.org.au/wp-content/themes/ala2011/images/${projectInstance['iconImage']}" width="40" height="36" alt="">${projectInstance['iconLabel']}</td>

          </tr>
        </g:each>
        </tbody>
      </table>
      <div class="paginateButtons">
        <g:paginate total="${projectInstanceTotal}" prev="" next="" />
      </div>
</div>
</body>
</html>
