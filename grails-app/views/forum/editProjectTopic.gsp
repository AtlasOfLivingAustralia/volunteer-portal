<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html>
  <head>
      <title>Volunteer Portal - Atlas of Living Australia</title>
      <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
      <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
      <g:javascript library="jquery.tools.min"/>
      <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
      <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>
      <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>

      <style type="text/css">

        #title {
          width: 400px;
        }

      </style>

  </head>
  <body class="sublevel sub-site volunteerportal">

    <script type="text/javascript">

      $(document).ready(function() {
      });

    </script>

    <cl:navbar selected="" />

    <header id="page-header">
      <div class="inner">
        <cl:messages />
        <nav id="breadcrumb">
          <ol>
            <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
            <li><a href="${createLink(controller: 'project', action:'index', id: topic.project.id)}">${topic.project.featuredLabel}</a></li>
            <li><a href="${createLink(controller: 'forum', action:'projectForum', params:[projectId:topic.project.id])}"><g:message code="forum.project.forum" default="Project Forum"/></a></li>
            <li class="last"><g:message code="forum.editprojecttopic.label" default="Edit topic" /></li>
          </ol>
        </nav>
        <h1><g:message code="forum.editProjectTopicHeading.label" default="{0} Forum - Edit Topic" args="${[topic.project.featuredLabel]}" /></h1>
      </div>
    </header>
    <div>
      <div class="inner">
        <g:form controller="forum" action="updateProjectTopic" params="${[topicId: topic.id]}" >
          <div class="newTopicFields">
            <h2><g:message code="forum.projectTopicTitle.label" default="Topic title" /></h2>
            <g:textField id="title" name="title" maxlength="200" value="${topic.title}" />
            %{--<h2><g:message code="forum.newProjectTopicMessage.label" default="New topic message" /></h2>--}%
            %{--<g:textArea name="text" rows="6" cols="80" value="${params.text}" />--}%
            <vpf:ifModerator>
              <div class="moderatorOptions">
                <h2><g:message code="forum.moderatorOptions.label" default="Moderator Options" /></h2>
                <label for="sticky"><g:message code="forum.sticky.label" default="Sticky" /></label>
                <g:checkBox name="sticky" checked="${topic.sticky}"/>
                <br/>
                <label for="locked"><g:message code="forum.locked.label" default="Locked" /></label>
                <g:checkBox name="locked" checked="${topic.locked}"/>
                <br/>
                <label for="priority"><g:message code="forum.priority.label" default="Priority" /></label>
                <g:select from="${au.org.ala.volunteer.ForumTopicPriority.values()}" name="priority" value="${topic.priority}" />
              </div>
            </vpf:ifModerator>
            <button type="submit">Update</button>
          </div>
        </g:form>
      </div>
    </div>
  </body>
</html>