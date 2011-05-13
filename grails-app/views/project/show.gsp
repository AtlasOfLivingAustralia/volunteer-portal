<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}"/>
  <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>
<body class="two-column-right">
  <div id="wrapper">
    <div id="column-one">
      <div class="section">
        <h1><g:message code="default.show.label" args="[entityName]"/></h1>
        <g:if test="${flash.message}">
          <div class="message">${flash.message}</div>
        </g:if>
        <div class="dialog">
          <table>
            <tbody>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="project.name.label" default="Name"/></td>
              <td valign="top" class="value">${fieldValue(bean: projectInstance, field: "name")}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="project.description.label" default="Description"/></td>
              <td valign="top" class="value">${fieldValue(bean: projectInstance, field: "description")}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="project.created.label" default="Created"/></td>
              <td valign="top" class="value"><g:formatDate date="${projectInstance?.created}"/></td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="project.templateId.label" default="Template Id"/></td>
              <td valign="top" class="value">${fieldValue(bean: projectInstance, field: "templateId")}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="project.taskCount.label" default="Task count"/></td>
              <td valign="top" class="value">
                <g:if test="${taskCount.size()>0 && taskCount.get(0)>0}">
                  <g:link controller="task" action="project" id="${projectInstance.id}" title="Click to view loaded tasks">${taskCount.get(0)} tasks loaded</g:link>
                </g:if>
                <g:else>
                  0
                </g:else>
              </td>
            </tr>
            </tbody>
          </table>
        </div>
        <div class="buttons">
          <g:form>
            <g:hiddenField name="id" value="${projectInstance?.id}"/>
            <span class="button"><g:actionSubmit class="edit" action="edit" value="${message(code: 'default.button.edit.label', default: 'Edit')}"/></span>
            <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/></span>
          </g:form>
        </div>
      </div>
    </div><!-- column-one -->
    <div id="column-two">
      <div class="section">
        <h2>Actions</h2>
        <ul>
          <li><span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span></li>
          <li><span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]"/></g:link></span></li>
          <li><span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]"/></g:link></span></li>
          <li><g:link class="list" action="deleteTasks" controller="project" id="${projectInstance.id}">
              <g:message code="default.delete.tasks" default="Delete tasks"/></g:link>
          </li>
          <li><g:link class="list" action="load" controller="task" id="${projectInstance.id}">
              <g:message code="default.upload.tasks" default="Upload tasks"/></g:link>
          </li>
          <li><g:link class="list" action="edit" controller="project" id="${projectInstance.id}">
              <g:message code="default.edit.project" default="Upload tasks"/></g:link>
          </li>
        </ul>
      </div>
    </div><!-- column-two -->
    </div>
  </div>
</body>
</html>
