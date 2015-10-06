<%@ page import="au.org.ala.volunteer.ViewedTask" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'viewedTask.label', default: 'ViewedTask')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body>
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
    <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label"
                                                                               args="[entityName]"/></g:link></span>
</div>

<div class="inner">
    <h1><g:message code="default.list.label" args="[entityName]"/></h1>
    <cl:messages/>
    <div class="list">
        <table>
            <thead>
            <tr>

                <g:sortableColumn property="id" title="${message(code: 'viewedTask.id.label', default: 'Id')}"/>

                <g:sortableColumn property="userId"
                                  title="${message(code: 'viewedTask.userId.label', default: 'User Id')}"/>

                <th><g:message code="viewedTask.task.label" default="Task"/></th>

                <g:sortableColumn property="numberOfViews"
                                  title="${message(code: 'viewedTask.numberOfViews.label', default: 'Number Of Views')}"/>

                <g:sortableColumn property="dateCreated"
                                  title="${message(code: 'viewedTask.dateCreated.label', default: 'Date Created')}"/>

                <g:sortableColumn property="lastUpdated"
                                  title="${message(code: 'viewedTask.lastUpdated.label', default: 'Last Updated')}"/>

            </tr>
            </thead>
            <tbody>
            <g:each in="${viewedTaskInstanceList}" status="i" var="viewedTaskInstance">
                <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                    <td><g:link action="show"
                                id="${viewedTaskInstance.id}">${fieldValue(bean: viewedTaskInstance, field: "id")}</g:link></td>

                    <td>${fieldValue(bean: viewedTaskInstance, field: "userId")}</td>

                    <td>${fieldValue(bean: viewedTaskInstance, field: "task")}</td>

                    <td>${fieldValue(bean: viewedTaskInstance, field: "numberOfViews")}</td>

                    <td><g:formatDate date="${viewedTaskInstance.dateCreated}"/></td>

                    <td><g:formatDate date="${viewedTaskInstance.lastUpdated}"/></td>

                </tr>
            </g:each>
            </tbody>
        </table>
    </div>

    <div class="paginateButtons">
        <g:paginate total="${viewedTaskInstanceTotal}"/>
    </div>
</div>
</body>
</html>
