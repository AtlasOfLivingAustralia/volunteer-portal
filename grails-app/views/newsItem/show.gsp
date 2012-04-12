<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.NewsItem" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}" />
        <title><g:message code="default.show.label" args="[entityName]" /></title>
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
              <li><a href="${createLink(controller: 'newsItem', action:'list')}">News items</a></li>
              <li class="last"><g:formatDate date="${newsItemInstance?.created}" format="dd-MM-yyyy" />  - <g:link controller="project" action="index" id="${newsItemInstance?.project?.id}">${newsItemInstance?.project?.name}</g:link> - ${fieldValue(bean: newsItemInstance, field: "createdBy")}</li>
            </ol>
          </nav>
          <hgroup>
            <h1>${fieldValue(bean: newsItemInstance, field: "title")}</h1>
          </hgroup>
        </div>
      </header>

        <div class="body">
            <g:if test="${flash.message}">
              <div class="message">${flash.message}</div>
            </g:if>
            <div class="inner">

                <h3>${fieldValue(bean: newsItemInstance, field: "shortDescription")}</h3>

                <div>
                  ${newsItemInstance.body}
                </div>

                <br />

                <div style="text-align: left">
                  <g:link controller="newsItem" action="list">Read more news items...</g:link>
                </div>

            </div>

          <cl:ifGranted role="ROLE_VP_ADMIN">
            <div class="buttons">
                <g:form>
                    <g:hiddenField name="id" value="${newsItemInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" action="edit" value="${message(code: 'default.button.edit.label', default: 'Edit')}" /></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" /></span>
                </g:form>
            </div>
          </cl:ifGranted>

        </div>
    </body>
</html>
