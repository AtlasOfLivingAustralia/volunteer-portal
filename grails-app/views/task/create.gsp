<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title><g:message code="default.create.label" args="[entityName]"/></title>
</head>

<body>
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
    <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label"
                                                                           args="[entityName]"/></g:link></span>
</div>

<div class="inner">
    <h1><g:message code="default.create.label" args="[entityName]"/></h1>
    <cl:messages/>
    <g:hasErrors bean="${taskInstance}">
        <div class="errors">
            <g:renderErrors bean="${taskInstance}" as="list"/>
        </div>
    </g:hasErrors>
    <g:form action="save">
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
                        <label for="project"><g:message code="task.project.label" default="Project"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: taskInstance, field: 'project', 'errors')}">
                        <g:select name="project.id" from="${au.org.ala.volunteer.Project.list()}" optionKey="id"
                                  value="${taskInstance?.project?.id}"/>
                    </td>
                </tr>

                </tbody>
            </table>
        </div>

        <div class="buttons">
            <span class="button"><g:submitButton name="create" class="save"
                                                 value="${message(code: 'default.button.create.label', default: 'Create')}"/></span>
        </div>
    </g:form>
</div>
</body>
</html>
