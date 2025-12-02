<%@ page import="au.org.ala.volunteer.Institution" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <title><cl:pageTitle title="${g.message(code:"task.manage.upload.label", default:"Manage Task Uploads")}" /></title>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'task.manage.upload.label', default: 'Manage Task Uploads')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]
    %>
</cl:headerContent>

<div class="container" role="main">

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-6">
                    <g:select class="form-control institutitonFilter"
                              name="institutionFilter"
                              from="${institutionList}"
                              optionKey="id"
                              value="${params?.institutionFilter}"
                              noSelection="['':'- Filter by Institution -']" />
                </div>
                <div class="col-md-6">
                    <div class="custom-search-input body">
                        <div class="input-group">
                            <input type="text" id="searchbox" class="form-control input-lg" value="${params.q}" placeholder="Search Expedition Name..."/>
                            <span class="input-group-btn">
                                <button id="btnSearch" class="btn btn-info btn-lg" type="button">
                                    <i class="glyphicon glyphicon-search"></i>
                                </button>
                            </span>
                        </div>
                    </div>
                </div>

            </div>
            <div class="row">
                <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                    ${taskListCount ?: 0} Tasks found.
                </div>
            </div>

            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                            <tr>
                                <g:sortableColumn property="id"
                                                  title="${message(code: 'task.id.label')}"
                                                  params="${params}"/>

                                <g:sortableColumn property="project"
                                                  title="${message(code: 'project.name.label')}"
                                                  params="${params}"/>

                                <g:sortableColumn property="externalIdentifier"
                                                  title="${message(code: 'task.externalIdentifier.label')}"
                                                  params="${params}"/>

                                <g:sortableColumn property="retriesRemaining"
                                                  title="${message(code: 'task.manage.retriesRemaining.label')}"
                                                  params="${params}"/>

                                <g:sortableColumn property="timeCreated"
                                                  title="${message(code: 'task.manage.timeCreated.label')}"
                                                  params="${params}"/>

                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <g:each in="${taskList}" status="i" var="taskUpload">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}" taskId="${taskUpload.id}">
                                <td>${taskUpload.id}</td>
                                <td>
                                    <g:link controller="project" action="show" id="${taskUpload.projectId}">
                                        ${taskUpload.project}
                                    </g:link> <cl:archivedOrInactiveProjectWarning projectId="${taskUpload.projectId}"/>
                                </td>
                                <td>${taskUpload.externalIdentifier}</td>
                                <td>${taskUpload.retriesRemaining}</td>
                                <td><g:formatDate date="${taskUpload.timeCreated}" format="dd/MM/yyyy HH:mm:ss"/></td>
                                <td>
                                    <button role="button" class="btn btn-danger btn-xs delete-task-upload"
                                            data-image-name="${taskUpload.externalIdentifier}"
                                            data-href="${createLink(controller: "task", action: "delete-upload", id: taskUpload.id, params: params)}"
                                            title="Delete Queued Task"><i class="fa fa-trash"></i></button>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${taskListCount ?: 0}" action="manageProjectTaskUploads" params="${params}"/>
                    </div>
                </div>
            </div>



        </div>
    </div>

</div>

<asset:script type="text/javascript">
jQuery(function($) {

    $("#searchbox").keydown(function(e) {
        if (e.keyCode === 13) {
            doProjectSearch();
        }
    });

    $("#btnSearch").click(function(e) {
        e.preventDefault();
        doProjectSearch();
    });

    $('.institutitonFilter').change(function() {
        let filter = $(this).val();

        window.location = "${createLink(controller: 'task', action: 'manageProjectTaskUploads')}" +
            "?q=${params.q}&institutionFilter=" + filter;
    });

    function doProjectSearch() {
        var q = $("#searchbox").val();

        window.location = "${createLink(controller: 'task', action: 'manageProjectTaskUploads')}" +
            "?institutionFilter=${params.institutionFilter}&q=" +
            encodeURIComponent(q);
    }

});
</asset:script>
    </body>
    </html>