<%@ page import="au.org.ala.volunteer.FieldDefinitionType; au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.label" default="Administration"/></title>
    <r:require modules="bootstrap-file-input, bootbox"/>
    <r:script type='text/javascript'>

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
                        title: "Add field definition",
                        url:"${createLink(action: 'editStagingFieldFragment', params: [projectId: projectInstance.id])}"
                    }
                    bvp.showModal(options);
                });

                $(".btnEditField").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldDefinitionId]").attr("fieldDefinitionId");
                    if (fieldId) {
                        var options = {
                            title: "Edit field definition",
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
                        title: "Upload a data file",
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
                    bootbox.confirm('Are you sure you wish to delete all images from the staging area?', function(result) {
                        if (result) {
                            window.location = "${createLink(controller: 'task', action: 'deleteAllStagedImages', params: [projectId: projectInstance.id])}";
                        }
                    });
                });

                $("#btnSelectImages").click(function(e) {
                    e.preventDefault();
                    var opts = {
                        title:"Upload images to the staging area",
                        url: "${createLink(action: "selectImagesForStagingFragment", params: [projectId: projectInstance.id])}"
                    };

                    bvp.showModal(opts);
                });

            });

    </r:script>
</head>

<body class="admin">

<cl:headerContent title="Project Task Staging" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance.featuredLabel],
                [link: createLink(controller: 'project', action: 'editTaskSettings', id: projectInstance.id), label: "Edit Project"]
        ]
    %>
</cl:headerContent>

<div class="container task-staging">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-3">
                    <h4><span class="numberCircle">1</span>&nbsp;Upload Images</h4>

                    <p>
                        Upload your images to the staging area
                    </p>
                    <p>
                        In addition to task image files, you can also upload auxiliary data files that can contain additional data that should
                        be attached to individual tasks (e.g. OCR text)
                        <cl:helpText markdown="${false}" tooltipPosition="bottomLeft" tipPosition="bottomLeft" customClass="upload-images-tooltip">
                                <p>
                                    Image filenames should be of the form <code>&lt;filename&gt;.jpg</code>
                                    <b/>
                                    Example: image01.jpg
                                </p>

                                <p>
                                    Text files must match the following pattern:
                                </p>
                                <code>&lt;imageFilename&gt;__&lt;DwC field name&gt;__&lt;record index&gt;.txt</code>
                                where:
                                <ul>
                                    <li><code>imageFilename</code> matches exactly the name of an image file already uploaded, including the file extension
                                    </li>
                                    <li><code>DwC field name</code> is the name of the field which should be populated with the contents of the file
                                    </li>
                                    <li><code>record index</code> is the field index if the same field name can contain multiple values. (defaults to 0 if omitted)
                                    </li>
                                </ul>

                                <p><strong>Important:</strong> <code>__</code> in the filename are two underscore characters.
                                </p>

                                <div>
                                    <p>
                                        For example, assuming an image file has been staged with the name <code>image01.jpg</code>:
                                        <br/>
                                        The contents of <code>image01.jpg__occurrenceRemarks__0.txt</code> will populate the <em>occurrenceRemarks</em> field at index 0
                                    </p>
                                </div>
                        </cl:helpText>
                    </p>
                </div>
            
                <div class="col-md-3">
                    <h4><span class="numberCircle">2</span>&nbsp;Upload datafile (Optional)</h4>

                    <p>
                        Upload a csv file containing extra data to attach to each task. This can also be used for prepopulating fields within your template.
                    </p>
                </div>
            
                <div class="col-md-3">
                    <h4><span class="numberCircle">3</span>&nbsp;Configure columns (Optional)</h4>
                    <p>
                        Add and configure columns in the table below to pre-populate data in your tasks.
                        <cl:helpText>
                            <p>Pre-populated field values can be derived from the image filename, or portions thereof, or can also be read from a separate csv datafile keyed by the image filename.</p>
        
                            <p><strong>Note:</strong> Only data displayed in the staged images table will be loaded</p>
                        </cl:helpText>
                    </p>
                </div>

                <div class="col-md-3">
                    <h4><span class="numberCircle">4</span>&nbsp;Create tasks</h4>
                    Review the staged images table, and create the tasks.
                </div>
            </div>

            <div class="row">
                <div class="col-md-3" style="text-align: center">
                    <button id="btnSelectImages" class="btn btn-default">Select files</button>
                </div>

                <div class="col-md-3" style="text-align: center">
                    <g:if test="${hasDataFile}">
                        <button class="btn btn-warning" id="btnClearDataFile">Clear data file</button>
                        <a href="${dataFileUrl}">View data file</a>
                    </g:if>
                    <g:else>
                        <button class="btn btn-default" id="btnUploadDataFile"><i class="fa fa-upload"></i>&nbsp;Upload data file
                        </button>
                    </g:else>
                </div>

                <div class="col-md-3" style="text-align: center">
                    <button class="btnAddFieldDefinition btn btn-default"><i class="fa fa-plus"></i> Add column</button>
                </div>

                <div class="col-md-3" style="text-align: center">
                    <button id="btnLoadTasks" class="btn btn-primary"
                            style="margin-left: 10px">Create tasks from staged images</button>
                </div>
            </div>

            <hr/>

            <div class="row">
                <div class="col-md-12">
                    <h3>Staged images (${images.size()})

                        <div class="btn-group pull-right">
                            <a class="btn btn-default dropdown-toggle" data-toggle="dropdown" href="#">
                                <i class="fa fa-cog"></i> Actions
                                <span class="caret"></span>
                            </a>
                            <ul class="dropdown-menu">
                                <li>
                                    <a href="#" class="btnAddFieldDefinition"><i
                                            class="fa fa-plus"></i>&nbsp;Add a column</a>
                                </li>
                                <li class="divider"></li>

                                <li>
                                    <a href="#" id="btnExportTasksCSV"><i
                                            class="fa fa-file"></i>&nbsp;Export staged tasks as CSV</a>
                                </li>
                                <li class="divider"></li>
                                <li>
                                    <a href="#" id="btnClearStagingArea"><i
                                            class="fa fa-trash"></i>&nbsp;Delete all images</a>
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
                                Image file
                            </th>
                            <g:each in="${profile.fieldDefinitions.sort({ it.id })}" var="field">
                                <th fieldDefinitionId="${field.id}" style="vertical-align: bottom;">
                                    <div class="text-center display-inline-block">
                                        ${field.fieldName}<g:if test="${field.recordIndex}">[${field.recordIndex}]</g:if>
                                        <br/>
                                        <div class="small">
                                            <span style="font-weight: normal">( ${field.fieldDefinitionType}: <b>${field.format}</b> - </span>

                                            <a href="#" class="btnEditField btn btn-xs btn-default" title="Edit column definition">
                                                <i class="fa fa-edit"></i>
                                            </a>
                                            <g:if test="${field.fieldName != 'externalIdentifier'}">
                                                <a href="#" class="btnDeleteField btn btn-xs btn-danger" title="Remove column">
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
                                    <button title="Delete image" class="btn btn-xs btn-danger btnDeleteImage" imageName="${image.name}"><i
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
</body>
</html>
