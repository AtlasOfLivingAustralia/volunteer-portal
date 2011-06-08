<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <title>Volunteer Portal - Atlas of Living Australia</title>
</head>
<body class="two-column-right">
  <div class="body">
    <h1>Welcome to the Volunteer Portal</h1>
    <br/>
    <p>This is a prototype web application for providing users with the ability to transcribe specimen records.
    <br/>For more information contact <strong>Paul Flemons</strong>.</p>
      <div class='front-image'>
           <img src="${resource(dir:'images', file:'map.png')}"/>
      </div>
      <div class='front-buttons'>
          <g:link controller="transcribe">
              <img src="${resource(dir:'images', file:'start-button.png')}"/>
          </g:link><br/>
          <g:link controller="user">
              <img src="${resource(dir:'images', file:'score.png')}"/>
          </g:link>
          <g:link controller="user" action="myStats">
              <img src="${resource(dir:'images', file:'stats.png')}"/>
          </g:link>
      </div>
  </div>
</body>
</html>