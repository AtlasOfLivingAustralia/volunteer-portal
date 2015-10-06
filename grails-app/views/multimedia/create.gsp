<%@ page import="au.org.ala.volunteer.Multimedia" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'multimedia.label', default: 'Multimedia')}"/>
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
    <g:hasErrors bean="${multimediaInstance}">
        <div class="errors">
            <g:renderErrors bean="${multimediaInstance}" as="list"/>
        </div>
    </g:hasErrors>
    <g:form action="save">
        <div class="dialog">
            <table>
                <tbody>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="created"><g:message code="multimedia.created.label" default="Created"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: multimediaInstance, field: 'created', 'errors')}">
                        <g:datePicker name="created" precision="day" value="${multimediaInstance?.created}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="creator"><g:message code="multimedia.creator.label" default="Creator"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: multimediaInstance, field: 'creator', 'errors')}">
                        <g:textField name="creator" maxlength="200" value="${multimediaInstance?.creator}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="filePath"><g:message code="multimedia.filePath.label" default="File Path"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: multimediaInstance, field: 'filePath', 'errors')}">
                        <g:textField name="filePath" maxlength="200" value="${multimediaInstance?.filePath}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="filePathToThumbnail"><g:message code="multimedia.filePathToThumbnail.label"
                                                                    default="File Path To Thumbnail"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: multimediaInstance, field: 'filePathToThumbnail', 'errors')}">
                        <g:textField name="filePathToThumbnail" maxlength="200"
                                     value="${multimediaInstance?.filePathToThumbnail}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="licence"><g:message code="multimedia.licence.label" default="Licence"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: multimediaInstance, field: 'licence', 'errors')}">
                        <g:textField name="licence" maxlength="200" value="${multimediaInstance?.licence}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="mimeType"><g:message code="multimedia.mimeType.label" default="Mime Type"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: multimediaInstance, field: 'mimeType', 'errors')}">
                        <g:textField name="mimeType" maxlength="50" value="${multimediaInstance?.mimeType}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="record"><g:message code="multimedia.record.label" default="Record"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: multimediaInstance, field: 'record', 'errors')}">
                        <g:select name="record.id" from="${au.org.ala.volunteer.Record.list()}" optionKey="id"
                                  value="${multimediaInstance?.record?.id}" noSelection="['null': '']"/>
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
