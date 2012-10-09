<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
  <title><g:message code="admin.label" default="Administration"/></title>
</head>
<body class="sublevel sub-site volunteerportal">
    <div class="nav">
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <span class="menuButton">Admin</span>
    </div>
    <div>
      <h2>Task consistency report</h2>
      <div class="inner">
        <div>${taskCount} tasks checked.</div>
        <div>${errorCount} tasks found with errors.</div>
        <table class="bvp-expeditions">
          <thead>
            <tr>
              <th style="text-align: left"></th>
              <th style="text-align: left"></th>
            </tr>
          </thead>
          <g:each in="${results}" var="result">
            <tr>
              <td>${result.task.id}</td>
              <td>${result.message}</td>
            </tr>
          </g:each>
        </table>

      </div>
    </div>
    <br />
</body>
</html>
