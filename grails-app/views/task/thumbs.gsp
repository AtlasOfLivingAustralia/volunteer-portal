<%@ page contentType="text/html; charset=UTF-8" %>
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
    <span class="menuButton"><g:link controller="project" action="list"><g:message code="task.thumbs.projects"/></g:link></span>
    <g:if test="${projectInstance}">
        <span class="menuButton">${projectInstance.name}</span>
    </g:if>
    <g:else>
        <span class="menuButton"><g:message code="task.thumbs.tasks"/></span>
    </g:else>
</div>

<div class="inner">
    <h1><g:message code="task.thumbs.task_list"/> <g:if test="${projectInstance}"><g:message code="task.thumbs.task_list.for"/> ${projectInstance.name}</g:if></h1>
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
            <p><g:message code="task.thumbs.no_tasks_loaded"/></p>
        </div>
    </g:else>
</div>
</body>
</html>
