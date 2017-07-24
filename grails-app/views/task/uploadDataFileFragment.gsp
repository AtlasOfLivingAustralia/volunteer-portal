<g:form controller="task" action="uploadStagingDataFile" method="post" enctype="multipart/form-data"
        class="form-horizontal">
    <g:hiddenField name="projectId" value="${projectInstance.id}"/>
    <div class="form-group">
        <label for="dataFile" class="col-md-3"><g:message code="task.uploadDataFileFragment.select_a_data_file"/></label>

        <div class="col-md-9">
            <input type="file" name="dataFile" id="dataFile" data-filename-placement="inside"/>
        </div>
    </div>
    <br/>

    <div><g:message code="task.uploadDataFileFragment.csv_conventions_title"/>
        <ul>
            <li><g:message code="task.uploadDataFileFragment.csv_conventions_1"/></li>
            <li><g:message code="task.uploadDataFileFragment.csv_conventions_2"/></li>
            <li><g:message code="task.uploadDataFileFragment.csv_conventions_3"/></li>
            <li><g:message code="task.uploadDataFileFragment.csv_conventions_4"/></li>
            <li><g:message code="task.uploadDataFileFragment.csv_conventions_5"/></li>
        </ul>
    </div>

    <div class="form-group">
        <div class="text-center">
            <button class="btn btn-default" id="btnCancelDataFileUpload"><g:message code="default.cancel"/></button>
            <g:submitButton class="btn btn-primary" name="${message(code: 'task.uploadDataFileFragment.upload_data_file')}"/>
        </div>
    </div>

</g:form>

<script>

    $("#btnCancelDataFileUpload").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

    // Initialize input type file
    $('input[type=file]').bootstrapFileInput();

</script>
