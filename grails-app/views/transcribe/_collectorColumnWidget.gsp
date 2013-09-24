<div class="collectorColumnWidget control-group">

    <div class="row-fluid">
        <div class="span10">
            <g:textField name="recordValues.0.${field.fieldType}" class="span5 autocomplete ${field.fieldType.toString()}" value="${recordValues.get(0)?.get(field.fieldType.toString())}" />
            <g:hiddenField name="recordValues.0.recordedByID" class="recordedByID" id="recordValues.0.recordedByID" value="${recordValues[0]?.recordedByID?.encodeAsHTML()}"/>
            <g:textField name="recordValues.1.${field.fieldType}" class="span5 autocomplete ${field.fieldType.toString()}" value="${recordValues.get(1)?.get(field.fieldType.toString())}" />
            <g:hiddenField name="recordValues.1.recordedByID" class="recordedByID" id="recordValues.1.recordedByID" value="${recordValues[1]?.recordedByID?.encodeAsHTML()}"/>
        </div>
    </div>
    <div class="row-fluid">
        <div class="span10">
            <g:textField name="recordValues.2.${field.fieldType}" class="span5 autocomplete ${field.fieldType.toString()}" value="${recordValues.get(2)?.get(field.fieldType.toString())}" />
            <g:hiddenField name="recordValues.2.recordedByID" class="recordedByID" id="recordValues.2.recordedByID" value="${recordValues[2]?.recordedByID?.encodeAsHTML()}"/>
            <g:textField name="recordValues.3.${field.fieldType}" class="span5 autocomplete ${field.fieldType.toString()}" value="${recordValues.get(3)?.get(field.fieldType.toString())}" />
            <g:hiddenField name="recordValues.3.recordedByID" class="recordedByID" id="recordValues.3.recordedByID" value="${recordValues[3]?.recordedByID?.encodeAsHTML()}"/>
        </div>
    </div>

</div>