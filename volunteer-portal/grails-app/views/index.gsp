<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="ala"/>
  <title>Volunteer Portal - Atlas of Living Australia</title>
</head>                               y
<body class="two-column-right">
<div id="content">
  <div class="section">
    <h1>Welcome to the Volunteer Portal</h1>
    <p>This is a prototype web application for providing users with the ability to transcribe specimen records.
    <br/>For more information contact <strong>Paul Flemons</strong>.</p>
    <div id="actionList" class="dialog">
      <h2>User actions:</h2>
      <ul>
        <li class="controller"><a href="https://auth.ala.org.au/cas/login?service=http://localhost:8080/volunteer-portal/">Register/Login</a></li>
        <li class="controller"><g:link controller="transcribe">Transcribe</g:link></li>
        <li class="controller"><g:link controller="validate">Validate</g:link></li>
        <li class="controller"><g:link controller="user">User scoreboard</g:link></li>
        <li class="controller"><g:link controller="user" action="myStats">My stats</g:link></li>
      </ul>
    </div>
    <div id="adminActionList" class="dialog">
      <h2>Admin actions:</h2>
      <ul>
        <li class="controller"><g:link controller="project" action="create">Create a Project</g:link></li>
        <li class="controller"><g:link controller="project">List Projects</g:link></li>
        <li class="controller"><g:link controller="task">List Tasks</g:link></li>
        <li class="controller"><g:link controller="task" action="load">Upload tasks for transcribing</g:link></li>
        <li class="controller"><g:link controller="picklist" action="load">Create a picklist</g:link></li>
        <li class="controller"><g:link controller="picklist" action="list">List picklists</g:link></li>
      </ul>
    </div>
  </div>
</div>
</body>
</html>