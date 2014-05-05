<div class="form-horizontal">

    <div class="control-group">
        <label class="control-label" for="fieldName">Field name</label>
        <div class="controls">
            <g:select name="fieldName" from="${au.org.ala.volunteer.DarwinCoreField.values().sort({ it.name() })}" value="${fieldDefinition?.fieldName}"/>
        </div>
    </div>

    <div class="control-group">
        <label class="control-label" for="recordIndex">Index (optional)</label>
        <div class="controls">
            <g:textField name="recordIndex" value="${fieldDefinition?.recordIndex}"/>
        </div>
    </div>

    <div class="control-group">
        <label class="control-label" for="fieldType">Field type</label>
        <div class="controls">
            <g:select class="fieldType" name="fieldType" from="${au.org.ala.volunteer.FieldDefinitionType.values()}" value="${fieldDefinition?.fieldDefinitionType}"/>
        </div>
    </div>

    <div id="formatBlock">
        <div class="control-group">
            <label class="control-label" for="definition" id="formatLabel">Definition/Value</label>
            <div class="controls">
                <g:textField name="definition" value="${fieldDefinition?.format}" />
            </div>
        </div>
    </div>

    <div class="control-group">

        <div class="controls">
            <button class="btn" id="btnCancelEditFieldDefinition">Cancel</button>
            <button class="btn btn-primary" id="btnSaveFieldDefinition">Save</button>
        </div>
    </div>

    <script>

        $("#btnCancelEditFieldDefinition").click(function(e) {
            e.preventDefault();
            hideModal();
        });

        $("#btnSaveFieldDefinition").click(function(e) {
            e.preventDefault();
            var fieldName = encodeURIComponent($("#fieldName").val());
            var fieldType = encodeURIComponent($("#fieldType").val());
            var recordIndex = encodeURIComponent($("#recordIndex").val());
            var format = encodeURIComponent($("#definition").val());
            if (fieldName) {
                window.location = "${createLink(controller:'task', action:'saveFieldDefinition', params:[projectId: projectInstance.id, fieldDefinitionId: fieldDefinition?.id])}&fieldName=" + fieldName + "&fieldType=" + fieldType + "&recordIndex=" + recordIndex + "&format=" + format
            }

            hideModal();
        });

        $("#fieldType").change(function() {
            updateFormatOptions();
        });

        function updateFormatOptions() {
            var fieldType = $("#fieldType").val();
            if (fieldType == 'Sequence') {
                $("#formatBlock").css('display', 'none');
            } else {
                $("#formatBlock").css('display', 'block');
                if (fieldType == 'NameRegex') {
                    $("#formatLabel").html("Expression")
                } else if (fieldType == 'NamePattern') {
                    $("#formatLabel").html("Pattern")
                } else if (fieldType == 'DataFileColumn') {
                    $("#formatLabel").html("Column (leave blank to use field name)")
                } else {
                    $("#formatLabel").html("Value")
                }
            }
        }

        updateFormatOptions();

    </script>

</div>