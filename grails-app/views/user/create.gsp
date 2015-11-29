<%@ page import="au.org.ala.volunteer.User" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}"/>
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
    <g:hasErrors bean="${userInstance}">
        <div class="errors">
            <g:renderErrors bean="${userInstance}" as="list"/>
        </div>
    </g:hasErrors>
    <g:form action="save">
        <div class="dialog">
            <table>
                <tbody>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="created"><g:message code="user.created.label" default="Created"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'created', 'errors')}">
                        <g:datePicker name="created" precision="day" value="${userInstance?.created}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="transcribedCount"><g:message code="user.transcribedCount.label"
                                                                 default="Transcribed Count"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: userInstance, field: 'transcribedCount', 'errors')}">
                        <g:textField name="transcribedCount"
                                     value="${fieldValue(bean: userInstance, field: 'transcribedCount')}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="validatedCount"><g:message code="user.validatedCount.label"
                                                               default="Validated Count"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'validatedCount', 'errors')}">
                        <g:textField name="validatedCount"
                                     value="${fieldValue(bean: userInstance, field: 'validatedCount')}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="userId"><g:message code="user.userId.label" default="User Id"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'userId', 'errors')}">
                        <g:textField name="userId" maxlength="200" value="${userInstance?.userId}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="displayName"><g:message code="user.displayName.label"
                                                            default="Display Name"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: userInstance, field: 'displayName', 'errors')}">
                        <g:textField name="displayName" value="${userInstance?.displayName}"/>
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
