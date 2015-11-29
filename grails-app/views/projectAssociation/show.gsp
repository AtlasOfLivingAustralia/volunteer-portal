<%@ page import="au.org.ala.volunteer.ProjectAssociation" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'projectAssociation.label', default: 'ProjectAssociation')}"/>
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
                <td valign="top" class="name"><g:message code="projectAssociation.id.label" default="Id"/></td>

                <td valign="top" class="value">${fieldValue(bean: projectAssociationInstance, field: "id")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="projectAssociation.entityUid.label"
                                                         default="Entity Uid"/></td>

                <td valign="top" class="value">${fieldValue(bean: projectAssociationInstance, field: "entityUid")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="projectAssociation.project.label"
                                                         default="Project"/></td>

                <td valign="top" class="value"><g:link controller="project" action="show"
                                                       id="${projectAssociationInstance?.project?.id}">${projectAssociationInstance?.project?.encodeAsHTML()}</g:link></td>

            </tr>

            </tbody>
        </table>
    </div>

    <div class="buttons">
        <g:form>
            <g:hiddenField name="id" value="${projectAssociationInstance?.id}"/>
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
