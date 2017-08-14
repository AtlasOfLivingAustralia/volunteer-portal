<%@ page import="au.org.ala.volunteer.FieldDefinitionType; au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.label" default="Administration"/></title>
</head>

<body class="admin">

<cl:headerContent title="Project Task Staging" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance.i18nName],
                [link: createLink(controller: 'project', action: 'editTaskSettings', id: projectInstance.id), label: "Edit Project"]
        ]
    %>
</cl:headerContent>

<div class="container task-staging">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-3">
                    <h4><span class="numberCircle">1</span>&nbsp;<g:message code="task.staging.upload_images"/></h4>

                    <p>
                        <g:message code="task.staging.upload_images.description"/>
                    </p>
                    <p>
                    <g:message code="task.staging.description2"/>
                        <cl:helpText markdown="${false}" tooltipPosition="bottomLeft" tipPosition="bottomLeft" customClass="upload-images-tooltip">
                            <g:message code="task.staging.description.help1"/>
                        </cl:helpText>
                    </p>
                </div>
            
                <div class="col-md-3">
                    <h4><span class="numberCircle">2</span>&nbsp;<g:message code="task.staging.upload_datafile"/></h4>

                    <p>
                        <g:message code="task.staging.upload_datafile.description"/>
                    </p>
                </div>
            
                <div class="col-md-3">
                    <h4><span class="numberCircle">3</span>&nbsp;<g:message code="task.staging.configure_columns"/></h4>
                    <p><g:message code="task.staging.configure_columns.description"/>

                        <cl:helpText>
                            <g:message code="task.staging.configure_columns.help"/>
                        </cl:helpText>
                    </p>
                </div>

                <div class="col-md-3">
                    <h4><span class="numberCircle">4</span>&nbsp;<g:message code="task.staging.create_tasks"/></h4>
                    <g:message code="task.staging.create_tasks.description"/>
                </div>
            </div>

            <div class="row">
                <div class="col-md-3" style="text-align: center">
                    <button id="btnSelectImages" class="btn btn-default"><g:message code="task.staging.select_files"/></button>
                </div>

                <div class="col-md-3" style="text-align: center">
                    <g:if test="${hasDataFile}">
                        <button class="btn btn-warning" id="btnClearDataFile"><g:message code="task.staging.clear_data_file"/></button>
                        <a href="${dataFileUrl}"><g:message code="task.staging.view_data_file"/></a>
                    </g:if>
                    <g:else>
                        <button class="btn btn-default" id="btnUploadDataFile"><i class="fa fa-upload"></i>&nbsp;<g:message code="task.staging.upload_data_file"/>
                        </button>
                    </g:else>
                </div>

                <div class="col-md-3" style="text-align: center">
                    <button class="btnAddFieldDefinition btn btn-default"><i class="fa fa-plus"></i> <g:message code="task.staging.add_column"/></button>
                </div>

                <div class="col-md-3" style="text-align: center">
                    <button id="btnLoadTasks" class="btn btn-primary"
                            style="margin-left: 10px"><g:message code="task.staging.create_tasks_from_staged_images"/></button>
                </div>
            </div>

            <hr/>

            <div class="row">
                <div class="col-md-12">
                    <h3><g:message code="task.staging.staged_images"/> (${images.size()})

                        <div class="btn-group pull-right">
                            <a class="btn btn-default dropdown-toggle" data-toggle="dropdown" href="#">
                                <i class="fa fa-cog"></i> <g:message code="task.staging.actions"/>
                                <span class="caret"></span>
                            </a>
                            <ul class="dropdown-menu">
                                <li>
                                    <a href="#" class="btnAddFieldDefinition"><i
                                            class="fa fa-plus"></i>&nbsp;<g:message code="task.staging.add_a_column"/></a>
                                </li>
                                <li class="divider"></li>

                                <li>
                                    <a href="#" id="btnExportTasksCSV"><i
                                            class="fa fa-file"></i>&nbsp;<g:message code="task.staging.export_staged_tasks_as_csv"/></a>
                                </li>
                                <li class="divider"></li>
                                <li>
                                    <a href="#" id="btnClearStagingArea"><i
                                            class="fa fa-trash"></i>&nbsp;<g:message code="task.staging.delete_all_images"/></a>
                                </li>
                            </ul>
                        </div>
                    </h3>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <th>
                                <div>&nbsp;</div>
                                <g:message code="task.staging.image_file"/>
                            </th>
                            <g:each in="${profile.fieldDefinitions.sort({ it.id })}" var="field">
                                <th fieldDefinitionId="${field.id}" style="vertical-align: bottom;">
                                    <div class="text-center display-inline-block">
                                        ${field.fieldName}<g:if test="${field.recordIndex}">[${field.recordIndex}]</g:if>
                                        <br/>
                                        <div class="small">
                                            <span style="font-weight: normal">( ${field.fieldDefinitionType}: <b>${field.format}</b> - </span>

                                            <a href="#" class="btnEditField btn btn-xs btn-default" title="${message(code: 'task.staging.edit_column_definition')}">
                                                <i class="fa fa-edit"></i>
                                            </a>
                                            <g:if test="${field.fieldName != 'externalIdentifier'}">
                                                <a href="#" class="btnDeleteField btn btn-xs btn-danger" title="${message(code: 'task.staging.remove_column')}">
                                                    <i class="fa fa-remove"></i>
                                                </a>
                                            </g:if>
                                            )
                                        </div>
                                    </div>
                                </th>
                            </g:each>
                            <th style="width: 40px">
                            </th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${images}" var="image">
                            <tr>
                                <td>
                                    <a href="${image.url}">${image.name}</a>
                                    <g:if test="${image.shadowFiles}">
                                        <ul class="nav nav-pills nav-stacked" style="margin-left: 10px">
                                            <g:each in="${image.shadowFiles}" var="shadow">
                                                <li>
                                                    <div class="label">
                                                        <g:set var="shadowLabel"
                                                               value="${shadow.stagedFile.name.replace(shadow.fieldName, "<em>${shadow.fieldName}</em>")}"/>
                                                        <i class="fa fa-chevron-right"></i> ${shadowLabel}
                                                        <a href="#" class="btnDeleteShadowFile btn btn-xs btn-danger"
                                                           title="Delete shadow file ${shadow.stagedFile.name}"
                                                           filename="${shadow.stagedFile.name}"><i
                                                                class="fa fa-remove"></i></a>
                                                    </div>
                                                </li>
                                            </g:each>
                                        </ul>
                                    </g:if>
                                </td>
                                <g:each in="${profile.fieldDefinitions.sort({ it.id })}" var="field">
                                    <td>${image.valueMap[field.fieldName + "_" + field.recordIndex]}</td>
                                </g:each>
                                <td>
                                    <button title="${message(code: "task.staging.delete_image")}" class="btn btn-xs btn-danger btnDeleteImage" imageName="${image.name}"><i
                                            class="fa fa-remove"></i></button>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:javascript src="bootbox" asset-defer=""/>
<asset:script type='text/javascript'>

    $(document).ready(function () {

        bvp.bindTooltips("a.fieldHelp", 650);

        $(".btnDeleteImage").click(function(e) {
            var imageName = $(this).attr("imageName");
            if (imageName) {
                window.location = "${createLink(controller: 'task', action: 'unstageImage', params: [projectId: projectInstance.id])}&imageName=" + imageName;
                    }
                });


                $(".btnDeleteShadowFile").click(function(e) {
                    var filename = $(this).attr("filename");
                    if (filename) {
                        window.location = "${createLink(controller: 'task', action: 'unstageImage', params: [projectId: projectInstance.id])}&imageName=" + filename;
                    }
                });


                $(".btnAddFieldDefinition").click(function(e) {
                    e.preventDefault();
                    var options = {
                        title: "${message(code: 'task.staging.add_field_definition')}",
                        url:"${createLink(action: 'editStagingFieldFragment', params: [projectId: projectInstance.id])}"
                    }
                    bvp.showModal(options);
                });

                $(".btnEditField").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldDefinitionId]").attr("fieldDefinitionId");
                    if (fieldId) {
                        var options = {
                            title: "${message(code: 'task.staging.edit_field_definition')}",
                            url:"${createLink(action: 'editStagingFieldFragment', params: [projectId: projectInstance.id])}&fieldDefinitionId=" + fieldId
                        };
                        bvp.showModal(options);
                    }
                });

                $(".btnDeleteField").click(function(e) {
                    var fieldId = $(this).parents("[fieldDefinitionId]").attr("fieldDefinitionId");
                    if (fieldId) {
                        window.location = "${createLink(controller: 'task', action: 'deleteFieldDefinition', params: [projectId: projectInstance.id])}&fieldDefinitionId=" + fieldId;
                    }
                });

                $("#btnLoadTasks").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller: 'task', action: 'loadStagedTasks', params: [projectId: projectInstance.id])}";
                });

                $("#btnExportTasksCSV").click(function(e) {
                    e.preventDefault();
                    window.open("${createLink(controller: "task", action: 'exportStagedTasksCSV', params: [projectId: projectInstance.id])}", "ExportCSV");
                });

                $("#btnUploadDataFile").click(function(e) {
                    e.preventDefault();
                    var options = {
                        title: "${message(code: 'task.staging.upload_a_data_file')}",
                        url:"${createLink(action: 'uploadDataFileFragment', params: [projectId: projectInstance.id])}"
                    }
                    bvp.showModal(options);

                });

                $("#btnClearDataFile").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller: 'task', action: 'clearStagedDataFile', params: [projectId: projectInstance.id])}";
                });

                $("#btnClearStagingArea").click(function(e) {
                    e.preventDefault();
                    bootbox.confirm('${message(code: 'task.staging.delete_confirmation')}', function(result) {
                        if (result) {
                            window.location = "${createLink(controller: 'task', action: 'deleteAllStagedImages', params: [projectId: projectInstance.id])}";
                        }
                    });
                });

                $("#btnSelectImages").click(function(e) {
                    e.preventDefault();
                    var opts = {
                        title:"${message(code: 'task.staging.upload_images_to_the_staging_area')}",
                        url: "${createLink(action: "selectImagesForStagingFragment", params: [projectId: projectInstance.id])}"
                    };

                    bvp.showModal(opts);
                });

            });

</asset:script>
</body>
</html>
