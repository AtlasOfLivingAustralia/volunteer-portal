<%@ page import="au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <r:require module="amplify" />
        <title>Project Administration</title>

        <r:script type="text/javascript">

            $(document).ready(function () {

                $(".lastViewedTask").click(function(e) {
                    e.preventDefault();
                    var viewedTaskId = $(this).attr("viewedTaskId");
                    if (viewedTaskId) {
                        var options = {
                            title: "Last view for task",
                            url: "${createLink(action:'viewedTaskFragment')}?viewedTaskId=" + viewedTaskId
                        }
                        bvp.showModal(options);
                    }
                });

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

                $("#btnExportAll").click(function(e) {
                    e.preventDefault();
                    var options = {
                        title:'Export all tasks',
                        url:"${createLink(action:"exportOptionsFragment", params:[exportCriteria:'all', projectId: projectInstance.id])}"
                    };
                    bvp.showModal(options);
                });

                $("#btnExportTranscribed").click(function(e) {
                    e.preventDefault();
                    var options = {
                        title:'Export transcribed tasks',
                        url:"${createLink(action:"exportOptionsFragment", params:[exportCriteria:'transcribed', projectId: projectInstance.id])}"
                    };
                    bvp.showModal(options);

                });

                $("#btnExportValidated").click(function(e) {
                    e.preventDefault();
                    var options = {
                        title:'Export validated tasks',
                        url:"${createLink(action:"exportOptionsFragment", params:[exportCriteria:'validated', projectId: projectInstance.id])}"
                    };
                    bvp.showModal(options);
                });

                <g:if test="${params.lastTaskId}">
                     amplify.store("bvp_task_${params.lastTaskId}", null);
                </g:if>

            }); // end .ready()

            function doSearch() {
                var query = $("#q").val()
                location.href = "?q=" + query;
            }

            function validateInSeparateWindow(taskId) {
                window.open("${createLink(controller:'validate', action:'task')}/" + taskId, "bvp_validate_window");
            }
        </r:script>
    </head>

    <body>

        <cl:headerContent title="Project Admin - ${projectInstance ? projectInstance.featuredLabel : 'Tasks'}" selectedNavItem="expeditions">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'project', action: 'list'), label: 'Expeditions'],
                    [link: createLink(controller: 'project', action: 'index', id: projectInstance?.id), label: projectInstance?.featuredLabel]
                ]
            %>

            <div>
                <cl:ifAdmin>
                    <button class="btn" style="float:left;margin:5px;" onclick="location.href = '${createLink(controller:'project', action:'edit', id:projectInstance.id)}'">Edit Project</button>
                    <button class="btn" style="float:left;margin:5px;" onclick="location.href = '${createLink(controller:'project', action:'mailingList', id:projectInstance.id)}'">Mailing List</button>
                    <button class="btn" style="float:left;margin:5px;" onclick="location.href = '${createLink(controller:'picklist', id:projectInstance.id)}'">Picklists</button>
                </cl:ifAdmin>
                <g:link style="color: white" class="btn btn-info pull-right" controller="user" action="myStats" id="${userInstance.id}" params="${['projectId': projectInstance.id]}">My Stats</g:link>
            </div>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <div class="alert alert-info">
                    Total Tasks: ${taskInstanceTotal},
                    Transcribed Tasks: ${Task.countByProjectAndFullyTranscribedByNotIsNull(projectInstance)},
                    Validated Tasks: ${Task.countByProjectAndFullyValidatedByNotIsNull(projectInstance)}
                    &nbsp;&nbsp;
                    <button id="btnExportAll" class="btn btn-small">Export all</button>
                    <button id="btnExportTranscribed" class="btn btn-small">Export transcribed</button>
                    <button id="btnExportValidated" class="btn btn-small">Export validated</button>

                    %{--<button class="btn btn-small" onclick="location.href = '${createLink(controller:'project', action:'exportCSV', id:projectInstance.id)}'">Export all</button>--}%
                    %{--<button class="btn btn-small" onclick="location.href = '${createLink(controller:'project', action:'exportCSV', id:projectInstance.id, params:[transcribed:true])}'">Export transcribed</button>--}%
                    %{--<button class="btn btn-small" onclick="location.href = '${createLink(controller:'project', action:'exportCSV', id:projectInstance.id, params:[validated:true])}'">Export validated</button>--}%
                    <input class="input-small" style="margin-bottom: 0px" type="text" name="q" id="q" value="${params.q}" size="30"/>
                    <button class="btn btn-small btn-primary" id="searchButton">search</button>

                    <div class="btn-group pull-right">
                        <a href="${createLink(action:'projectAdmin', id:projectInstance.id)}" class="btn btn-small ${params.mode != 'thumbs' ? 'active' : ''}" title="View task list">
                            <i class="icon-th-list"></i>
                        </a>
                        <a href="${createLink(action:'projectAdmin', id:projectInstance.id, params:[mode:'thumbs', max: 48])}" class="btn btn-small ${params.mode == 'thumbs' ? 'active' : ''}" title="View task thumbnails">
                            <i class="icon-th"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="content">
            <div class="span12">
                <g:if test="${params.mode == 'thumbs'}">
                    <g:render template="taskListThumbs" />
                </g:if>
                <g:else>
                    <g:render template="taskListTable" />
                </g:else>
            </div>
        </div>
    </body>
</html>
