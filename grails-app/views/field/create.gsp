<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'field.label', default: 'Field')}"/>
    <title><g:message code="default.create.label" args="[entityName]"/></title>
</head>

<body>
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
    <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label"
                                                                           args="[entityName]"/></g:link></span>
</div>

<div>
    <h1><g:message code="default.create.label" args="[entityName]"/></h1>
    <cl:messages/>

    <g:hasErrors bean="${fieldInstance}">
        <div class="errors">
            <g:renderErrors bean="${fieldInstance}" as="list"/>
        </div>
    </g:hasErrors>
    <g:form action="save">
        <div class="dialog">
            <table>
                <tbody>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="task"><g:message code="field.task.label" default="Task"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: fieldInstance, field: 'task', 'errors')}">
                        <g:select name="task.id" from="${au.org.ala.volunteer.Task.list()}" optionKey="id"
                                  value="${fieldInstance?.task?.id}" noSelection="['null': '']"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="name"><g:message code="field.name.label" default="Name"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: fieldInstance, field: 'name', 'errors')}">
                        <g:textField name="name" maxlength="200" value="${fieldInstance?.name}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="recordIdx"><g:message code="field.recordIdx.label" default="Record Idx"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: fieldInstance, field: 'recordIdx', 'errors')}">
                        <g:textField name="recordIdx" value="${fieldValue(bean: fieldInstance, field: 'recordIdx')}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="transcribedByUserId"><g:message code="field.transcribedByUserId.label"
                                                                    default="Transcribed By User Id"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: fieldInstance, field: 'transcribedByUserId', 'errors')}">
                        <g:textField name="transcribedByUserId" maxlength="200"
                                     value="${fieldInstance?.transcribedByUserId}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="validatedByUserId"><g:message code="field.validatedByUserId.label"
                                                                  default="Validated By User Id"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: fieldInstance, field: 'validatedByUserId', 'errors')}">
                        <g:textField name="validatedByUserId" maxlength="200"
                                     value="${fieldInstance?.validatedByUserId}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="value"><g:message code="field.value.label" default="Value"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: fieldInstance, field: 'value', 'errors')}">
                        <g:textField name="value" value="${fieldInstance?.value}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="superceded"><g:message code="field.superceded.label" default="Superceded"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: fieldInstance, field: 'superceded', 'errors')}">
                        <g:checkBox name="superceded" value="${fieldInstance?.superceded}"/>
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
