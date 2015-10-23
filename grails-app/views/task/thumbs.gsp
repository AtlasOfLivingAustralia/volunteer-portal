<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<%@ page import="groovy.time.*" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="two-column-right">
<div class="nav">
    <span class="menuButton"><a class="crumb" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
    <span class="menuButton"><g:link controller="project" action="list">Projects</g:link></span>
    <g:if test="${projectInstance}">
        <span class="menuButton">${projectInstance.name}</span>
    </g:if>
    <g:else>
        <span class="menuButton">Tasks</span>
    </g:else>
</div>

<div class="inner">
    <h1>Task list <g:if test="${projectInstance}">for ${projectInstance.name}</g:if></h1>
    <g:if test="${taskInstanceList}">
        <div class="list">
            <g:renderTaskList taskInstanceList="${taskInstanceList}" noOfColumns="4"/>
        </div>

        <div class="paginateButtons">
            <g:paginate total="${taskInstanceTotal}" id="${projectInstance?.id}"/>
        </div>
    </g:if>
    <g:else>
        <div>
            <p>No tasks currently loaded for this project.</p>
        </div>
    </g:else>
</div>
</body>
</html>
