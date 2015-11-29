<div class="form-horizontal">

    <div class="form-group">
        <label class="control-label col-md-3" for="fieldType">Field type</label>

        <div class="col-md-6">
            <g:select class="fieldType form-control" name="fieldType" from="${au.org.ala.volunteer.FieldDefinitionType.values()}"
                      value="${fieldDefinition?.fieldDefinitionType}"/>
        </div>
        <div class="col-md-3">
            <cl:helpText tooltipPosition="topLeft" tipPosition="bottomRight" width="1000">
                <ul>
                    <li><code>NameRegex</code> extracts part of the filename out using a <em>regular expression</em> and a capturing group.
                    </li>
                    <li><code>NamePattern</code> extracts part of the filename out using a wildcard surrounded by parentheses <code>(*)</code>
                    </li>
                    <li><code>Literal</code> to assign the same static field value to every task</li>
                    <li><code>Sequence</code> assigns a automatically incremented number to each task</li>
                    <li><code>DataFileColumn</code> assigns a value from an uploaded csv file</li>
                </ul>
            </cl:helpText>
        </div>
    </div>

    <div id="formatBlock">
        <div class="form-group">
            <label class="control-label col-md-3" for="definition" id="formatLabel">Definition/Value</label>

            <div class="col-md-6">
                <g:textField name="definition" value="${fieldDefinition?.format}" class="form-control"/>

                <g:if test="${hasDataFile && dataFileColumns}">
                    <g:select name="dataFileColumn" from="${dataFileColumns}" value="${fieldDefinition?.format}" class="form-control"/>
                </g:if>
            </div>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="fieldName">Field name</label>

        <div class="col-md-6">
            <g:select name="fieldName" from="${au.org.ala.volunteer.DarwinCoreField.values().sort({ it.name() })}"
                      value="${fieldDefinition?.fieldName}" class="form-control"/>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="recordIndex">Index (optional)</label>

        <div class="col-md-6">
            <g:textField name="recordIndex" value="${fieldDefinition?.recordIndex}" class="form-control"/>
        </div>
    </div>

    <div class="form-group">

        <div class="col-md-offset-3 col-md-9">
            <button class="btn btn-default" id="btnCancelEditFieldDefinition">Cancel</button>
            <button class="btn btn-primary" id="btnSaveFieldDefinition">Save</button>
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
                    $("#formatLabel").html("Expression")
                } else if (fieldType == 'NamePattern') {
                    $("#formatLabel").html("Pattern")
                } else if (fieldType == 'DataFileColumn') {
                    $("#formatLabel").html("Column (leave blank to use field name)")
                    <g:if test="${hasDataFile && dataFileColumns}">
                    $("#definition").css("display", "none");
                    $("#dataFileColumn").css("display", "block");
                    </g:if>
                } else {
                    $("#formatLabel").html("Value")
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