<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'templateField.label', default: 'TemplateField')}"/>
  <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>
<body>
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

        <g:sortableColumn property="id" title="${message(code: 'templateField.id.label', default: 'Id')}"/>

        <g:sortableColumn property="dataType" title="${message(code: 'templateField.dataType.label', default: 'Data Type')}"/>

        <g:sortableColumn property="defaultValue" title="${message(code: 'templateField.defaultValue.label', default: 'Default Value')}"/>

        <g:sortableColumn property="mandatory" title="${message(code: 'templateField.mandatory.label', default: 'Mandatory')}"/>

        <g:sortableColumn property="multiValue" title="${message(code: 'templateField.multiValue.label', default: 'Multi Value')}"/>

        <g:sortableColumn property="name" title="${message(code: 'templateField.name.label', default: 'Name')}"/>

      </tr>
      </thead>
      <tbody>
      <g:each in="${templateFieldInstanceList}" status="i" var="templateFieldInstance">
        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

          <td><g:link action="show" id="${templateFieldInstance.id}">${fieldValue(bean: templateFieldInstance, field: "id")}</g:link></td>

          <td>${fieldValue(bean: templateFieldInstance, field: "dataType")}</td>

          <td>${fieldValue(bean: templateFieldInstance, field: "defaultValue")}</td>

          <td><g:formatBoolean boolean="${templateFieldInstance.mandatory}"/></td>

          <td><g:formatBoolean boolean="${templateFieldInstance.multiValue}"/></td>

          <td>${fieldValue(bean: templateFieldInstance, field: "name")}</td>

        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div class="paginateButtons">
    <g:paginate total="${templateFieldInstanceTotal}"/>
  </div>
</div>
</body>
</html>
