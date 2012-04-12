<%@ page import="au.org.ala.volunteer.ViewedTask; au.org.ala.volunteer.Task" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title>Thank you - we are done for now!</title>
    <script type="text/javascript">
        $(document).ready(function() {
            $("li#goBack a").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(action:'task', id: id, controller:'transcribe')}";
            });

            $("li#projectHome a").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(action:'index', controller:'project', id: taskInstance?.project?.id)}";
            });

            $("li#viewTask a").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(controller:'transcribe', action:'showNextFromProject', id:taskInstance?.project?.id)}";
            });

            $("li#viewStats a").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(action:'myStats', controller:'user')}";
            });

            //$("#dateSaved").html(" at " + new Date());
        });
    </script>
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
          <li class="last">What next?</li>
        </ol>
      </nav>
      <hgroup>
        <h1>Transcription Saved</h1>
      </hgroup>
    </div>
  </header>

  <div class="body">
      <div class="inner">
          <p></p>
          <h2>Thank you - your transcription was saved <span id="dateSaved">at
          <g:formatDate date="${ViewedTask.findByTaskAndUserId(taskInstance, userId)?.lastUpdated}" format="h:mm:ss a z 'on' d MMMM yyyy"/></span></h2>
          %{--<h3>What do you want to do next?</h3>--}%
          <ul>
              <li id="goBack"><a href="#">Return to the saved task</a></li>
              <li id="viewTask"><a href="#">Transcribe another task</a></li>
              <li id="projectHome"><a href="#">Return to project start page</a></li>
              <li id="viewStats"><a href="#">View My Stats</a></li>
          </ul>
      </div>
  </div>
</body>
</html>
