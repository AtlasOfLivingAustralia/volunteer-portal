<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
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
    <g:hasErrors bean="${taskInstance}">
        <div class="errors">
            <g:renderErrors bean="${taskInstance}" as="list"/>
        </div>
    </g:hasErrors>
    <g:form method="post">
        <g:hiddenField name="id" value="${taskInstance?.id}"/>
        <g:hiddenField name="version" value="${taskInstance?.version}"/>
        <div class="dialog">
            <table>
                <tbody>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="externalIdentifier"><g:message code="task.externalIdentifier.label"
                                                                   default="External Identifier"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: taskInstance, field: 'externalIdentifier', 'errors')}">
                        <g:textField name="externalIdentifier" value="${taskInstance?.externalIdentifier}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="externalUrl"><g:message code="task.externalUrl.label"
                                                            default="External Url"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: taskInstance, field: 'externalUrl', 'errors')}">
                        <g:textField name="externalUrl" value="${taskInstance?.externalUrl}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="fullyTranscribedBy"><g:message code="task.fullyTranscribedBy.label"
                                                                   default="Fully Transcribed By"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: taskInstance, field: 'fullyTranscribedBy', 'errors')}">
                        <g:textField name="fullyTranscribedBy" value="${taskInstance?.fullyTranscribedBy}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="fullyValidatedBy"><g:message code="task.fullyValidatedBy.label"
                                                                 default="Fully Validated By"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: taskInstance, field: 'fullyValidatedBy', 'errors')}">
                        <g:textField name="fullyValidatedBy" value="${taskInstance?.fullyValidatedBy}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="viewed"><g:message code="task.viewed.label" default="Viewed"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: taskInstance, field: 'viewed', 'errors')}">
                        <g:textField name="viewed" value="${fieldValue(bean: taskInstance, field: 'viewed')}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="created"><g:message code="task.created.label" default="Created"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: taskInstance, field: 'created', 'errors')}">
                        <g:datePicker name="created" precision="day" value="${taskInstance?.created}" default="none"
                                      noSelection="['': '']"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="fields"><g:message code="task.fields.label" default="Fields"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: taskInstance, field: 'fields', 'errors')}">

                        <ul>
                            <g:each in="${taskInstance?.fields ?}" var="f">
                                <li><g:link controller="field" action="show"
                                            id="${f.id}">${f?.encodeAsHTML()}</g:link></li>
                            </g:each>
                        </ul>
                        <g:link controller="field" action="create"
                                params="['task.id': taskInstance?.id]">${message(code: 'default.add.label', args: [message(code: 'field.label', default: 'Field')])}</g:link>

                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="multimedia"><g:message code="task.multimedia.label" default="Multimedia"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: taskInstance, field: 'multimedia', 'errors')}">

                        <ul>
                            <g:each in="${taskInstance?.multimedia ?}" var="m">
                                <li><g:link controller="multimedia" action="show"
                                            id="${m.id}">${m?.encodeAsHTML()}</g:link></li>
                            </g:each>
                        </ul>
                        <g:link controller="multimedia" action="create"
                                params="['task.id': taskInstance?.id]">${message(code: 'default.add.label', args: [message(code: 'multimedia.label', default: 'Multimedia')])}</g:link>

                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="project"><g:message code="task.project.label" default="Project"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: taskInstance, field: 'project', 'errors')}">
                        <g:select name="project.id" from="${au.org.ala.volunteer.Project.list()}" optionKey="id"
                                  value="${taskInstance?.project?.id}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="viewedTasks"><g:message code="task.viewedTasks.label"
                                                            default="Viewed Tasks"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: taskInstance, field: 'viewedTasks', 'errors')}">

                        <ul>
                            <g:each in="${taskInstance?.viewedTasks ?}" var="v">
                                <li><g:link controller="viewedTask" action="show"
                                            id="${v.id}">${v?.encodeAsHTML()}</g:link></li>
                            </g:each>
                        </ul>
                        <g:link controller="viewedTask" action="create"
                                params="['task.id': taskInstance?.id]">${message(code: 'default.add.label', args: [message(code: 'viewedTask.label', default: 'ViewedTask')])}</g:link>

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
