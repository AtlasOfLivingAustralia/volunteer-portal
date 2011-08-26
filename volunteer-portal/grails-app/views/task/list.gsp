
<%@ page import="au.org.ala.volunteer.Task" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
            <span class="menuButton"><g:link controller="project" action="list"> Projects </g:link></span>
            <g:if test="${projectInstance}">
                <span class="menuButton">${projectInstance.name}</span>
            </g:if>
            <g:else>
                <span class="menuButton">Tasks</span>
            </g:else>
        </div>
        <div class="body">
            <h1>Admin <g:message code="default.list.label" args="[entityName]" /></h1>
            <div style="margin: 8px 0 4px 0;">
                Total Tasks: ${taskInstanceTotal},
                Transcribed Tasks: ${Task.countByProjectAndFullyTranscribedByNotIsNull(projectInstance)},
                Validated Tasks: ${Task.countByProjectAndFullyValidatedByNotIsNull(projectInstance)}
                &nbsp;&nbsp;<button onclick="location.href='${createLink(controller:'project', action:'exportCSV', id:projectInstance.id)}'">Export validated tasks as CSV</button>
            </div>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                            <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'Id')}" />
                        
                            <g:sortableColumn property="externalIdentifier" title="${message(code: 'task.externalIdentifier.label', default: 'External Identifier')}" />
                        
                            %{--<g:sortableColumn property="project" title="${message(code: 'task.project.label', default: 'Project')}" />--}%
                        
                            <g:sortableColumn property="fullyTranscribedBy" title="${message(code: 'task.fullyTranscribedBy.label', default: 'Fully Transcribed By')}" />
                        
                            <g:sortableColumn property="fullyValidatedBy" title="${message(code: 'task.fullyValidatedBy.label', default: 'Fully Validated By')}" />
                        
                            %{--<g:sortableColumn property="viewed" title="${message(code: 'task.viewed.label', default: 'Viewed')}" />--}%

                            <cl:ifGranted role="ROLE_ADMIN">
                                <th>Validate</th>
                            </cl:ifGranted>

                            %{--<th>debug</th>--}%
                            
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${taskInstanceList}" status="i" var="taskInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link controller="transcribe" action="task" id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link></td>
                        
                            <td>${fieldValue(bean: taskInstance, field: "externalIdentifier")}</td>
                        
                            %{--<td>${fieldValue(bean: taskInstance, field: "project")}</td>--}%
                        
                            <td>${fieldValue(bean: taskInstance, field: "fullyTranscribedBy")}</td>
                        
                            <td>${fieldValue(bean: taskInstance, field: "fullyValidatedBy")}</td>
                        
                            %{--<td>${fieldValue(bean: taskInstance, field: "viewed")}</td>--}%

                            <cl:ifGranted role="ROLE_ADMIN">
                                <td>
                                    <g:if test="${!taskInstance.fullyValidatedBy}">
                                        <g:link controller="validate" action="task" id="${taskInstance.id}">Validate</g:link>
                                    </g:if>
                                    <g:else>
                                        Validated
                                    </g:else>
                                </td>
                            </cl:ifGranted>

                            %{--<td><cl:loggedInName /></td>--}%

                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${taskInstanceTotal}" id="${params?.id}"/>
            </div>
        </div>
    </body>
</html>
