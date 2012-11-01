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

      <style type="text/css">
        .buttonBar {
          margin-bottom: 10px;
        }

        .value textarea {
          width: 400px
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
            <li><a href="${createLink(controller: 'project', action:'index', id: projectInstance.id)}">${projectInstance.featuredLabel}</a></li>
            <li><a href="${createLink(controller: 'forum', action:'projectForum', params:[projectId:projectInstance.id])}"><g:message code="forum.project.forum" default="Project Forum"/></a></li>
            <li class="last"><g:message code="forum.newprojecttopic.label" default="New topic" /></li>
          </ol>
        </nav>
        <h1>Project Forum - ${projectInstance.featuredLabel}</h1>
      </div>
    </header>
    <div>
      <div class="inner">
        <h2>Add new project topic</h2>
        <g:form controller="forum" action="saveNewProjectTopic" params="${[projectId: projectInstance.id]}" >
          <table style="width:100%" >
            <tbody>
              %{--<tr class="prop">--}%
                  %{--<td valign="top" class="name">--}%
                    %{--<label for="name"><g:message code="forum.project.label" default="Project" /></label>--}%
                  %{--</td>--}%
                  %{--<td valign="top" class="value">--}%
                      %{--<g:textField name="name" maxlength="200" value="${projectInstance?.featuredLabel}" disabled="true" />--}%
                  %{--</td>--}%
              %{--</tr>--}%
              <tr class="prop">
                  <td valign="top" class="name">
                    <label for="title"><g:message code="forum.title.label" default="Title" /></label>
                  </td>
                  <td valign="top" class="value">
                      <g:textField name="title" maxlength="200" value="${params.title}" />
                  </td>
              </tr>
              <tr class="prop">
                  <td valign="top" class="name">
                    <label for="text"><g:message code="forum.message.label" default="Message" /></label>
                  </td>
                  <td valign="top" class="value">
                      <g:textArea name="text" rows="6" cols="80" value="${params.text}" />
                  </td>
              </tr>
              <vpf:ifModerator>
                <tr>
                  <td valign="top" class="name">
                    <label for="sticky"><g:message code="forum.sticky.label" default="Sticky" /></label>
                  </td>
                  <td valign="top" class="value">
                      <g:checkBox name="sticky" checked="${params.sticky}"/>
                  </td>
                </tr>
                <tr>
                  <td valign="top" class="name">
                    <label for="locked"><g:message code="forum.locked.label" default="Locked" /></label>
                  </td>
                  <td valign="top" class="value">
                      <g:checkBox name="locked" checked="${params.locked}"/>
                  </td>
                </tr>
                <tr>
                  <td valign="top" class="name">
                    <label for="priority"><g:message code="forum.priority.label" default="Priority" /></label>
                  </td>
                  <td valign="top" class="value">
                      <g:select from="${au.org.ala.volunteer.ForumTopicPriority.values()}" name="priority" />
                  </td>
                </tr>

              </vpf:ifModerator>
            </tbody>
          </table>
          <button type="submit">Save</button>
        </g:form>
      </div>
    </div>
  </body>
</html>