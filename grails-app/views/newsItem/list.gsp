<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.NewsItem" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
    </head>

    <body class="sublevel sub-site volunteerportal">
      <nav id="nav-site">
        <ul class="sf sf-js-enabled">
          <li class="nav-bvp"><a href="${createLink(uri:'/')}">Biodiversity Volunteer Portal</a></li>
          <li class="nav-expeditions"><g:link controller="project" action="list">Expeditions</g:link></li>
          <li class="nav-tutorials"><a href="${createLink(uri:'/tutorials.gsp')}">Tutorials</a></li>
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
              <li class="last">
                <g:if test="${projectInstance}">
                  ${projectInstance.name}&nbsp;
                </g:if>
                News Items
              </li>
            </ol>
          </nav>
          <hgroup>
            <h1>News Items<g:if test="${projectInstance}"> - ${projectInstance.featuredLabel}</g:if>
            </h1>
          </hgroup>
        </div>
      </header>

        <div class="body">
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="inner">
                <table class="bvp-expeditions">
                    <thead>
                        <tr>
                            <g:sortableColumn style="text-align: left; width: 100px" property="created" title="${message(code: 'newsItem.created.label', default: 'Date')}" />
                            <g:sortableColumn style="text-align: left; width: 200px" property="title" title="${message(code: 'newsItem.title.label', default: 'Title')}" />
                            <g:sortableColumn style="text-align: left" property="body" title="${message(code: 'newsItem.body.label', default: 'Body')}" />
                            <th style="text-align: left; width: 150px"><g:message code="newsItem.project.label" default="Project" /></th>
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${newsItemInstanceList}" status="i" var="newsItemInstance">
                        <tr>

                            <td style="vertical-align: top"><g:formatDate date="${newsItemInstance.created}" format="dd-MM-yyyy" /></td>

                            <td style="vertical-align: top">
                              <b><g:link controller="newsItem" action="show" id="${newsItemInstance.id}">${fieldValue(bean: newsItemInstance, field: "title")}</g:link></b>

                              <cl:ifGranted role="ROLE_VP_ADMIN">
                                  &nbsp;<g:link style="color: #d3d3d3;" controller="newsItem" action="edit" id="${newsItemInstance.id}">edit...</g:link>
                              </cl:ifGranted>

                            </td>

                            <td>${newsItemInstance?.body}</td>

                            <td style="vertical-align: top">
                              <g:link controller="project" action="index" id="${newsItemInstance?.project?.id}">${newsItemInstance?.project?.featuredLabel}</g:link>
                            </td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
                <div class="paginateButtons">
                    <g:paginate total="${newsItemInstanceTotal}" />
                </div>
            </div>
        </div>
      <script type="text/javascript">
        $("th > a").addClass("button")
        $("th.sorted > a").addClass("current")
      </script>

    </body>
</html>
