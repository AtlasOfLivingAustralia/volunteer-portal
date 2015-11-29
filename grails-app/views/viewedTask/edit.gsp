<%@ page import="au.org.ala.volunteer.ViewedTask" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'viewedTask.label', default: 'ViewedTask')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
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
    <h1><g:message code="default.edit.label" args="[entityName]"/></h1>
    <cl:messages/>

    <g:hasErrors bean="${viewedTaskInstance}">
        <div class="errors">
            <g:renderErrors bean="${viewedTaskInstance}" as="list"/>
        </div>
    </g:hasErrors>
    <g:form method="post">
        <g:hiddenField name="id" value="${viewedTaskInstance?.id}"/>
        <g:hiddenField name="version" value="${viewedTaskInstance?.version}"/>
        <div class="dialog">
            <table>
                <tbody>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="userId"><g:message code="viewedTask.userId.label" default="User Id"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: viewedTaskInstance, field: 'userId', 'errors')}">
                        <g:textField name="userId" value="${viewedTaskInstance?.userId}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="task"><g:message code="viewedTask.task.label" default="Task"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: viewedTaskInstance, field: 'task', 'errors')}">
                        <g:select name="task.id" from="${au.org.ala.volunteer.Task.list()}" optionKey="id"
                                  value="${viewedTaskInstance?.task?.id}" noSelection="['null': '']"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="numberOfViews"><g:message code="viewedTask.numberOfViews.label"
                                                              default="Number Of Views"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: viewedTaskInstance, field: 'numberOfViews', 'errors')}">
                        <g:textField name="numberOfViews"
                                     value="${fieldValue(bean: viewedTaskInstance, field: 'numberOfViews')}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="lastView"><g:message code="viewedTask.lastView.label" default="Last View"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: viewedTaskInstance, field: 'lastView', 'errors')}">
                        <g:textField name="lastView"
                                     value="${fieldValue(bean: viewedTaskInstance, field: 'lastView')}"/>
                    </td>
                </tr>

                </tbody>
            </table>
        </div>

        <div class="buttons">
            <span class="button"><g:actionSubmit class="save" action="update"
                                                 value="${message(code: 'default.button.update.label', default: 'Update')}"/></span>
            <span class="button"><g:actionSubmit class="delete" action="delete"
                                                 value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                 onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/></span>
        </div>
    </g:form>
</div>
</body>
</html>
