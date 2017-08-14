<%@ page import="au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>

    <asset:script type="text/javascript">
        $(document).ready(function () {

            $("#searchButton").click(function (e) {
                e.preventDefault();
                doSearch();
            });

            $("#q").keypress(function (e) {
                if (e.keyCode == 13) {
                    e.preventDefault();
                    doSearch();
                }
            });

        });

        function doSearch() {
            var query = $("#q").val()
            location.href = "?q=" + query;
        }
    </asset:script>

</head>

<body>

<cl:headerContent title="Task List - ${projectInstance ? projectInstance?.i18nName : ''}"
                  selectedNavItem="expeditions">
    <%
        if (projectInstance) {
            pageScope.crumbs = [
                    [link: createLink(controller: 'project', action: 'list'), label: 'Expeditions'],
                    [link: createLink(controller: 'project', action: 'index', id: projectInstance?.id), label: projectInstance?.i18nName]
            ]
        }
    %>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <div class="alert alert-info">
                        <g:message code="task.list.total_tasks"/> ${taskInstanceTotal},
                        <g:if test="${projectInstance}">
                            <g:message code="task.list.transcribed_tasks"/> ${Task.countByProjectAndFullyTranscribedByNotIsNull(projectInstance)},
                            <g:message code="task.list.validated_tasks"/> ${Task.countByProjectAndFullyValidatedByNotIsNull(projectInstance)}
                        </g:if>
                        &nbsp;&nbsp;
                        <input style="margin-bottom: 0px" type="text" name="q" id="q" value="${params.q}" size="40"/>
                        <button class="btn" id="searchButton"> <g:message code="task.list.search"/></button>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <table class="table table-condensed table-striped table-hover">
                        <thead>
                        <tr>

                            <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'Id')}"
                                              params="${[q: params.q]}"/>

                            <g:sortableColumn property="externalIdentifier"
                                              title="${message(code: 'task.externalIdentifier.label', default: 'Image ID')}"
                                              params="${[q: params.q]}"/>

                            <g:each in="${extraFields}"
                                    var="field"><th>${field.key?.capitalize().replaceAll(~/([a-z])([A-Z])/, '$1 $2')}</th></g:each>

                            <g:sortableColumn property="fullyTranscribedBy"
                                              title="${message(code: 'task.fullyTranscribedBy.label', default: 'Fully Transcribed By')}"
                                              params="${[q: params.q]}"/>

                            <g:sortableColumn property="isValid" title="${message(code: 'task.isValid.label', default: 'Status')}"
                                              params="${[q: params.q]}" style="text-align: center;"/>

                            <th style="text-align: center;"> <g:message code="task.list.action"/></th>
                            %{--<th>debug</th>--}%

                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${taskInstanceList}" status="i" var="taskInstance">
                            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                                <td><g:link controller="transcribe" action="task"
                                            id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link></td>

                                <td>${fieldValue(bean: taskInstance, field: "externalIdentifier")}</td>

                                <g:each in="${extraFields}" var="field"><td>${field.value[i]?.value}</td></g:each>

                            %{--<td>${taskInstance.fullyTranscribedBy?.replaceAll(/@.*/, "...")}</td>--}%

                                <td>
                                    <g:if test="${taskInstance.fullyTranscribedBy}">
                                        <g:set var="thisUser" value="${User.findByUserId(taskInstance.fullyTranscribedBy)}"/>
                                        <g:link controller="user" action="show" id="${thisUser?.id}"><cl:userDetails
                                                id="${taskInstance.fullyTranscribedBy}" displayName="true"/></g:link>
                                    </g:if>
                                </td>

                                <td style="text-align: center;">
                                    <g:if test="${taskInstance.isValid == true}"> <g:message code="task.list.validated"/></g:if>
                                    <g:elseif test="${taskInstance.isValid == false}"> <g:message code="task.list.invalidated"/></g:elseif>
                                    <g:elseif test="${taskInstance.fullyTranscribedBy}"> <g:message code="task.list.submitted"/></g:elseif>
                                </td>

                                <td style="text-align: center;">
                                    <g:if test="${taskInstance.fullyTranscribedBy}">
                                        <g:link class="btn btn-sm btn-info" controller="task" action="show"
                                                id="${taskInstance.id}"> <g:message code="task.list.view"/></g:link>
                                    </g:if>
                                    <g:else>
                                        <button class="btn btn-sm btn-default"
                                                onclick="location.href = '${createLink(controller:'transcribe', action:'task', id:taskInstance.id)}'"> <g:message code="task.list.transcribe"/></button>
                                    </g:else>
                                </td>

                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${taskInstanceTotal}" id="${params?.id}" params="${[q: params.q]}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
