<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.Task" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title>Thank you - we are done for now!</title>
  </head>
  <body class="sublevel sub-site volunteerportal">

  <nav id="nav-site">
    <ul class="sf sf-js-enabled">
      <li class="nav-bvp"><a href="${createLink(uri:'/')}">Biodiversity Volunteer Portal</a></li>
      <li class="nav-expeditions"><g:link controller="project" action="list">Expeditions</g:link></li>
      <li class="nav-tutorials selected"><a href="${createLink(uri:'/tutorials.gsp')}">Tutorials</a></li>
      <li class="nav-submitexpedition"><a href="${createLink(uri:'/submitAnExpedition.gsp')}">Submit an Expedition</a></li>
      <li class="nav-aboutbvp"><a href="${createLink(uri:'/about.gsp')}">About the Portal</a></li>
    </ul>
  </nav>

  <header id="page-header">
    <div class="inner">
      <g:if test="${flash.message}">
        <div class="message">${flash.message}</div>
      </g:if>

      <nav id="breadcrumb">
        <ol>
          <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
          <li class="last">Thanks - we're done!</li>
        </ol>
      </nav>
      <hgroup>
        <h1>Thank you - we are done for now !</h1>
      </hgroup>
    </div>
  </header>

  <div class="body">

    <div class="inner">

      <p style="text-align: center">There are currently no new tasks ready to transcribe.</p>
      <p style="text-align: center">Please check back later for more transcription tasks.</p>
    </div>
  </div>
  </body>
</html>
