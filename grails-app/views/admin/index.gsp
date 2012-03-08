<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
  <title><g:message code="admin.label" default="Administration"/></title>
</head>
<body class="two-column-right">
    <div class="nav">
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <span class="menuButton">Admin</span>
    </div>
    <div class="body">
      <h1>Administration</h1>
      <div class="list">
        <button style="float:left;margin:5px;" onclick="location.href='${createLink(controller:'admin', action:'mailingList')}'">Global mailing List</button>
        <button style="float:left;margin:5px;" onclick="location.href='${createLink(controller:'picklist', action:'manage')}'">Bulk manage picklists</button>
      </div>
    </div>
</body>
</html>
