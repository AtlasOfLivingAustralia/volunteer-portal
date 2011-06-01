<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}"/>
  <title><g:message code="default.create.label" args="[entityName]"/></title>
</head>
<body class="two-column-right">

<div class="nav">
  <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
  <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]"/></g:link></span>
</div>
<div class="body">
  <h1><g:message code="default.create.label" args="[entityName]"/></h1>
  <g:if test="${flash.message}">
    <div class="message">${flash.message}</div>
  </g:if>
  <g:hasErrors bean="${projectInstance}">
    <div class="errors">
      <g:renderErrors bean="${projectInstance}" as="list"/>
    </div>
  </g:hasErrors>
  <g:form action="save">
    <div class="dialog">
      <table>
        <tbody>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="name"><g:message code="project.name.label" default="Name"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'name', 'errors')}">
            <g:textField name="name" maxlength="200" value="${projectInstance?.name}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="description"><g:message code="project.description.label" default="Description"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'description', 'errors')}">
            <g:textArea name="description" cols="40" rows="5" value="${projectInstance?.description}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="created"><g:message code="project.created.label" default="Created"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'created', 'errors')}">
            <g:datePicker name="created" precision="day" value="${projectInstance?.created}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="templateId"><g:message code="project.templateId.label" default="Template Id"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'templateId', 'errors')}">
            <g:select name="templateId" id="templateId" from="${templateList}" optionKey="id" optionValue="name"/>
          </td>
        </tr>

        </tbody>
      </table>
    </div>
    <div class="buttons">
      <span class="button"><g:submitButton name="create" class="save" value="${message(code: 'default.button.create.label', default: 'Create')}"/></span>
    </div>
  </g:form>
  </div>
</body>
</html>
