<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
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
                <span class="menuButton"><g:link controller="project" action="index" id="${projectInstance.id}">${projectInstance.name}</g:link></span>
            </g:if>
            <g:else>
                <span class="menuButton">Tasks</span>
            </g:else>
        </div>
        <div class="inner">
            <h1><g:message code="default.list.label" args="[entityName]" /></h1>
            <div style="margin: 8px 0 6px 0; clear: both;">
                Total Tasks: ${taskInstanceTotal},
                <g:if test="${projectInstance}">
                    Transcribed Tasks: ${Task.countByProjectAndFullyTranscribedByNotIsNull(projectInstance)},
                    Validated Tasks: ${Task.countByProjectAndFullyValidatedByNotIsNull(projectInstance)}
                </g:if>
                &nbsp;&nbsp;
                <input type="text" name="q" id="q" value="${params.q}" size="40" />
                <button id="searchButton">search</button>
            </div>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table style="border-top: 2px solid #D9D9D9; width: 100%;">
                    <thead>
                        <tr>
                        
                            <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'Id')}" params="${[q:params.q]}"/>

                            <g:sortableColumn property="externalIdentifier" title="${message(code: 'task.externalIdentifier.label', default: 'Image ID')}" params="${[q:params.q]}"/>
                        
                            <g:each in="${extraFields}" var="field"><th>${field.key?.capitalize().replaceAll(~/([a-z])([A-Z])/, '$1 $2')}</th></g:each>
                        
                            <g:sortableColumn property="fullyTranscribedBy" title="${message(code: 'task.fullyTranscribedBy.label', default: 'Fully Transcribed By')}" params="${[q:params.q]}"/>
                        
                            <g:sortableColumn property="isValid" title="${message(code: 'task.isValid.label', default: 'Status')}" params="${[q:params.q]}" style="text-align: center;"/>

                            <th style="text-align: center;">Action</th>
                            %{--<th>debug</th>--}%
                            
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${taskInstanceList}" status="i" var="taskInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link controller="transcribe" action="task" id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link></td>
                        
                            <td>${fieldValue(bean: taskInstance, field: "externalIdentifier")}</td>

                            <g:each in="${extraFields}" var="field"><td>${field.value[i]?.value}</td></g:each>
                        
                            %{--<td>${taskInstance.fullyTranscribedBy?.replaceAll(/@.*/, "...")}</td>--}%

                            <td>
                                <g:if test="${taskInstance.fullyTranscribedBy}">
                                    <g:set var="thisUser" value="${User.findByUserId(taskInstance.fullyTranscribedBy)}"/>
                                    <g:link controller="user" action="show" id="${thisUser.id}">${thisUser.displayName}</g:link>
                                </g:if>
                            </td>
                        
                            <td style="text-align: center;">
                                <g:if test="${taskInstance.isValid == true}">validated</g:if>
                                <g:elseif test="${taskInstance.isValid == false}">invalidated</g:elseif>
                                <g:elseif test="${taskInstance.fullyTranscribedBy}">submitted</g:elseif>
                            </td>

                            <td style="text-align: center;">
                                <g:if test="${taskInstance.fullyTranscribedBy}">
                                    <g:link controller="transcribe" action="task" id="${taskInstance.id}">view</g:link>
                                </g:if>
                                <g:else>
                                    <button onclick="location.href='${createLink(controller:'transcribe', action:'task', id:taskInstance.id)}'">transcribe</button>
                                </g:else>
                            </td>

                            %{--<td><cl:loggedInName /></td>--}%

                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${taskInstanceTotal}" id="${params?.id}" params="${[q:params?.q]}"/>
            </div>
        </div>
    </body>
</html>
