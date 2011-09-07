
<%@ page import="au.org.ala.volunteer.Task" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
        <script type="text/javascript">
            $(document).ready(function() {
                $("#searchButton").click(function(e) {
                    e.preventDefault();
                    var query = $("#q").val()
                    location.href="?q=" + query;
                });

            }); // end .ready()
        </script>
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
            <button style="float:right;margin:5px;" onclick="location.href='${createLink(controller:'project', action:'edit', id:projectInstance.id)}'">Edit Project</button>
            <button style="float:right;margin:5px;" onclick="location.href='${createLink(controller:'newsItem', action:'create', params:['project.id': projectInstance.id])}'">New News Item</button>
            <button style="float:right;margin:5px;" onclick="location.href='${createLink(controller:'project', action:'mailingList', id:projectInstance.id)}'">Mailing List</button>
            <h1>Admin <g:message code="default.list.label" args="[entityName]" /></h1>
            <div style="margin: 8px 0 6px 0; clear: both;">
                Total Tasks: ${taskInstanceTotal},
                Transcribed Tasks: ${Task.countByProjectAndFullyTranscribedByNotIsNull(projectInstance)},
                Validated Tasks: ${Task.countByProjectAndFullyValidatedByNotIsNull(projectInstance)}
                &nbsp;&nbsp;
                <button onclick="location.href='${createLink(controller:'project', action:'exportCSV', id:projectInstance.id, params:[validated:true])}'">Export validated tasks</button>
                <button onclick="location.href='${createLink(controller:'project', action:'exportCSV', id:projectInstance.id, params:[validated:false])}'">Export transcribed tasks</button>
                <input type="text" name="q" id="q" value="${params.q}"/>
                <button id="searchButton">search</button>
            </div>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table style="border-top: 2px solid #D9D9D9;">
                    <thead>
                        <tr>
                        
                            <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'Id')}" params="${[q:params.q]}"/>
                        
                            <th>catalogNumber</th>
                        
                            <g:sortableColumn property="fullyTranscribedBy" title="${message(code: 'task.fullyTranscribedBy.label', default: 'Fully Transcribed By')}" params="${[q:params.q]}"/>
                        
                            <g:sortableColumn property="fullyValidatedBy" title="${message(code: 'task.fullyValidatedBy.label', default: 'Fully Validated By')}" params="${[q:params.q]}"/>
                        
                            <g:sortableColumn property="isValid" title="${message(code: 'task.isValid.label', default: 'Is Valid')}" params="${[q:params.q]}" style="text-align: center;"/>

                            <th style="text-align: center;">Action</th>

                            %{--<th>debug</th>--}%
                            
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${taskInstanceList}" status="i" var="taskInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link controller="transcribe" action="task" id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link></td>
                        
                            <td>${catalogNums[i]?.value}</td>
                        
                            <td>${fieldValue(bean: taskInstance, field: "fullyTranscribedBy")}</td>
                        
                            <td>${fieldValue(bean: taskInstance, field: "fullyValidatedBy")}</td>
                        
                            <td style="text-align: center;">${fieldValue(bean: taskInstance, field: "isValid")}</td>

                            <td style="text-align: center;">
                                <g:if test="${taskInstance.fullyValidatedBy}">
                                    <g:link controller="validate" action="task" id="${taskInstance.id}">review</g:link>
                                </g:if>
                                <g:else>
                                    <button onclick="location.href='${createLink(controller:'validate', action:'task', id:taskInstance.id)}'">validate</button>
                                </g:else>
                            </td>

                            %{--<td><cl:loggedInName /></td>--}%

                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${taskInstanceTotal}" id="${params?.id}" params="${[q:params.q]}"/>
            </div>
        </div>
    </body>
</html>
