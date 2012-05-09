<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
  <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
      <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}"/>
      <title>Volunteers</title>
  </head>

  <body class="sublevel sub-site volunteerportal">

    <cl:navbar selected="" />

    <header id="page-header">
      <div class="inner">
        <nav id="breadcrumb">
          <ol>
            <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
            <li class="last">Volunteers</li>
          </ol>
        </nav>
        <h1>Volunteer list <g:if test="${projectInstance}">for ${projectInstance.name}</g:if></h1>
        </div><!--inner-->
    </header>

<div class="inner">

    <cl:messages />

    <div class="list">
        <table class="bvp-expeditions">
            <thead>
              <tr>
                  <g:if test="${projectInstance}">
                      <th></th>
                      <th>Name</th>
                      <th>Tasks completed</th>
                      <th>Tasks validated</th>
                      <th>A volunteer since</th>
                  </g:if>
                  <g:else>
                      <th></th>
                      <g:sortableColumn style="text-align: left" property="displayName" title="${message(code: 'user.user.label', default: 'Name')}"/>
                      <g:sortableColumn property="transcribedCount" title="${message(code: 'user.recordsTranscribedCount.label', default: 'Tasks completed')}"/>
                      <g:sortableColumn property="validatedCount" title="${message(code: 'user.transcribedValidatedCount.label', default: 'Tasks validated')}"/>
                      <g:sortableColumn property="created" title="${message(code: 'user.created.label', default: 'A volunteer since')}"/>
                  </g:else>

              </tr>
            </thead>
            <tbody>
            <g:each in="${userInstanceList}" status="i" var="userInstance">
                <tr>
                    <td><img src="http://www.gravatar.com/avatar/${userInstance.userId.toLowerCase().encodeAsMD5()}?s=80" class="avatar"/></td>
                    <td style="width:300px;">
                        <g:link controller="user" action="show" id="${userInstance.id}">${fieldValue(bean: userInstance, field: "displayName")}</g:link>
                        <g:if test="${userInstance.userId == currentUser}">(that's you!)</g:if>
                    </td>
                    <td class="bold centertext">${fieldValue(bean: userInstance, field: "transcribedCount")}</td>
                    <td class="bold centertext">${fieldValue(bean: userInstance, field: "validatedCount")}</td>
                    <td class="bold centertext"><prettytime:display date="${userInstance?.created}"/></td>
                </tr>
            </g:each>
            </tbody>
        </table>
    </div>

    <div class="paginateButtons">
        <g:paginate total="${userInstanceTotal}" id="${params.id}"/>
    </div>
</div>
  <script type="text/javascript">
    $("th > a").addClass("button")
    $("th.sorted > a").addClass("current")
  </script>
</body>
</html>
