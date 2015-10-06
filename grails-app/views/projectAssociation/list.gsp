<%@ page import="au.org.ala.volunteer.ProjectAssociation" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'projectAssociation.label', default: 'ProjectAssociation')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body>
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
    <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label"
                                                                               args="[entityName]"/></g:link></span>
</div>

<div>
    <h1><g:message code="default.list.label" args="[entityName]"/></h1>
    <cl:messages/>
    <div class="list">
        <table>
            <thead>
            <tr>

                <g:sortableColumn property="id" title="${message(code: 'projectAssociation.id.label', default: 'Id')}"/>

                <g:sortableColumn property="entityUid"
                                  title="${message(code: 'projectAssociation.entityUid.label', default: 'Entity Uid')}"/>

                <th><g:message code="projectAssociation.project.label" default="Project"/></th>

            </tr>
            </thead>
            <tbody>
            <g:each in="${projectAssociationInstanceList}" status="i" var="projectAssociationInstance">
                <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                    <td><g:link action="show"
                                id="${projectAssociationInstance.id}">${fieldValue(bean: projectAssociationInstance, field: "id")}</g:link></td>

                    <td>${fieldValue(bean: projectAssociationInstance, field: "entityUid")}</td>

                    <td>${fieldValue(bean: projectAssociationInstance, field: "project")}</td>

                </tr>
            </g:each>
            </tbody>
        </table>
    </div>

    <div class="paginateButtons">
        <g:paginate total="${projectAssociationInstanceTotal}"/>
    </div>
</div>
</body>
</html>
