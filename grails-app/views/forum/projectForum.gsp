<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html>
  <head>
      <title>Volunteer Portal - Atlas of Living Australia</title>
      <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
      <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
      <link rel="stylesheet" href="${resource(dir:'css',file:'forum.css')}" />
      <g:javascript library="jquery.tools.min"/>
      <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
      <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>

      <style type="text/css">

        .buttonBar {
          margin-bottom: 10px;
        }

      </style>

  </head>
  <body class="sublevel sub-site volunteerportal">

    <script type="text/javascript">

      $(document).ready(function() {

        $("#btnNewProjectTopic").click(function(e) {
          e.preventDefault();
          window.location = "${createLink(controller: 'forum', action:'addProjectTopic', params:[projectId: projectInstance.id])}";
        });

        $("#deleteTopicLink").click(function(e) {

          var topicId = $(this).parents("tr[topicId]").attr("topicId");

          if (topicId) {
            if (confirm("Are you sure you want to delete this topic?")) {
              window.location = "${createLink(controller:'forum', action:'deleteProjectTopic')}?topicId=" + topicId;
            }

          }
        });

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
            <li class="last"><g:message code="default.projectforum.label" default="Project Forum" /></li>
          </ol>
        </nav>
        <h1>Project Forum - ${projectInstance.featuredLabel}</h1>
      </div>
    </header>
    <div>
      <div class="inner">
        <div class="buttonBar">
          <button id="btnNewProjectTopic" class="button">Create a new topic&nbsp;<img src="${resource(dir:'images', file:'newTopic.png')}"/></button>
        </div>
        <div class="topicTable">
          <table class="forum-table">
            <thead>
              <tr>
                <th colspan="2">Topic</th>
                <th>Replies</th>
                <th>Views</th>
                <th>Posted by</th>
                <th>Date</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
            <g:if test="${topics?.size() == 0}">
              <tr>
                <td colspan="7">
                  There are no topics in this forum yet.
                </td>
              </tr>
            </g:if>
            <g:else>
              <g:each in="${topics}" var="topic">
                <tr class="${topic.priority}${topic.sticky ? ' sticky' : ''}" topicId="${topic.id}">
                  <td style="width: 20px; padding: 0px">
                    <g:if test="${topic.sticky}">
                      <img src="${resource(dir:'images', file:'forum_sticky_topic.png')}"/>
                    </g:if>
                  </td>
                  <td><a href="${createLink(controller: 'forum', action:'projectForumTopic', id:topic.id)}">${topic.title}</a></td>
                  <td>${topicCounts[topic] - 1}</td>
                  <td>${topic.views ?: 0}</td>
                  <td>${topic.creator.displayName}</td>
                  <td>${formatDate(date: topic.dateCreated, format: 'dd MMM yyyy HH:mm:ss')}</td>
                  <td>
                    <a class="button" href="${createLink(controller:'forum', action:'postProjectMessage', params:[topicId: topic.id])}">Reply</a>
                    <vpf:ifModerator project="${projectInstance}">
                      <a class="button" href="${createLink(controller:'forum', action:'editProjectTopic', params:[topicId: topic.id])}">Edit</a>
                      <a class="button" href="#" id="deleteTopicLink">Delete</a>
                    </vpf:ifModerator>
                  </td>
                </tr>
              </g:each>
            </g:else>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </body>
</html>
