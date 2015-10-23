<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'field.label', default: 'Field')}"/>
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

<div>
    <h1><g:message code="default.show.label" args="[entityName]"/></h1>
    <cl:messages/>
    <div class="dialog">
        <table>
            <tbody>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="field.id.label" default="Id"/></td>

                <td valign="top" class="value">${fieldValue(bean: fieldInstance, field: "id")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="field.task.label" default="Task"/></td>

                <td valign="top" class="value"><g:link controller="task" action="show"
                                                       id="${fieldInstance?.task?.id}">${fieldInstance?.task?.encodeAsHTML()}</g:link></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="field.name.label" default="Name"/></td>

                <td valign="top" class="value">${fieldValue(bean: fieldInstance, field: "name")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="field.recordIdx.label" default="Record Idx"/></td>

                <td valign="top" class="value">${fieldValue(bean: fieldInstance, field: "recordIdx")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="field.transcribedByUserId.label"
                                                         default="Transcribed By User Id"/></td>

                <td valign="top" class="value">${fieldValue(bean: fieldInstance, field: "transcribedByUserId")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="field.validatedByUserId.label"
                                                         default="Validated By User Id"/></td>

                <td valign="top" class="value">${fieldValue(bean: fieldInstance, field: "validatedByUserId")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="field.value.label" default="Value"/></td>

                <td valign="top" class="value">${fieldValue(bean: fieldInstance, field: "value")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="field.superceded.label" default="Superceded"/></td>

                <td valign="top" class="value"><g:formatBoolean boolean="${fieldInstance?.superceded}"/></td>

            </tr>

            </tbody>
        </table>
    </div>

    <div class="buttons">
        <g:form>
            <g:hiddenField name="id" value="${fieldInstance?.id}"/>
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
