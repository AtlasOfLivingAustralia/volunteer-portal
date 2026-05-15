<%@ page import="au.org.ala.volunteer.Institution" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <title><cl:pageTitle title="${g.message(code:"task.manage.upload.label", default:"Manage Task Uploads")}" /></title>

    <style>
        .btn, .custom-search-input {
            border-radius: 5px;
        }

        .task-error-count {
            padding-left: 0.6rem;
            padding-right: 0.6rem;
        }

        .task-descriptor-table {
            font-size: 1.2rem;
        }
        .task-descriptor-institution {
            font-size: 0.8rem;
            font-style: italic;
            margin-left: 10px;
        }

        .action-button {
            margin-left: 3px;
        }
    </style>
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
                    <table class="table table-striped table-hover task-descriptor-table">
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

                                <g:sortableColumn property="dateUpdated"
                                                  title="${message(code: 'task.manage.dateUpdated.label')}"
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
                                    </g:link> <cl:archivedOrInactiveProjectWarning archived="${taskUpload.projectIsArchived}"
                                                                                   inactive="${taskUpload.projectIsInactive}"/><br/>
                                    <g:if test="${!params.institutionFilter}">
                                    <span class="task-descriptor-institution">(${taskUpload.institution})</span>
                                    </g:if>
                                </td>
                                <td>${taskUpload.externalIdentifier}</td>
                                <td class="row-centered">${taskUpload.retriesRemaining}</td>
                                <td><g:formatDate date="${taskUpload.dateUpdated}" format="dd/MM/yyyy HH:mm:ss"/></td>
                                <td class="text-nowrap">
                                    <button role="button" class="btn btn-warning btn-xs action-button task-error-count"
                                            data-task-id="${taskUpload.id}"
                                            data-href="${createLink(controller: "task", action: "taskDescriptorErrors", id: taskUpload.id)}"
                                            data-external-id="${taskUpload.externalIdentifier}"
                                            title="${message(code: "task.manage.view.errors.label", default: "View Upload Errors")}">${taskUpload.errorCount}</button>

                                    <button role="button" class="btn btn-xs action-button reset-task-descriptor"
                                        data-href="${createLink(controller: "task", action: "resetTaskDescriptorRetries", id: taskUpload.id, params: params)}"
                                        title="${message(code: "task.manage.resetRetries.label", default: "Reset Retries")}"><i class="fa fa-refresh"></i></button>

                                    <button role="button" class="btn btn-danger btn-xs action-button delete-task-descriptor"
                                            data-image-name="${taskUpload.externalIdentifier}"
                                            data-href="${createLink(controller: "task", action: "deleteTaskDescriptor", id: taskUpload.id, params: params)}"
                                            title="${message(code: "task.manage.delete.label", default: "Delete Queued Task")}"><i class="fa fa-trash"></i></button>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="col-md-4">
                        <button role="button" class="btn btn-primary" id="btnDeleteAllTasks"
                            data-href="${createLink(controller: 'task', action: 'deleteTaskDescriptorList', params: params)}">Delete All Listed Tasks</button>
                    </div>

                    <div class="pagination">
                        <g:paginate total="${taskListCount ?: 0}" action="manageProjectTaskUploads" params="${params}"/>
                    </div>
                </div>
            </div>



        </div>
    </div>

</div>

<div id="taskErrorsModal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Task Descriptor Errors</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="text-center"><em>Loading…</em></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<asset:script type="text/javascript">
jQuery(function($) {
    $.extend({
        postGo: function(url, params) {
            var $form = $("<form>").attr("method", "post").attr("action", url);
            $.each(params, function(name, value) {
                if ($.isArray(value) || Array.isArray(value)) {
                    $("<input type='hidden'>").attr("name", name + "[]").attr("value", value).appendTo($form);
                } else {
                    $("<input type='hidden'>").attr("name", name).attr("value", value).appendTo($form);
                }
            });
            $form.appendTo("body");
            $form.submit();
        }
    });

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
            "?q=" + encodeURIComponent("${params.q?.encodeAsJavaScript()}") +
            "&institutionFilter=" + encodeURIComponent(filter);
    });

    function doProjectSearch() {
        var q = $("#searchbox").val();

        window.location = "${createLink(controller: 'task', action: 'manageProjectTaskUploads')}" +
            "?institutionFilter=${params.institutionFilter}&q=" +
            encodeURIComponent(q);
    }

    function bindConfirm(selector, messageFn) {
        $(selector).click(function(e) {
            var href = $(this).data('href');
            var name = $(this).data('imageName');
            bootbox.confirm(messageFn(name), function(result) {
                if (result) {
                    $.postGo(href);
                }
            });
        });
    }

    bindConfirm('.delete-task-descriptor', function(name) {
      return 'Are you sure you wish to delete the task descriptor (image upload) for "' + name + '"?';
    });

    bindConfirm('.reset-task-descriptor', function() {
      return 'Are you sure you wish to reset the retries remaining for this task descriptor (image upload)?';
    });

    $('#btnDeleteAllTasks').click(function(e) {
        var $this = $(this);
        var href = $this.data('href');
        bootbox.confirm("Are you sure you wish to delete ALL the listed task descriptors (image uploads)?", function(result) {
            if (result) {
                let idListParams = {taskDescriptorIds: getTaskDescriptorIds()};
                $.postGo(href, idListParams);
            }
        });
    });

    function getTaskDescriptorIds() {
        var ids = [];
        $('tr[taskId]').each(function() {
            ids.push($(this).attr('taskId'));
        });
        return ids;
    }

    // bind modal open for task errors
    $('.task-error-count').click(function(e) {
        e.preventDefault();
        var $btn = $(this);
        var href = $btn.data('href');
        var externalId = $btn.data('externalId');

        var $modal = $('#taskErrorsModal');
        $modal.find('.modal-title').text('Errors for Task ' + externalId);
        $modal.find('.modal-body').html('<div class="text-center"><em>Loading…</em></div>');
        $modal.modal('show');

        $.get(href, function(html) {
            // expect server to return an HTML fragment
            $modal.find('.modal-body').html(html);
            trimStackTrace();
        }).fail(function() {
            $modal.find('.modal-body').html('<div class="text-danger">Unable to load errors. Please try again.</div>');
        });
    });

    function trimStackTrace() {
        new Cuttr('.stackTrace', {
            //options here
            truncate: 'words',
            length: 10,
            readMore: true,
            readMoreText: 'Show',
            readLessText: 'Hide',
            readMoreBtnPosition: 'after',
            readMoreBtnAdditionalClasses: 'btn btn-hollow grey btn-sm'
        });
    }

});
</asset:script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/cuttr/1.4.3/cuttr.min.js"></script>
</body>
</html>