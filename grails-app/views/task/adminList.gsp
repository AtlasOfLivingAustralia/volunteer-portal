<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<%@ page import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <title>Expedition administration</title>
    <content tag="primaryColour">${projectInstance.institution?.themeColour}</content>
</head>

<body class="admin">
    <cl:headerContent title="Expedition administration - ${projectInstance ? projectInstance.featuredLabel : 'Tasks'}"
                      selectedNavItem="expeditions">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'project', action: 'list'), label: 'Expeditions'],
                    [link: createLink(controller: 'project', action: 'index', id: projectInstance?.id), label: projectInstance?.featuredLabel]
            ]
        %>
        <g:if test="${projectInstance.archived || projectInstance.inactive}">
            <h2>
        </g:if>
            <g:if test="${projectInstance.archived}"> <small><span class="label label-info"><g:message code="status.archived" /></span></small></g:if>
            <g:if test="${projectInstance.inactive}"> <small><span class="label label-warning"><g:message code="status.inactive" /></span></small></g:if>
        <g:if test="${projectInstance.archived || projectInstance.inactive}">
            </h2>
        </g:if>
        <div style="padding-bottom: 1em;">
            <cl:projectCreatedBy project="${projectInstance}" />
        </div>


            <div class="btn-group">
                <a class="btn btn-primary dropdown-toggle" data-toggle="dropdown" href="#">
                    <i class="fa fa-cog"></i> Tools
                    <span class="caret"></span>
                </a>
                <ul class="dropdown-menu">
                    <cl:ifAdmin>
                    <li>
                        <a href="${createLink(controller: 'project', action: 'edit', id: projectInstance.id)}"><i
                                class="fa fa-edit"></i>&nbsp;Edit project</a>
                    </li>
                    <li class="divider"></li>
                    <li>
                        <a href="${createLink(controller: 'institutionMessage', action: 'create', params: [projectId: projectInstance.id])}"><i
                                class="fa fa-envelope-o"></i>&nbsp;Send a message to Volunteers</a>
                    </li>
                    <li>
                        <a href="${createLink(controller: 'picklist', id: projectInstance.id)}"><i
                                class="fa fa-list-alt"></i>&nbsp;Manage picklists</a>
                    </li>
                    <g:if test="${projectInstance.picklistInstitutionCode}">
                    <li class="divider"></li>
                    <li>
                        <a href="${createLink(controller: 'projectTools', action: 'matchRecordedByIdFromPicklist', id: projectInstance.id)}"><i
                                class="fa fa-wrench"></i>&nbsp;Update empty recordedByID values from picklist match
                        </a>
                    </li>
                    </g:if>
                    <li>
                        <a href="${createLink(controller: 'projectTools', action: 'reindexProjectTasks', id: projectInstance.id)}"><i
                                class="fa fa-flag"></i>&nbsp;Reindex tasks</a>
                    </li>
                    <li class="divider"></li>
                    </cl:ifAdmin>
                    <li>
                        <a href="${createLink(controller: 'user', action: 'myStats', id: userInstance.id, params: ['projectId': projectInstance.id])}"><i
                                class="fa fa-signal"></i>&nbsp;View my stats for this project</a>
                    </li>
                    <li>
                        <a href="${createLink(controller: 'institution', action: 'index', id: projectInstance.institution.id)}"><i
                                class="fa fa-building"></i>&nbsp;View Institution page</a>
                    </li>
                    <li class="divider"></li>
                    <li><a href="#" id="btnExportAll"><i class="fa fa-download"></i>&nbsp;Export all tasks</a></li>
                    <li><a href="#" id="btnExportTranscribed"><i class="fa fa-download"></i>&nbsp;Export transcribed tasks</a></li>
                    <li><a href="#" id="btnExportValidated"><i class="fa fa-download"></i>&nbsp;Export validated tasks</a></li>
                </ul>
            </div>
%{--        <g:link style="color: white" class="btn btn-info" controller="user" action="myStats"--}%
%{--                id="${userInstance.id}" params="${['projectId': projectInstance.id]}">My Stats</g:link>--}%
    </cl:headerContent>
<div class="container" role="main">
    <div class="panel panel-default">
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
                    <td style="text-align: center;"><cl:formatFileSize size="${projectInstance?.sizeInBytes}"/></td>
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
                              optionKey="key" optionValue="value"
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
                <div class="col-md-12 table-responsive">
                    <g:if test="${params.mode == 'thumbs'}">
                        <g:render template="taskListThumbs"/>
                    </g:if>
                    <g:else>
                        <g:render template="taskListTable"/>
                    </g:else>
                </div>
            </div>
        </div>
    </div>
</div>

<asset:javascript src="amplify" asset-defer=""/>
<asset:script type="text/javascript">
    $(document).ready(function () {

        $(".lastViewedTask").click(function(e) {
            e.preventDefault();
            var viewedTaskId = $(this).attr("viewedTaskId");
            if (viewedTaskId) {
                var options = {
                    title: "Last view for task",
                    url: "${createLink(action: 'viewedTaskFragment').encodeAsJavaScript()}?viewedTaskId=" + viewedTaskId
                };
                bvp.showModal(options);
            }
        });

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
            var url = "${createLink(controller: 'task', action: 'projectAdmin', id: projectInstance.id)}?";
        <g:if test="${params.q}">
            url += "q=${params.q}&";
        </g:if>
        <g:if test="${params.mode}">
            url += "mode=${params.mode}&max=${params.max}&";
        </g:if>
            url += "statusFilter=" + filter;

            window.location = url;
        });

        $("#btnExportAll").click(function(e) {
            e.preventDefault();
            var options = {
                title:'Export all tasks',
                url:"${createLink(action: "exportOptionsFragment", params: [exportCriteria: 'all', projectId: projectInstance.id]).encodeAsJavaScript()}"
            };
            bvp.showModal(options);
        });

        $("#btnExportTranscribed").click(function(e) {
            e.preventDefault();
            var options = {
                title:'Export transcribed tasks',
                url:"${createLink(action: "exportOptionsFragment", params: [exportCriteria: 'transcribed', projectId: projectInstance.id]).encodeAsJavaScript()}"
            };
            bvp.showModal(options);
        });

        $("#btnExportValidated").click(function(e) {
            e.preventDefault();
            var options = {
                title:'Export validated tasks',
                url:"${createLink(action: "exportOptionsFragment", params: [exportCriteria: 'validated', projectId: projectInstance.id]).encodeAsJavaScript()}"
            };
            bvp.showModal(options);
        });

<g:if test="${params.lastTaskId}">
        amplify.store("bvp_task_${params.lastTaskId}", null);
</g:if>

    }); // end .ready()

    function doSearch() {
        var query = $("#projectAdminSearch").val();
        location.href = "?q=" + query;
    }

    function validateInSeparateWindow(taskId) {
        window.open("${createLink(controller: 'validate', action: 'task').encodeAsJavaScript()}/" + taskId, "bvp_validate_window");
    }
</asset:script>
</body>
</html>