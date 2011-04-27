<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'templateField.label', default: 'TemplateField')}"/>
  <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>
<body>
<div class="nav">
  <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
  <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]"/></g:link></span>
  <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]"/></g:link></span>
</div>
<div class="body">
  <h1><g:message code="default.edit.label" args="[entityName]"/></h1>
  <g:if test="${flash.message}">
    <div class="message">${flash.message}</div>
  </g:if>
  <g:hasErrors bean="${templateFieldInstance}">
    <div class="errors">
      <g:renderErrors bean="${templateFieldInstance}" as="list"/>
    </div>
  </g:hasErrors>
  <g:form method="post">
    <g:hiddenField name="id" value="${templateFieldInstance?.id}"/>
    <g:hiddenField name="version" value="${templateFieldInstance?.version}"/>
    <div class="dialog">
      <table>
        <tbody>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="dataType"><g:message code="templateField.dataType.label" default="Data Type"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'dataType', 'errors')}">
            <g:textField name="dataType" maxlength="200" value="${templateFieldInstance?.dataType}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="defaultValue"><g:message code="templateField.defaultValue.label" default="Default Value"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'defaultValue', 'errors')}">
            <g:textField name="defaultValue" maxlength="200" value="${templateFieldInstance?.defaultValue}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="mandatory"><g:message code="templateField.mandatory.label" default="Mandatory"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'mandatory', 'errors')}">
            <g:checkBox name="mandatory" value="${templateFieldInstance?.mandatory}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="multiValue"><g:message code="templateField.multiValue.label" default="Multi Value"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'multiValue', 'errors')}">
            <g:checkBox name="multiValue" value="${templateFieldInstance?.multiValue}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="name"><g:message code="templateField.name.label" default="Name"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'name', 'errors')}">
            <g:textField name="name" maxlength="200" value="${templateFieldInstance?.name}"/>
          </td>
        </tr>

        <tr class="prop">
          <td valign="top" class="name">
            <label for="templateId"><g:message code="templateField.templateId.label" default="Template Id"/></label>
          </td>
          <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'templateId', 'errors')}">
            <g:textField name="templateId" value="${fieldValue(bean: templateFieldInstance, field: 'templateId')}"/>
          </td>
        </tr>

        </tbody>
      </table>
    </div>
    <div class="buttons">
      <span class="button"><g:actionSubmit class="save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}"/></span>
      <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/></span>
    </div>
  </g:form>
</div>
</body>
</html>
