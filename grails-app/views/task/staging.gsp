<%@ page import="au.org.ala.volunteer.FieldDefinitionType; au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
        <style type="text/css">

            .well {
                /*background-color: rgba(245, 245, 245, 0.4);*/
            }

            .dropdown-menu a {
                text-decoration: none;
            }

        </style>
        <r:script type='text/javascript'>

            $(document).ready(function () {

                $(".btnDeleteImage").click(function(e) {
                    var imageName = $(this).attr("imageName");
                    if (imageName) {
                        window.location = "${createLink(controller:'task', action:'unstageImage', params:[projectId: projectInstance.id])}&imageName=" + imageName;
                    }
                });


                $(".btnDeleteShadowFile").click(function(e) {
                    var filename = $(this).attr("filename");
                    if (filename) {
                        window.location = "${createLink(controller:'task', action:'unstageImage', params:[projectId: projectInstance.id])}&imageName=" + filename;
                    }
                });


                $("#btnAddFieldDefinition").click(function(e) {
                    e.preventDefault();
                    var options = {
                        title: "Add field definition",
                        url:"${createLink(action:'editStagingFieldFragment', params:[projectId: projectInstance.id])}"
                    }
                    showModal(options);
                });

                $(".btnEditField").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldDefinitionId]").attr("fieldDefinitionId");
                    if (fieldId) {
                        var options = {
                            title: "Edit field definition",
                            url:"${createLink(action: 'editStagingFieldFragment', params: [projectId: projectInstance.id])}&fieldDefinitionId=" + fieldId
                        };
                        showModal(options);
                    }
                });

                $(".btnDeleteField").click(function(e) {
                    var fieldId = $(this).parents("[fieldDefinitionId]").attr("fieldDefinitionId");
                    if (fieldId) {
                        window.location = "${createLink(controller:'task', action:'deleteFieldDefinition', params:[projectId:projectInstance.id])}&fieldDefinitionId=" + fieldId;
                    }
                });

                $("#btnLoadTasks").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'task', action:'loadStagedTasks', params:[projectId: projectInstance.id])}";
                });

                $("#btnExportTasksCSV").click(function(e) {
                    e.preventDefault();
                    window.open("${createLink(controller:"task", action:'exportStagedTasksCSV', params:[projectId: projectInstance.id])}", "ExportCSV");
                });

                $("#btnClearDataFile").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'task', action:'clearStagedDataFile', params:[projectId: projectInstance.id])}";
                });

                $("#btnClearStagingArea").click(function(e) {
                    e.preventDefault();
                    if (confirm("Are you sure you wish to delete all images from the staging area?")) {
                        window.location = "${createLink(controller:'task', action:'deleteAllStagedImages', params:[projectId: projectInstance.id])}";
                    }
                });

            });

        </r:script>
    </head>

    <body class="sublevel sub-site volunteerportal">

        <cl:headerContent title="Project Task Staging" selectedNavItem="expeditions">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'project', action: 'index', id:projectInstance.id), label: projectInstance.featuredLabel],
                    [link: createLink(controller: 'project', action: 'edit', id:projectInstance.id), label: "Edit"]
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">

                %{--<div class="well well-small">--}%

                    %{--<h3 style="display: inline-block">Field Definitions</h3>--}%
                    %{--<button class="btn btn-success pull-right" id="btnAddFieldDefinition"><i class="icon-plus icon-white"></i> Add field</button>--}%
                    %{--<table class="table table-striped table-condensed">--}%
                        %{--<thead>--}%
                            %{--<tr>--}%
                                %{--<th>Field</th>--}%
                                %{--<th>Record Index</th>--}%
                                %{--<th>Field Type</th>--}%
                                %{--<th>Field Value definition</th>--}%
                                %{--<th></th>--}%
                            %{--</tr>--}%
                        %{--</thead>--}%
                        %{--<tbody>--}%
                            %{--<g:each in="${profile.fieldDefinitions.sort({it.id})}" var="field">--}%
                                %{--<tr fieldDefinitionId="${field.id}">--}%
                                    %{--<td>${field.fieldName}</td>--}%
                                    %{--<td>${field.recordIndex}</td>--}%
                                    %{--<td>${field.fieldDefinitionType}</td>--}%
                                    %{--<td>--}%
                                        %{--<g:if test="${field.fieldDefinitionType != FieldDefinitionType.Sequence}">--}%
                                            %{--${field.format}--}%
                                        %{--</g:if>--}%
                                    %{--</td>--}%
                                    %{--<td>--}%
                                        %{--<button class="btn btn-small btnEditField"><i class="icon-edit"></i></button>--}%
                                        %{--<g:if test="${field.fieldName != 'externalIdentifier'}">--}%
                                            %{--<button class="btn btn-small btn-danger btnDeleteField"><i class="icon-remove icon-white"></i></button>--}%
                                        %{--</g:if>--}%
                                    %{--</td>--}%
                                %{--</tr>--}%
                            %{--</g:each>--}%
                        %{--</tbody>--}%
                    %{--</table>--}%

                %{--</div>--}%

                <div id="dataFileSection" class="well well-small">
                    <h4>Upload a csv data file for field values</h4>
                    <g:if test="${hasDataFile}">
                        A data file has been uploaded for this project.
                        <button class="btn btn-warning" id="btnClearDataFile">Clear data file</button>
                        &nbsp;
                        <a href="${dataFileUrl}">View data file</a>
                    </g:if>
                    <g:else>
                        <g:form controller="task" action="uploadStagingDataFile" method="post" enctype="multipart/form-data">
                            <input type="file" name="dataFile" id="dataFile" />
                            <g:hiddenField name="projectId" value="${projectInstance.id}"/>
                            <g:submitButton class="btn btn-primary" name="Upload Data File"/>

                        </g:form>
                        <br />
                        <div>CSV data files should follow the following conventions:
                            <ul>
                                <li>First row should contain column headings (comma separated)</li>
                                <li>Column headers should be darwin core field names, except for the first one, which should be <code>filename</code></li>
                                <li>Subsequent rows should contain the image filename in the first column, and optionally values for each field for the rest of the columns.</li>
                                <li>The image filename must match exactly a filename in the table, otherwise values will not be applied</li>
                                <li><strong>Important!</strong> There must be a field defined in the section above above for each desired column name with a field type of <code>DataFileColumn</code></li>
                            </ul>
                        </div>
                    </g:else>

                </div>


                <div id="uploadImagesSection" class="well well-small">
                    <h4>Upload task images to staging area</h4>
                    <g:form controller="task" action="stageImage" method="post" enctype="multipart/form-data">
                        %{--<label for="imageFile"><strong>Upload task image file:</strong></label>--}%
                        <input type="file" name="imageFile" id="imageFile" multiple="multiple"/>
                        <g:hiddenField name="projectId" value="${projectInstance.id}"/>
                        <g:submitButton class="btn" name="Stage images"/>
                    </g:form>
                </div>

                <div id="imagesSection" class="">
                    <table style="width:100%; margin-bottom: 5px">
                        <tr>
                            <td><h4>Staged images (${images.size()})</h4></td>
                            <td>
                                %{--<button class="btn btn-success"><i class="icon-upload icon-white"></i>&nbsp;Upload Images</button>--}%

                                <div class="btn-group pull-right">
                                    <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
                                        <i class="icon-cog"></i>
                                        <span class="caret"></span>
                                    </a>
                                    <ul class="dropdown-menu">
                                        <li>
                                            <a href="#" id="btnAddFieldDefinition"><i class="icon-plus"></i>&nbsp;Add a column</a>
                                        </li>
                                        <li class="divider"></li>

                                        <li>
                                            <a href="#" id="btnExportTasksCSV"><i class="icon-file"></i>&nbsp;Export staged tasks as CSV</a>
                                        </li>
                                        <li class="divider"></li>
                                        <li>
                                            <a href="#" id="btnClearStagingArea"><i class="icon-trash"></i>&nbsp;Delete all images</a>
                                        </li>
                                    </ul>
                                </div>
                                <button id="btnLoadTasks" class="btn btn-primary pull-right" style="margin-right: 10px">Create tasks from staged images</button>
                            </td>
                        </tr>
                    </table>


                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                                <th>
                                    <div>&nbsp;</div>
                                    Image file
                                </th>
                                <g:each in="${profile.fieldDefinitions.sort({it.id})}" var="field">
                                    <th fieldDefinitionId="${field.id}">
                                        <div class="label" style="display: block">
                                            <span style="font-weight: normal">${field.fieldDefinitionType} "${field.format}"</span>

                                            <a href="#" class="btnEditField pull-right" title="Edit column definition"><i class="icon-edit icon-white"></i></a>
                                            <g:if test="${field.fieldName != 'externalIdentifier'}">
                                                <a href="#" class="btnDeleteField pull-right" title="Remove column"><i class="icon-remove icon-white"></i></a>
                                            </g:if>

                                        </div>
                                        ${field.fieldName}<g:if test="${field.recordIndex}">[${field.recordIndex}]</g:if>
                                    </th>
                                </g:each>
                                <th style="width: 120px">
                                    %{--<button id="btnAddFieldDefinition" class="btn btn-small">Add column</button>--}%
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
                                                            <g:set var="shadowLabel" value="${shadow.stagedFile.name.replace(shadow.fieldName, "<em>${shadow.fieldName}</em>")}" />
                                                            <i class="icon-chevron-right icon-white"></i> ${shadowLabel}
                                                            <a href="#" class="btnDeleteShadowFile" title="Delete shadow file ${shadow.stagedFile.name}" filename="${shadow.stagedFile.name}"><i class="icon-remove icon-white"></i></a>
                                                        </div>
                                                    </li>
                                                </g:each>
                                            </ul>
                                        </g:if>
                                    </td>
                                    <g:each in="${profile.fieldDefinitions.sort({it.id})}" var="field">
                                        <td>${image.valueMap[field.fieldName + "_" + field.recordIndex]}</td>
                                    </g:each>
                                    <td>
                                        <button class="btn btn-small btn-danger btnDeleteImage" imageName="${image.name}"><i class="icon-remove icon-white"></i></button>
                                    </td>
                                </tr>
                            </g:each>
                        </tbody>
                    </table>
                </div>

            </div>
        </div>
    </body>
</html>
