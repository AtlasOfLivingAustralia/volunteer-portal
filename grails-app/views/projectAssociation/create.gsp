<%@ page import="au.org.ala.volunteer.ProjectAssociation" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'projectAssociation.label', default: 'ProjectAssociation')}"/>
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
    <g:hasErrors bean="${projectAssociationInstance}">
        <div class="errors">
            <g:renderErrors bean="${projectAssociationInstance}" as="list"/>
        </div>
    </g:hasErrors>
    <g:form action="save">
        <div class="dialog">
            <table>
                <tbody>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="entityUid"><g:message code="projectAssociation.entityUid.label"
                                                          default="Entity Uid"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: projectAssociationInstance, field: 'entityUid', 'errors')}">
                        <g:textField name="entityUid" maxlength="200" value="${projectAssociationInstance?.entityUid}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="project"><g:message code="projectAssociation.project.label"
                                                        default="Project"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: projectAssociationInstance, field: 'project', 'errors')}">
                        <g:select name="project.id" from="${au.org.ala.volunteer.Project.list()}" optionKey="id"
                                  value="${projectAssociationInstance?.project?.id}"/>
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
