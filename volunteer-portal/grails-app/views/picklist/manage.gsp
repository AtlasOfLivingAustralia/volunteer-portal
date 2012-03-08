<%@ page import="au.org.ala.volunteer.Picklist" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
  <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
  <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>
<body >
  <g:form controller="picklist" action="manage">
    <div class="nav">
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <span class="menuButton"><a class="home" href="${createLink(uri: '/admin/index')}"><g:message code="default.admin.label" default="Admin"/></a></span>
      <span class="menuButton">Picklists</span>
    </div>
    <h1><g:message code="manage.list.label" args="[entityName]" default="Manage picklists"/></h1>
    <br >
    <div class="body">
      <g:select name="picklistId" from="${picklistInstanceList}" optionKey="id" optionValue="name" value="${id}" />
      <g:actionSubmit name="download.picklist" value="${message(code:'download.picklist.label', default: 'Download')}" action="download" />
      <g:actionSubmit name="load.textarea" value="${message(code:'loadtextarea.label', default: 'Load items into text area')}" action="loadcsv" />
    </div>
    <br />
    <p>
    <g:message code="picklist.paste.here.label" default="Paste csv list here. Each line should take the format '&lt;value&gt;'[,&lt;optional key&gt;]"/>
    </p>
    <g:textArea name="picklist" rows="25" cols="40" value="${picklistData}"/>
    <br >
    <g:actionSubmit name="upload.picklist" value="${message(code:'upload.picklist.label', default: 'Upload')}" action="uploadCsvData" />
  </g:form>
</body>
</html>
