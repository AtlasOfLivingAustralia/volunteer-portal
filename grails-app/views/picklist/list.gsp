<%@ page import="au.org.ala.volunteer.Picklist" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
  <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>
<body class="two-column-right">
<div id="content">
  <div class="section">
    <div class="nav">
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]"/></g:link></span>
    </div>
    <div class="body">
      <h1><g:message code="default.list.label" args="[entityName]"/></h1>
      <g:if test="${flash.message}">
        <div class="message">${flash.message}</div>
      </g:if>
      <div class="list">
        <table>
          <thead>
          <tr>
            <g:sortableColumn property="id" title="${message(code: 'picklist.id.label', default: 'Id')}"/>
            <g:sortableColumn property="name" title="${message(code: 'picklist.name.label', default: 'Name')}"/>
            <th>Show list</th>
            <th>Delete</th>
          </tr>
          </thead>
          <tbody>
          <g:each in="${picklistInstanceList}" status="i" var="picklistInstance">
            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
              <td><g:link action="show" id="${picklistInstance.id}">${fieldValue(bean: picklistInstance, field: "id")}</g:link></td>
              <td>${fieldValue(bean: picklistInstance, field: "name")}</td>
              <td>show</td>
              <td>delete</td>
            </tr>
          </g:each>
          </tbody>
        </table>
      </div>
      <div class="paginateButtons">
        <g:paginate total="${picklistInstanceTotal}"/>
      </div>
    </div>
  </div>
</div>
</body>
</html>
