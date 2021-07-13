<%@ page import="au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>
<body>
<cl:headerContent title="Task List - ${projectInstance ? projectInstance?.featuredLabel : ''}"
                  selectedNavItem="expeditions">
    <%
        if (projectInstance) {
            pageScope.crumbs = [
                    [link: createLink(controller: 'project', action: 'list'), label: 'Expeditions'],
                    [link: createLink(controller: 'project', action: 'index', id: projectInstance?.id), label: projectInstance?.featuredLabel]
            ]
        }
    %>
</cl:headerContent>

<div class="container" role="main">
    <div class="panel panel-default" style="margin-top: 2em;">
        <div class="panel-body">
            <h4>Expedition Statistics</h4>
            <table class="table table-condensed">
                <tr>
                    <th style="text-align: center;"><g:message code="project.stats.total-tasks" default="Total Tasks"/></th>
                    <th style="text-align: center;"><g:message code="project.stats.transcribed-tasks" default="Transcribed"/></th>
                    <th style="text-align: center;"><g:message code="project.stats.validated-tasks" default="Validated"/></th>
                    <th style="text-align: center;"><g:message code="project.stats.tasks-left" default="Tasks Left"/></th>
                    <th style="text-align: center;"><g:message code="project.stats.disk-usage" default="Total Disk Usage"/></th>
                </tr>
                <tr>
                    <td style="text-align: center;">${taskInstanceTotal}</td>
                    <td style="text-align: center;">${transcribedCount}</td>
                    <td style="text-align: center;">${validatedCount}</td>
                    <td style="text-align: center;">${taskInstanceTotal - transcribedCount}</td>
                    <td style="text-align: center;"><cl:formatFileSize size="${projectSize}"/></td>
                </tr>
            </table>
        </div>
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-4">
                    <div class="input-group">
                        <input class="form-control" style="height:32px" type="text" name="projectAdminSearch"
                               id="projectAdminSearch" value="${params.q}"
                               placeholder="Search tasks..."
                               size="60"/>
                        <span class="input-group-btn">
                            <button class="btn btn-small btn-primary" id="searchButton">
                                <i class="glyphicon glyphicon-search"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-md-4">
                    <g:select class="form-control statusFilter" name="statusFilter" from="${statusFilterList}"
                              optionKey="key" optionValue="value" style="height:32px"
                              value="${params?.statusFilter}" noSelection="['':'All tasks']" />

                </div>
                <div class="col-md-2">
                    <a class="btn btn-default bs3"
                       href="${createLink(controller: 'task', action: 'projectAdmin', id: projectInstance.id)}">Reset</a>
                </div>
                <div class="col-md-2">
                    <div class="btn-group btn-group-sm pull-right">
                        <g:link action="projectAdmin" id="${projectInstance.id}" class="btn btn-default ${params.mode != 'thumbs' ? 'active' : ''}" title="View task list">
                            <i class="fa fa-th-list"></i>
                        </g:link>
                        <g:link action="projectAdmin" id="${projectInstance.id}" params="[mode: 'thumbs', max: 48]" class="btn btn-default ${params.mode == 'thumbs' ? 'active' : ''}" title="View task thumbnails">
                            <i class="fa fa-th"></i>
                        </g:link>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                    ${taskQueryTotal ?: 0} Tasks found.
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

%{--                            <g:each in="${extraFields}"--}%
%{--                                    var="field"><th>${field.key?.capitalize().replaceAll(~/([a-z])([A-Z])/, '$1 $2')}</th></g:each>--}%

                            <th><span class=""><g:message code="transcription.fullyTranscribedBy.label" default="Fully Transcribed By" /></span></th>

                            <g:sortableColumn property="isValid" title="${message(code: 'task.isValid.label', default: 'Status')}"
                                              params="${[q: params.q]}" style="text-align: center;"/>

                            <th style="text-align: center;">Action</th>
                            %{--<th>debug</th>--}%

                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${taskInstanceList}" status="i" var="taskInstance">
                            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                                <td><g:link controller="transcribe" action="task"
                                            id="${taskInstance.id}">${fieldValue(bean: taskInstance, field: "id")}</g:link></td>

                                <td>${fieldValue(bean: taskInstance, field: "externalIdentifier")}</td>

%{--                                <g:each in="${extraFields}" var="field"><td>${field.value[i]?.value}</td></g:each>--}%

                            %{--<td>${taskInstance.fullyTranscribedBy?.replaceAll(/@.*/, "...")}</td>--}%

                                <td>
                                    <g:set var="transcribers" value="${taskInstance.transcriptions*.fullyTranscribedBy}" />
                                    <g:if test="${transcribers}">
                                        <g:each in="${transcribers}" var="transcriber" status="j"><g:if test="${j != 0}">, </g:if><g:set var="thisUser" value="${User.findByUserId(transcriber)}"/><g:link controller="user" action="show" id="${thisUser?.id}"><cl:userDetails id="${transcriber}" displayName="true"/></g:link></g:each>
                                    </g:if>
                                </td>

                                <td style="text-align: center;">
                                    <g:if test="${taskInstance.isValid == true}">validated</g:if>
                                    <g:elseif test="${taskInstance.isValid == false}">invalidated</g:elseif>
                                    <g:elseif test="${taskInstance.transcriptions*.fullyTranscribedBy}">submitted</g:elseif>
                                </td>

                                <td style="text-align: center;">
                                    <g:if test="${taskInstance.transcriptions*.fullyTranscribedBy}">
                                        <g:link class="btn btn-sm btn-info" controller="task" action="show"
                                                id="${taskInstance.id}">view</g:link>
                                    </g:if>
                                    <g:else>
                                        <button class="btn btn-sm btn-default"
                                                onclick="location.href = '${createLink(controller:'transcribe', action:'task', id:taskInstance.id)}'">transcribe</button>
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

<asset:script type="text/javascript">
    $(document).ready(function () {

        $("#searchButton").click(function (e) {
            e.preventDefault();
            doSearch();
        });

        $("#projectAdminSearch").keyup(function (e) {
            if (e.keyCode === 13) {
                e.preventDefault();
                doSearch();
            }
        });

        $('.statusFilter').change(function() {
            let filter = $(this).val();
            var url = "${createLink(controller: 'task', action: 'list', id: projectInstance.id)}?";
        <g:if test="${params.q}">
            url += "q=${params.q}&";
        </g:if>
        <g:if test="${params.mode}">
            url += "mode=${params.mode}&max=${params.max}&";
        </g:if>
            url += "statusFilter=" + filter;

            window.location = url;
        });

});

function doSearch() {
var query = $("#projectAdminSearch").val();
location.href = "?q=" + query;
}
</asset:script>

</body>
</html>
