<%@ page import="au.org.ala.volunteer.User" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}"/>
  <title><g:message code="default.create.label" args="[entityName]"/></title>
</head>
<body>
<div class="nav">
  <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
  <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]"/></g:link></span>
</div>
<div class="body">
  <h1><g:message code="default.create.label" args="[entityName]"/></h1>
  <g:if test="${flash.message}">
    <div class="message">${flash.message}</div>
  </g:if>
  <g:hasErrors bean="${userInstance}">
    <div class="errors">
      <g:renderErrors bean="${userInstance}" as="list"/>
    </div>
  </g:hasErrors>
  <g:form action="save">
    <div class="dialog">
      <table>
        <tbody>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="created"><g:message code="user.created.label" default="Created"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'created', 'errors')}">
            <g:datePicker name="created" precision="day" value="${userInstance?.created}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="recordsTranscribedCount"><g:message code="user.recordsTranscribedCount.label" default="Records Transcribed Count"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'recordsTranscribedCount', 'errors')}">
            <g:textField name="recordsTranscribedCount" value="${fieldValue(bean: userInstance, field: 'recordsTranscribedCount')}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="transcribedValidatedCount"><g:message code="user.transcribedValidatedCount.label" default="Transcribed Validated Count"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'transcribedValidatedCount', 'errors')}">
            <g:textField name="transcribedValidatedCount" value="${fieldValue(bean: userInstance, field: 'transcribedValidatedCount')}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="userId"><g:message code="user.userId.label" default="User Id"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'userId', 'errors')}">
            <g:textField name="userId" maxlength="200" value="${userInstance?.userId}"/>
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
