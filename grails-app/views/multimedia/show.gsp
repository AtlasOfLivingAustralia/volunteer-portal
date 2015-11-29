<%@ page import="au.org.ala.volunteer.Multimedia" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'multimedia.label', default: 'Multimedia')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>

<body class="two-column-right">
<div id="content">
    <div class="section">
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message
                    code="default.home.label"/></a></span>
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
                        <td valign="top" class="name"><g:message code="multimedia.id.label" default="Id"/></td>

                        <td valign="top" class="value">${fieldValue(bean: multimediaInstance, field: "id")}</td>

                    </tr>

                    <tr class="prop">
                        <td valign="top" class="name"><g:message code="multimedia.created.label"
                                                                 default="Created"/></td>

                        <td valign="top" class="value"><g:formatDate date="${multimediaInstance?.created}"/></td>

                    </tr>

                    <tr class="prop">
                        <td valign="top" class="name"><g:message code="multimedia.creator.label"
                                                                 default="Creator"/></td>

                        <td valign="top" class="value">${fieldValue(bean: multimediaInstance, field: "creator")}</td>

                    </tr>

                    <tr class="prop">
                        <td valign="top" class="name"><g:message code="multimedia.filePath.label"
                                                                 default="File Path"/></td>

                        <td valign="top" class="value">${fieldValue(bean: multimediaInstance, field: "filePath")}</td>

                    </tr>

                    <tr class="prop">
                        <td valign="top" class="name"><g:message code="multimedia.filePathToThumbnail.label"
                                                                 default="File Path To Thumbnail"/></td>

                        <td valign="top"
                            class="value">${fieldValue(bean: multimediaInstance, field: "filePathToThumbnail")}</td>

                    </tr>

                    <tr class="prop">
                        <td valign="top" class="name"><g:message code="multimedia.licence.label"
                                                                 default="Licence"/></td>

                        <td valign="top" class="value">${fieldValue(bean: multimediaInstance, field: "licence")}</td>

                    </tr>

                    <tr class="prop">
                        <td valign="top" class="name"><g:message code="multimedia.mimeType.label"
                                                                 default="Mime Type"/></td>

                        <td valign="top" class="value">${fieldValue(bean: multimediaInstance, field: "mimeType")}</td>

                    </tr>

                    <tr class="prop">
                        <td valign="top" class="name"><g:message code="multimedia.task.label" default="Task"/></td>

                        <td valign="top" class="value"><g:link controller="task" action="show"
                                                               id="${multimediaInstance?.task?.id}">${multimediaInstance?.task?.encodeAsHTML()}</g:link></td>

                    </tr>


                    <tr class="prop">
                        <td valign="top" class="name"><g:message code="multimedia.image.label" default="Image"/></td>

                        <td valign="top" class="value">
                            <img src="${multimediaInstance?.filePath}"/>
                        </td>

                    </tr>

                    </tbody>
                </table>
            </div>

            <div class="buttons">
                <g:form>
                    <g:hiddenField name="id" value="${multimediaInstance?.id}"/>
                    <span class="button"><g:actionSubmit class="edit" action="edit"
                                                         value="${message(code: 'default.button.edit.label', default: 'Edit')}"/></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete"
                                                         value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                         onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/></span>
                </g:form>
            </div>
        </div>
    </div>
</div>
</body>
</html>
