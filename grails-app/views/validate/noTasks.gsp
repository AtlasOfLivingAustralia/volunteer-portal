<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
  <title>Thank you - we are done for now!</title>
</head>
<body class="two-column-right">
<div class="nav">
  <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
</div>
<div class="body">
  <h1>Thank you - we are done for now !</h1>
  <div class="dialog">
    <p>There are currently no new tasks ready to be validated.</p>
    <p>Please check back later for more validation tasks.</p>
  </div>
</div>
</body>
</html>
