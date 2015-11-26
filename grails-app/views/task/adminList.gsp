<%@ page import="au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <r:require module="amplify"/>
    <title>Expedition administration</title>
    <content tag="primaryColour">${projectInstance.institution?.themeColour}</content>

    <r:script type="text/javascript">

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
                    if (e.keyCode == 13) {
                        e.preventDefault();
                        doSearch();
                    }
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
    </r:script>
</head>

<body>

<cl:headerContent title="Expedition administration - ${projectInstance ? projectInstance.featuredLabel : 'Tasks'}"
                  selectedNavItem="expeditions">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'list'), label: 'Expeditions'],
                [link: createLink(controller: 'project', action: 'index', id: projectInstance?.id), label: projectInstance?.featuredLabel]
        ]
    %>

    <div>
        <cl:ifAdmin>
            <div class="btn-group">
                <a class="btn btn-primary dropdown-toggle" data-toggle="dropdown" href="#">
                    <i class="icon-cog"></i> Tools
                    <span class="caret"></span>
                </a>
                <ul class="dropdown-menu">
                    <li>
                        <a href="${createLink(controller: 'project', action: 'edit', id: projectInstance.id)}"><i
                                class="icon-edit"></i>&nbsp;Edit project</a>
                    </li>
                    <li class="divider"></li>
                    <li>
                        <a href="${createLink(controller: 'project', action: 'mailingList', id: projectInstance.id)}"><i
                                class="icon-envelope"></i>&nbsp;Mailing list</a>
                    </li>
                    <li>
                        <a href="${createLink(controller: 'picklist', id: projectInstance.id)}"><i
                                class="icon-list-alt"></i>&nbsp;Manage picklists</a>
                    </li>
                    <g:if test="${projectInstance.picklistInstitutionCode}">
                        <li class="divider"></li>
                        <li>
                            <a href="${createLink(controller: 'projectTools', action: 'matchRecordedByIdFromPicklist', id: projectInstance.id)}"><i
                                    class="icon-wrench"></i>&nbsp;Update empty recordedByID values from picklist match
                            </a>
                        </li>
                    </g:if>
                    <li>
                        <a href="${createLink(controller: 'projectTools', action: 'reindexProjectTasks', id: projectInstance.id)}"><i
                                class="icon-flag"></i>&nbsp;Reindex tasks</a>
                    </li>
                </ul>
            </div>
        </cl:ifAdmin>
        <g:link style="color: white" class="btn btn-info pull-right" controller="user" action="myStats"
                id="${userInstance.id}" params="${['projectId': projectInstance.id]}">My Stats</g:link>
    </div>
</cl:headerContent>

<div class="container">
<div class="row">
    <div class="col-sm-12">
        <div class="alert alert-info">
            <div class="row">
                <div class="col-sm-8">
                    Total Tasks: ${taskInstanceTotal},
                    Transcribed Tasks: ${Task.countByProjectAndFullyTranscribedByNotIsNull(projectInstance)},
                    Validated Tasks: ${Task.countByProjectAndFullyValidatedByNotIsNull(projectInstance)}
                    &nbsp;
                    <div class="btn-group btn-group-sm" role="group" aria-label="Export">
                        <button id="btnExportAll" class="btn btn-default">Export all</button>
                        <button id="btnExportTranscribed" class="btn btn-default">Export transcribed</button>
                        <button id="btnExportValidated" class="btn btn-default">Export validated</button>
                    </div>
                </div>
                <div class="col-sm-2">
                    <div class="input-group">
                        <input class="form-control input-lg" style="height:32px" type="text" name="projectAdminSearch" id="projectAdminSearch" value="${params.q}"
                               size="30"/>
                        <span class="input-group-btn">
                            <button class="btn btn-small btn-primary" id="searchButton">
                                <i class="glyphicon glyphicon-search"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-sm-2">
                    <div class="btn-group btn-group-sm pull-right">
                        <g:link action="projectAdmin" id="${projectInstance.id}" class="btn btn-default btn-small ${params.mode != 'thumbs' ? 'active' : ''}" title="View task list">
                            <i class="fa fa-th-list"></i>
                        </g:link>
                        <g:link action="projectAdmin" id="${projectInstance.id}" params="[mode: 'thumbs', max: 48]" class="btn btn-default btn-small ${params.mode == 'thumbs' ? 'active' : ''}" title="View task thumbnails">
                            <i class="fa fa-th"></i>
                        </g:link>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</div>
<div class="container">
<div class="row" id="content">
    <div class="col-sm-12">
        <div class="panel panel-default">
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
</body>
</html>
