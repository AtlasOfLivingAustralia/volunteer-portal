<div class="form-horizontal">

    <div class="form-group">
        <label class="control-label col-md-3" for="fieldType"><g:message code="task.editStagingFieldFragment.field_type"/></label>

        <div class="col-md-6">
            <g:select class="fieldType form-control" name="fieldType" from="${au.org.ala.volunteer.FieldDefinitionType.values()}"
                      value="${fieldDefinition?.fieldDefinitionType}"/>
        </div>
        <div class="col-md-3">
            <cl:helpText tooltipPosition="topLeft" tipPosition="bottomRight" width="1000">
                <ul>
                    <li><g:message code="task.editStagingFieldFragment.nameregex"/>
                    </li>
                    <li><g:message code="task.editStagingFieldFragment.namepattern"/>
                    </li>
                    <li><g:message code="task.editStagingFieldFragment.literal"/></li>
                    <li><g:message code="task.editStagingFieldFragment.sequence"/></li>
                    <li><g:message code="task.editStagingFieldFragment.datafilecolumn"/></li>
                </ul>
            </cl:helpText>
        </div>
    </div>

    <div id="formatBlock">
        <div class="form-group">
            <label class="control-label col-md-3" for="definition" id="formatLabel"><g:message code="task.editStagingFieldFragment.definition"/></label>

            <div class="col-md-6">
                <g:textField name="definition" value="${fieldDefinition?.format}" class="form-control"/>

                <g:if test="${hasDataFile && dataFileColumns}">
                    <g:select name="dataFileColumn" from="${dataFileColumns}" value="${fieldDefinition?.format}" class="form-control"/>
                </g:if>
            </div>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="fieldName"><g:message code="task.editStagingFieldFragment.field_name"/></label>

        <div class="col-md-6">
            <g:select name="fieldName" from="${au.org.ala.volunteer.DarwinCoreField.values().sort({ it.name() })}"
                      value="${fieldDefinition?.fieldName}" class="form-control"/>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="recordIndex"><g:message code="task.editStagingFieldFragment.index"/></label>

        <div class="col-md-6">
            <g:textField name="recordIndex" value="${fieldDefinition?.recordIndex}" class="form-control"/>
        </div>
    </div>

    <div class="form-group">

        <div class="col-md-offset-3 col-md-9">
            <button class="btn btn-default" id="btnCancelEditFieldDefinition"><g:message code="default.cancel"/></button>
            <button class="btn btn-primary" id="btnSaveFieldDefinition"><g:message code="default.button.save.label"/></button>
        </div>
    </div>

    <script>

        $("#btnCancelEditFieldDefinition").click(function (e) {
            e.preventDefault();
            bvp.hideModal();
        });

        $("#btnSaveFieldDefinition").click(function (e) {
            e.preventDefault();
            var fieldName = encodeURIComponent($("#fieldName").val());
            var fieldType = encodeURIComponent($("#fieldType").val());
            var recordIndex = encodeURIComponent($("#recordIndex").val());
            var format = encodeURIComponent($("#definition").val());

            if (fieldName) {
                window.location = "${createLink(controller:'task', action:'saveFieldDefinition', params:[projectId: projectInstance.id, fieldDefinitionId: fieldDefinition?.id])}&fieldName=" + fieldName + "&fieldType=" + fieldType + "&recordIndex=" + recordIndex + "&format=" + format
            }
        });

        $("#fieldType").change(function () {
            updateFormatOptions();
        });

        $("#dataFileColumn").change(function () {
            $("#fieldName").val($("#dataFileColumn").val());
        });

        function updateFormatOptions() {
            var fieldType = $("#fieldType").val();
            $("#definition").css("display", "block");
            $("#dataFileColumn").css("display", "none");

            if (fieldType == 'Sequence') {
                $("#formatBlock").css('display', 'none');
            } else {
                $("#formatBlock").css('display', 'block');
                if (fieldType == 'NameRegex') {
                    $("#formatLabel").html("${message(code: "task.editStagingFieldFragment.expression")}")
                } else if (fieldType == 'NamePattern') {
                    $("#formatLabel").html("${message(code: "task.editStagingFieldFragment.pattern")}")
                } else if (fieldType == 'DataFileColumn') {
                    $("#formatLabel").html("${message(code: "task.editStagingFieldFragment.column")}")
                    <g:if test="${hasDataFile && dataFileColumns}">
                    $("#definition").css("display", "none");
                    $("#dataFileColumn").css("display", "block");
                    </g:if>
                } else {
                    $("#formatLabel").html("${message(code: "task.editStagingFieldFragment.value")}")
                }
            }
        }

        $("#dataFileColumn").change(function () {
            $("#definition").val($("#dataFileColumn").val());
        });

        updateFormatOptions();

        bvp.bindTooltips();

    </script>

</div>