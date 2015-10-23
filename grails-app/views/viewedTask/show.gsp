<%@ page import="au.org.ala.volunteer.ViewedTask" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'viewedTask.label', default: 'ViewedTask')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>

<body>
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
    <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label"
                                                                           args="[entityName]"/></g:link></span>
    <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label"
                                                                               args="[entityName]"/></g:link></span>
</div>

<div class="inner">
    <h1><g:message code="default.show.label" args="[entityName]"/></h1>
    <cl:messages/>
    <div class="dialog">
        <table>
            <tbody>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="viewedTask.id.label" default="Id"/></td>

                <td valign="top" class="value">${fieldValue(bean: viewedTaskInstance, field: "id")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="viewedTask.userId.label" default="User Id"/></td>

                <td valign="top" class="value">${fieldValue(bean: viewedTaskInstance, field: "userId")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="viewedTask.task.label" default="Task"/></td>

                <td valign="top" class="value"><g:link controller="task" action="show"
                                                       id="${viewedTaskInstance?.task?.id}">${viewedTaskInstance?.task?.encodeAsHTML()}</g:link></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="viewedTask.numberOfViews.label"
                                                         default="Number Of Views"/></td>

                <td valign="top" class="value">${fieldValue(bean: viewedTaskInstance, field: "numberOfViews")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="viewedTask.dateCreated.label"
                                                         default="Date Created"/></td>

                <td valign="top" class="value"><g:formatDate date="${viewedTaskInstance?.dateCreated}"/></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="viewedTask.lastUpdated.label"
                                                         default="Last Updated"/></td>

                <td valign="top" class="value"><g:formatDate date="${viewedTaskInstance?.lastUpdated}"/></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="viewedTask.lastView.label" default="Last View"/></td>

                <td valign="top" class="value">${fieldValue(bean: viewedTaskInstance, field: "lastView")}</td>

            </tr>

            </tbody>
        </table>
    </div>

    <div class="buttons">
        <g:form>
            <g:hiddenField name="id" value="${viewedTaskInstance?.id}"/>
            <span class="button"><g:actionSubmit class="edit" action="edit"
                                                 value="${message(code: 'default.button.edit.label', default: 'Edit')}"/></span>
            <span class="button"><g:actionSubmit class="delete" action="delete"
                                                 value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                 onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/></span>
        </g:form>
    </div>
</div>
</body>
</html>
