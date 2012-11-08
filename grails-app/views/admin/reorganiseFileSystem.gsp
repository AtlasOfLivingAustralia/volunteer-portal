<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
  <title><g:message code="admin.label" default="Administration"/></title>
</head>
<body class="sublevel sub-site volunteerportal">
    <div class="nav">
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <span class="menuButton">Admin</span>
    </div>
    <div>
      <h2>Image filesystem restructure</h2>
      <div class="inner">
        <table class="bvp-expeditions">
          <thead>
            <tr>
              <th style="text-align: left"></th>
              <th style="text-align: left"></th>
            </tr>
          </thead>
          <tr>
            <td>Tasks found at wrong level</td>
            <td>${taskCount}</td>
          </tr>
          <tr>
            <td>Non task directories</td>
            <td>${nonTaskDirectories?.size()}</td>
          </tr>
          <tr>
            <td>Existing project directories</td>
            <td>${existingProjectDirectories?.size()}</td>
          </tr>

        </table>

      </div>
    </div>
    <br />
</body>
</html>
