<%@ page import="au.org.ala.volunteer.FieldDefinitionType; au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.label" default="Administration"/></title>

    <style>
        .progress {
            height: 20px;
            border-radius: 25px;
          //  background-color: silver;
        }

    </style>

</head>

<body class="admin">

<cl:headerContent title="Expedition Task Staging" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance.featuredLabel],
                [link: createLink(controller: 'project', action: 'editTaskSettings', id: projectInstance.id), label: "Edit Expedition"]
        ]
    %>
</cl:headerContent>

<div class="container task-staging">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-3">
                    <h4><span class="numberCircle">1</span>&nbsp;Upload Task Files</h4>

                    <p>
                        Upload your <g:if test="${isAudioProject}">audio samples</g:if><g:else>images</g:else> to the staging area
                    </p>
                    <g:if test="${!isAudioProject}">
                    <p>
                        In addition to task files, you can also upload auxiliary data files that can contain additional data that should
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
                    </g:if>
                    <g:else>
                        <p>
                            Note: AAC files will be renamed to *.mp3 due to file format requirements.
                        </p>
                    </g:else>
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
                        <button class="btn btn-default"
                                id="btnUploadDataFile"
                            <g:if test="${isAudioProject}">disabled="disabled" title="No applicable for Audio expeditions"</g:if>
                                >
                            <i class="fa fa-upload"></i>&nbsp;Upload data file
                        </button>
                    </g:else>
                </div>

                <div class="col-md-3" style="text-align: center">
                    <button class="btnAddFieldDefinition btn btn-default"
                        <g:if test="${isAudioProject}">disabled="disabled" title="No applicable for Audio expeditions"</g:if>
                        >
                        <i class="fa fa-plus"></i> Add column</button>
                </div>

                <div class="col-md-3" style="text-align: center">
                    <button id="btnLoadTasks" class="btn btn-primary"
                            style="margin-left: 10px">Create tasks from staged <g:if test="${isAudioProject}">audio</g:if><g:else>images</g:else></button>
                </div>
            </div>

            <hr/>

            <div id="upload-progress"></div>
            <div id="stagedImages">
                <g:include controller="task" action="stagedImages" />
            </div>
        </div>
    </div>
</div>
<script id="upload-progress-tmpl" type="text/x-handlebars">
<div id="upload-progress">
<div class="row">
  <div class="col-sm-6">
    <p>
      <span>Files uploaded: {{complete}}</span>
      {{#errors}}<span>Files failed: {{errors}}</span>{{/errors}}
      <span>Files remaining: {{remaining}}</span>
      <span>Total files: {{total}}</span>
      <button id="pause-upload" class="btn btn-xs btn-warning{{#paused}} active{{/paused}}">{{^paused}}Pause{{/paused}}{{#paused}}Resume{{/paused}}</button>
      <button id="cancel-upload" class="btn btn-xs btn-danger">Cancel</button>
    </p>
  </div>
  <div class="col-sm-6">
  {{#currentFiles}}
    <div data-key="{{filename}}">
      <p>{{filename}} uploading</p>
      <div class="progress">
        <div class="progress-bar" role="progressbar" aria-valuenow="{{progress}}" aria-valuemin="0" aria-valuemax="100"><span class="sr-only">{{progress}}%</span></div>
      </div>
    </div>
  {{/currentFiles}}
  </div>
  <div class="col-sm-12">
    <div class="progress">
      <div class="progress-bar{{#remaining}} progress-bar-striped active{{/remaining}}" role="progressbar" aria-valuenow="{{progress}}" aria-valuemin="0" aria-valuemax="100" style="width: {{progress}}%"><span class="sr-only">{{progress}}%</span></div>
    </div>
  </div>
</div>

</div>
</script>
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:javascript src="bootbox" asset-defer=""/>
<asset:javascript src="digivol-stageImage.js" asset-defer="" />
<asset:script type='text/javascript'>

    digivolStageFiles({
        projectId: ${projectInstance.id},
        isAudioProject: ${isAudioProject},
        stagedImagesUrl: "${createLink(action: 'stagedImages', params: [projectId: projectInstance.id])}",
        uploadFileUrl: "${createLink(controller: 'ajax', action: 'resumableUploadImage', params: [projectId: projectInstance.id])}",
        uploadAudioUrl: "${createLink(controller: 'ajax', action: 'resumableUploadAudio', params: [projectId: projectInstance.id])}",
        unStageImageUrl: "${createLink(controller: 'task', action: 'unstageImage', params: [projectId: projectInstance.id])}&imageName=",
        addFieldUrl: "${createLink(action: 'editStagingFieldFragment', params: [projectId: projectInstance.id])}",
        clearStagingUrl: "${createLink(controller: 'task', action: 'deleteAllStagedImages', params: [projectId: projectInstance.id])}",
        exportCSVUrl: "${createLink(controller: "task", action: 'exportStagedTasksCSV', params: [projectId: projectInstance.id])}",
        editFieldUrl: "${createLink(action: 'editStagingFieldFragment', params: [projectId: projectInstance.id])}&fieldDefinitionId=",
        deleteFieldUrl:"${createLink(controller: 'task', action: 'deleteFieldDefinition', params: [projectId: projectInstance.id])}&fieldDefinitionId="
    }, window);

    $(document).ready(function () {

        bvp.bindTooltips("a.fieldHelp", 650);

        $(".btnAddFieldDefinition").click(function(e) {
            e.preventDefault();
            var options = {
                title: "Add field definition",
                url: "${createLink(action: 'editStagingFieldFragment', params: [projectId: projectInstance.id])}"
            };
            bvp.showModal(options);
        });

        $("#btnLoadTasks").click(function(e) {
            e.preventDefault();
            window.location = "${createLink(controller: 'task', action: 'loadStagedTasks', params: [projectId: projectInstance.id])}";
        });

        $("#btnUploadDataFile").click(function(e) {
            e.preventDefault();
            var options = {
                title: "Upload a data file",
                url:"${createLink(action: 'uploadDataFileFragment', params: [projectId: projectInstance.id])}"
            };
            bvp.showModal(options);

        });

        $("#btnClearDataFile").click(function(e) {
            e.preventDefault();
            window.location = "${createLink(controller: 'task', action: 'clearStagedDataFile', params: [projectId: projectInstance.id])}";
        });

    });

</asset:script>
</body>
</html>
