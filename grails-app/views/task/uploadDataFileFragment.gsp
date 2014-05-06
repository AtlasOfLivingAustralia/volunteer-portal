<g:form controller="task" action="uploadStagingDataFile" method="post" enctype="multipart/form-data" class="form-horizontal">
    <g:hiddenField name="projectId" value="${projectInstance.id}"/>
    <div class="control-group">
        <label for="dataFile">Select a data file</label>
        <div class="controls">
            <input type="file" name="dataFile" id="dataFile"/>
        </div>
    </div>
    <br/>

    <div>CSV data files should follow the following conventions:
        <ul>
            <li>First row should contain column headings (comma separated)</li>
            <li>Column headers should be darwin core field names, except for the first one, which should be <code>filename</code>
            </li>
            <li>Subsequent rows should contain the image filename in the first column, and optionally values for each field for the rest of the columns.</li>
            <li>The image filename must match exactly a filename in the table, otherwise values will not be applied</li>
            <li><strong>Important!</strong> There must be a column defined in the staged images section for each desired column name with a field type of <code>DataFileColumn</code>
            </li>
        </ul>
    </div>

    <div class="control-group">
        <div class="controls">
            <button class="btn" id="btnCancelDataFileUpload">Cancel</button>
            <g:submitButton class="btn btn-primary" name="Upload Data File"/>
        </div>
    </div>

</g:form>

<script>

    $("#btnCancelDataFileUpload").click(function(e) {
        e.preventDefault();
        hideModal();
    });

</script>
