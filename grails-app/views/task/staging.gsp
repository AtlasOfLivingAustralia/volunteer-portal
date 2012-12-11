<%@ page import="au.org.ala.volunteer.FieldDefinitionType; au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
        <style type="text/css">

        .bvp-expeditions td button {
            margin-top: 5px;
        }

        .section {
            border: 1px solid #a9a9a9;
            padding: 10px;
            margin-bottom: 10px;
        }
        .section h4 {
            margin-bottom: 5px;
        }

        #btnLoadTasks {
            background: orange;
            background-image: -webkit-gradient(linear,left top,left bottom,color-stop(0,#FFA500 ),color-stop(1, #FF8C00));
        }


        </style>
        <script type='text/javascript'>

            $(document).ready(function () {

                $(".btnDeleteImage").click(function(e) {
                    var imageName = $(this).attr("imageName");
                    if (imageName) {
                        window.location = "${createLink(controller:'task', action:'unstageImage', params:[projectId: projectInstance.id])}&imageName=" + imageName;
                    }
                });

                $("#btnAddFieldDefinition").click(function(e) {
                    var fieldName = encodeURIComponent($("#fieldName").val());
                    if (fieldName) {
                        window.location = "${createLink(controller:'task', action:'addFieldDefinition', params:[projectId: projectInstance.id])}&fieldName=" + fieldName
                    }
                });

                $(".fieldType").change(function(e) {
                    var fieldId = $(this).parents("tr[fieldDefinitionId]").attr("fieldDefinitionId");
                    var newFieldType = encodeURI($(this).val());
                    if (fieldId && newFieldType) {
                        window.location = "${createLink(controller:'task', action:'updateFieldDefinitionType', params:[projectId:projectInstance.id])}&fieldDefinitionId=" + fieldId + "&newFieldType=" + newFieldType;
                    }
                });

                $(".fieldValue").change(function(e) {
                    var fieldId = $(this).parents("tr[fieldDefinitionId]").attr("fieldDefinitionId");
                    var newFieldValue = encodeURIComponent($(this).val());
                    if (fieldId && newFieldValue) {
                        window.location = "${createLink(controller:'task', action:'updateFieldDefinitionFormat', params:[projectId:projectInstance.id])}&fieldDefinitionId=" + fieldId + "&newFieldFormat=" + newFieldValue;
                    }
                });

                $(".btnDeleteField").click(function(e) {
                    var fieldId = $(this).parents("tr[fieldDefinitionId]").attr("fieldDefinitionId");
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
                })

                $("#btnClearStagingArea").click(function(e) {
                    e.preventDefault();
                    if (confirm("Are you sure you wish to delete all images from the staging area?")) {
                        window.location = "${createLink(controller:'task', action:'deleteAllStagedImages', params:[projectId: projectInstance.id])}";
                    }
                });

            });

        </script>
    </head>

    <body class="sublevel sub-site volunteerportal">

        <cl:navbar/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li><a class="home" href="${createLink(controller: 'project', action: 'index', id: projectInstance.id)}">${projectInstance.featuredLabel}</a>
                        <li><a class="home" href="${createLink(controller: 'project', action: 'edit', id: projectInstance.id)}">Edit Project</a>
                        </li>
                        <li class="last">Task Load Staging</li>
                    </ol>
                </nav>
                <hgroup>
                    <h1>Project Task Staging</h1>
                </hgroup>
            </div>
        </header>

        <div>
            <div class="inner">

                <div id="fieldDefinitionsSection" class="section">
                    <table style="width: 100%">
                        <tr>
                            <td>
                                <h4>Field Definitions</h4>
                            </td>
                            <td>
                                <g:select name="fieldName" from="${au.org.ala.volunteer.DarwinCoreField.values().sort({ it.name() })}"/>
                                <button class="button" id="btnAddFieldDefinition">Add field</button>
                            </td>
                        </tr>
                    </table>

                    <table class="bvp-expeditions">
                        <thead>
                            <tr>
                                <th style="text-align: left">Field</th>
                                <th style="text-align: left">Field Type</th>
                                <th style="text-align: left">Field Value definition</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <g:each in="${profile.fieldDefinitions.sort({it.id})}" var="field">
                                <tr fieldDefinitionId="${field.id}">
                                    <td>${field.fieldName}</td>
                                    <td><g:select class="fieldType" name="fieldType" from="${au.org.ala.volunteer.FieldDefinitionType.values()}" value="${field.fieldDefinitionType}"/></td>
                                    <td>
                                        <g:if test="${field.fieldDefinitionType != FieldDefinitionType.Sequence && field.fieldDefinitionType != au.org.ala.volunteer.FieldDefinitionType.DataFileColumn}">
                                            <g:textField class="fieldValue" name="fieldValue" value="${field.format}" size="40"/>
                                        </g:if>
                                    </td>
                                    <td><button class="button btnDeleteField">Delete</button></td>
                                </tr>
                            </g:each>
                        </tbody>
                    </table>

                </div>

                <div id="dataFileSection" class="section">
                    <h4>Upload a csv data file for field values</h4>
                    <g:if test="${hasDataFile}">
                        A data file has been uploaded for this project.
                        <button class="button" id="btnClearDataFile">Clear data file</button>
                        &nbsp;
                        <a href="${dataFileUrl}">View data file</a>
                    </g:if>
                    <g:else>
                        <g:form controller="task" action="uploadStagingDataFile" method="post" enctype="multipart/form-data">
                            <input type="file" name="dataFile" id="dataFile" />
                            <g:hiddenField name="projectId" value="${projectInstance.id}"/>
                            <g:submitButton name="Upload Data File"/>

                        </g:form>
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


                <div id="uploadImagesSection" class="section">
                    <h4>Upload task images to staging area</h4>
                    <g:form controller="task" action="stageImage" method="post" enctype="multipart/form-data">
                        %{--<label for="imageFile"><strong>Upload task image file:</strong></label>--}%
                        <input type="file" name="imageFile" id="imageFile" multiple="multiple"/>
                        <g:hiddenField name="projectId" value="${projectInstance.id}"/>
                        <g:submitButton name="Stage images"/>
                    </g:form>
                </div>

                <div id="imagesSection" class="section">

                    <div>
                        <button id="btnExportTasksCSV">Export staged tasks as CSV</button>
                        <button id="btnClearStagingArea" style="color:red">Delete all images</button>
                        <button id="btnLoadTasks" >Create tasks from staged images</button>
                        <span><strong>Warning: </strong> The staging area will be cleared once these images are submitted.</span>
                    </div>
                    <hr/>

                    <h4>Staged images (${images.size()})</h4>
                    <table class="bvp-expeditions">
                        <thead>
                            <tr>
                                <th style="text-align: left">Image file</th>
                                <g:each in="${profile.fieldDefinitions.sort({it.id})}" var="field">
                                    <th style="text-align: left">${field.fieldName}</th>
                                </g:each>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <g:each in="${images}" var="image">
                                <tr>
                                    <td><a href="${image.url}">${image.name}</a></td>
                                    <g:each in="${profile.fieldDefinitions.sort({it.id})}" var="field">
                                        <td>${image.valueMap[field.fieldName]}</td>
                                    </g:each>
                                    <td>
                                        <button class="button btnDeleteImage" imageName="${image.name}">Delete</button>
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
