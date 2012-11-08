<%@ page import="au.org.ala.volunteer.NewsItem" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}" />
        <title><g:message code="default.show.label" args="[entityName]" /></title>
    </head>
    <body class="sublevel sub-site volunteerportal">

      <cl:navbar />

      <header id="page-header">
        <div class="inner">
          <cl:messages />
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

        <div>
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

          <cl:ifAdmin>
            <div class="buttons">
                <g:form>
                    <g:hiddenField name="id" value="${newsItemInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" action="edit" value="${message(code: 'default.button.edit.label', default: 'Edit')}" /></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" /></span>
                </g:form>
            </div>
          </cl:ifAdmin>

        </div>
    </body>
</html>
