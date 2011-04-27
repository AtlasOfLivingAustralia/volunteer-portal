<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <g:set var="entityName" value="${message(code: 'record.label', default: 'Record')}"/>
  <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>
<body class="two-column-right">
<div id="content">
  <div class="section">
    <div class="nav">
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]"/></g:link></span>
      <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]"/></g:link></span>
    </div>
    <div class="body">
      <h1>Load CSV</h1>

      <g:form method="post">
        <div class="dialog">
          <table>
            <tbody>
            <tr class="prop">
              <td valign="top" class="name">
                <label for="projectId"><g:message code="record.projectId.label" default="Project Id"/></label>
              </td>
              <td valign="top" class="value">
                <g:select name="projectId" id="projectId" from="${projectList}" optionKey="id" optionValue="name"/>
              </td>
            </tr>

            <tr class="prop">
              <td valign="top" class="name">
                <label for="csv"><g:message code="record.csv.label" default="Paste CSV here"/></label>
              </td>
              <td valign="top" class="value">
                <g:textArea name="csv" value="" cols="100" rows="50"/>
              </td>
            </tr>

            </tbody>
          </table>
        </div>
        <div class="buttons">
          <span class="button"><g:actionSubmit class="submit" action="loadCSV" value="${message(code: 'default.button.submit.label', default: 'Submit')}"/></span>
          <span class="button"><g:actionSubmit class="cancel" action="list" value="${message(code: 'default.button.cancel.label', default: 'Cancel')}"/></span>
        </div>
      </g:form>
    </div>
  </div>
</div>

</body>
</html>
