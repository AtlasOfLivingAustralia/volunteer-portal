<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>

<body>
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
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
                <td valign="top" class="name"><g:message code="task.id.label" default="Id"/></td>

                <td valign="top" class="value">${fieldValue(bean: taskInstance, field: "id")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="task.externalIdentifier.label"
                                                         default="External Identifier"/></td>

                <td valign="top" class="value">${fieldValue(bean: taskInstance, field: "externalIdentifier")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="task.externalUrl.label" default="External Url"/></td>

                <td valign="top" class="value">${fieldValue(bean: taskInstance, field: "externalUrl")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="task.fullyTranscribedBy.label"
                                                         default="Fully Transcribed By"/></td>

                <td valign="top" class="value">${fieldValue(bean: taskInstance, field: "fullyTranscribedBy")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="task.fullyValidatedBy.label"
                                                         default="Fully Validated By"/></td>

                <td valign="top" class="value">${fieldValue(bean: taskInstance, field: "fullyValidatedBy")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="task.viewed.label" default="Viewed"/></td>

                <td valign="top" class="value">${fieldValue(bean: taskInstance, field: "viewed")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="task.created.label" default="Created"/></td>

                <td valign="top" class="value"><g:formatDate date="${taskInstance?.created}"/></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="task.fields.label" default="Fields"/></td>

                <td valign="top" style="text-align: left;" class="value">
                    <ul>
                        <g:each in="${taskInstance.fields.sort { it.superceded }}" var="f">
                            <li><g:link controller="field" action="show" id="${f.id}">
                                <g:if test="${f.superceded == true}">
                                    (Superceded)&nbsp;
                                </g:if>
                                ${f?.name + ' = ' + f.value}</g:link></li>
                        </g:each>
                    </ul>
                </td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="task.multimedia.label" default="Multimedia"/></td>

                <td valign="top" style="text-align: left;" class="value">
                    <ul>
                        <g:each in="${taskInstance.multimedia}" var="m">
                            <li><g:link controller="multimedia" action="show"
                                        id="${m.id}">${m?.encodeAsHTML()}</g:link></li>
                        </g:each>
                    </ul>
                </td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="task.project.label" default="Project"/></td>

                <td valign="top" class="value"><g:link controller="project" action="show"
                                                       id="${taskInstance?.project?.id}">${taskInstance?.project?.encodeAsHTML()}</g:link></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="task.viewedTasks.label" default="Viewed Tasks"/></td>

                <td valign="top" style="text-align: left;" class="value">
                    <ul>
                        <g:each in="${taskInstance.viewedTasks}" var="v">
                            <li><g:link controller="viewedTask" action="show"
                                        id="${v.id}">${v?.encodeAsHTML()}</g:link></li>
                        </g:each>
                    </ul>
                </td>

            </tr>

            </tbody>
        </table>
    </div>

    <div class="buttons">
        <g:form>
            <g:hiddenField name="id" value="${taskInstance?.id}"/>
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
